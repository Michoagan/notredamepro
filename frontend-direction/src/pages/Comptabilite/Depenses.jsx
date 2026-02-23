import React, { useState } from 'react';
import { Plus, Filter, FileText } from 'lucide-react';

export default function Depenses() {
    const [depenses, setDepenses] = useState([]);

    const handleAdd = () => {
        alert("Formulaire de dépense à implémenter.");
    };

    return (
        <div className="space-y-6">
            <header className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-slate-800">Gestion des Dépenses</h1>
                    <p className="text-slate-500">Enregistrement et suivi des charges</p>
                </div>
                <button
                    onClick={handleAdd}
                    className="flex items-center space-x-2 bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 transition shadow-sm"
                >
                    <Plus className="w-4 h-4" />
                    <span>Nouvelle Dépense</span>
                </button>
            </header>

            <div className="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
                <div className="p-4 border-b border-slate-100 flex justify-end gap-2 bg-slate-50">
                    <button className="flex items-center space-x-2 px-3 py-1.5 bg-white border border-slate-300 rounded text-sm text-slate-600 hover:bg-slate-50">
                        <Filter className="w-4 h-4" />
                        <span>Filtrer</span>
                    </button>
                </div>

                <div className="overflow-x-auto">
                    <table className="w-full text-left text-sm">
                        <thead className="bg-slate-50 text-slate-500 font-medium border-b border-slate-200">
                            <tr>
                                <th className="px-6 py-4">Date</th>
                                <th className="px-6 py-4">Libellé</th>
                                <th className="px-6 py-4">Catégorie</th>
                                <th className="px-6 py-4 text-right">Montant</th>
                                <th className="px-6 py-4 text-center">Justificatif</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-slate-100">
                            {depenses.length === 0 ? (
                                <tr>
                                    <td colSpan="5" className="px-6 py-12 text-center text-slate-400">
                                        <div className="flex flex-col items-center">
                                            <FileText className="w-12 h-12 mb-3 text-slate-300" />
                                            <p>Aucune dépense enregistrée pour le moment.</p>
                                        </div>
                                    </td>
                                </tr>
                            ) : (
                                depenses.map((d, i) => (
                                    <tr key={i}>
                                        {/* Rows content */}
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    );
}
