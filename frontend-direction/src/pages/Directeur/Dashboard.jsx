import React from 'react';
import { TrendingUp, Users, DollarSign, Activity } from 'lucide-react';

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
    return (
        <div className="p-8 space-y-8">
            <header>
                <h1 className="text-2xl font-bold text-slate-800">Espace Direction Générale</h1>
                <p className="text-slate-500">Pilotage et Vue stratégique</p>
            </header>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                <KPICard label="Effectif Total" value="1,240" trend="5" icon={Users} color="bg-blue-600" />
                <KPICard label="Recettes du mois" value="12M FCFA" trend="12" icon={DollarSign} color="bg-emerald-600" />
                <KPICard label="Taux de Réussite Global" value="87%" icon={TrendingUp} color="bg-purple-600" />
                <KPICard label="Activité Plateforme" value="Elevée" icon={Activity} color="bg-orange-600" />
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
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
