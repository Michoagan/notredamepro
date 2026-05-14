import React, { useState, useEffect } from 'react';
import surveillantService from '../../services/surveillant';
import { AlertTriangle, Plus, Search, Filter } from 'lucide-react';

const Discipline = () => {
    const [plaintes, setPlaintes] = useState([]);
    const [loading, setLoading] = useState(true);
    const [showModal, setShowModal] = useState(false);

    // Filters
    const [filters, setFilters] = useState({
        classe_id: '',
        date: '',
        type: ''
    });

    const [classes, setClasses] = useState([]); // Pour le filtre et le modal

    // Form State
    const [formData, setFormData] = useState({
        eleve_id: '',
        classe_id: '',
        type_plainte: 'bavardage',
        date_plainte: new Date().toISOString().split('T')[0],
        details: '',
        sanction: ''
    });

    useEffect(() => {
        loadData();
    }, [filters]); // Reload on filter change

    const loadData = async () => {
        setLoading(true);
        try {
            const [plaintesData, classesData] = await Promise.all([
                surveillantService.getPlaintes(filters),
                fetchClasses() // Placeholder
            ]);

            if (plaintesData.data) {
                setPlaintes(plaintesData.data);
            }
        } catch (error) {
            console.error(error);
        } finally {
            setLoading(false);
        }
    };

    const fetchClasses = async () => {
        try {
            const response = await fetch('${import.meta.env.VITE_API_BASE_URL}/api/classes/index', {
                headers: { 'Authorization': `Bearer ${localStorage.getItem('token')}` }
            });
            const data = await response.json();
            setClasses(data);
        } catch (e) {
            console.error("Erreur chargement classes", e);
            setClasses([]);
        }
    };

    const handleFilterChange = (e) => {
        setFilters(prev => ({ ...prev, [e.target.name]: e.target.value }));
    };

    return (
        <div className="space-y-6">
            <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                <h1 className="text-2xl font-bold text-slate-900">Discipline & Sanctions</h1>
                <button
                    onClick={() => setShowModal(true)}
                    className="bg-red-600 text-white px-4 py-2 rounded-lg flex items-center space-x-2 hover:bg-red-700 transition shadow-sm"
                >
                    <Plus className="w-4 h-4" />
                    <span>Nouvelle Plainte</span>
                </button>
            </div>

            {/* Filtres */}
            <div className="bg-white p-4 rounded-xl border border-slate-200 flex flex-wrap gap-4 items-center">
                <div className="flex items-center space-x-2 text-slate-500">
                    <Filter className="w-4 h-4" />
                    <span className="text-sm font-medium">Filtrer par :</span>
                </div>

                <select
                    name="classe_id"
                    value={filters.classe_id}
                    onChange={handleFilterChange}
                    className="px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-red-500 focus:border-red-500"
                >
                    <option value="">Toutes les classes</option>
                    {classes.map(c => <option key={c.id} value={c.id}>{c.nom}</option>)}
                </select>

                <select
                    name="type"
                    value={filters.type}
                    onChange={handleFilterChange}
                    className="px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-red-500 focus:border-red-500"
                >
                    <option value="">Tous les types</option>
                    <option value="bavardage">Bavardage</option>
                    <option value="retard">Retard</option>
                    <option value="absence">Absence</option>
                    <option value="pagaille">Pagaille</option>
                    <option value="autre">Autre</option>
                </select>

                <input
                    type="date"
                    name="date"
                    value={filters.date}
                    onChange={handleFilterChange}
                    className="px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-red-500 focus:border-red-500"
                />
            </div>

            {/* Liste Plaintes */}
            <div className="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
                <div className="overflow-x-auto">
                    <table className="w-full text-sm text-left">
                        <thead className="bg-slate-50 text-slate-500 uppercase text-xs">
                            <tr>
                                <th className="px-6 py-3">Date</th>
                                <th className="px-6 py-3">Élève</th>
                                <th className="px-6 py-3">Type</th>
                                <th className="px-6 py-3">Détails</th>
                                <th className="px-6 py-3">Sanction</th>
                                <th className="px-6 py-3">Statut</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-slate-100">
                            {loading ? (
                                <tr><td colSpan="6" className="text-center py-8">Chargement...</td></tr>
                            ) : plaintes.length === 0 ? (
                                <tr><td colSpan="6" className="text-center py-8 text-slate-500">Aucune plainte trouvée.</td></tr>
                            ) : (
                                plaintes.map(plainte => (
                                    <tr key={plainte.id} className="hover:bg-slate-50">
                                        <td className="px-6 py-4 whitespace-nowrap text-slate-500">
                                            {new Date(plainte.date_plainte).toLocaleDateString()}
                                        </td>
                                        <td className="px-6 py-4 font-medium text-slate-900">
                                            {plainte.eleve ? `${plainte.eleve.nom} ${plainte.eleve.prenom}` : 'Inconnu'}
                                            <div className="text-xs text-slate-400 font-normal">
                                                {plainte.classe ? plainte.classe.nom : ''}
                                            </div>
                                        </td>
                                        <td className="px-6 py-4">
                                            <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-semibold bg-red-50 text-red-700 capitalize">
                                                {plainte.type_plainte}
                                            </span>
                                        </td>
                                        <td className="px-6 py-4 text-slate-600 max-w-xs truncate" title={plainte.details}>
                                            {plainte.details}
                                        </td>
                                        <td className="px-6 py-4 text-slate-900 font-medium">
                                            {plainte.sanction || '-'}
                                        </td>
                                        <td className="px-6 py-4">
                                            <span className={`inline-flex px-2 py-1 rounded text-xs font-medium 
                                                ${plainte.statut === 'enregistrée' ? 'bg-yellow-100 text-yellow-800' : 'bg-green-100 text-green-800'}`}>
                                                {plainte.statut}
                                            </span>
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>
            </div>

            {/* Modal Placeholder - Simplification pour cet exemple */}
            {showModal && (
                <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center">
                    <div className="bg-white p-6 rounded-xl max-w-lg w-full">
                        <h2 className="text-xl font-bold mb-4">Nouvelle Plainte</h2>
                        <p className="text-slate-500 mb-4">Fonctionnalité complète à venir (Formulaire d'ajout)</p>
                        <button onClick={() => setShowModal(false)} className="px-4 py-2 bg-slate-200 rounded text-slate-700">Fermer</button>
                    </div>
                </div>
            )}
        </div>
    );
};

export default Discipline;
