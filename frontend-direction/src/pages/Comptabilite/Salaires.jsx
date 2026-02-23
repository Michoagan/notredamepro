import React, { useEffect, useState } from 'react';
import { getSalaires, generateSalaires, payerSalaire, updateSalaire } from '../../services/comptabilite';
import { Loader2, DollarSign, Calculator, CheckCircle, AlertCircle } from 'lucide-react';

export default function Salaires() {
    const [salaires, setSalaires] = useState([]);
    const [loading, setLoading] = useState(true);
    const [generating, setGenerating] = useState(false);

    // Default to current month/year
    const today = new Date();
    const [mois, setMois] = useState(today.getMonth() + 1);
    const [annee, setAnnee] = useState(today.getFullYear());

    useEffect(() => {
        loadSalaires();
    }, [mois, annee]);

    const loadSalaires = async () => {
        setLoading(true);
        try {
            const data = await getSalaires(mois, annee);
            setSalaires(data);
        } catch (error) {
            console.error(error);
        } finally {
            setLoading(false);
        }
    };

    const handleGenerate = async () => {
        if (!window.confirm("Voulez-vous calculer les heures et générer les bulletins pour ce mois ?")) return;
        setGenerating(true);
        try {
            await generateSalaires(mois, annee);
            await loadSalaires();
        } catch (error) {
            alert("Erreur lors de la génération");
        } finally {
            setGenerating(false);
        }
    };

    const handlePayer = async (salaire) => {
        if (!window.confirm(`Confirmer le paiement de ${salaire.net_a_payer} F à ${salaire.professeur.first_name} ${salaire.professeur.last_name} ?`)) return;
        try {
            await payerSalaire(salaire.id);
            // Update local state to avoid full reload
            setSalaires(salaires.map(s => s.id === salaire.id ? { ...s, statut: 'paye', date_paiement: new Date().toISOString() } : s));
        } catch (error) {
            alert("Erreur paiement");
        }
    };

    return (
        <div className="p-8 space-y-6">
            <header className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-slate-800">Gestion des Salaires</h1>
                    <p className="text-slate-500">Calcul automatique et paiements</p>
                </div>
                <div className="flex space-x-4 items-center">
                    <select
                        value={mois}
                        onChange={e => setMois(parseInt(e.target.value))}
                        className="p-2 border rounded-lg bg-white"
                    >
                        {[...Array(12)].map((_, i) => (
                            <option key={i + 1} value={i + 1}>{new Date(0, i).toLocaleString('fr-FR', { month: 'long' })}</option>
                        ))}
                    </select>
                    <select
                        value={annee}
                        onChange={e => setAnnee(parseInt(e.target.value))}
                        className="p-2 border rounded-lg bg-white"
                    >
                        <option value={2025}>2025</option>
                        <option value={2026}>2026</option>
                    </select>
                    <button
                        onClick={handleGenerate}
                        disabled={generating}
                        className="bg-purple-600 text-white px-4 py-2 rounded-lg flex items-center hover:bg-purple-700 disabled:opacity-50"
                    >
                        {generating ? <Loader2 className="w-5 h-5 animate-spin mr-2" /> : <Calculator className="w-5 h-5 mr-2" />}
                        Calculer Heures
                    </button>
                </div>
            </header>

            <div className="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
                <table className="w-full text-left">
                    <thead className="bg-slate-50 border-b border-slate-200">
                        <tr>
                            <th className="px-6 py-4 font-semibold text-slate-600">Professeur</th>
                            <th className="px-6 py-4 font-semibold text-slate-600">Taux H.</th>
                            <th className="px-6 py-4 font-semibold text-slate-600">Heures</th>
                            <th className="px-6 py-4 font-semibold text-slate-600">Base</th>
                            <th className="px-6 py-4 font-semibold text-slate-600">Primes/Ret.</th>
                            <th className="px-6 py-4 font-semibold text-slate-600">Net à Payer</th>
                            <th className="px-6 py-4 font-semibold text-slate-600">Action</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-100">
                        {loading ? (
                            <tr><td colSpan="7" className="p-8 text-center"><Loader2 className="w-6 h-6 animate-spin mx-auto text-blue-600" /></td></tr>
                        ) : salaires.length === 0 ? (
                            <tr><td colSpan="7" className="p-8 text-center text-slate-500">Aucun salaire généré pour ce mois. Cliquez sur "Calculer".</td></tr>
                        ) : (
                            salaires.map(salaire => (
                                <tr key={salaire.id} className="hover:bg-slate-50">
                                    <td className="px-6 py-4 font-medium">
                                        {salaire.professeur?.first_name} {salaire.professeur?.last_name}
                                    </td>
                                    <td className="px-6 py-4 text-slate-500">{salaire.taux_horaire} F</td>
                                    <td className="px-6 py-4 text-slate-500 font-bold">{salaire.heures_travaillees} h</td>
                                    <td className="px-6 py-4 text-slate-500">{new Intl.NumberFormat('fr-FR').format(salaire.montant_base)} F</td>
                                    <td className="px-6 py-4 text-xs">
                                        <div className="text-green-600">+ {salaire.primes}</div>
                                        <div className="text-red-500">- {salaire.retenues}</div>
                                    </td>
                                    <td className="px-6 py-4 font-bold text-slate-800 text-lg">
                                        {new Intl.NumberFormat('fr-FR').format(salaire.net_a_payer)} F
                                    </td>
                                    <td className="px-6 py-4">
                                        {salaire.statut === 'paye' ? (
                                            <span className="flex items-center text-green-600 font-medium text-sm">
                                                <CheckCircle className="w-4 h-4 mr-1" /> Payé le {new Date(salaire.date_paiement).toLocaleDateString()}
                                            </span>
                                        ) : (
                                            <button
                                                onClick={() => handlePayer(salaire)}
                                                className="bg-emerald-600 text-white px-3 py-1.5 rounded-lg text-sm hover:bg-emerald-700 flex items-center"
                                            >
                                                <DollarSign className="w-4 h-4 mr-1" /> Payer
                                            </button>
                                        )}
                                    </td>
                                </tr>
                            ))
                        )}
                    </tbody>
                </table>
            </div>
        </div>
    );
}
