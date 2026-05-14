import React, { useState, useEffect } from 'react';
import surveillantService from '../../services/surveillant';
import { Users, Clock, AlertTriangle, Calendar, UserCheck, BookOpen } from 'lucide-react';

const StatCard = ({ title, value, icon: Icon, color }) => (
    <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-100">
        <div className="flex justify-between items-start">
            <div>
                <p className="text-sm font-medium text-slate-500 mb-1">{title}</p>
                <h3 className="text-2xl font-bold text-slate-800">{value}</h3>
            </div>
            <div className={`p-2 rounded-lg ${color}`}>
                <Icon className="w-5 h-5 text-white" />
            </div>
        </div>
    </div>
);

export default function SurveillantDashboard() {
    const [data, setData] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchData = async () => {
            try {
                const response = await surveillantService.getDashboard();
                if (response.success) {
                    setData(response);
                }
            } catch (error) {
                console.error("Erreur chargement dashboard surveillant", error);
            } finally {
                setLoading(false);
            }
        };
        fetchData();
    }, []);

    if (loading) return <div className="p-8 text-center text-slate-500">Chargement...</div>;

    const { stats, plaintes, evenements } = data || { stats: {}, plaintes: [], evenements: [] };

    return (
        <div className="space-y-8">
            <header className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-slate-800">Espace Surveillant</h1>
                    <p className="text-slate-500">Vue d'ensemble de la vie scolaire</p>
                </div>
                <div className="text-sm text-slate-500">
                    {new Date().toLocaleDateString('fr-FR', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
                </div>
            </header>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                <StatCard
                    title="Plaintes (Semaine)"
                    value={stats?.plaintes_semaine || 0}
                    icon={AlertTriangle}
                    color="bg-red-500"
                />
                <StatCard
                    title="Total Élèves"
                    value={stats?.eleves_total || 0}
                    icon={Users}
                    color="bg-blue-500"
                />
                <StatCard
                    title="Professeurs"
                    value={stats?.professeurs_total || 0}
                    icon={UserCheck}
                    color="bg-green-500"
                />
                <StatCard
                    title="Classes"
                    value={stats?.classes_total || 0}
                    icon={BookOpen}
                    color="bg-purple-500"
                />
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                {/* Derniers Incidents */}
                <div className="bg-white rounded-xl shadow-sm border border-slate-100 overflow-hidden">
                    <div className="p-6 border-b border-slate-100 flex justify-between items-center">
                        <h2 className="text-lg font-semibold text-slate-800">Derniers Incidents</h2>
                    </div>
                    <div className="divide-y divide-slate-100">
                        {plaintes && plaintes.length > 0 ? (
                            plaintes.map((plainte) => (
                                <div key={plainte.id} className="p-4 hover:bg-slate-50 transition">
                                    <div className="flex justify-between items-start mb-1">
                                        <span className={`px-2 py-0.5 rounded text-xs font-medium ${plainte.type_plainte === 'absence' ? 'bg-red-100 text-red-700' :
                                            plainte.type_plainte === 'retard' ? 'bg-orange-100 text-orange-700' :
                                                'bg-slate-100 text-slate-700'
                                            }`}>
                                            {plainte.type_plainte.toUpperCase()}
                                        </span>
                                        <span className="text-xs text-slate-400">
                                            {new Date(plainte.date_plainte).toLocaleDateString('fr-FR')}
                                        </span>
                                    </div>
                                    <p className="font-medium text-slate-800">
                                        {plainte.eleve?.nom} {plainte.eleve?.prenom}
                                        <span className="text-slate-500 font-normal ml-1">({plainte.classe?.nom})</span>
                                    </p>
                                    <p className="text-sm text-slate-500 mt-1 line-clamp-1">{plainte.details}</p>
                                </div>
                            ))
                        ) : (
                            <div className="p-8 text-center text-slate-500">Aucun incident récent.</div>
                        )}
                    </div>
                </div>

                {/* Événements à venir */}
                <div className="bg-white rounded-xl shadow-sm border border-slate-100 overflow-hidden">
                    <div className="p-6 border-b border-slate-100 flex justify-between items-center">
                        <h2 className="text-lg font-semibold text-slate-800">Événements à Venir</h2>
                    </div>
                    <div className="divide-y divide-slate-100">
                        {evenements && evenements.length > 0 ? (
                            evenements.map((event) => (
                                <div key={event.id} className="p-4 hover:bg-slate-50 transition flex items-start space-x-4">
                                    <div className="bg-blue-50 text-blue-600 p-3 rounded-lg text-center min-w-[60px]">
                                        <div className="text-xs font-bold uppercase">{new Date(event.date_debut).toLocaleString('fr-FR', { month: 'short' })}</div>
                                        <div className="text-xl font-bold">{new Date(event.date_debut).getDate()}</div>
                                    </div>
                                    <div>
                                        <h4 className="font-semibold text-slate-800">{event.titre}</h4>
                                        <div className="flex items-center text-xs text-slate-500 mt-1 space-x-3">
                                            <span className="flex items-center"><Clock className="w-3 h-3 mr-1" /> {new Date(event.date_debut).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</span>
                                            {event.lieu && <span>📍 {event.lieu}</span>}
                                        </div>
                                    </div>
                                </div>
                            ))
                        ) : (
                            <div className="p-8 text-center text-slate-500">Aucun événement à venir.</div>
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
}
