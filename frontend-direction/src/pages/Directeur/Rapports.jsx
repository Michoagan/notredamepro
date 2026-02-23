import React from 'react';

export default function Rapports() {
    return (
        <div className="p-8 space-y-6">
            <header>
                <h1 className="text-2xl font-bold text-slate-800">Rapports & Statistiques</h1>
                <p className="text-slate-500">Analyses détaillées de l'établissement</p>
            </header>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div className="bg-white p-6 rounded-xl border border-slate-200 hover:shadow-md transition cursor-pointer">
                    <h3 className="font-semibold text-lg text-slate-800 mb-2">Rapport Financier</h3>
                    <p className="text-slate-500 text-sm">Bilan des entrées et sorties, état des scolarités.</p>
                </div>
                <div className="bg-white p-6 rounded-xl border border-slate-200 hover:shadow-md transition cursor-pointer">
                    <h3 className="font-semibold text-lg text-slate-800 mb-2">Rapport Pédagogique</h3>
                    <p className="text-slate-500 text-sm">Performance des classes, taux de réussite par matière.</p>
                </div>
                <div className="bg-white p-6 rounded-xl border border-slate-200 hover:shadow-md transition cursor-pointer">
                    <h3 className="font-semibold text-lg text-slate-800 mb-2">Rapport Administratif</h3>
                    <p className="text-slate-500 text-sm">Effectifs, présence du personnel, maintenance.</p>
                </div>
            </div>
        </div>
    );
}
