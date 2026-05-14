import React, { useState, useEffect } from 'react';
import { AlertTriangle, Plus, Search, Loader2 } from 'lucide-react';
import surveillantService from '../../services/surveillant';

export default function Discipline() {
    const [incidents, setIncidents] = useState([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');

    useEffect(() => {
        loadIncidents();
    }, []);

    const loadIncidents = async () => {
        setLoading(true);
        try {
            const data = await surveillantService.getPlaintes();
            setIncidents(data);
        } catch (error) {
            console.error("Erreur chargement plaintes", error);
        } finally {
            setLoading(false);
        }
    };

    const handleReport = () => {
        alert("Formulaire de signalement à implémenter.");
    };

    const filteredIncidents = incidents.filter(incident =>
        incident.eleve?.nom?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        incident.eleve?.prenom?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        incident.type_plainte?.toLowerCase().includes(searchTerm.toLowerCase())
    );

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
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                        />
                    </div>
                </div>

                {loading ? (
                    <div className="p-12 flex justify-center text-slate-500">
                        <Loader2 className="w-8 h-8 animate-spin text-blue-600" />
                    </div>
                ) : filteredIncidents.length === 0 ? (
                    <div className="p-12 text-center text-slate-500">
                        <div className="bg-slate-50 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                            <AlertTriangle className="w-8 h-8 text-slate-300" />
                        </div>
                        <p>Aucun incident enregistré récemment.</p>
                    </div>
                ) : (
                    <div className="overflow-x-auto">
                        <table className="w-full text-left text-sm">
                            <thead className="bg-slate-50 text-slate-500 font-medium border-b border-slate-200">
                                <tr>
                                    <th className="px-6 py-4">Date</th>
                                    <th className="px-6 py-4">Élève</th>
                                    <th className="px-6 py-4">Classe</th>
                                    <th className="px-6 py-4">Type</th>
                                    <th className="px-6 py-4">Statut</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-100">
                                {filteredIncidents.map(incident => (
                                    <tr key={incident.id} className="hover:bg-slate-50 transition">
                                        <td className="px-6 py-4 whitespace-nowrap">
                                            {new Date(incident.date_plainte).toLocaleDateString('fr-FR')}
                                        </td>
                                        <td className="px-6 py-4 font-medium text-slate-900">
                                            {incident.eleve?.nom} {incident.eleve?.prenom}
                                        </td>
                                        <td className="px-6 py-4">
                                            {incident.classe?.nom}
                                        </td>
                                        <td className="px-6 py-4">
                                            <span className={`px-2 py-1 rounded-full text-xs font-semibold uppercase ${incident.type_plainte === 'absence' ? 'bg-red-100 text-red-700' :
                                                    incident.type_plainte === 'retard' ? 'bg-orange-100 text-orange-700' :
                                                        'bg-slate-100 text-slate-700'
                                                }`}>
                                                {incident.type_plainte}
                                            </span>
                                        </td>
                                        <td className="px-6 py-4">
                                            <span className="px-2 py-1 bg-slate-100 text-slate-600 rounded-lg text-xs font-medium capitalize">
                                                {incident.statut || 'Enregistrée'}
                                            </span>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                )}
            </div>
        </div>
    );
}
