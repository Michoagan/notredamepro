import React, { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "../../../components/ui/card";
import { Button } from "../../../components/ui/button";
import { Save, BookOpen, User, Loader2, Info } from 'lucide-react';
import paieService from '../../../services/paieService';

const PaieConfig = () => {
    const [classes, setClasses]       = useState([]);
    const [professeurs, setProfesseurs] = useState([]);
    const [loading, setLoading]       = useState(true);
    const [saving, setSaving]         = useState(false);
    const [message, setMessage]       = useState(null);
    const [classeForm, setClasseForm] = useState([]);
    const [activeTab, setActiveTab]   = useState('classes'); // 'classes' | 'primes'

    // État pour la configuration des primes
    const [selectedMois, setSelectedMois] = useState(new Date().getMonth() + 1);
    const [selectedAnnee, setSelectedAnnee] = useState(new Date().getFullYear());
    const [primesForm, setPrimesForm] = useState([]);
    const [loadingPrimes, setLoadingPrimes] = useState(false);

    useEffect(() => { loadData(); }, []);

    const loadData = async () => {
        setLoading(true);
        try {
            const res = await paieService.getConfiguration();
            if (res.data.success) {
                setClasses(res.data.classes || []);
                setProfesseurs(res.data.professeurs || []);
                setClasseForm((res.data.classes || []).map(c => ({
                    id: c.id,
                    nom: c.nom,
                    taux_horaire: c.taux_horaire ?? 0,
                })));
            }
        } catch (err) {
            console.error('Erreur chargement:', err);
        } finally {
            setLoading(false);
        }
    };

    const loadPrimes = async () => {
        setLoadingPrimes(true);
        try {
            const res = await paieService.getPrimesMensuelles({ mois: selectedMois, annee: selectedAnnee });
            if (res.data.success) {
                // Construire un tableau : un professeur = une prime (0 si pas encore assignée)
                const existantes = res.data.primes || [];
                const form = professeurs.map(prof => {
                    const existing = existantes.find(p => p.professeur_id === prof.id);
                    return {
                        professeur_id: prof.id,
                        nom: `${prof.first_name} ${prof.last_name}`,
                        montant: existing ? existing.montant : 0,
                        motif: existing ? existing.motif : '',
                        prime_id: existing ? existing.id : null,
                    };
                });
                setPrimesForm(form);
            }
        } catch (err) {
            console.error('Erreur chargement primes:', err);
        } finally {
            setLoadingPrimes(false);
        }
    };

    const saveTaux = async () => {
        setSaving(true);
        setMessage(null);
        try {
            const res = await paieService.saveConfiguration({
                classes: classeForm.map(c => ({ id: c.id, taux_horaire: parseFloat(c.taux_horaire) || 0 })),
            });
            if (res.data.success) {
                setMessage({ type: 'success', text: 'Taux horaires sauvegardés avec succès !' });
                loadData();
            }
        } catch (err) {
            setMessage({ type: 'error', text: 'Erreur lors de la sauvegarde.' });
        } finally {
            setSaving(false);
        }
    };

    const savePrimes = async () => {
        setSaving(true);
        setMessage(null);
        try {
            const primes = primesForm
                .filter(p => parseFloat(p.montant) > 0)
                .map(p => ({
                    professeur_id: p.professeur_id,
                    mois: selectedMois,
                    annee: selectedAnnee,
                    montant: parseFloat(p.montant),
                    motif: p.motif || 'Prime mensuelle',
                }));
            const res = await paieService.savePrimesMensuelles({ primes });
            if (res.data.success) {
                setMessage({ type: 'success', text: 'Primes enregistrées avec succès !' });
            }
        } catch (err) {
            setMessage({ type: 'error', text: 'Erreur lors de la sauvegarde des primes.' });
        } finally {
            setSaving(false);
        }
    };

    if (loading) return <div className="p-8 flex justify-center"><Loader2 className="animate-spin text-blue-600" size={32} /></div>;

    const moisNoms = ['Janvier','Février','Mars','Avril','Mai','Juin','Juillet','Août','Septembre','Octobre','Novembre','Décembre'];

    return (
        <div className="space-y-6">
            <div>
                <h1 className="text-2xl font-bold tracking-tight text-slate-900 border-l-4 border-blue-600 pl-3">
                    Configuration des Salaires
                </h1>
                <p className="text-sm text-slate-500 mt-1 pl-3">
                    Définissez les taux horaires par classe et les primes mensuelles par professeur.
                </p>
            </div>

            {/* Info Banner */}
            <div className="flex items-start gap-3 bg-blue-50 border border-blue-200 rounded-lg p-4 text-sm text-blue-800">
                <Info size={18} className="mt-0.5 shrink-0" />
                <div>
                    <strong>Règle de calcul du salaire :</strong><br/>
                    <code className="bg-blue-100 px-1 rounded">Salaire = Σ (heures par classe × taux classe) + primes du professeur</code><br/>
                    <span className="text-blue-600 text-xs mt-1 block">Les heures sont issues du Cahier de Texte (heures non encore payées).</span>
                </div>
            </div>

            {/* Tabs */}
            <div className="flex gap-1 bg-slate-100 p-1 rounded-lg w-fit">
                <button
                    onClick={() => setActiveTab('classes')}
                    className={`px-4 py-2 rounded-md text-sm font-medium transition-all flex items-center gap-2 ${activeTab === 'classes' ? 'bg-white shadow text-slate-900' : 'text-slate-500 hover:text-slate-700'}`}
                >
                    <BookOpen size={16} /> Taux Horaires (par classe)
                </button>
                <button
                    onClick={() => { setActiveTab('primes'); loadPrimes(); }}
                    className={`px-4 py-2 rounded-md text-sm font-medium transition-all flex items-center gap-2 ${activeTab === 'primes' ? 'bg-white shadow text-slate-900' : 'text-slate-500 hover:text-slate-700'}`}
                >
                    <User size={16} /> Primes Mensuelles (par professeur)
                </button>
            </div>

            {message && (
                <div className={`p-3 rounded-md text-sm ${message.type === 'success' ? 'bg-green-50 text-green-700 border border-green-200' : 'bg-red-50 text-red-700 border border-red-200'}`}>
                    {message.text}
                </div>
            )}

            {/* ─── Onglet Taux Horaires ─── */}
            {activeTab === 'classes' && (
                <Card className="shadow-sm border-slate-200">
                    <CardHeader className="border-b bg-slate-50 flex flex-row items-center justify-between">
                        <div>
                            <CardTitle className="text-lg flex items-center gap-2">
                                <BookOpen size={20} className="text-blue-600" />
                                Taux Horaires par Classe
                            </CardTitle>
                            <CardDescription className="mt-1">
                                Ces taux sont appliqués à toutes les heures effectuées dans la classe, quel que soit le professeur.
                            </CardDescription>
                        </div>
                        <Button onClick={saveTaux} disabled={saving} className="bg-blue-600 hover:bg-blue-700 text-white">
                            {saving ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : <Save className="mr-2 h-4 w-4" />}
                            Enregistrer les taux
                        </Button>
                    </CardHeader>
                    <CardContent className="p-6">
                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                            {classeForm.map((c, i) => (
                                <div key={c.id} className="bg-slate-50 p-4 rounded-xl border border-slate-200">
                                    <label className="block text-sm font-semibold text-slate-800 mb-2">{c.nom}</label>
                                    <div className="flex items-center gap-2">
                                        <input
                                            type="number"
                                            min="0"
                                            value={c.taux_horaire}
                                            onChange={(e) => {
                                                const newForm = [...classeForm];
                                                newForm[i].taux_horaire = e.target.value;
                                                setClasseForm(newForm);
                                            }}
                                            className="flex-1 p-2 border border-slate-300 rounded-md focus:ring-blue-500 focus:border-blue-500 text-right font-mono"
                                        />
                                        <span className="text-sm text-slate-500 shrink-0">FCFA/h</span>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </CardContent>
                </Card>
            )}

            {/* ─── Onglet Primes ─── */}
            {activeTab === 'primes' && (
                <Card className="shadow-sm border-slate-200">
                    <CardHeader className="border-b bg-slate-50">
                        <div className="flex items-start justify-between">
                            <div>
                                <CardTitle className="text-lg flex items-center gap-2">
                                    <User size={20} className="text-emerald-600" />
                                    Primes Mensuelles par Professeur
                                </CardTitle>
                                <CardDescription className="mt-1">
                                    Ces primes s'ajoutent aux heures calculées pour constituer le salaire net.
                                </CardDescription>
                            </div>
                            <div className="flex items-center gap-2">
                                <select
                                    value={selectedMois}
                                    onChange={(e) => setSelectedMois(Number(e.target.value))}
                                    className="p-2 border border-slate-300 rounded-md text-sm"
                                >
                                    {moisNoms.map((m, i) => <option key={i+1} value={i+1}>{m}</option>)}
                                </select>
                                <input
                                    type="number"
                                    value={selectedAnnee}
                                    onChange={(e) => setSelectedAnnee(Number(e.target.value))}
                                    className="w-24 p-2 border border-slate-300 rounded-md text-sm"
                                />
                                <Button variant="outline" onClick={loadPrimes} disabled={loadingPrimes}>
                                    {loadingPrimes ? <Loader2 className="h-4 w-4 animate-spin" /> : 'Charger'}
                                </Button>
                                <Button onClick={savePrimes} disabled={saving} className="bg-emerald-600 hover:bg-emerald-700 text-white">
                                    {saving ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : <Save className="mr-2 h-4 w-4" />}
                                    Enregistrer
                                </Button>
                            </div>
                        </div>
                    </CardHeader>
                    <CardContent className="p-6">
                        {loadingPrimes ? (
                            <div className="flex justify-center py-8"><Loader2 className="animate-spin text-emerald-600" size={28} /></div>
                        ) : primesForm.length === 0 ? (
                            <p className="text-slate-500 text-center py-8">Cliquez sur "Charger" pour afficher les professeurs.</p>
                        ) : (
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                {primesForm.map((p, i) => (
                                    <div key={p.professeur_id} className="bg-slate-50 p-4 rounded-xl border border-slate-200">
                                        <p className="font-semibold text-slate-800 mb-3">{p.nom}</p>
                                        <div className="grid grid-cols-2 gap-3">
                                            <div>
                                                <label className="block text-xs text-slate-500 mb-1">Montant prime (FCFA)</label>
                                                <input
                                                    type="number"
                                                    min="0"
                                                    value={p.montant}
                                                    onChange={(e) => {
                                                        const f = [...primesForm]; f[i].montant = e.target.value; setPrimesForm(f);
                                                    }}
                                                    className="w-full p-2 border border-slate-300 rounded-md focus:ring-emerald-500 focus:border-emerald-500 text-right font-mono"
                                                />
                                            </div>
                                            <div>
                                                <label className="block text-xs text-slate-500 mb-1">Motif</label>
                                                <input
                                                    type="text"
                                                    placeholder="Prime mensuelle..."
                                                    value={p.motif}
                                                    onChange={(e) => {
                                                        const f = [...primesForm]; f[i].motif = e.target.value; setPrimesForm(f);
                                                    }}
                                                    className="w-full p-2 border border-slate-300 rounded-md focus:ring-emerald-500 focus:border-emerald-500 text-sm"
                                                />
                                            </div>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        )}
                    </CardContent>
                </Card>
            )}
        </div>
    );
};

export default PaieConfig;
