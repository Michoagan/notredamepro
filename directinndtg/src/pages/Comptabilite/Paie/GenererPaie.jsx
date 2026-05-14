import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "../../../components/ui/card";
import { Button } from "../../../components/ui/button";
import { Calculator, Download, Loader2, Calendar } from 'lucide-react';
import paieService from '../../../services/paieService';

const GenererPaie = () => {
    const [mois, setMois] = useState(new Date().getMonth() + 1);
    const [annee, setAnnee] = useState(new Date().getFullYear());
    const [loading, setLoading] = useState(false);
    const [resultats, setResultats] = useState([]);
    const [message, setMessage] = useState(null);

    const handleGenerer = async () => {
        setLoading(true);
        setMessage(null);
        try {
            const res = await paieService.genererPaie({ mois, annee });
            if (res.data.success) {
                setResultats(res.data.paies);
                if (res.data.paies.length === 0) {
                    setMessage({ type: 'info', text: 'Aucune donnée de paie trouvée pour ce mois (Aucun cours enregistré ou taux configuré).' });
                }
            }
        } catch (error) {
            console.error("Erreur génération:", error);
            setMessage({ type: 'error', text: 'Erreur lors de la génération des paies.' });
        } finally {
            setLoading(false);
        }
    };

    const formatCurrency = (amount) => {
        return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF' }).format(amount);
    };

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <h1 className="text-2xl font-bold tracking-tight text-slate-900 border-l-4 border-green-600 pl-3">
                    Génération des Salaires Professeurs
                </h1>
            </div>

            <Card className="shadow-sm border-slate-200">
                <CardHeader className="bg-slate-50 border-b pb-4 flex flex-row items-center justify-between">
                    <div>
                        <CardTitle className="text-lg flex items-center gap-2">
                            <Calendar className="text-green-600" size={20} />
                            Période de Paie
                        </CardTitle>
                        <CardDescription>
                            Sélectionnez le mois et l'année pour calculer les salaires basés sur le cahier de texte.
                        </CardDescription>
                    </div>
                </CardHeader>
                <CardContent className="p-6">
                    <div className="flex items-end gap-6">
                        <div className="w-1/4">
                            <label className="block text-sm font-medium text-slate-700 mb-1">Mois</label>
                            <select
                                value={mois}
                                onChange={e => setMois(parseInt(e.target.value))}
                                className="w-full p-2.5 border border-slate-300 rounded-lg focus:ring-green-500 focus:border-green-500"
                            >
                                {[
                                    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
                                    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
                                ].map((m, i) => (
                                    <option key={i + 1} value={i + 1}>{m}</option>
                                ))}
                            </select>
                        </div>
                        <div className="w-1/4">
                            <label className="block text-sm font-medium text-slate-700 mb-1">Année</label>
                            <input
                                type="number"
                                value={annee}
                                onChange={e => setAnnee(parseInt(e.target.value))}
                                className="w-full p-2.5 border border-slate-300 rounded-lg focus:ring-green-500 focus:border-green-500"
                            />
                        </div>
                        <Button
                            onClick={handleGenerer}
                            disabled={loading}
                            className="bg-green-600 hover:bg-green-700 text-white h-11 px-8"
                        >
                            {loading ? <Loader2 className="mr-2 h-5 w-5 animate-spin" /> : <Calculator className="mr-2 h-5 w-5" />}
                            Calculer & Générer
                        </Button>
                    </div>

                    {message && (
                        <div className={`mt-6 p-4 rounded-lg text-sm ${message.type === 'error' ? 'bg-red-50 text-red-700 border border-red-200' : 'bg-blue-50 text-blue-700 border border-blue-200'}`}>
                            {message.text}
                        </div>
                    )}
                </CardContent>
            </Card>

            {resultats.length > 0 && (
                <Card className="shadow-sm border-slate-200 overflow-hidden">
                    <div className="overflow-x-auto">
                        <table className="w-full text-sm text-left text-slate-600">
                            <thead className="text-xs text-slate-700 uppercase bg-slate-50 border-b">
                                <tr>
                                    <th className="px-6 py-4">Professeur</th>
                                    <th className="px-6 py-4 text-center">Vol. Horaire Total</th>
                                    <th className="px-6 py-4 text-right">Rémunération Heures</th>
                                    <th className="px-6 py-4 text-right">Total Primes</th>
                                    <th className="px-6 py-4 text-right font-bold bg-slate-100">Salaire Net</th>
                                    <th className="px-6 py-4 text-center">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                {resultats.map((res, i) => (
                                    <tr key={i} className="border-b hover:bg-slate-50">
                                        <td className="px-6 py-4 font-medium text-slate-900">
                                            {res.professeur.prenom} {res.professeur.nom}
                                        </td>
                                        <td className="px-6 py-4 text-center font-semibold text-blue-600">
                                            {res.total_heures} h
                                        </td>
                                        <td className="px-6 py-4 text-right">
                                            {formatCurrency(res.montant_heures)}
                                        </td>
                                        <td className="px-6 py-4 text-right">
                                            {formatCurrency(res.montant_primes)}
                                        </td>
                                        <td className="px-6 py-4 text-right font-bold text-slate-900 bg-slate-50">
                                            {formatCurrency(res.montant_total)}
                                        </td>
                                        <td className="px-6 py-4 text-center">
                                            <Button variant="outline" size="sm" className="text-slate-600 border-slate-300">
                                                <Download className="h-4 w-4 mr-1" /> Fiche
                                            </Button>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                </Card>
            )}
        </div>
    );
};

export default GenererPaie;
