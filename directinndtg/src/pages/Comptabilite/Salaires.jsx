import React, { useEffect, useState, useRef } from 'react';
import { getSalaires, generateSalaires, payerSalaire, updateSalaire } from '../../services/comptabilite';
import { Loader2, DollarSign, Calculator, CheckCircle, Printer } from 'lucide-react';
import { useReactToPrint } from 'react-to-print';
import { QRCodeCanvas } from 'qrcode.react';

// Composant caché pour l'impression de la fiche de paie brute
const FicheDePaieTemplate = React.forwardRef(({ salaire, mois, annee }, ref) => {
    if (!salaire) return null;

    const isProf = !!salaire.professeur;
    const user = isProf ? salaire.professeur : salaire.directionUser;
    const nomComplet = `${user?.first_name} ${user?.last_name}`;
    const fonction = isProf ? 'Professeur' : (user?.role?.charAt(0).toUpperCase() + user?.role?.slice(1) || 'Agent');

    // Date formatting helper
    const getMonthName = (m) => new Date(0, m - 1).toLocaleString('fr-FR', { month: 'long' });

    return (
        <div ref={ref} className="p-10 font-sans text-slate-800 bg-white" style={{ width: '210mm', minHeight: '297mm', margin: '0 auto' }}>
            {/* Header */}
            <div className="text-center border-b-2 border-blue-800 pb-6 mb-8">
                <h1 className="text-3xl font-extrabold text-blue-900 tracking-wider">COMPLEXE SCOLAIRE NOTRE DAME</h1>
                <h2 className="text-xl font-bold mt-4 text-slate-600 uppercase tracking-widest">Fiche de Paie</h2>
                <p className="mt-2 text-lg">Période : <strong className="capitalize">{getMonthName(mois)} {annee}</strong></p>
            </div>

            {/* Identité */}
            <div className="grid grid-cols-2 gap-4 mb-8">
                <div className="border border-slate-300 rounded p-4">
                    <p className="text-sm text-slate-500 uppercase">Nom et Prénom(s)</p>
                    <p className="font-bold text-lg">{nomComplet}</p>
                </div>
                <div className="border border-slate-300 rounded p-4">
                    <p className="text-sm text-slate-500 uppercase">Fonction</p>
                    <p className="font-bold text-lg">{fonction}</p>
                </div>
                <div className="border border-slate-300 rounded p-4">
                    <p className="text-sm text-slate-500 uppercase">Statut du Paiement</p>
                    <p className={`font-bold text-lg ${salaire.statut === 'paye' ? 'text-green-600' : 'text-amber-600'}`}>
                        {salaire.statut === 'paye' ? 'Payé' : 'En attente'}
                    </p>
                </div>
                <div className="border border-slate-300 rounded p-4">
                    <p className="text-sm text-slate-500 uppercase">Date d'édition</p>
                    <p className="font-bold text-lg">{new Date().toLocaleDateString('fr-FR')}</p>
                </div>
            </div>

            {/* Détails financiers */}
            <table className="w-full border-collapse mb-8 border border-slate-300">
                <thead>
                    <tr className="bg-slate-100 border-b border-slate-300">
                        <th className="p-3 text-left border-r border-slate-300">Désignation</th>
                        <th className="p-3 text-right border-r border-slate-300">Base / Taux</th>
                        <th className="p-3 text-right border-r border-slate-300">Heures</th>
                        <th className="p-3 text-right">Montant (FCFA)</th>
                    </tr>
                </thead>
                <tbody>
                    <tr className="border-b border-slate-200">
                        <td className="p-3 border-r border-slate-300">{isProf ? 'Rémunération Heures Normales' : 'Salaire de Base Fixe'}</td>
                        <td className="p-3 text-right border-r border-slate-300">{new Intl.NumberFormat('fr-FR').format(isProf ? salaire.taux_horaire : salaire.montant_base)}</td>
                        <td className="p-3 text-right border-r border-slate-300">{isProf ? salaire.heures_travaillees : '-'}</td>
                        <td className="p-3 text-right font-medium">{new Intl.NumberFormat('fr-FR').format(salaire.montant_base)}</td>
                    </tr>
                    {salaire.primes > 0 && (
                        <tr className="border-b border-slate-200">
                            <td className="p-3 border-r border-slate-300">Primes et Indemnités</td>
                            <td className="p-3 text-right border-r border-slate-300">-</td>
                            <td className="p-3 text-right border-r border-slate-300">-</td>
                            <td className="p-3 text-right font-medium text-green-600">+ {new Intl.NumberFormat('fr-FR').format(salaire.primes)}</td>
                        </tr>
                    )}
                    {salaire.retenues > 0 && (
                        <tr className="border-b border-slate-200">
                            <td className="p-3 border-r border-slate-300">Retenues (Avances, Absences)</td>
                            <td className="p-3 text-right border-r border-slate-300">-</td>
                            <td className="p-3 text-right border-r border-slate-300">-</td>
                            <td className="p-3 text-right font-medium text-red-600">- {new Intl.NumberFormat('fr-FR').format(salaire.retenues)}</td>
                        </tr>
                    )}
                    <tr className="bg-blue-50 border-t-2 border-blue-200">
                        <td colSpan="3" className="p-4 font-bold text-lg text-blue-900 border-r border-slate-300">NET À PAYER</td>
                        <td className="p-4 text-right font-bold text-xl text-blue-900">{new Intl.NumberFormat('fr-FR').format(salaire.net_a_payer)} FCFA</td>
                    </tr>
                </tbody>
            </table>

            {/* Signatures */}
            <div className="flex justify-between items-end mt-16 pt-8">
                <div className="w-1/3 text-center">
                    <p className="font-bold mb-16">Le Comptable</p>
                    <div className="border-t border-dotted border-slate-400 w-48 mx-auto pt-2 text-sm text-slate-500">Signature & Cachet</div>
                </div>
                <div className="w-1/3 flex flex-col items-center justify-end">
                    <QRCodeCanvas
                        value={JSON.stringify({
                            doc: "Fiche de Paie",
                            employe: nomComplet,
                            periode: `${getMonthName(mois)} ${annee}`,
                            net: salaire.net_a_payer,
                            auth: "NDTG-PRO"
                        })}
                        size={80}
                        level="L"
                    />
                    <div className="text-[10px] text-slate-500 mt-2">Document Authentifié</div>
                </div>
                <div className="w-1/3 text-center">
                    <p className="font-bold mb-16">L'Employé(e)</p>
                    <div className="border-t border-dotted border-slate-400 w-48 mx-auto pt-2 text-sm text-slate-500">Signature</div>
                </div>
            </div>

            <div className="mt-20 pt-4 border-t border-slate-200 text-center text-xs text-slate-400">
                Document certifié généré le {new Date().toLocaleString('fr-FR')} par la plateforme logicielle Notre Dame Pro.
            </div>
        </div>
    );
});

export default function Salaires() {
    const [salaires, setSalaires] = useState([]);
    const [loading, setLoading] = useState(true);
    const [generating, setGenerating] = useState(false);
    const [message, setMessage] = useState(null);

    // Default to current month/year
    const today = new Date();
    const [mois, setMois] = useState(today.getMonth() + 1);
    const [annee, setAnnee] = useState(today.getFullYear());

    // Print Logic
    const printRef = useRef();
    const [activePrintSalaire, setActivePrintSalaire] = useState(null);

    const handlePrint = useReactToPrint({
        content: () => printRef.current,
        documentTitle: `Fiche_de_Paie_${mois}_${annee}`,
        onAfterPrint: () => setActivePrintSalaire(null),
    });

    // Trigger Print after Setting State
    useEffect(() => {
        if (activePrintSalaire) {
            handlePrint();
        }
    }, [activePrintSalaire, handlePrint]);

    useEffect(() => {
        loadSalaires();
    }, [mois, annee]);

    const loadSalaires = async () => {
        setLoading(true);
        try {
            const data = await getSalaires(mois, annee);
            setSalaires(data);
        } catch (error) {
            console.error(error);
        } finally {
            setLoading(false);
        }
    };

    const handleGenerate = async () => {
        if (!window.confirm("Voulez-vous calculer les heures et générer les bulletins pour ce mois ?")) return;
        setGenerating(true);
        try {
            await generateSalaires(mois, annee);
            await loadSalaires();
            setMessage({ type: 'success', text: "Génération automatique effectuée avec succès." });
        } catch (error) {
            setMessage({ type: 'error', text: "Erreur lors de la génération. Pensez à vérifier si une configuration de taux est manquante." });
        } finally {
            setGenerating(false);
        }
    };

    const handlePayer = async (salaire) => {
        const isProf = !!salaire.professeur;
        const user = isProf ? salaire.professeur : salaire.directionUser;
        if (!window.confirm(`Confirmer le paiement de ${salaire.net_a_payer} ! F à ${user?.first_name} ${user?.last_name} ?`)) return;
        try {
            await payerSalaire(salaire.id);
            setSalaires(salaires.map(s => s.id === salaire.id ? { ...s, statut: 'paye', date_paiement: new Date().toISOString() } : s));
            setMessage({ type: 'success', text: `Paiement validé pour ${user?.first_name} ${user?.last_name}.` });
        } catch (error) {
            setMessage({ type: 'error', text: "Erreur lors du paiement. Veuillez réessayer." });
        }
    };

    const [editingId, setEditingId] = useState(null);
    const [editForm, setEditForm] = useState({ primes: 0, retenues: 0 });

    const handleEdit = (salaire) => {
        setEditingId(salaire.id);
        setEditForm({ primes: salaire.primes, retenues: salaire.retenues });
    };

    const handleSaveEdit = async (id) => {
        try {
            const res = await updateSalaire(id, editForm);
            if (res.success) {
                setSalaires(salaires.map(s => s.id === id ? res.salaire : s));
                setEditingId(null);
                setMessage({ type: 'success', text: "Ligne mise à jour." });
            }
        } catch (error) {
            setMessage({ type: 'error', text: "Erreur lors de la mise à jour." });
        }
    };

    return (
        <div className="p-8 space-y-6">
            {/* COMPOSANT CACHÉ POUR L'IMPRESSION */}
            <div style={{ display: 'none' }}>
                <FicheDePaieTemplate ref={printRef} salaire={activePrintSalaire} mois={mois} annee={annee} />
            </div>

            <header className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-slate-800">Gestion des Salaires</h1>
                    <p className="text-slate-500">Calcul automatique et paiements du personnel</p>
                </div>
                <div className="flex space-x-4 items-center">
                    <select
                        value={mois}
                        onChange={e => setMois(parseInt(e.target.value))}
                        className="p-2 border rounded-lg bg-white"
                    >
                        {[...Array(12)].map((_, i) => (
                            <option key={i + 1} value={i + 1}>{new Date(0, i).toLocaleString('fr-FR', { month: 'long' })}</option>
                        ))}
                    </select>
                    <select
                        value={annee}
                        onChange={e => setAnnee(parseInt(e.target.value))}
                        className="p-2 border rounded-lg bg-white"
                    >
                        <option value={2025}>2025</option>
                        <option value={2026}>2026</option>
                    </select>
                    <button
                        onClick={handleGenerate}
                        disabled={generating}
                        className="bg-purple-600 text-white px-4 py-2 rounded-lg flex items-center hover:bg-purple-700 disabled:opacity-50"
                    >
                        {generating ? <Loader2 className="w-5 h-5 animate-spin mr-2" /> : <Calculator className="w-5 h-5 mr-2" />}
                        Générer Fiches
                    </button>
                </div>
            </header>

            {message && (
                <div className={`p-4 rounded-lg text-sm flex justify-between items-center ${message.type === 'error' ? 'bg-red-50 text-red-700 border border-red-200' : 'bg-green-50 text-green-700 border border-green-200'}`}>
                    <span>{message.text}</span>
                    <button onClick={() => setMessage(null)} className="text-lg leading-none hover:opacity-70">&times;</button>
                </div>
            )}

            <div className="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
                <table className="w-full text-left">
                    <thead className="bg-slate-50 border-b border-slate-200">
                        <tr>
                            <th className="px-6 py-4 font-semibold text-slate-600">Personnel / Fonction</th>
                            <th className="px-6 py-4 font-semibold text-slate-600">Base / Taux</th>
                            <th className="px-6 py-4 font-semibold text-slate-600">Heures</th>
                            <th className="px-6 py-4 font-semibold text-slate-600">Montant Base</th>
                            <th className="px-6 py-4 font-semibold text-slate-600">Primes/Ret.</th>
                            <th className="px-6 py-4 font-semibold text-slate-600">Net à Payer</th>
                            <th className="px-6 py-4 font-semibold text-slate-600 text-right">Action</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-100">
                        {loading ? (
                            <tr><td colSpan="7" className="p-8 text-center"><Loader2 className="w-6 h-6 animate-spin mx-auto text-blue-600" /></td></tr>
                        ) : salaires.length === 0 ? (
                            <tr><td colSpan="7" className="p-8 text-center text-slate-500">Aucun salaire généré pour ce mois. Cliquez sur "Générer Fiches".</td></tr>
                        ) : (
                            salaires.map(salaire => {
                                const isProf = !!salaire.professeur;
                                const user = isProf ? salaire.professeur : salaire.directionUser;
                                const role = isProf ? 'Professeur' : (user?.role?.charAt(0).toUpperCase() + user?.role?.slice(1) || 'Agent');

                                return (
                                    <tr key={salaire.id} className="hover:bg-slate-50">
                                        <td className="px-6 py-4">
                                            <div className="font-medium">{user?.first_name} {user?.last_name}</div>
                                            <div className="text-xs text-slate-500">{role}</div>
                                        </td>
                                        <td className="px-6 py-4 text-slate-500">
                                            {isProf ? `${new Intl.NumberFormat('fr-FR').format(salaire.taux_horaire)} F/h` : 'Fixe'}
                                        </td>
                                        <td className="px-6 py-4 text-slate-500 font-bold">
                                            {isProf ? `${salaire.heures_travaillees} h` : '-'}
                                        </td>
                                        <td className="px-6 py-4 text-slate-500">
                                            {new Intl.NumberFormat('fr-FR').format(salaire.montant_base)} F
                                        </td>
                                        <td className="px-6 py-4 text-sm">
                                            {editingId === salaire.id ? (
                                                <div className="flex flex-col space-y-2">
                                                    <input
                                                        type="number"
                                                        value={editForm.primes}
                                                        onChange={e => setEditForm({ ...editForm, primes: parseFloat(e.target.value) || 0 })}
                                                        className="w-24 p-1.5 border border-slate-300 rounded text-green-700 text-xs"
                                                        placeholder="Primes"
                                                    />
                                                    <input
                                                        type="number"
                                                        value={editForm.retenues}
                                                        onChange={e => setEditForm({ ...editForm, retenues: parseFloat(e.target.value) || 0 })}
                                                        className="w-24 p-1.5 border border-slate-300 rounded text-red-600 text-xs"
                                                        placeholder="Retenues"
                                                    />
                                                </div>
                                            ) : (
                                                <>
                                                    {salaire.primes > 0 && <div className="text-green-600 font-medium">+ {new Intl.NumberFormat('fr-FR').format(salaire.primes)}</div>}
                                                    {salaire.retenues > 0 && <div className="text-red-500 font-medium">- {new Intl.NumberFormat('fr-FR').format(salaire.retenues)}</div>}
                                                    {salaire.primes === 0 && salaire.retenues === 0 && <span className="text-slate-400">-</span>}
                                                </>
                                            )}
                                        </td>
                                        <td className="px-6 py-4 font-bold text-slate-800 text-lg">
                                            {new Intl.NumberFormat('fr-FR').format(salaire.net_a_payer)} F
                                        </td>
                                        <td className="px-6 py-4 flex space-x-2 justify-end">
                                            {salaire.statut === 'paye' ? (
                                                <>
                                                    <span className="flex items-center text-green-600 font-medium text-sm px-3 py-1.5 bg-green-50 rounded-lg">
                                                        <CheckCircle className="w-4 h-4 mr-1.5" /> Réglé
                                                    </span>
                                                    <button
                                                        onClick={() => setActivePrintSalaire(salaire)}
                                                        className="bg-slate-800 text-white px-3 py-1.5 rounded-lg text-sm hover:bg-slate-700 flex items-center shadow-sm"
                                                        title="Imprimer Fiche"
                                                    >
                                                        <Printer className="w-4 h-4 mr-1.5" /> Imprimer
                                                    </button>
                                                </>
                                            ) : editingId === salaire.id ? (
                                                <button
                                                    onClick={() => handleSaveEdit(salaire.id)}
                                                    className="bg-blue-600 text-white px-4 py-1.5 rounded-lg text-sm hover:bg-blue-700 transition"
                                                >
                                                    Sauver
                                                </button>
                                            ) : (
                                                <>
                                                    <button
                                                        onClick={() => handleEdit(salaire)}
                                                        className="bg-white border border-slate-300 text-slate-700 px-3 py-1.5 rounded-lg text-sm hover:bg-slate-50 transition"
                                                    >
                                                        Modifier
                                                    </button>
                                                    <button
                                                        onClick={() => handlePayer(salaire)}
                                                        className="bg-emerald-600 text-white px-3 py-1.5 rounded-lg text-sm hover:bg-emerald-700 flex items-center shadow-sm transition"
                                                    >
                                                        <DollarSign className="w-4 h-4 mr-1" /> Payer
                                                    </button>
                                                    <button
                                                        onClick={() => setActivePrintSalaire(salaire)}
                                                        className="bg-slate-100 text-slate-700 border border-slate-200 px-3 py-1.5 rounded-lg text-sm hover:bg-slate-200 flex items-center transition"
                                                        title="Imprimer Proforma"
                                                    >
                                                        <Printer className="w-4 h-4" />
                                                    </button>
                                                </>
                                            )}
                                        </td>
                                    </tr>
                                )
                            })
                        )}
                    </tbody>
                </table>
            </div>
        </div>
    );
}
