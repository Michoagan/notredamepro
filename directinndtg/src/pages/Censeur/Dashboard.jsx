import React, { useState, useEffect } from 'react';
import censeurService from '../../services/censeur';
import {
    LayoutDashboard,
    BookOpen,
    Users,
    FileCheck,
    Activity
} from 'lucide-react';

const Card = ({ title, value, icon: Icon, color }) => (
    <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-200 flex items-center justify-between">
        <div>
            <p className="text-slate-500 text-sm font-medium uppercase tracking-wide">{title}</p>
            <h3 className="text-3xl font-bold text-slate-900 mt-2">{value}</h3>
        </div>
        <div className={`p-4 rounded-full ${color}`}>
            <Icon className="w-8 h-8 text-white" />
        </div>
    </div>
);

const CenseurDashboard = () => {
    const [stats, setStats] = useState(null);
    const [cahiers, setCahiers] = useState([]);
    const [loading, setLoading] = useState(true);
    const [annee, setAnnee] = useState('');

    useEffect(() => {
        const loadData = async () => {
            setLoading(true);
            try {
                const statsRes = await censeurService.getDashboardStats(annee);
                
                if (statsRes.data && statsRes.data.success) {
                    setStats(statsRes.data.data);
                }
            } catch (error) {
                console.error("Erreur chargement dashboard", error);
            } finally {
                setLoading(false);
            }
        };
        loadData();
    }, [annee]);

    if (loading) return <div className="text-center py-10">Chargement...</div>;

    return (
        <div className="space-y-8">
            <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-slate-900">Tableau de Bord Censeur</h1>
                    <span className="text-slate-500">{new Date().toLocaleDateString('fr-FR', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}</span>
                </div>
                {stats?.annees_disponibles && (
                    <div className="flex items-center space-x-2 bg-white border border-slate-200 text-sm text-slate-600 px-4 py-2 rounded-lg shadow-sm">
                        <span className="font-medium text-slate-500">Année :</span>
                        <select 
                            value={stats.annee_scolaire_active} 
                            onChange={(e) => setAnnee(e.target.value)}
                            className="bg-transparent border-none text-sm font-bold text-slate-800 focus:ring-0 cursor-pointer outline-none"
                        >
                            {stats.annees_disponibles.map(a => (
                                <option key={a} value={a}>{a}</option>
                            ))}
                        </select>
                    </div>
                )}
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                <Card
                    title="Classes"
                    value={stats?.classes_count || 0}
                    icon={BookOpen}
                    color="bg-blue-500"
                />
                <Card
                    title="Professeurs"
                    value={stats?.professeurs_count || 0}
                    icon={Users}
                    color="bg-purple-500"
                />
                <Card
                    title="Notes en Attente"
                    value={stats?.notes_pending_validation || 0}
                    icon={FileCheck}
                    color={stats?.notes_pending_validation > 0 ? "bg-orange-500" : "bg-green-500"}
                />
                <Card
                    title="Total Élèves"
                    value={stats?.eleves_count || "N/A"}
                    icon={Activity}
                    color="bg-slate-500"
                />
            </div>

            {/* Statistiques de Prise de Décision Section */}
            <div className="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
                <div className="p-6 border-b border-slate-100 flex justify-between items-center">
                    <h2 className="text-lg font-semibold text-slate-900 flex items-center gap-2">
                        <Activity className="w-5 h-5 text-blue-600" />
                        Statistiques de Prise de Décision (Performances par Salle)
                    </h2>
                </div>
                <div className="overflow-x-auto">
                    <table className="w-full text-left text-sm">
                        <thead className="bg-slate-50 text-slate-500 uppercase">
                            <tr>
                                <th className="px-6 py-4 font-medium">Classe</th>
                                <th className="px-6 py-4 font-medium text-center">Effectif</th>
                                <th className="px-6 py-4 font-medium text-center">Moyenne Générale</th>
                                <th className="px-6 py-4 font-medium text-center">Taux de Réussite</th>
                                <th className="px-6 py-4 font-medium text-center">Statut</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-slate-100">
                            {stats?.decision_stats && stats.decision_stats.length > 0 ? (
                                stats.decision_stats.map((classe) => (
                                    <tr key={classe.id} className="hover:bg-slate-50 transition-colors">
                                        <td className="px-6 py-4 font-bold text-slate-800">
                                            {classe.nom}
                                        </td>
                                        <td className="px-6 py-4 text-center text-slate-600">
                                            {classe.effectif} élèves
                                        </td>
                                        <td className="px-6 py-4 text-center">
                                            <span className={`font-bold ${classe.moyenne_generale >= 12 ? 'text-green-600' : classe.moyenne_generale >= 10 ? 'text-blue-600' : classe.moyenne_generale > 0 ? 'text-red-600' : 'text-slate-400'}`}>
                                                {classe.moyenne_generale > 0 ? classe.moyenne_generale.toFixed(2) : '-'} / 20
                                            </span>
                                        </td>
                                        <td className="px-6 py-4 text-center">
                                            <div className="flex items-center justify-center gap-2">
                                                <div className="w-24 bg-slate-200 rounded-full h-2.5">
                                                    <div className={`h-2.5 rounded-full ${classe.moyenne_generale > 0 ? (classe.taux_reussite >= 50 ? 'bg-green-500' : 'bg-red-500') : 'bg-slate-300'}`} style={{ width: `${classe.taux_reussite}%` }}></div>
                                                </div>
                                                <span className="font-medium text-slate-700">{classe.taux_reussite}%</span>
                                            </div>
                                        </td>
                                        <td className="px-6 py-4 text-center">
                                            {classe.moyenne_generale >= 12 ? (
                                                <span className="bg-green-100 text-green-700 px-3 py-1 rounded-full text-xs font-bold">Excellent</span>
                                            ) : classe.moyenne_generale >= 10 ? (
                                                <span className="bg-blue-100 text-blue-700 px-3 py-1 rounded-full text-xs font-bold">Passable</span>
                                            ) : classe.moyenne_generale > 0 ? (
                                                <span className="bg-red-100 text-red-700 px-3 py-1 rounded-full text-xs font-bold">Critique</span>
                                            ) : (
                                                <span className="bg-slate-100 text-slate-500 px-3 py-1 rounded-full text-xs font-bold">N/A</span>
                                            )}
                                        </td>
                                    </tr>
                                ))
                            ) : (
                                <tr>
                                    <td colSpan="5" className="px-6 py-8 text-center text-slate-500">
                                        Aucune donnée statistique disponible pour le moment.
                                    </td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    );
};

export default CenseurDashboard;
