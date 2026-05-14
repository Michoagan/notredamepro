import React, { useState, useEffect } from 'react';
import { Search, Plus, CreditCard, Banknote, Download, Loader2, AlertCircle, X, Check, CheckCircle } from 'lucide-react';
import { getPaiements, createPaiement, getPaiementQrCode } from '../../services/caisse';
import { getEleves } from '../../services/secretariat';
import { generateReceiptPDF } from '../../utils/pdfGenerator';

export default function Paiements() {
    const [transactions, setTransactions] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [searchTerm, setSearchTerm] = useState('');

    // Modal state
    const [showModal, setShowModal] = useState(false);
    const [submitting, setSubmitting] = useState(false);

    // Autocomplete state
    const [searchStudent, setSearchStudent] = useState('');
    const [students, setStudents] = useState([]);
    const [selectedStudent, setSelectedStudent] = useState(null);
    const [showStudentResults, setShowStudentResults] = useState(false);

    // Success State
    const [paymentSuccessData, setPaymentSuccessData] = useState(null);

    // Form data
    const [formData, setFormData] = useState({
        montant: '',
        methode: 'especes'
    });

    useEffect(() => {
        fetchPaiements();
    }, []);

    const fetchPaiements = async () => {
        try {
            setLoading(true);
            const data = await getPaiements();
            setTransactions(data);
        } catch (err) {
            console.error('Erreur fetch paiements', err);
            setError('Impossible de charger les paiements.');
        } finally {
            setLoading(false);
        }
    };

    // --- Search Logic for Students inside Modal ---
    useEffect(() => {
        const delayDebounceFn = setTimeout(() => {
            if (searchStudent.length > 2) {
                searchElevesAPI();
            } else {
                setStudents([]);
                setShowStudentResults(false);
            }
        }, 500);

        return () => clearTimeout(delayDebounceFn);
    }, [searchStudent]);

    const searchElevesAPI = async () => {
        try {
            const response = await getEleves({ search: searchStudent });
            if (response.classes) {
                const flatStudents = response.classes.flatMap(c =>
                    c.eleves.map(e => ({ ...e, classe: { nom: c.nom } }))
                );
                setStudents(flatStudents);
            } else {
                setStudents([]);
            }
            setShowStudentResults(true);
        } catch (err) {
            console.error('Erreur recherche elèves', err);
        }
    };

    const selectStudent = (student) => {
        setSelectedStudent(student);
        setSearchStudent(`${student.nom} ${student.prenom} (${student.matricule})`);
        setShowStudentResults(false);
    };

    const handleOpenModal = () => setShowModal(true);
    const handleCloseModal = () => {
        setShowModal(false);
        setSearchStudent('');
        setSelectedStudent(null);
        setFormData({ montant: '', methode: 'especes' });
        setPaymentSuccessData(null);
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        if (!selectedStudent) {
            alert('Veuillez sélectionner un élève.');
            return;
        }

        try {
            setSubmitting(true);
            const payload = {
                montant: parseFloat(formData.montant),
                methode: formData.methode,
                eleve_id: selectedStudent.id
            };
            const response = await createPaiement(payload);

            if (response.success && response.paiement) {
                setPaymentSuccessData(response.paiement);
                await fetchPaiements();
            } else {
                alert('Erreur: ' + (response.message || 'Inconnue'));
            }

        } catch (err) {
            console.error('Erreur save paiement', err);
            alert('Erreur lors de la création du paiement.');
        } finally {
            setSubmitting(false);
        }
    };

    const handleDownloadReceipt = async (paiement) => {
        try {
            // 1. Fetch QR Code from Backend
            const qrResponse = await getPaiementQrCode(paiement.id);
            const qrBase64 = qrResponse.qrCodeBase64;

            // 2. Generate PDF locally in React
            generateReceiptPDF(paiement, 'scolarite', qrBase64);

        } catch (error) {
            console.error("Erreur PDF:", error);
            alert("Erreur lors de la génération du reçu.");
        }
    };

    // --- Filter Main List ---
    const filteredTransactions = transactions.filter(t => {
        if (!searchTerm) return true;
        const q = searchTerm.toLowerCase();
        const eleveMatch = t.eleve && (`${t.eleve.nom} ${t.eleve.prenom} ${t.eleve.matricule}`).toLowerCase().includes(q);
        const refMatch = t.reference && t.reference.toLowerCase().includes(q);
        const classeMatch = t.eleve?.classe?.nom && t.eleve.classe.nom.toLowerCase().includes(q);
        return eleveMatch || refMatch || classeMatch;
    });

    return (
        <div className="space-y-6">
            <header className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-slate-800">Scolarités & Paiements</h1>
                    <p className="text-slate-500">Encaissement et suivi des règlements</p>
                </div>
                <button
                    onClick={handleOpenModal}
                    className="flex items-center space-x-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition shadow-sm"
                >
                    <Plus className="w-4 h-4" />
                    <span>Nouveau Paiement</span>
                </button>
            </header>

            <div className="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
                <div className="p-4 border-b border-slate-100 flex flex-wrap gap-4 items-center justify-between bg-slate-50">
                    <div className="relative w-full max-w-md">
                        <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
                        <input
                            type="text"
                            placeholder="Rechercher élève, matricule, classe ou ref..."
                            className="w-full pl-9 pr-4 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 outline-none"
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                        />
                    </div>
                </div>

                <div className="overflow-x-auto">
                    <table className="w-full text-left text-sm">
                        <thead className="bg-slate-50 text-slate-500 font-medium border-b border-slate-200">
                            <tr>
                                <th className="px-6 py-4">Date</th>
                                <th className="px-6 py-4">Élève</th>
                                <th className="px-6 py-4">Motif</th>
                                <th className="px-6 py-4">Mode</th>
                                <th className="px-6 py-4 text-right">Montant</th>
                                <th className="px-6 py-4 text-center">Statut</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-slate-100">
                            {loading ? (
                                <tr>
                                    <td colSpan="6" className="px-6 py-8 text-center text-slate-500">
                                        <Loader2 className="w-6 h-6 animate-spin mx-auto mb-2 text-blue-600" />
                                        Chargement des paiements...
                                    </td>
                                </tr>
                            ) : error ? (
                                <tr>
                                    <td colSpan="6" className="px-6 py-8 text-center text-red-500">
                                        <AlertCircle className="w-6 h-6 mx-auto mb-2" />
                                        {error}
                                    </td>
                                </tr>
                            ) : filteredTransactions.length === 0 ? (
                                <tr>
                                    <td colSpan="6" className="px-6 py-12 text-center text-slate-500">
                                        Aucun paiement trouvé.
                                    </td>
                                </tr>
                            ) : (
                                filteredTransactions.map((t) => (
                                    <tr key={t.id} className="hover:bg-slate-50 transition">
                                        <td className="px-6 py-4 text-slate-500">
                                            {new Date(t.date_paiement).toLocaleDateString('fr-FR')}
                                        </td>
                                        <td className="px-6 py-4">
                                            <div className="font-medium text-slate-900">
                                                {t.eleve ? `${t.eleve.nom} ${t.eleve.prenom}` : 'N/A'}
                                            </div>
                                            <div className="text-xs text-slate-500">
                                                {t.eleve?.classe?.nom || 'Sans classe'}
                                            </div>
                                        </td>
                                        <td className="px-6 py-4">
                                            {t.contribution ? t.contribution.nom : 'Scolarité'}
                                        </td>
                                        <td className="px-6 py-4">
                                            <span className="inline-flex items-center space-x-1 px-2 py-1 rounded bg-slate-100 text-slate-600 text-xs">
                                                {t.methode === 'especes' ? <Banknote className="w-3 h-3" /> : <CreditCard className="w-3 h-3" />}
                                                <span className="capitalize">{t.methode}</span>
                                            </span>
                                        </td>
                                        <td className="px-6 py-4 text-right font-bold text-slate-800">
                                            {new Intl.NumberFormat('fr-FR').format(t.montant)} FCFA
                                        </td>
                                        <td className="px-6 py-4 text-center">
                                            <span className={`text-xs px-2 py-1 rounded-full font-medium ${t.statut === 'success' ? 'bg-green-100 text-green-700' : t.statut === 'pending' ? 'bg-yellow-100 text-yellow-700' : 'bg-red-100 text-red-700'}`}>
                                                {t.statut}
                                            </span>
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>
            </div>

            {/* Modal de création Paiement */}
            {showModal && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                    <div className="bg-white rounded-xl shadow-xl w-full max-w-md overflow-hidden flex flex-col max-h-[90vh]">
                        <div className="flex justify-between items-center p-4 border-b border-slate-100 bg-slate-50">
                            <h2 className="font-bold text-slate-800">
                                {paymentSuccessData ? 'Paiement Réussi' : 'Enregistrer un Paiement'}
                            </h2>
                            <button onClick={handleCloseModal} className="text-slate-400 hover:text-slate-600">
                                <X className="w-5 h-5" />
                            </button>
                        </div>

                        {paymentSuccessData ? (
                            <div className="p-8 text-center flex flex-col items-center justify-center">
                                <CheckCircle className="w-16 h-16 text-green-500 mb-4" />
                                <h3 className="text-xl font-bold text-slate-800 mb-2">Paiement enregistré avec succès</h3>
                                <p className="text-slate-600 mb-6">
                                    Référence: <span className="font-mono font-medium">{paymentSuccessData.reference}</span>
                                </p>

                                <div className="flex flex-col w-full gap-3">
                                    <button
                                        onClick={() => handleDownloadReceipt(paymentSuccessData)}
                                        className="flex justify-center items-center gap-2 w-full px-4 py-3 bg-blue-600 text-white rounded hover:bg-blue-700 transition font-medium"
                                    >
                                        <Download className="w-5 h-5" />
                                        Télécharger le Reçu PDF
                                    </button>

                                    <button
                                        onClick={handleCloseModal}
                                        className="w-full px-4 py-3 bg-slate-100 text-slate-700 rounded hover:bg-slate-200 transition font-medium border border-slate-200"
                                    >
                                        Fermer et retourner à la liste
                                    </button>
                                </div>
                            </div>
                        ) : (
                            <form onSubmit={handleSubmit} className="p-6 space-y-5 overflow-y-auto flex-1">
                                {/* Autocomplete Input */}
                                <div className="relative">
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Rechercher l'élève</label>
                                    <div className="relative">
                                        <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
                                        <input
                                            type="text"
                                            className="w-full pl-9 pr-4 py-2 border border-slate-300 rounded focus:ring-2 focus:ring-blue-500 outline-none"
                                            placeholder="Nom, Prénom ou Matricule..."
                                            value={searchStudent}
                                            onChange={(e) => {
                                                setSearchStudent(e.target.value);
                                                setSelectedStudent(null);
                                            }}
                                            required={!selectedStudent}
                                        />
                                        {selectedStudent && (
                                            <div className="absolute right-3 top-1/2 -translate-y-1/2 text-green-500">
                                                <Check className="w-4 h-4" />
                                            </div>
                                        )}
                                    </div>

                                    {/* Dropdown */}
                                    {showStudentResults && students.length > 0 && !selectedStudent && (
                                        <div className="absolute z-10 w-full mt-1 bg-white border border-slate-200 rounded-lg shadow-lg max-h-48 overflow-y-auto">
                                            {students.map((student) => (
                                                <div
                                                    key={student.id}
                                                    className="px-4 py-2 hover:bg-slate-50 cursor-pointer border-b border-slate-50 last:border-0"
                                                    onClick={() => selectStudent(student)}
                                                >
                                                    <div className="font-medium text-slate-900">{student.nom} {student.prenom}</div>
                                                    <div className="text-xs text-slate-500">
                                                        Matricule: {student.matricule} • Classe: {student.classe?.nom || 'N/A'}
                                                    </div>
                                                </div>
                                            ))}
                                        </div>
                                    )}
                                    {showStudentResults && students.length === 0 && searchStudent.length > 2 && (
                                        <div className="absolute z-10 w-full mt-1 bg-white border border-slate-200 rounded-lg shadow-lg p-4 text-center text-sm text-slate-500">
                                            Aucun élève trouvé
                                        </div>
                                    )}
                                </div>

                                <div className="grid grid-cols-2 gap-4">
                                    <div>
                                        <label className="block text-sm font-medium text-slate-700 mb-1">Montant (FCFA)</label>
                                        <input
                                            type="number"
                                            required
                                            min="1"
                                            className="w-full p-2 border border-slate-300 rounded focus:ring-2 focus:ring-blue-500 outline-none"
                                            value={formData.montant}
                                            onChange={(e) => setFormData({ ...formData, montant: e.target.value })}
                                        />
                                    </div>
                                    <div>
                                        <label className="block text-sm font-medium text-slate-700 mb-1">Méthode</label>
                                        <select
                                            required
                                            className="w-full p-2 border border-slate-300 rounded focus:ring-2 focus:ring-blue-500 outline-none"
                                            value={formData.methode}
                                            onChange={(e) => setFormData({ ...formData, methode: e.target.value })}
                                        >
                                            <option value="especes">Espèces</option>
                                            <option value="cheque">Chèque</option>
                                            <option value="virement">Virement Bancaire</option>
                                        </select>
                                    </div>
                                </div>

                                <div className="pt-4 border-t border-slate-100 flex justify-end gap-2 mt-4">
                                    <button
                                        type="button"
                                        onClick={handleCloseModal}
                                        className="px-4 py-2 text-slate-600 hover:bg-slate-100 rounded"
                                    >
                                        Annuler
                                    </button>
                                    <button
                                        type="submit"
                                        disabled={submitting || !selectedStudent}
                                        className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 transition flex items-center disabled:opacity-50 disabled:cursor-not-allowed"
                                    >
                                        {submitting && <Loader2 className="w-4 h-4 mr-2 animate-spin" />}
                                        Enregistrer
                                    </button>
                                </div>
                            </form>
                        )}
                    </div>
                </div>
            )}
        </div>
    );
}
