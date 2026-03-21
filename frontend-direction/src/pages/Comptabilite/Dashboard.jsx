import React, { useEffect, useState } from 'react';
import { getComptaDashboard } from '../../services/comptabilite';
import { Loader2, TrendingUp, TrendingDown, Wallet, Box, AlertTriangle, ArrowRightLeft } from 'lucide-react';

const StatCard = ({ title, amount, icon: Icon, color, isCurrency = true, className }) => (
    <div className={`rounded-xl bg-white p-6 shadow-sm border border-slate-100 ${className}`}>
        <div className="flex items-center justify-between">
            <div>
                <p className="text-sm font-medium text-slate-500">{title}</p>
                <p className={`mt-2 text-2xl font-bold ${color}`}>
                    {isCurrency
                        ? new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF' }).format(amount)
                        : amount}
                </p>
            </div>
            <div className={`rounded-full p-3 ${color.replace('text-', 'bg-').replace('600', '100').replace('500', '100')}`}>
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
        <div className="space-y-8 p-8 max-w-7xl mx-auto">
            <div className="flex items-center justify-between border-b pb-4">
                <div>
                    <h1 className="text-3xl font-bold text-slate-800">Comptabilité Analytique</h1>
                    <p className="text-slate-500 mt-1">Bilan Financier et Inventaire Automatique</p>
                </div>
                <div className="bg-white border text-sm text-slate-600 px-4 py-2 rounded-lg shadow-sm">
                    Période: <span className="font-semibold">{new Date(stats.period.start).toLocaleDateString()}</span> au <span className="font-semibold">{new Date(stats.period.end).toLocaleDateString()}</span>
                </div>
            </div>

            {/* SECTION 1: BILAN FINANCIER */}
            <section className="space-y-4">
                <div className="flex items-center space-x-2 mb-4">
                    <Wallet className="w-6 h-6 text-blue-600" />
                    <h2 className="text-xl font-bold text-slate-800">1. Bilan Financier (Trésorerie)</h2>
                </div>

                <div className="grid gap-6 md:grid-cols-3">
                    <StatCard
                        title="Total Entrées"
                        amount={stats.financier.entrees.total}
                        icon={TrendingUp}
                        color="text-green-600"
                    />
                    <StatCard
                        title="Total Sorties"
                        amount={stats.financier.sorties.total}
                        icon={TrendingDown}
                        color="text-red-600"
                    />
                    <StatCard
                        title="Solde Net"
                        amount={stats.financier.solde_net}
                        icon={Wallet}
                        color={stats.financier.solde_net >= 0 ? "text-blue-600" : "text-amber-600"}
                    />
                </div>

                <div className="grid gap-6 md:grid-cols-2 mt-4">
                    <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-100">
                        <h3 className="font-semibold text-slate-700 mb-4 border-b pb-2">Détail des Entrées</h3>
                        <div className="space-y-3">
                            <div className="flex justify-between p-2 hover:bg-slate-50 rounded">
                                <span className="text-slate-600">Scolarités encaissées</span>
                                <span className="font-medium text-green-700">{new Intl.NumberFormat('fr-FR').format(stats.financier.entrees.scolarite)} FCFA</span>
                            </div>
                            <div className="flex justify-between p-2 hover:bg-slate-50 rounded">
                                <span className="text-slate-600">Ventes Boutique/Cantine</span>
                                <span className="font-medium text-green-700">{new Intl.NumberFormat('fr-FR').format(stats.financier.entrees.ventes)} FCFA</span>
                            </div>
                        </div>
                    </div>

                    <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-100">
                        <h3 className="font-semibold text-slate-700 mb-4 border-b pb-2">Détail des Sorties</h3>
                        <div className="space-y-3">
                            <div className="flex justify-between p-2 hover:bg-slate-50 rounded">
                                <span className="text-slate-600">Salaires Payés</span>
                                <span className="font-medium text-red-700">{new Intl.NumberFormat('fr-FR').format(stats.financier.sorties.salaires)} FCFA</span>
                            </div>
                            <div className="flex justify-between p-2 hover:bg-slate-50 rounded">
                                <span className="text-slate-600">Dépenses Générales</span>
                                <span className="font-medium text-red-700">{new Intl.NumberFormat('fr-FR').format(stats.financier.sorties.depenses_generales)} FCFA</span>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            {/* SECTION 2: BILAN INVENTAIRE */}
            <section className="space-y-4 pt-6 mt-6 border-t border-slate-200">
                <div className="flex items-center space-x-2 mb-4">
                    <Box className="w-6 h-6 text-purple-600" />
                    <h2 className="text-xl font-bold text-slate-800">2. Bilan d'Inventaire (Patrimoine)</h2>
                </div>

                <div className="grid gap-6 md:grid-cols-3">
                    <StatCard
                        title="Valeur Financière du Stock"
                        amount={stats.inventaire.valeur_totale}
                        icon={Box}
                        color="text-purple-600"
                    />
                    <StatCard
                        title="Alertes Rupture de Stock"
                        amount={stats.inventaire.alertes_rupture}
                        icon={AlertTriangle}
                        color={stats.inventaire.alertes_rupture > 0 ? "text-red-500" : "text-slate-400"}
                        isCurrency={false}
                    />
                    <StatCard
                        title="Mouvements (Entrées / Sorties)"
                        amount={`${stats.inventaire.mouvements.entrees} / ${stats.inventaire.mouvements.sorties}`}
                        icon={ArrowRightLeft}
                        color="text-slate-600"
                        isCurrency={false}
                    />
                </div>
            </section>
        </div>
    );
}
