import React, { useState, useEffect } from 'react';
import { getComptaStats } from '../../services/directeur';
import { Loader2, TrendingUp, TrendingDown, Wallet, Calendar } from 'lucide-react';
import { 
    BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer,
    AreaChart, Area
} from 'recharts';

export default function DirecteurComptabilite() {
    const [data, setData] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchData();
    }, []);

    const fetchData = async () => {
        try {
            setLoading(true);
            const res = await getComptaStats();
            if (res.success) {
                setData(res);
            }
        } catch (error) {
            console.error("Erreur de chargement", error);
        } finally {
            setLoading(false);
        }
    };

    if (loading) return <div className="flex justify-center p-12"><Loader2 className="h-8 w-8 animate-spin text-blue-600" /></div>;
    if (!data) return null;

    const statsMensuelles = data.stats_mensuelles;

    return (
        <div className="space-y-8 max-w-7xl mx-auto p-4 md:p-8">
            <header className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                <div>
                    <h1 className="text-3xl font-bold text-slate-800">Analyses Comptables</h1>
                    <p className="text-slate-500 mt-1">Évolution des revenus et dépenses (6 derniers mois)</p>
                </div>
                <div className="flex items-center space-x-2 bg-white px-4 py-2 rounded-lg border shadow-sm">
                    <Calendar className="w-4 h-4 text-slate-400" />
                    <span className="text-sm font-bold text-slate-800">Année : {data.annee_scolaire}</span>
                </div>
            </header>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                {/* Graphique Revenus vs Dépenses */}
                <div className="bg-white p-6 rounded-2xl shadow-sm border border-slate-200">
                    <h3 className="text-lg font-bold text-slate-800 mb-6">Comparatif Mensuel</h3>
                    <div className="h-[350px] w-full">
                        <ResponsiveContainer width="100%" height="100%">
                            <BarChart data={statsMensuelles}>
                                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                                <XAxis dataKey="mois" axisLine={false} tickLine={false} tick={{fill: '#64748b'}} />
                                <YAxis axisLine={false} tickLine={false} tick={{fill: '#64748b'}} />
                                <Tooltip 
                                    contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)' }}
                                    formatter={(value) => `${new Intl.NumberFormat('fr-FR').format(value)} F`}
                                />
                                <Legend iconType="circle" />
                                <Bar dataKey="revenu" name="Revenus" fill="#3b82f6" radius={[4, 4, 0, 0]} />
                                <Bar dataKey="depense" name="Dépenses" fill="#f43f5e" radius={[4, 4, 0, 0]} />
                            </BarChart>
                        </ResponsiveContainer>
                    </div>
                </div>

                {/* Graphique Solde Net (Courbe) */}
                <div className="bg-white p-6 rounded-2xl shadow-sm border border-slate-200">
                    <h3 className="text-lg font-bold text-slate-800 mb-6">Tendance du Solde Net</h3>
                    <div className="h-[350px] w-full">
                        <ResponsiveContainer width="100%" height="100%">
                            <AreaChart data={statsMensuelles}>
                                <defs>
                                    <linearGradient id="colorSolde" x1="0" y1="0" x2="0" y2="1">
                                        <stop offset="5%" stopColor="#10b981" stopOpacity={0.1}/>
                                        <stop offset="95%" stopColor="#10b981" stopOpacity={0}/>
                                    </linearGradient>
                                </defs>
                                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                                <XAxis dataKey="mois" axisLine={false} tickLine={false} tick={{fill: '#64748b'}} />
                                <YAxis axisLine={false} tickLine={false} tick={{fill: '#64748b'}} />
                                <Tooltip 
                                    contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)' }}
                                    formatter={(value) => `${new Intl.NumberFormat('fr-FR').format(value)} F`}
                                />
                                <Area 
                                    type="monotone" 
                                    dataKey="solde" 
                                    name="Solde Net" 
                                    stroke="#10b981" 
                                    strokeWidth={3}
                                    fillOpacity={1} 
                                    fill="url(#colorSolde)" 
                                />
                            </AreaChart>
                        </ResponsiveContainer>
                    </div>
                </div>
            </div>

            {/* Tableau Récapitulatif */}
            <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
                <div className="p-6 border-b border-slate-100 bg-slate-50">
                    <h3 className="font-bold text-slate-800">Détails des flux financiers</h3>
                </div>
                <div className="overflow-x-auto">
                    <table className="w-full text-left">
                        <thead className="bg-slate-50 text-slate-500 uppercase text-xs font-bold tracking-wider">
                            <tr>
                                <th className="px-6 py-4">Période</th>
                                <th className="px-6 py-4 text-right">Revenus</th>
                                <th className="px-6 py-4 text-right">Dépenses</th>
                                <th className="px-6 py-4 text-right">Balance</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-slate-100">
                            {statsMensuelles.map((s, idx) => (
                                <tr key={idx} className="hover:bg-slate-50 transition">
                                    <td className="px-6 py-4 font-bold text-slate-700">{s.mois}</td>
                                    <td className="px-6 py-4 text-right text-blue-600 font-medium">{new Intl.NumberFormat('fr-FR').format(s.revenu)} F</td>
                                    <td className="px-6 py-4 text-right text-rose-600 font-medium">{new Intl.NumberFormat('fr-FR').format(s.depense)} F</td>
                                    <td className={`px-6 py-4 text-right font-bold ${s.solde >= 0 ? 'text-emerald-600' : 'text-red-600'}`}>
                                        <div className="flex items-center justify-end">
                                            {s.solde >= 0 ? <TrendingUp className="w-4 h-4 mr-1.5" /> : <TrendingDown className="w-4 h-4 mr-1.5" />}
                                            {new Intl.NumberFormat('fr-FR').format(s.solde)} F
                                        </div>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    );
}
