import React, { useState } from 'react';
import { Search, Plus, CreditCard, Banknote, Download } from 'lucide-react';

export default function Paiements() {
    const [transactions, setTransactions] = useState([
        { id: 1, eleve: 'Kouassi Aya', classe: '6ème A', date: '2024-02-15', montant: 50000, type: 'Scolarité', mode: 'Espèces' },
        { id: 2, eleve: 'Diop Moussa', classe: '5ème B', date: '2024-02-14', montant: 25000, type: 'Cantine', mode: 'Mobile Money' },
    ]);

    return (
        <div className="space-y-6">
            <header className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-slate-800">Scolarités & Paiements</h1>
                    <p className="text-slate-500">Encaissement et suivi des règlements</p>
                </div>
                <button className="flex items-center space-x-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition shadow-sm">
                    <Plus className="w-4 h-4" />
                    <span>Nouveau Paiement</span>
                </button>
            </header>

            <div className="bg-white rounded-xl shadow-sm border border-slate-200">
                <div className="p-4 border-b border-slate-100 flex flex-wrap gap-4 items-center justify-between bg-slate-50">
                    <div className="relative w-full max-w-md">
                        <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
                        <input
                            type="text"
                            placeholder="Rechercher élève, matricule..."
                            className="w-full pl-9 pr-4 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 outline-none"
                        />
                    </div>
                    <button className="flex items-center space-x-2 text-slate-600 hover:text-slate-900 text-sm font-medium">
                        <Download className="w-4 h-4" />
                        <span>Exporter</span>
                    </button>
                </div>

                <div className="overflow-x-auto">
                    <table className="w-full text-left text-sm">
                        <thead className="bg-slate-50 text-slate-500 font-medium border-b border-slate-200">
                            <tr>
                                <th className="px-6 py-4">Date</th>
                                <th className="px-6 py-4">Élève</th>
                                <th className="px-6 py-4">Motif</th>
                                <th className="px-6 py-4">Mode</th>
                                <th className="px-6 py-4 text-right">Montant</th>
                                <th className="px-6 py-4 text-center">Reçu</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-slate-100">
                            {transactions.map((t) => (
                                <tr key={t.id} className="hover:bg-slate-50 transition">
                                    <td className="px-6 py-4 text-slate-500">{new Date(t.date).toLocaleDateString('fr-FR')}</td>
                                    <td className="px-6 py-4">
                                        <div className="font-medium text-slate-900">{t.eleve}</div>
                                        <div className="text-xs text-slate-500">{t.classe}</div>
                                    </td>
                                    <td className="px-6 py-4">{t.type}</td>
                                    <td className="px-6 py-4">
                                        <span className="inline-flex items-center space-x-1 px-2 py-1 rounded bg-slate-100 text-slate-600 text-xs">
                                            {t.mode === 'Espèces' ? <Banknote className="w-3 h-3" /> : <CreditCard className="w-3 h-3" />}
                                            <span>{t.mode}</span>
                                        </span>
                                    </td>
                                    <td className="px-6 py-4 text-right font-bold text-slate-800">
                                        {new Intl.NumberFormat('fr-FR').format(t.montant)} FCFA
                                    </td>
                                    <td className="px-6 py-4 text-center">
                                        <button className="text-blue-600 hover:text-blue-800 text-xs font-medium">Voir</button>
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
