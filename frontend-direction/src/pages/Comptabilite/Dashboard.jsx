import React, { useEffect, useState } from 'react';
import { getComptaDashboard } from '../../services/comptabilite';
import { Loader2, TrendingUp, TrendingDown, Wallet } from 'lucide-react';

const StatCard = ({ title, amount, icon: Icon, color, className }) => (
    <div className={`rounded-xl bg-white p-6 shadow-sm border border-slate-100 ${className}`}>
        <div className="flex items-center justify-between">
            <div>
                <p className="text-sm font-medium text-slate-500">{title}</p>
                <p className={`mt-2 text-2xl font-bold ${color}`}>
                    {new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF' }).format(amount)}
                </p>
            </div>
            <div className={`rounded-full p-3 ${color.replace('text-', 'bg-').replace('600', '100')}`}>
                <Icon className={`h-6 w-6 ${color}`} />
            </div>
        </div>
    </div>
);

export default function ComptabiliteDashboard() {
    const [stats, setStats] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        loadData();
    }, []);

    const loadData = async () => {
        try {
            const data = await getComptaDashboard();
            setStats(data);
        } catch (err) {
            console.error(err);
            setError('Impossible de charger les données comptables.');
        } finally {
            setLoading(false);
        }
    };

    if (loading) return <div className="flex justify-center p-12"><Loader2 className="h-8 w-8 animate-spin text-blue-600" /></div>;
    if (error) return <div className="p-4 text-red-600 bg-red-50 rounded-lg">{error}</div>;

    return (
        <div className="space-y-6 p-8">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-2xl font-bold text-slate-800">Comptabilité</h1>
                    <p className="text-slate-500">Vue d'ensemble financière</p>
                </div>
                <span className="text-sm text-slate-500 bg-slate-100 px-3 py-1 rounded-full">Période: {stats.period.start} au {stats.period.end}</span>
            </div>

            <div className="grid gap-6 md:grid-cols-3">
                <StatCard
                    title="Total Entrées"
                    amount={stats.entrees.total}
                    icon={TrendingUp}
                    color="text-green-600"
                />
                <StatCard
                    title="Total Dépenses"
                    amount={stats.sorties.total}
                    icon={TrendingDown}
                    color="text-red-600"
                />
                <StatCard
                    title="Solde Actuel"
                    amount={stats.solde}
                    icon={Wallet}
                    color={stats.solde >= 0 ? "text-blue-600" : "text-amber-600"}
                />
            </div>

            {/* Details Sections */}
            <div className="grid gap-6 md:grid-cols-2">
                <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-100">
                    <h3 className="font-semibold text-slate-700 mb-4">Détail Entrées</h3>
                    <div className="space-y-3">
                        <div className="flex justify-between p-2 hover:bg-slate-50 rounded">
                            <span>Scolarité</span>
                            <span className="font-medium text-slate-900">{new Intl.NumberFormat('fr-FR').format(stats.entrees.scolarite)} FCFA</span>
                        </div>
                        <div className="flex justify-between p-2 hover:bg-slate-50 rounded">
                            <span>Ventes & Autres</span>
                            <span className="font-medium text-slate-900">{new Intl.NumberFormat('fr-FR').format(stats.entrees.ventes)} FCFA</span>
                        </div>
                    </div>
                </div>

                <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-100">
                    <h3 className="font-semibold text-slate-700 mb-4">Détail Sorties</h3>
                    <div className="space-y-3">
                        <div className="flex justify-between p-2 hover:bg-slate-50 rounded">
                            <span>Dépenses Totales</span>
                            <span className="font-medium text-slate-900">{new Intl.NumberFormat('fr-FR').format(stats.sorties.depenses)} FCFA</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}
