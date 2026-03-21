import React, { useState, useEffect } from 'react';
import { Plus, Filter, FileText, Loader2, X, AlertCircle } from 'lucide-react';
import { getDepenses, createDepense } from '../../services/comptabilite';

export default function Depenses() {
    const [depenses, setDepenses] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    // Modal state
    const [showModal, setShowModal] = useState(false);
    const [submitting, setSubmitting] = useState(false);
    const [formData, setFormData] = useState({
        motif: '',
        montant: '',
        categorie: 'autre',
        date_depense: new Date().toISOString().split('T')[0],
        description: ''
    });

    useEffect(() => {
        fetchDepenses();
    }, []);

    const fetchDepenses = async () => {
        try {
            setLoading(true);
            const data = await getDepenses();
            setDepenses(data);
        } catch (err) {
            console.error('Erreur fetch depenses', err);
            setError('Erreur lors du chargement des dépenses.');
        } finally {
            setLoading(false);
        }
    };

    const handleOpenModal = () => setShowModal(true);
    const handleCloseModal = () => {
        setShowModal(false);
        setFormData({
            motif: '',
            montant: '',
            categorie: 'autre',
            date_depense: new Date().toISOString().split('T')[0],
            description: ''
        });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            setSubmitting(true);
            const payload = {
                ...formData,
                montant: parseFloat(formData.montant)
            };
            await createDepense(payload);
            await fetchDepenses();
            handleCloseModal();
        } catch (err) {
            console.error('Erreur save depense', err);
            alert('Erreur lors de la création de la dépense.');
        } finally {
            setSubmitting(false);
        }
    };

    return (
        <div className="space-y-6">
            <header className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-slate-800">Gestion des Dépenses</h1>
                    <p className="text-slate-500">Enregistrement et suivi des charges</p>
                </div>
                <button
                    onClick={handleOpenModal}
                    className="flex items-center space-x-2 bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 transition shadow-sm"
                >
                    <Plus className="w-4 h-4" />
                    <span>Nouvelle Dépense</span>
                </button>
            </header>

            <div className="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
                <div className="p-4 border-b border-slate-100 flex justify-end gap-2 bg-slate-50">
                    <button className="flex items-center space-x-2 px-3 py-1.5 bg-white border border-slate-300 rounded text-sm text-slate-600 hover:bg-slate-50">
                        <Filter className="w-4 h-4" />
                        <span>Filtrer</span>
                    </button>
                </div>

                <div className="overflow-x-auto">
                    <table className="w-full text-left text-sm">
                        <thead className="bg-slate-50 text-slate-500 font-medium border-b border-slate-200">
                            <tr>
                                <th className="px-6 py-4">Date</th>
                                <th className="px-6 py-4">Motif</th>
                                <th className="px-6 py-4">Catégorie</th>
                                <th className="px-6 py-4">Auteur</th>
                                <th className="px-6 py-4 text-right">Montant</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-slate-100">
                            {loading ? (
                                <tr>
                                    <td colSpan="5" className="px-6 py-8 text-center text-slate-500">
                                        <Loader2 className="w-6 h-6 animate-spin mx-auto mb-2 text-blue-600" />
                                        Chargement des dépenses...
                                    </td>
                                </tr>
                            ) : error ? (
                                <tr>
                                    <td colSpan="5" className="px-6 py-8 text-center text-red-500">
                                        <AlertCircle className="w-6 h-6 mx-auto mb-2" />
                                        {error}
                                    </td>
                                </tr>
                            ) : depenses.length === 0 ? (
                                <tr>
                                    <td colSpan="5" className="px-6 py-12 text-center text-slate-400">
                                        <div className="flex flex-col items-center">
                                            <FileText className="w-12 h-12 mb-3 text-slate-300" />
                                            <p>Aucune dépense enregistrée pour le moment.</p>
                                        </div>
                                    </td>
                                </tr>
                            ) : (
                                depenses.map((d) => (
                                    <tr key={d.id} className="hover:bg-slate-50 transition">
                                        <td className="px-6 py-4 text-slate-500">
                                            {new Date(d.date_depense).toLocaleDateString('fr-FR')}
                                        </td>
                                        <td className="px-6 py-4 font-medium text-slate-900">
                                            {d.motif}
                                            {d.description && <div className="text-xs text-slate-500 font-normal">{d.description}</div>}
                                        </td>
                                        <td className="px-6 py-4">
                                            <span className="capitalize px-2 py-1 bg-slate-100 text-slate-600 rounded text-xs">
                                                {d.categorie.replace('_', ' ')}
                                            </span>
                                        </td>
                                        <td className="px-6 py-4 text-slate-600">
                                            {d.auteur ? `${d.auteur.nom} ${d.auteur.prenom}` : 'N/A'}
                                        </td>
                                        <td className="px-6 py-4 text-right font-bold text-red-600">
                                            -{new Intl.NumberFormat('fr-FR').format(d.montant)} F
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>
            </div>

            {/* Modal de création */}
            {showModal && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                    <div className="bg-white rounded-xl shadow-xl w-full max-w-md overflow-hidden">
                        <div className="flex justify-between items-center p-4 border-b border-slate-100 bg-slate-50">
                            <h2 className="font-bold text-slate-800">Enregistrer une dépense</h2>
                            <button onClick={handleCloseModal} className="text-slate-400 hover:text-slate-600">
                                <X className="w-5 h-5" />
                            </button>
                        </div>
                        <form onSubmit={handleSubmit} className="p-6 space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Motif</label>
                                <input
                                    type="text"
                                    required
                                    className="w-full p-2 border border-slate-300 rounded focus:ring-2 focus:ring-blue-500 outline-none"
                                    value={formData.motif}
                                    onChange={(e) => setFormData({ ...formData, motif: e.target.value })}
                                />
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Montant (FCFA)</label>
                                    <input
                                        type="number"
                                        required
                                        min="0"
                                        step="1"
                                        className="w-full p-2 border border-slate-300 rounded focus:ring-2 focus:ring-blue-500 outline-none"
                                        value={formData.montant}
                                        onChange={(e) => setFormData({ ...formData, montant: e.target.value })}
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Date</label>
                                    <input
                                        type="date"
                                        required
                                        className="w-full p-2 border border-slate-300 rounded focus:ring-2 focus:ring-blue-500 outline-none"
                                        value={formData.date_depense}
                                        onChange={(e) => setFormData({ ...formData, date_depense: e.target.value })}
                                    />
                                </div>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Catégorie</label>
                                <select
                                    required
                                    className="w-full p-2 border border-slate-300 rounded focus:ring-2 focus:ring-blue-500 outline-none"
                                    value={formData.categorie}
                                    onChange={(e) => setFormData({ ...formData, categorie: e.target.value })}
                                >
                                    <option value="achat_materiel">Achat de Matériel</option>
                                    <option value="salaire">Salaire / Honoraires</option>
                                    <option value="tache">Tâche Pédagogique (Correction, etc.)</option>
                                    <option value="autre">Autre Dépense</option>
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Description (Optionnel)</label>
                                <textarea
                                    rows="3"
                                    className="w-full p-2 border border-slate-300 rounded focus:ring-2 focus:ring-blue-500 outline-none"
                                    value={formData.description}
                                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                                ></textarea>
                            </div>

                            <div className="pt-4 border-t border-slate-100 flex justify-end gap-2">
                                <button
                                    type="button"
                                    onClick={handleCloseModal}
                                    className="px-4 py-2 text-slate-600 hover:bg-slate-100 rounded"
                                >
                                    Annuler
                                </button>
                                <button
                                    type="submit"
                                    disabled={submitting}
                                    className="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700 transition flex items-center disabled:opacity-50"
                                >
                                    {submitting && <Loader2 className="w-4 h-4 mr-2 animate-spin" />}
                                    Enregistrer
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
