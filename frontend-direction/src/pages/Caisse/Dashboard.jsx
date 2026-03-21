import React, { useState, useEffect } from 'react';
import { getCaisseDashboard } from '../../services/caisse';
import { Loader2, TrendingUp, HandCoins, Activity, Calendar as CalendarIcon } from 'lucide-react';

export default function Dashboard() {
    const [stats, setStats] = useState(null);
    const [loading, setLoading] = useState(true);
    const [date, setDate] = useState(new Date().toISOString().split('T')[0]);

    useEffect(() => {
        fetchDashboard();
    }, [date]);

    const fetchDashboard = async () => {
        try {
            setLoading(true);
            const data = await getCaisseDashboard(date);
            setStats(data);
        } catch (error) {
            console.error("Erreur de chargement du dashboard caisse", error);
        } finally {
            setLoading(false);
        }
    };

    if (loading && !stats) {
        return (
            <div className="flex justify-center items-center h-full">
                <Loader2 className="w-8 h-8 animate-spin text-blue-600" />
            </div>
        );
    }

    return (
        <div className="p-6 space-y-6">
            <header className="flex justify-between items-center bg-white p-6 rounded-xl shadow-sm border border-slate-100">
                <div>
                    <h1 className="text-2xl font-bold text-slate-800">Caisse - Tableau de bord</h1>
                    <p className="text-slate-500">Recettes du jour</p>
                </div>
                <div className="flex items-center space-x-2 bg-slate-50 px-4 py-2 rounded-lg border border-slate-200">
                    <CalendarIcon className="w-5 h-5 text-slate-400" />
                    <input
                        type="date"
                        value={date}
                        onChange={(e) => setDate(e.target.value)}
                        className="bg-transparent border-none outline-none font-medium text-slate-700"
                    />
                </div>
            </header>

            {stats && (
                <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-100 flex items-center space-x-4">
                        <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center">
                            <HandCoins className="w-6 h-6 text-blue-600" />
                        </div>
                        <div>
                            <p className="text-sm font-medium text-slate-500">Scolarités encaissées</p>
                            <h3 className="text-2xl font-bold text-slate-800">{new Intl.NumberFormat('fr-FR').format(stats.entrees?.scolarite || 0)} <span className="text-sm text-slate-500 font-normal">FCFA</span></h3>
                        </div>
                    </div>

                    <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-100 flex items-center space-x-4">
                        <div className="w-12 h-12 bg-emerald-100 rounded-full flex items-center justify-center">
                            <TrendingUp className="w-6 h-6 text-emerald-600" />
                        </div>
                        <div>
                            <p className="text-sm font-medium text-slate-500">Autres Recettes (Ventes)</p>
                            <h3 className="text-2xl font-bold text-slate-800">{new Intl.NumberFormat('fr-FR').format(stats.entrees?.ventes || 0)} <span className="text-sm text-slate-500 font-normal">FCFA</span></h3>
                        </div>
                    </div>

                    <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-100 flex items-center space-x-4 bg-gradient-to-br from-slate-800 to-slate-900 border-none text-white">
                        <div className="w-12 h-12 bg-white/20 rounded-full flex items-center justify-center">
                            <Activity className="w-6 h-6 text-white" />
                        </div>
                        <div>
                            <p className="text-sm font-medium text-slate-300">Total Encaissé (Jour)</p>
                            <h3 className="text-2xl font-bold text-white max-w-full overflow-hidden text-ellipsis whitespace-nowrap">{new Intl.NumberFormat('fr-FR').format(stats.entrees?.total || 0)} <span className="text-sm text-slate-300 font-normal">FCFA</span></h3>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
