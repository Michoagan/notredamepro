import React, { useState, useEffect } from 'react';
import { getGlobalPerformance } from '../../services/directeur';
import { Loader2, TrendingUp, Award, Clock, BookOpen, Search } from 'lucide-react';

export default function PerformancesGlobales() {
    const [stats, setStats] = useState([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');

    useEffect(() => {
        fetchData();
    }, []);

    const fetchData = async () => {
        try {
            setLoading(true);
            const res = await getGlobalPerformance();
            if (res.success) {
                setStats(res.stats);
            }
        } catch (error) {
            console.error("Erreur de chargement", error);
        } finally {
            setLoading(false);
        }
    };

    const filteredStats = stats.filter(s => 
        s.nom_complet.toLowerCase().includes(searchTerm.toLowerCase()) ||
        s.matiere.toLowerCase().includes(searchTerm.toLowerCase())
    );

    if (loading) return <div className="flex justify-center p-12"><Loader2 className="h-8 w-8 animate-spin text-blue-600" /></div>;

    return (
        <div className="space-y-6 max-w-7xl mx-auto p-4 md:p-8">
            <header>
                <h1 className="text-3xl font-bold text-slate-800">Performances Globales des Professeurs</h1>
                <p className="text-slate-500 mt-1">Audit pédagogique, assiduité et progression des programmes</p>
            </header>

            <div className="bg-white p-4 rounded-xl shadow-sm border border-slate-200 flex items-center justify-between">
                <div className="relative w-full max-w-md">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
                    <input 
                        type="text"
                        placeholder="Chercher par nom ou matière..."
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                        className="w-full pl-9 pr-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                    />
                </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {filteredStats.map((prof) => (
                    <div key={prof.id} className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden hover:shadow-md transition group">
                        <div className="p-6">
                            <h3 className="text-lg font-bold text-slate-800 group-hover:text-blue-600 transition">{prof.nom_complet}</h3>
                            <p className="text-sm text-slate-500 font-medium uppercase tracking-wider">{prof.matiere}</p>
                            
                            <div className="mt-6 space-y-4">
                                {/* Assiduité */}
                                <div>
                                    <div className="flex justify-between text-sm mb-1">
                                        <span className="flex items-center text-slate-600"><Clock className="w-4 h-4 mr-1.5" /> Assiduité</span>
                                        <span className={`font-bold ${prof.assiduite >= 80 ? 'text-emerald-600' : 'text-amber-600'}`}>{prof.assiduite}%</span>
                                    </div>
                                    <div className="w-full bg-slate-100 rounded-full h-2">
                                        <div className={`h-2 rounded-full ${prof.assiduite >= 80 ? 'bg-emerald-500' : 'bg-amber-500'}`} style={{ width: `${prof.assiduite}%` }}></div>
                                    </div>
                                </div>

                                {/* Programme */}
                                <div>
                                    <div className="flex justify-between text-sm mb-1">
                                        <span className="flex items-center text-slate-600"><BookOpen className="w-4 h-4 mr-1.5" /> Programme</span>
                                        <span className="font-bold text-blue-600">{prof.programme}%</span>
                                    </div>
                                    <div className="w-full bg-slate-100 rounded-full h-2">
                                        <div className="h-2 rounded-full bg-blue-500" style={{ width: `${prof.programme}%` }}></div>
                                    </div>
                                </div>

                                {/* Impact */}
                                <div>
                                    <div className="flex justify-between text-sm mb-1">
                                        <span className="flex items-center text-slate-600"><Award className="w-4 h-4 mr-1.5" /> Taux de Réussite</span>
                                        <span className={`font-bold ${prof.impact >= 50 ? 'text-indigo-600' : 'text-red-500'}`}>{prof.impact}%</span>
                                    </div>
                                    <div className="w-full bg-slate-100 rounded-full h-2">
                                        <div className={`h-2 rounded-full ${prof.impact >= 50 ? 'bg-indigo-500' : 'bg-red-500'}`} style={{ width: `${prof.impact}%` }}></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div className="bg-slate-50 p-4 border-t border-slate-100">
                            <a href={`/directeur/personnel/${prof.id}/performance`} className="block text-center text-sm font-bold text-slate-600 hover:text-blue-600 transition">
                                Voir audit détaillé & IA
                            </a>
                        </div>
                    </div>
                ))}
            </div>
        </div>
    );
}
