import React, { useState } from 'react';
import { AlertTriangle, Plus, Search } from 'lucide-react';

export default function Discipline() {
    const [incidents, setIncidents] = useState([]); // Mock data would go here

    const handleReport = () => {
        alert("Formulaire de signalement à implémenter.");
    };

    return (
        <div className="space-y-6">
            <header className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-slate-800">Discipline & Sanctions</h1>
                    <p className="text-slate-500">Gestion des incidents et suivi comportemental</p>
                </div>
                <button
                    onClick={handleReport}
                    className="flex items-center space-x-2 bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 transition"
                >
                    <Plus className="w-4 h-4" />
                    <span>Nouvel Incident</span>
                </button>
            </header>

            {/* Quick Stats or Filters can go here */}

            <div className="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
                <div className="p-4 border-b border-slate-100 bg-slate-50 flex items-center justify-between">
                    <h2 className="font-semibold text-slate-800 flex items-center gap-2">
                        <AlertTriangle className="w-5 h-5 text-orange-500" />
                        Journal des Incidents
                    </h2>
                    <div className="relative">
                        <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
                        <input
                            type="text"
                            placeholder="Rechercher élève..."
                            className="pl-9 pr-4 py-1.5 text-sm border rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                        />
                    </div>
                </div>

                <div className="p-12 text-center text-slate-500">
                    <div className="bg-slate-50 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                        <AlertTriangle className="w-8 h-8 text-slate-300" />
                    </div>
                    <p>Aucun incident enregistré récemment.</p>
                </div>
            </div>
        </div>
    );
}
