import React, { useState, useEffect } from 'react';
import censeurService from '../../services/censeur';
import api from '../../services/api';
import { Calendar, BookOpen, Clock } from 'lucide-react';

const CahiersTexte = () => {
    const [cahiers, setCahiers] = useState([]);
    const [loading, setLoading] = useState(false);

    const [classes, setClasses] = useState([]);
    const [filters, setFilters] = useState({
        classe_id: '',
        date: ''
    });

    useEffect(() => {
        fetchClasses();
    }, []);

    useEffect(() => {
        loadData();
    }, [filters]);

    const fetchClasses = async () => {
        try {
            const res = await api.get('/classes/index');
            setClasses(Array.isArray(res.data) ? res.data : (res.data.data || res.data.classes || []));
        } catch (e) { console.error(e); }
    };

    const loadData = async () => {
        setLoading(true);
        try {
            const res = await censeurService.getCahiersTexte(filters);
            if (res.data?.success) {
                const results = res.data.data;
                setCahiers(Array.isArray(results) ? results : (results?.data || []));
            }
        } catch (error) {
            console.error(error);
        } finally {
            setLoading(false);
        }
    };

    const handleFilterChange = (e) => {
        setFilters({ ...filters, [e.target.name]: e.target.value });
    };

    return (
        <div className="space-y-6">
            <h1 className="text-2xl font-bold text-slate-900">Cahiers de Texte Numériques</h1>

            {/* Filtres */}
            <div className="bg-white p-4 rounded-xl border border-slate-200 flex flex-wrap gap-4 items-center shadow-sm">
                <select
                    name="classe_id"
                    value={filters.classe_id}
                    onChange={handleFilterChange}
                    className="px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500"
                >
                    <option value="">Toutes les classes</option>
                    {classes.map(c => <option key={c.id} value={c.id}>{c.nom}</option>)}
                </select>

                <input
                    type="date"
                    name="date"
                    value={filters.date}
                    onChange={handleFilterChange}
                    className="px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500"
                />
            </div>

            {/* Liste */}
            <div className="space-y-4">
                {loading ? (
                    <p className="text-center text-slate-500 py-8">Chargement...</p>
                ) : cahiers.length === 0 ? (
                    <div className="text-center py-12 bg-slate-50 rounded-xl border border-dashed border-slate-300">
                        <BookOpen className="w-12 h-12 text-slate-300 mx-auto mb-3" />
                        <p className="text-slate-500 font-medium">Aucune entrée de cahier de texte trouvée.</p>
                    </div>
                ) : (
                    cahiers.map(entry => (
                        <div key={entry.id} className="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
                            <div className="bg-slate-50 p-4 border-b border-slate-100 flex justify-between items-center">
                                <div className="flex items-center space-x-3">
                                    <span className="font-bold text-slate-900">{entry.classe?.nom}</span>
                                    <span className="text-sm text-slate-500">|</span>
                                    <span className="text-sm font-medium text-slate-700">
                                        Prof. {entry.professeur?.last_name || entry.professeur?.nom} {entry.professeur?.first_name || entry.professeur?.prenom}
                                    </span>
                                </div>
                                <div className="flex items-center space-x-2 text-sm text-slate-500">
                                    <Calendar className="w-4 h-4" />
                                    <span>{new Date(entry.date_cours).toLocaleDateString()}</span>
                                    <Clock className="w-4 h-4 ml-2" />
                                    <span>{entry.heure_debut?.substring(0, 5)} ({entry.duree_cours}h)</span>
                                </div>
                            </div>
                            <div className="p-6 grid grid-cols-1 md:grid-cols-2 gap-6">
                                <div>
                                    <h4 className="text-xs uppercase tracking-wider text-slate-500 font-bold mb-2">Contenu & Objectifs</h4>
                                    <div className="prose prose-sm text-slate-700">
                                        <p className="mb-1 font-semibold">{entry.notion_cours}</p>
                                        <p className="whitespace-pre-wrap">{entry.contenu_cours}</p>
                                    </div>
                                </div>
                                <div className="bg-yellow-50 p-4 rounded-lg border border-yellow-100">
                                    <h4 className="text-xs uppercase tracking-wider text-yellow-700 font-bold mb-2">Travail à faire</h4>
                                    <p className="text-sm text-yellow-900 whitespace-pre-wrap">
                                        {entry.travail_a_faire || 'Aucun travail assigné.'}
                                    </p>
                                </div>
                            </div>
                        </div>
                    ))
                )}
            </div>
        </div>
    );
};

export default CahiersTexte;
