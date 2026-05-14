import React, { useState, useEffect } from 'react';
import surveillantService from '../../services/surveillant';
import { UserCheck, Users, Calendar, Search } from 'lucide-react';

const Attendance = () => {
    const [activeTab, setActiveTab] = useState('eleves'); // 'eleves' | 'professeurs'
    const [data, setData] = useState([]);
    const [loading, setLoading] = useState(false);

    // Filters
    const [date, setDate] = useState(new Date().toISOString().split('T')[0]);
    const [classeId, setClasseId] = useState('');
    const [classes, setClasses] = useState([]);

    useEffect(() => {
        fetchClasses();
    }, []);

    useEffect(() => {
        loadPresences();
    }, [activeTab, date, classeId]);

    const fetchClasses = async () => {
        try {
            const response = await fetch('${import.meta.env.VITE_API_BASE_URL}/api/classes/index', {
                headers: { 'Authorization': `Bearer ${localStorage.getItem('token')}` }
            });
            const d = await response.json();
            setClasses(d);
        } catch (e) { console.error(e); }
    };

    const loadPresences = async () => {
        setLoading(true);
        try {
            let response;
            if (activeTab === 'eleves') {
                response = await surveillantService.getPresencesEleves(date, classeId);
            } else {
                response = await surveillantService.getPresencesProfesseurs(date);
            }
            if (response.data) {
                setData(response.data);
            }
        } catch (error) {
            console.error(error);
            setData([]);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="space-y-6">
            <h1 className="text-2xl font-bold text-slate-900">Suivi des Présences</h1>

            {/* Tabs */}
            <div className="flex space-x-1 bg-slate-100 p-1 rounded-lg w-fit">
                <button
                    onClick={() => setActiveTab('eleves')}
                    className={`px-4 py-2 rounded-md text-sm font-medium transition ${activeTab === 'eleves' ? 'bg-white text-slate-900 shadow-sm' : 'text-slate-500 hover:text-slate-700'}`}
                >
                    <div className="flex items-center space-x-2">
                        <Users className="w-4 h-4" />
                        <span>Élèves</span>
                    </div>
                </button>
                <button
                    onClick={() => setActiveTab('professeurs')}
                    className={`px-4 py-2 rounded-md text-sm font-medium transition ${activeTab === 'professeurs' ? 'bg-white text-slate-900 shadow-sm' : 'text-slate-500 hover:text-slate-700'}`}
                >
                    <div className="flex items-center space-x-2">
                        <UserCheck className="w-4 h-4" />
                        <span>Professeurs</span>
                    </div>
                </button>
            </div>

            {/* Controls */}
            <div className="bg-white p-4 rounded-xl border border-slate-200 flex flex-wrap gap-4 items-center">
                <div className="flex items-center space-x-2">
                    <Calendar className="w-4 h-4 text-slate-400" />
                    <input
                        type="date"
                        value={date}
                        onChange={(e) => setDate(e.target.value)}
                        className="px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500"
                    />
                </div>

                {activeTab === 'eleves' && (
                    <select
                        value={classeId}
                        onChange={(e) => setClasseId(e.target.value)}
                        className="px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 min-w-[200px]"
                    >
                        <option value="">Toutes les classes</option>
                        {classes.map(c => <option key={c.id} value={c.id}>{c.nom}</option>)}
                    </select>
                )}
            </div>

            {/* Data Table */}
            <div className="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
                <div className="overflow-x-auto">
                    <table className="w-full text-sm text-left">
                        <thead className="bg-slate-50 text-slate-500 uppercase text-xs">
                            <tr>
                                <th className="px-6 py-3">Nom & Prénoms</th>
                                {activeTab === 'eleves' && <th className="px-6 py-3">Classe</th>}
                                <th className="px-6 py-3">Heure</th>
                                <th className="px-6 py-3">Statut</th>
                                <th className="px-6 py-3">Détails/Remarque</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-slate-100">
                            {loading ? (
                                <tr><td colSpan="5" className="text-center py-8">Chargement...</td></tr>
                            ) : data.length === 0 ? (
                                <tr><td colSpan="5" className="text-center py-8 text-slate-500">Aucune donnée de présence trouvée pour cette date.</td></tr>
                            ) : (
                                data.map((item, idx) => (
                                    <tr key={idx} className="hover:bg-slate-50">
                                        <td className="px-6 py-4 font-medium text-slate-900">
                                            {activeTab === 'eleves'
                                                ? (item.eleve ? `${item.eleve.nom} ${item.eleve.prenom}` : 'Inconnu')
                                                : (item.professeur ? `${item.professeur.nom} ${item.professeur.prenom}` : 'Inconnu')
                                            }
                                        </td>
                                        {activeTab === 'eleves' && (
                                            <td className="px-6 py-4 text-slate-500">
                                                {item.classe?.nom}
                                            </td>
                                        )}
                                        <td className="px-6 py-4 text-slate-600">
                                            {/* Heure arrivee si dispo */}
                                            {item.created_at ? new Date(item.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : '-'}
                                        </td>
                                        <td className="px-6 py-4">
                                            <span className={`inline-flex px-2 py-1 rounded text-xs font-semibold capitalize
                                                ${(item.present || item.status === 'Présent') ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}
                                            `}>
                                                {activeTab === 'eleves'
                                                    ? (item.present ? 'Présent' : 'Absent')
                                                    : item.status
                                                }
                                            </span>
                                        </td>
                                        <td className="px-6 py-4 text-slate-500 truncate max-w-xs">
                                            {item.remarque || item.observation || '-'}
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    );
};

export default Attendance;
