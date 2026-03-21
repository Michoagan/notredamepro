import React, { useState, useEffect } from 'react';
import { TrendingUp, Users, DollarSign, Activity, BookOpen, Layers } from 'lucide-react';
import { getDirecteurDashboard } from '../../services/directeur';

const KPICard = ({ label, value, trend, icon: Icon, color }) => (
    <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-100">
        <div className="flex justify-between items-start mb-4">
            <div className={`p-3 rounded-lg ${color} bg-opacity-10`}>
                <Icon className={`w-6 h-6 ${color.replace('bg-', 'text-')}`} />
            </div>
            {trend && <span className="text-green-500 text-xs font-bold">+ {trend}%</span>}
        </div>
        <h3 className="text-3xl font-bold text-slate-800 mb-1">{value}</h3>
        <p className="text-sm text-slate-500">{label}</p>
    </div>
);

export default function DirecteurDashboard() {
    const [stats, setStats] = useState({
        eleves: 0,
        professeurs: 0,
        classes: 0,
    });
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        loadDashboardStats();
    }, []);

    const loadDashboardStats = async () => {
        try {
            const data = await getDirecteurDashboard();
            if (data.success) {
                setStats({
                    eleves: data.data.eleves_count,
                    professeurs: data.data.professeurs_count,
                    classes: data.data.classes_count,
                });
            }
        } catch (error) {
            console.error(error);
        } finally {
            setLoading(false);
        }
    };

    if (loading) return <div className="p-8 text-center text-slate-500">Chargement...</div>;

    return (
        <div className="p-8 space-y-8">
            <header>
                <h1 className="text-2xl font-bold text-slate-800">Espace Direction Générale</h1>
                <p className="text-slate-500">Pilotage et Vue stratégique</p>
            </header>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                <KPICard label="Effectif Élèves" value={stats.eleves} icon={Users} color="bg-blue-600" />
                <KPICard label="Total Professeurs" value={stats.professeurs} icon={TrendingUp} color="bg-emerald-600" />
                <KPICard label="Total Classes" value={stats.classes} icon={BookOpen} color="bg-purple-600" />
                <KPICard label="Activité Plateforme" value="Élevée" icon={Activity} color="bg-orange-600" />
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-100 h-80">
                    <h3 className="font-semibold text-lg mb-4">Évolution des Inscriptions</h3>
                    <div className="flex items-center justify-center h-full text-slate-400">
                        Graphique à venir
                    </div>
                </div>
                <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-100 h-80">
                    <h3 className="font-semibold text-lg mb-4">Répartition Financière</h3>
                    <div className="flex items-center justify-center h-full text-slate-400">
                        Graphique à venir
                    </div>
                </div>
            </div>
        </div>
    );
}
