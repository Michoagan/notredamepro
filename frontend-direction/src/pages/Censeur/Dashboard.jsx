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
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const loadStats = async () => {
            try {
                const response = await censeurService.getDashboardStats();
                if (response.data && response.data.success) {
                    setStats(response.data.data);
                }
            } catch (error) {
                console.error("Erreur chargement dashboard", error);
            } finally {
                setLoading(false);
            }
        };
        loadStats();
    }, []);

    if (loading) return <div className="text-center py-10">Chargement...</div>;

    return (
        <div className="space-y-8">
            <div className="flex justify-between items-center">
                <h1 className="text-2xl font-bold text-slate-900">Tableau de Bord Censeur</h1>
                <span className="text-slate-500">{new Date().toLocaleDateString('fr-FR', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}</span>
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

            {/* Recent Logs Section */}
            <div className="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
                <div className="p-6 border-b border-slate-100 flex justify-between items-center">
                    <h2 className="text-lg font-semibold text-slate-900">Activités Récentes</h2>
                </div>
                <div className="divide-y divide-slate-100">
                    {stats?.recent_logs && stats.recent_logs.length > 0 ? (
                        stats.recent_logs.map((log) => (
                            <div key={log.id} className="p-4 flex items-center justify-between hover:bg-slate-50">
                                <div>
                                    <p className="font-medium text-slate-900">
                                        <span className="text-blue-600">[{log.action}]</span> {log.model}
                                    </p>
                                    <p className="text-sm text-slate-500">
                                        Par {log.user_name} ({log.user_role})
                                    </p>
                                </div>
                                <span className="text-xs text-slate-400">
                                    {new Date(log.created_at).toLocaleString('fr-FR')}
                                </span>
                            </div>
                        ))
                    ) : (
                        <div className="p-6 text-center text-slate-500">Aucune activité récente.</div>
                    )}
                </div>
            </div>
        </div>
    );
};

export default CenseurDashboard;
