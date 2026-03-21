import jsPDF from 'jspdf';
import 'jspdf-autotable';
import { format } from 'date-fns';

export const generateReceiptPDF = (transaction, type, qrBase64) => {
    // transaction is either a Paiement or Vente object
    // type is 'scolarite' or 'vente'

    const doc = new jsPDF();

    // --- Colors & Fonts ---
    const primaryColor = [26, 35, 126]; // #1a237e
    const secondaryColor = [211, 47, 47]; // #d32f2f
    const textColor = [51, 51, 51];

    // --- Header ---
    doc.setFontSize(18);
    doc.setTextColor(primaryColor[0], primaryColor[1], primaryColor[2]);
    doc.setFont('helvetica', 'bold');
    doc.text('C.S. NOTRE DAME DE TOUTES GRÂCES', 14, 20);

    doc.setFontSize(10);
    doc.setTextColor(textColor[0], textColor[1], textColor[2]);
    doc.setFont('helvetica', 'normal');
    doc.text('Quartier Ayelawadje, Cotonou', 14, 28);
    doc.text('Tél: +229 97 00 00 00', 14, 33);
    doc.text('Email: contact@ndtg.bj', 14, 38);

    // --- Receipt Title & Info ---
    doc.setFontSize(22);
    doc.setTextColor(secondaryColor[0], secondaryColor[1], secondaryColor[2]);
    doc.setFont('helvetica', 'bold');
    doc.text(type === 'scolarite' ? 'REÇU' : 'REÇU DE VENTE', 196, 25, { align: 'right' });

    doc.setFontSize(10);
    doc.setTextColor(textColor[0], textColor[1], textColor[2]);
    doc.setFont('helvetica', 'normal');
    const ref = transaction.reference;
    const date = type === 'scolarite' ? transaction.date_paiement : transaction.date_vente;

    doc.text(`Réf: ${ref}`, 196, 33, { align: 'right' });
    if (date) {
        doc.text(`Date: ${format(new Date(date), 'dd/MM/yyyy')}`, 196, 38, { align: 'right' });
        doc.text(`Heure: ${format(new Date(date), 'HH:mm')}`, 196, 43, { align: 'right' });
    }

    doc.setDrawColor(primaryColor[0], primaryColor[1], primaryColor[2]);
    doc.setLineWidth(0.5);
    doc.line(14, 50, 196, 50);

    // --- Details Section ---
    let startY = 60;

    // Client/Student Info Box (Left)
    doc.setDrawColor(200, 200, 200);
    doc.setFillColor(249, 249, 249);
    doc.roundedRect(14, startY, 80, 40, 2, 2, 'FD');

    doc.setFontSize(11);
    doc.setTextColor(primaryColor[0], primaryColor[1], primaryColor[2]);
    doc.setFont('helvetica', 'bold');
    doc.text(type === 'scolarite' ? 'Informations Élève' : 'Informations Client', 18, startY + 8);

    doc.setFontSize(10);
    doc.setTextColor(textColor[0], textColor[1], textColor[2]);
    doc.setFont('helvetica', 'normal');

    if (transaction.eleve) {
        doc.text(`Matricule: ${transaction.eleve.matricule}`, 18, startY + 16);
        doc.text(`Nom: ${transaction.eleve.nom} ${transaction.eleve.prenom}`, 18, startY + 23);
        doc.text(`Classe: ${transaction.eleve.classe?.nom || 'N/A'}`, 18, startY + 30);
    } else {
        doc.text(`Nom: ${transaction.nom_client || 'Client Anonyme'}`, 18, startY + 18);
    }

    // Payment Info Box (Right)
    doc.setDrawColor(200, 200, 200);
    doc.setFillColor(249, 249, 249);
    doc.roundedRect(116, startY, 80, 40, 2, 2, 'FD');

    doc.setFontSize(11);
    doc.setTextColor(primaryColor[0], primaryColor[1], primaryColor[2]);
    doc.setFont('helvetica', 'bold');
    doc.text('Détails du Paiement', 120, startY + 8);

    doc.setFontSize(10);
    doc.setTextColor(textColor[0], textColor[1], textColor[2]);
    doc.setFont('helvetica', 'normal');

    if (type === 'scolarite') {
        doc.text(`Mode: ${transaction.methode?.toUpperCase() || 'ESPÈCES'}`, 120, startY + 16);
    }

    doc.text('Statut: ', 120, startY + (type === 'scolarite' ? 23 : 18));
    doc.setTextColor(0, 128, 0); // Green
    doc.setFont('helvetica', 'bold');
    doc.text('PAYÉ', 135, startY + (type === 'scolarite' ? 23 : 18));

    doc.setTextColor(textColor[0], textColor[1], textColor[2]);
    doc.setFont('helvetica', 'normal');
    const caissier = type === 'scolarite' ? 'Direction/Comptabilité' : (transaction.auteur?.last_name || 'Direction/Comptabilité');
    doc.text(`Caissier(ère): ${caissier}`, 120, startY + (type === 'scolarite' ? 30 : 25));

    startY += 55;

    // --- Table ---
    if (type === 'scolarite') {
        doc.autoTable({
            startY: startY,
            head: [['Désignation', 'Année Scolaire', 'Montant']],
            body: [
                [
                    transaction.contribution?.description || 'Scolarité (Frais de scolarité)',
                    transaction.contribution?.annee_scolaire || 'Scolaire en cours',
                    `${transaction.montant.toLocaleString('fr-FR')} FCFA`
                ]
            ],
            headStyles: { fillColor: primaryColor, textColor: 255, fontStyle: 'bold' },
            columnStyles: { 2: { halign: 'right' } },
            margin: { left: 14, right: 14 }
        });
    } else {
        // Vente
        const tableBody = transaction.lignes?.map(line => [
            line.article?.designation || 'Article Inconnu',
            line.quantite.toString(),
            `${line.prix_unitaire.toLocaleString('fr-FR')} FCFA`,
            `${line.sous_total.toLocaleString('fr-FR')} FCFA`
        ]) || [];

        doc.autoTable({
            startY: startY,
            head: [['Article', 'Quantité', 'Prix Unitaire', 'Sous-total']],
            body: tableBody,
            headStyles: { fillColor: primaryColor, textColor: 255, fontStyle: 'bold' },
            columnStyles: { 2: { halign: 'right' }, 3: { halign: 'right' } },
            margin: { left: 14, right: 14 }
        });
    }

    // --- Total ---
    startY = doc.lastAutoTable.finalY + 15;
    const totalAmount = type === 'scolarite' ? transaction.montant : transaction.montant_total;

    doc.setFontSize(14);
    doc.setTextColor(textColor[0], textColor[1], textColor[2]);
    doc.setFont('helvetica', 'normal');
    doc.text('Montant Total: ', 140, startY);

    doc.setFontSize(16);
    doc.setTextColor(primaryColor[0], primaryColor[1], primaryColor[2]);
    doc.setFont('helvetica', 'bold');
    doc.text(`${totalAmount.toLocaleString('fr-FR')} FCFA`, 196, startY, { align: 'right' });

    // --- QR Code & Signature ---
    startY += 30;

    if (qrBase64) {
        // qrBase64 from Laravel is just the base64 string, so we prepend the data URI scheme
        const imgData = `data:image/png;base64,${qrBase64}`;
        doc.addImage(imgData, 'PNG', 14, startY - 10, 30, 30);

        doc.setFontSize(8);
        doc.setTextColor(150, 150, 150);
        doc.text('Document Authentifié', 29, startY + 23, { align: 'center' });
    }

    // Signature
    doc.setDrawColor(textColor[0], textColor[1], textColor[2]);
    doc.setLineWidth(0.5);
    doc.line(140, startY + 15, 196, startY + 15);

    doc.setFontSize(10);
    doc.setTextColor(textColor[0], textColor[1], textColor[2]);
    doc.setFont('helvetica', 'bold');
    doc.text('La Caisse / Direction', 168, startY + 22, { align: 'center' });

    // --- Footer ---
    doc.setFontSize(9);
    doc.setTextColor(150, 150, 150);
    doc.setFont('helvetica', 'normal');
    doc.text('Ce reçu est généré électroniquement par le système de gestion financière.', 105, 280, { align: 'center' });
    doc.text('Merci de le conserver précieusement.', 105, 285, { align: 'center' });

    // --- Save ---
    const filename = `Recu_${type === 'scolarite' ? 'Paiement' : 'Vente'}_${ref}.pdf`;
    doc.save(filename);
};
