import React, { useState, useEffect } from 'react';
import { Settings, Save, AlertCircle, Calendar, Plus } from 'lucide-react';
import { getTranchesScolarite, saveTranchesScolarite } from '../../services/comptabilite';

const Tranches = () => {
    const [tranches, setTranches] = useState([]);
    const [loading, setLoading] = useState(true);
    const [saving, setSaving] = useState(false);
    const [error, setError] = useState('');
    const [success, setSuccess] = useState('');
    const [annee, setAnnee] = useState('');

    useEffect(() => {
        fetchTranches();
    }, []);

    const fetchTranches = async () => {
        setLoading(true);
        setError('');
        try {
            const data = await getTranchesScolarite();
            if (data.success) {
                if (data.tranches && data.tranches.length > 0) {
                    setTranches(data.tranches);
                } else {
                    // Default values if nothing in DB yet
                    setTranches([
                        { nom: 'Tranche 1', pourcentage: 50, date_limite: '' },
                        { nom: 'Tranche 2', pourcentage: 30, date_limite: '' },
                        { nom: 'Tranche 3', pourcentage: 20, date_limite: '' }
                    ]);
                }
                setAnnee(data.annee_scolaire);
            } else {
                setError(data.message || 'Erreur lors du chargement des données');
            }
        } catch (err) {
            setError('Impossible de joindre le serveur.');
        } finally {
            setLoading(false);
        }
    };

    const handleDateChange = (index, value) => {
        const newTranches = [...tranches];
        newTranches[index].date_limite = value;
        setTranches(newTranches);
    };

    const handleSave = async () => {
        setSaving(true);
        setError('');
        setSuccess('');

        // Basic validation
        for (let i = 0; i < tranches.length; i++) {
            if (!tranches[i].date_limite) {
                setError(`Veuillez définir une date limite pour ${tranches[i].nom}`);
                setSaving(false);
                return;
            }
        }

        try {
            const data = await saveTranchesScolarite(tranches);
            if (data.success) {
                setSuccess('Les dates limites ont été enregistrées avec succès.');
                setTranches(data.tranches); // update with saved data (including IDs)
            } else {
                setError(data.message || 'Erreur lors de la sauvegarde');
            }
        } catch (err) {
            setError(err.response?.data?.message || 'Erreur réseau lors de la sauvegarde');
        } finally {
            setSaving(false);
        }
    };

    return (
        <div className="p-6 max-w-4xl mx-auto">
            <div className="flex justify-between items-center mb-6">
                <div>
                    <h1 className="text-2xl font-bold text-slate-900">Délais de Scolarité</h1>
                    <p className="text-slate-500">Gérez les dates limites des tranches pour l'année scolaire {annee}</p>
                </div>
            </div>

            {error && (
                <div className="mb-6 bg-red-50 text-red-600 p-4 rounded-lg flex items-center space-x-3">
                    <AlertCircle className="w-5 h-5" />
                    <p>{error}</p>
                </div>
            )}

            {success && (
                <div className="mb-6 bg-emerald-50 text-emerald-600 p-4 rounded-lg flex items-center space-x-3">
                    <CheckCircle className="w-5 h-5" />
                    <p>{success}</p>
                </div>
            )}

            <div className="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
                <div className="p-6">
                    <h2 className="text-lg font-semibold text-slate-800 mb-4 flex items-center">
                        <Calendar className="w-5 h-5 mr-2 text-blue-600" />
                        Configuration des Tranches
                    </h2>

                    {loading ? (
                        <div className="flex justify-center py-8">
                            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
                        </div>
                    ) : (
                        <div className="space-y-6">
                            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                                {tranches.map((tranche, index) => (
                                    <div key={index} className="bg-slate-50 p-4 rounded-lg border border-slate-200">
                                        <div className="flex justify-between items-center mb-4">
                                            <h3 className="font-semibold text-slate-800">{tranche.nom}</h3>
                                            <span className="bg-blue-100 text-blue-700 text-xs font-bold px-2 py-1 rounded-full">
                                                {tranche.pourcentage}%
                                            </span>
                                        </div>

                                        <div>
                                            <label className="block text-sm font-medium text-slate-700 mb-1">
                                                Date Limite
                                            </label>
                                            <input
                                                type="date"
                                                value={tranche.date_limite || ''}
                                                onChange={(e) => handleDateChange(index, e.target.value)}
                                                className="w-full rounded-md border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                                            />
                                        </div>
                                    </div>
                                ))}
                            </div>

                            <div className="flex justify-end pt-4 border-t border-slate-100">
                                <button
                                    onClick={handleSave}
                                    disabled={saving}
                                    className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
                                >
                                    {saving ? (
                                        <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin mr-2" />
                                    ) : (
                                        <Save className="w-5 h-5 mr-2" />
                                    )}
                                    Enregistrer
                                </button>
                            </div>
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
};

// Also define CheckCircle locally since it wasn't imported from lucide-react in the top block:
import { CheckCircle } from 'lucide-react';

export default Tranches;
