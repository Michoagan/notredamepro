import React, { useState, useEffect } from 'react';
import {
    Users, BookOpen, Activity, Loader2,
    Wallet, Box, AlertTriangle, TrendingUp, TrendingDown,
    Lightbulb, AlertCircle, CheckCircle2
} from 'lucide-react';
import { getDirecteurDashboard } from '../../services/directeur';

const KPICard = ({ label, value, icon: Icon, color, isCurrency = false }) => (
    <div className={`bg-white p-6 rounded-xl shadow-sm border border-slate-100 flex items-center space-x-4`}>
        <div className={`p-4 rounded-xl ${color.replace('text-', 'bg-').replace('600', '100').replace('500', '100')}`}>
            <Icon className={`w-8 h-8 ${color}`} />
        </div>
        <div>
            <p className="text-sm font-medium text-slate-500 uppercase tracking-wide">{label}</p>
            <h3 className="text-2xl font-bold text-slate-800 mt-1">
                {isCurrency
                    ? new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF' }).format(value)
                    : value}
            </h3>
        </div>
    </div>
);

const DecisionAlert = ({ type, titre, message }) => {
    let styles = "bg-blue-50 text-blue-800 border-blue-200";
    let Icon = Lightbulb;

    if (type === 'warning') {
        styles = "bg-amber-50 text-amber-900 border-amber-200";
        Icon = AlertTriangle;
    } else if (type === 'error') {
        styles = "bg-red-50 text-red-900 border-red-200";
        Icon = AlertCircle;
    } else if (type === 'success') {
        styles = "bg-emerald-50 text-emerald-900 border-emerald-200";
        Icon = CheckCircle2;
    }

    return (
        <div className={`p-4 rounded-lg border flex items-start space-x-3 shadow-sm ${styles}`}>
            <Icon className="w-6 h-6 shrink-0 mt-0.5" />
            <div>
                <h4 className="font-bold">{titre}</h4>
                <p className="text-sm mt-1 opacity-90">{message}</p>
            </div>
        </div>
    );
};

export default function DirecteurDashboard() {
    const [stats, setStats] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [annee, setAnnee] = useState('');

    useEffect(() => {
        loadDashboardStats(annee);
    }, [annee]);

    const loadDashboardStats = async (selectedAnnee) => {
        try {
            setLoading(true);
            const params = selectedAnnee ? { annee_scolaire: selectedAnnee } : {};
            const res = await getDirecteurDashboard(params);
            if (res.success) {
                setStats(res.data);
            } else {
                setError("Échec du chargement des données.");
            }
        } catch (err) {
            console.error(err);
            setError("Erreur réseau lors du chargement des données.");
        } finally {
            setLoading(false);
        }
    };

    if (loading) return <div className="flex justify-center p-12"><Loader2 className="h-8 w-8 animate-spin text-blue-600" /></div>;
    if (error) return <div className="p-4 text-red-600 bg-red-50 rounded-lg max-w-2xl mx-auto mt-8">{error}</div>;
    if (!stats) return null;

    const { statistiques, financier, inventaire, decisions } = stats;

    return (
        <div className="p-8 space-y-8 max-w-7xl mx-auto bg-slate-50 min-h-screen">
            <header className="flex justify-between items-end border-b pb-4">
                <div>
                    <h1 className="text-3xl font-bold text-slate-800">Vue Stratégique Direction</h1>
                    <p className="text-slate-500 mt-1">Scolarité, Finances, et Intelligence d'Analyse</p>
                </div>
                <div className="bg-white px-4 py-2 rounded-lg shadow-sm border flex items-center space-x-2">
                    <span className="text-sm font-medium text-slate-600">Année :</span>
                    <select 
                        value={stats.annee_scolaire_active} 
                        onChange={(e) => setAnnee(e.target.value)}
                        className="bg-transparent border-none text-sm font-bold text-slate-800 focus:ring-0 cursor-pointer"
                    >
                        {stats.annees_disponibles && stats.annees_disponibles.map(a => (
                            <option key={a} value={a}>{a}</option>
                        ))}
                    </select>
                </div>
            </header>

            {/* SECTION 1: SCOLARITÉ */}
            <section className="space-y-4">
                <h2 className="text-xl font-bold text-slate-800 flex items-center gap-2">
                    <BookOpen className="w-5 h-5 text-indigo-600" /> 1. Effectifs & Scolarité
                </h2>
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                    <KPICard label="Effectif Élèves" value={statistiques.totalEleves} icon={Users} color="text-indigo-600" />
                    <KPICard label="Professeurs Actifs" value={statistiques.totalProfesseurs} icon={Activity} color="text-emerald-600" />
                    <KPICard label="Total Classes" value={statistiques.totalClasses} icon={BookOpen} color="text-purple-600" />
                    <KPICard label="Sexe (G / F)" value={`${statistiques.garcons} / ${statistiques.filles}`} icon={Users} color="text-blue-500" />
                </div>
            </section>

            {/* SECTION 2: COMPTABILITÉ ANALYTIQUE (TRÉSORERIE & PATRIMOINE) */}
            <section className="space-y-4 pt-4">
                <h2 className="text-xl font-bold text-slate-800 flex items-center gap-2">
                    <Wallet className="w-5 h-5 text-blue-600" /> 2. Comptabilité Analytique
                </h2>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <KPICard
                        label="Solde Net Mensuel"
                        value={financier.solde_net}
                        icon={financier.solde_net >= 0 ? TrendingUp : TrendingDown}
                        color={financier.solde_net >= 0 ? "text-blue-600" : "text-amber-600"}
                        isCurrency={true}
                    />
                    <KPICard
                        label="Valeur Totale Stock"
                        value={inventaire.valeur_totale}
                        icon={Box}
                        color="text-purple-600"
                        isCurrency={true}
                    />
                    <KPICard
                        label="Alertes Stock"
                        value={inventaire.alertes_rupture}
                        icon={AlertTriangle}
                        color={inventaire.alertes_rupture > 0 ? "text-red-500" : "text-slate-400"}
                        isCurrency={false}
                    />
                </div>
            </section>

            {/* SECTION 3: ANALYSE & DÉCISIONS (IA SIMPLE) */}
            <section className="space-y-4 pt-4">
                <h2 className="text-xl font-bold text-slate-800 flex items-center gap-2">
                    <Lightbulb className="w-5 h-5 text-yellow-500" /> 3. Alertes & Recommandations
                </h2>
                <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-100">
                    {decisions.length === 0 ? (
                        <p className="text-slate-500 italic">Aucune alerte spécifique pour la période en cours.</p>
                    ) : (
                        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
                            {decisions.map((dec, index) => (
                                <DecisionAlert
                                    key={index}
                                    type={dec.type}
                                    titre={dec.titre}
                                    message={dec.message}
                                />
                            ))}
                        </div>
                    )}
                </div>
            </section>

            {/* SECTION 4: STATISTIQUES DE PRISE DE DÉCISION (PERFORMANCES PAR SALLE) */}
            <section className="space-y-4 pt-4">
                <h2 className="text-xl font-bold text-slate-800 flex items-center gap-2">
                    <Activity className="w-5 h-5 text-indigo-600" /> 4. Statistiques Pédagogiques (Prise de Décision)
                </h2>
                <div className="bg-white rounded-xl shadow-sm border border-slate-100 overflow-hidden">
                    <div className="overflow-x-auto">
                        <table className="w-full text-left text-sm">
                            <thead className="bg-slate-50 text-slate-500 uppercase">
                                <tr>
                                    <th className="px-6 py-4 font-medium">Classe</th>
                                    <th className="px-6 py-4 font-medium text-center">Effectif</th>
                                    <th className="px-6 py-4 font-medium text-center">Moyenne Générale</th>
                                    <th className="px-6 py-4 font-medium text-center">Taux de Réussite</th>
                                    <th className="px-6 py-4 font-medium text-center">Statut</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-100">
                                {statistiques.decision_stats && statistiques.decision_stats.length > 0 ? (
                                    statistiques.decision_stats.map((classe) => (
                                        <tr key={classe.id} className="hover:bg-slate-50 transition-colors">
                                            <td className="px-6 py-4 font-bold text-slate-800">
                                                {classe.nom}
                                            </td>
                                            <td className="px-6 py-4 text-center text-slate-600">
                                                {classe.effectif} élèves
                                            </td>
                                            <td className="px-6 py-4 text-center">
                                                <span className={`font-bold ${classe.moyenne_generale >= 12 ? 'text-emerald-600' : classe.moyenne_generale >= 10 ? 'text-blue-600' : classe.moyenne_generale > 0 ? 'text-red-600' : 'text-slate-400'}`}>
                                                    {classe.moyenne_generale > 0 ? classe.moyenne_generale.toFixed(2) : '-'} / 20
                                                </span>
                                            </td>
                                            <td className="px-6 py-4 text-center">
                                                <div className="flex items-center justify-center gap-2">
                                                    <div className="w-24 bg-slate-200 rounded-full h-2.5">
                                                        <div className={`h-2.5 rounded-full ${classe.moyenne_generale > 0 ? (classe.taux_reussite >= 50 ? 'bg-emerald-500' : 'bg-red-500') : 'bg-slate-300'}`} style={{ width: `${classe.taux_reussite}%` }}></div>
                                                    </div>
                                                    <span className="font-medium text-slate-700">{classe.taux_reussite}%</span>
                                                </div>
                                            </td>
                                            <td className="px-6 py-4 text-center">
                                                {classe.moyenne_generale >= 12 ? (
                                                    <span className="bg-emerald-100 text-emerald-700 px-3 py-1 rounded-full text-xs font-bold">Excellent</span>
                                                ) : classe.moyenne_generale >= 10 ? (
                                                    <span className="bg-blue-100 text-blue-700 px-3 py-1 rounded-full text-xs font-bold">Passable</span>
                                                ) : classe.moyenne_generale > 0 ? (
                                                    <span className="bg-red-100 text-red-700 px-3 py-1 rounded-full text-xs font-bold">Critique</span>
                                                ) : (
                                                    <span className="bg-slate-100 text-slate-500 px-3 py-1 rounded-full text-xs font-bold">N/A</span>
                                                )}
                                            </td>
                                        </tr>
                                    ))
                                ) : (
                                    <tr>
                                        <td colSpan="5" className="px-6 py-8 text-center text-slate-500">
                                            Aucune donnée statistique disponible pour le moment.
                                        </td>
                                    </tr>
                                )}
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>

        </div>
    );
}
