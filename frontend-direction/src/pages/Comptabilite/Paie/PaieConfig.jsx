import React, { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "../../../components/ui/card";
import { Button } from "../../../components/ui/button";
import { Save, User, Settings2, Loader2, Search } from 'lucide-react';
import paieService from '../../../services/paieService';

const PaieConfig = () => {
    const [professeurs, setProfesseurs] = useState([]);
    const [loading, setLoading] = useState(true);
    const [selectedProf, setSelectedProf] = useState(null);
    const [formData, setFormData] = useState([]);
    const [search, setSearch] = useState('');
    const [saving, setSaving] = useState(false);
    const [message, setMessage] = useState(null);

    useEffect(() => {
        loadData();
    }, []);

    const loadData = async () => {
        setLoading(true);
        try {
            const res = await paieService.getConfiguration();
            if (res.data.success) {
                setProfesseurs(res.data.professeurs);
            }
        } catch (error) {
            console.error("Erreur chargement:", error);
        } finally {
            setLoading(false);
        }
    };

    const handleSelectProf = (prof) => {
        setSelectedProf(prof);

        // Initialize form data with existing rates or defaults
        const initialForm = [];

        // Global / Principal Bonus rule (classe_id = null)
        const globalRate = prof.taux_horaires?.find(t => t.classe_id === null) || { taux_horaire: 0, prime_mensuelle: 0 };
        initialForm.push({
            classe_id: null,
            classe_nom: 'Paramètres Globaux (Prime Fixe / Prof Principal)',
            taux_horaire: globalRate.taux_horaire,
            prime_mensuelle: globalRate.prime_mensuelle
        });

        // Rules per class the prof teaches
        if (prof.classes && prof.classes.length > 0) {
            prof.classes.forEach(c => {
                const existing = prof.taux_horaires?.find(t => t.classe_id === c.id);
                initialForm.push({
                    classe_id: c.id,
                    classe_nom: c.nom,
                    taux_horaire: existing ? existing.taux_horaire : 0,
                    prime_mensuelle: existing ? existing.prime_mensuelle : 0
                });
            });
        }

        setFormData(initialForm);
        setMessage(null);
    };

    const handleChange = (index, field, value) => {
        const newForm = [...formData];
        newForm[index][field] = value;
        setFormData(newForm);
    };

    const handleSave = async () => {
        setSaving(true);
        setMessage(null);
        try {
            const dataToSave = {
                professeur_id: selectedProf.id,
                taux: formData.map(f => ({
                    classe_id: f.classe_id,
                    taux_horaire: parseFloat(f.taux_horaire) || 0,
                    prime_mensuelle: parseFloat(f.prime_mensuelle) || 0
                }))
            };

            const res = await paieService.saveConfiguration(dataToSave);
            if (res.data.success) {
                setMessage({ type: 'success', text: 'Configuration sauvegardée avec succès !' });
                loadData(); // Reload to get updated data
            }
        } catch (error) {
            console.error(error);
            setMessage({ type: 'error', text: 'Erreur lors de la sauvegarde.' });
        } finally {
            setSaving(false);
        }
    };

    const filteredProfs = professeurs.filter(p =>
        (p.prenom + ' ' + p.nom).toLowerCase().includes(search.toLowerCase())
    );

    if (loading) return <div className="p-8 flex justify-center"><Loader2 className="animate-spin text-blue-600" size={32} /></div>;

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <h1 className="text-2xl font-bold tracking-tight text-slate-900 border-l-4 border-blue-600 pl-3">
                    Configuration des Salaires
                </h1>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                {/* Professeurs List */}
                <Card className="md:col-span-1 shadow-sm border-slate-200">
                    <CardHeader className="bg-slate-50 border-b pb-4">
                        <CardTitle className="text-lg">Professeurs</CardTitle>
                        <div className="relative mt-2">
                            <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-slate-400" />
                            <input
                                type="text"
                                placeholder="Rechercher..."
                                className="w-full pl-9 pr-3 py-2 bg-white border border-slate-200 rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                                value={search}
                                onChange={(e) => setSearch(e.target.value)}
                            />
                        </div>
                    </CardHeader>
                    <div className="max-h-[600px] overflow-y-auto p-2">
                        {filteredProfs.map(prof => (
                            <div
                                key={prof.id}
                                onClick={() => handleSelectProf(prof)}
                                className={`p-3 mb-2 rounded-lg cursor-pointer border transition-all ${selectedProf?.id === prof.id ? 'bg-blue-50 border-blue-200 shadow-sm' : 'border-transparent hover:bg-slate-50'}`}
                            >
                                <div className="flex items-center space-x-3">
                                    <div className={`p-2 rounded-full ${selectedProf?.id === prof.id ? 'bg-blue-100 text-blue-600' : 'bg-slate-100 text-slate-500'}`}>
                                        <User size={18} />
                                    </div>
                                    <div>
                                        <p className="font-medium text-slate-900">{prof.prenom} {prof.nom}</p>
                                        <p className="text-xs text-slate-500">
                                            {prof.taux_horaires?.length > 0 ? 'Configuré' : 'Non configuré'}
                                        </p>
                                    </div>
                                </div>
                            </div>
                        ))}
                    </div>
                </Card>

                {/* Configuration Panel */}
                <Card className="md:col-span-2 shadow-sm border-slate-200">
                    {selectedProf ? (
                        <>
                            <CardHeader className="border-b bg-white">
                                <div className="flex justify-between items-center">
                                    <div>
                                        <CardTitle className="text-xl flex items-center gap-2">
                                            <Settings2 className="text-blue-600" size={24} />
                                            {selectedProf.prenom} {selectedProf.nom}
                                        </CardTitle>
                                        <CardDescription className="mt-1">
                                            Définissez les taux horaires et les primes pour ce professeur.
                                        </CardDescription>
                                    </div>
                                    <Button onClick={handleSave} disabled={saving} className="bg-blue-600 hover:bg-blue-700 text-white">
                                        {saving ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : <Save className="mr-2 h-4 w-4" />}
                                        Enregistrer
                                    </Button>
                                </div>
                                {message && (
                                    <div className={`mt-4 p-3 rounded-md text-sm ${message.type === 'success' ? 'bg-green-50 text-green-700 border border-green-200' : 'bg-red-50 text-red-700 border border-red-200'}`}>
                                        {message.text}
                                    </div>
                                )}
                            </CardHeader>
                            <CardContent className="p-6">
                                <div className="space-y-6">
                                    {formData.map((item, index) => (
                                        <div key={index} className="bg-slate-50 p-4 rounded-xl border border-slate-100">
                                            <h3 className="font-medium text-slate-800 mb-4 pb-2 border-b flex items-center justify-between">
                                                {item.classe_nom}
                                                {item.classe_id === null && <span className="text-xs bg-purple-100 text-purple-700 px-2 py-1 rounded-full font-semibold">Toutes classes / Fixe</span>}
                                            </h3>

                                            <div className="grid grid-cols-2 gap-6">
                                                <div>
                                                    <label className="block text-sm font-medium text-slate-700 mb-1">
                                                        {item.classe_id === null ? "Taux Horaire par Défaut (FCFA/h)" : "Taux Horaire (FCFA/h)"}
                                                    </label>
                                                    <input
                                                        type="number"
                                                        value={item.taux_horaire}
                                                        onChange={(e) => handleChange(index, 'taux_horaire', e.target.value)}
                                                        className="w-full p-2 border border-slate-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                                                    />
                                                </div>
                                                <div>
                                                    <label className="block text-sm font-medium text-slate-700 mb-1">
                                                        {item.classe_id === null ? "Prime Mensuelle Fixe (FCFA)" : "Prime pour cette classe (FCFA)"}
                                                    </label>
                                                    <input
                                                        type="number"
                                                        value={item.prime_mensuelle}
                                                        onChange={(e) => handleChange(index, 'prime_mensuelle', e.target.value)}
                                                        className="w-full p-2 border border-slate-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                                                    />
                                                </div>
                                            </div>
                                            {item.classe_id === null && (
                                                <p className="text-xs text-slate-500 mt-2">
                                                    * Utilisez ce champ pour les primes fixes (ex: Professeur Principal) ou un taux horaire global si vous ne voulez pas détailler par classe.
                                                </p>
                                            )}
                                        </div>
                                    ))}
                                </div>
                            </CardContent>
                        </>
                    ) : (
                        <div className="h-full flex flex-col items-center justify-center p-12 text-slate-400">
                            <User size={64} className="mb-4 opacity-20" />
                            <p className="text-lg font-medium">Sélectionnez un professeur</p>
                            <p className="text-sm">Cliquez sur un professeur dans la liste de gauche pour configurer son salaire.</p>
                        </div>
                    )}
                </Card>
            </div>
        </div>
    );
};

export default PaieConfig;
