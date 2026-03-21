import React, { useEffect, useState } from 'react';
import { getSettings, updateSettings } from '../../services/directeur';
import { Loader2, Save, Calendar } from 'lucide-react';

export default function Settings() {
    const [loading, setLoading] = useState(true);
    const [saving, setSaving] = useState(false);
    const [message, setMessage] = useState(null);
    const [formData, setFormData] = useState({
        annee_scolaire_debut: '',
        annee_scolaire_fin: '',
        current_annee_scolaire: '', // Will be populated from API or default
        current_trimestre: '',     // Will be populated from API or default
        trimestre_1_debut: '',
        trimestre_1_fin: '',
        trimestre_2_debut: '',
        trimestre_2_fin: '',
        trimestre_3_debut: '',
        trimestre_3_fin: '',
        paiement_en_ligne_actif: false
    });

    useEffect(() => {
        loadSettings();
    }, []);

    const loadSettings = async () => {
        try {
            const data = await getSettings();
            // Ensure boolean for checkbox and default for new fields if not present
            setFormData({
                ...data,
                current_annee_scolaire: data.current_annee_scolaire || '2025-2026', // Default value
                current_trimestre: data.current_trimestre || '1', // Default value
                paiement_en_ligne_actif: data.paiement_en_ligne_actif === '1' || data.paiement_en_ligne_actif === true
            });
        } catch (error) {
            console.error(error);
        } finally {
            setLoading(false);
        }
    };

    const handleChange = (e) => {
        const { name, value, type, checked } = e.target;
        setFormData(prevFormData => ({
            ...prevFormData,
            [name]: type === 'checkbox' ? checked : value
        }));
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setSaving(true);
        setMessage(null);
        try {
            // Convert boolean back to '1' or '0' for backend if needed, or send as boolean
            const dataToSend = {
                ...formData,
                paiement_en_ligne_actif: formData.paiement_en_ligne_actif ? '1' : '0'
            };
            await updateSettings(dataToSend);
            setMessage({ type: 'success', text: 'Paramètres mis à jour avec succès.' });
        } catch (error) {
            setMessage({ type: 'error', text: 'Erreur lors de la mise à jour.' });
        } finally {
            setSaving(false);
        }
    };

    if (loading) return <div className="p-12 text-center"><Loader2 className="w-8 h-8 animate-spin mx-auto text-blue-600" /></div>;

    return (
        <div className="p-8 space-y-6">
            <header>
                <h1 className="text-2xl font-bold text-slate-800">Paramètres Académiques</h1>
                <p className="text-slate-500">Définition de l'année scolaire et des périodes</p>
            </header>

            {message && (
                <div className={`p-4 rounded-lg text-sm ${message.type === 'success' ? 'bg-green-50 text-green-600' : 'bg-red-50 text-red-600'}`}>
                    {message.text}
                </div>
            )}

            <form onSubmit={handleSubmit} className="bg-white rounded-xl shadow-sm border border-slate-100 p-6 space-y-8">

                {/* Configuration Globale */}
                <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm">
                    <h2 className="text-lg font-bold text-slate-800 mb-4 flex items-center">
                        <Calendar className="w-5 h-5 mr-2 text-blue-600" />
                        Configuration Globale (Année Scolaire)
                    </h2>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6 p-4 bg-slate-50 rounded-lg border border-slate-100 mb-6">
                        <div>
                            <label className="block text-sm font-semibold text-slate-700 mb-2">Année Scolaire Courante</label>
                            <input
                                type="text"
                                className="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none"
                                placeholder="ex: 2025-2026"
                                name="current_annee_scolaire"
                                value={formData.current_annee_scolaire}
                                onChange={handleChange}
                            />
                            <p className="text-xs text-slate-500 mt-1">Utilisé globalement dans le système et sur les bulletins.</p>
                        </div>
                        <div>
                            <label className="block text-sm font-semibold text-slate-700 mb-2">Trimestre Courant</label>
                            <select
                                className="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none"
                                name="current_trimestre"
                                value={formData.current_trimestre}
                                onChange={handleChange}
                            >
                                <option value="1">1er Trimestre</option>
                                <option value="2">2ème Trimestre</option>
                                <option value="3">3ème Trimestre</option>
                            </select>
                            <p className="text-xs text-slate-500 mt-1">S'applique par défaut aux formulaires de notes etc.</p>
                        </div>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                            <label className="block text-sm font-medium text-slate-700 mb-1">Début de l'année</label>
                            <input
                                type="date"
                                name="annee_scolaire_debut"
                                className="w-full p-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                                value={formData.annee_scolaire_debut || ''}
                                onChange={handleChange}
                            />
                        </div>
                        <div>
                            <label className="block text-sm font-medium text-slate-700 mb-1">Fin de l'année</label>
                            <input
                                type="date"
                                name="annee_scolaire_fin"
                                className="w-full p-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                                value={formData.annee_scolaire_fin || ''}
                                onChange={handleChange}
                            />
                        </div>
                    </div>
                </div>

                <div className="border-t border-slate-100 pt-6"></div>

                {/* Trimestres */}
                <div>
                    <h2 className="text-lg font-semibold text-slate-800 mb-4">Trimestres</h2>

                    <div className="space-y-6">
                        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 items-end">
                            <div className="font-medium text-slate-600 mb-2 md:mb-0">1er Trimestre</div>
                            <div>
                                <label className="block text-xs text-slate-500 mb-1">Début</label>
                                <input
                                    type="date"
                                    name="trimestre_1_debut"
                                    className="w-full p-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                                    value={formData.trimestre_1_debut || ''}
                                    onChange={handleChange}
                                />
                            </div>
                            <div>
                                <label className="block text-xs text-slate-500 mb-1">Fin</label>
                                <input
                                    type="date"
                                    name="trimestre_1_fin"
                                    className="w-full p-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                                    value={formData.trimestre_1_fin || ''}
                                    onChange={handleChange}
                                />
                            </div>
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 items-end">
                            <div className="font-medium text-slate-600 mb-2 md:mb-0">2ème Trimestre</div>
                            <div>
                                <label className="block text-xs text-slate-500 mb-1">Début</label>
                                <input
                                    type="date"
                                    name="trimestre_2_debut"
                                    className="w-full p-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                                    value={formData.trimestre_2_debut || ''}
                                    onChange={handleChange}
                                />
                            </div>
                            <div>
                                <label className="block text-xs text-slate-500 mb-1">Fin</label>
                                <input
                                    type="date"
                                    name="trimestre_2_fin"
                                    className="w-full p-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                                    value={formData.trimestre_2_fin || ''}
                                    onChange={handleChange}
                                />
                            </div>
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 items-end">
                            <div className="font-medium text-slate-600 mb-2 md:mb-0">3ème Trimestre</div>
                            <div>
                                <label className="block text-xs text-slate-500 mb-1">Début</label>
                                <input
                                    type="date"
                                    name="trimestre_3_debut"
                                    className="w-full p-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                                    value={formData.trimestre_3_debut || ''}
                                    onChange={handleChange}
                                />
                            </div>
                            <div>
                                <label className="block text-xs text-slate-500 mb-1">Fin</label>
                                <input
                                    type="date"
                                    name="trimestre_3_fin"
                                    className="w-full p-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                                    value={formData.trimestre_3_fin || ''}
                                    onChange={handleChange}
                                />
                            </div>
                        </div>
                    </div>
                </div>

                <div className="border-t border-slate-100 pt-6"></div>

                {/* Paiements en ligne */}
                <div>
                    <h2 className="text-lg font-semibold text-slate-800 mb-4 flex items-center">
                        <svg className="w-5 h-5 mr-2 text-blue-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z" />
                        </svg>
                        Paiements
                    </h2>

                    <div className="flex items-center justify-between p-4 bg-slate-50 rounded-lg border border-slate-200">
                        <div>
                            <div className="font-medium text-slate-800">Paiement en ligne (Application Parents)</div>
                            <div className="text-sm text-slate-500">Autorise les parents à effectuer des paiements depuis l'application mobile.</div>
                        </div>
                        <label className="relative inline-flex items-center cursor-pointer">
                            <input
                                type="checkbox"
                                name="paiement_en_ligne_actif"
                                className="sr-only peer"
                                checked={formData.paiement_en_ligne_actif === '1' || formData.paiement_en_ligne_actif === 'true' || formData.paiement_en_ligne_actif === true}
                                onChange={handleChange}
                            />
                            <div className="w-11 h-6 bg-slate-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                        </label>
                    </div>
                </div>

                <div className="flex justify-end pt-6">
                    <button
                        type="submit"
                        disabled={saving}
                        className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 flex items-center shadow-sm"
                    >
                        {saving ? <Loader2 className="w-5 h-5 animate-spin mr-2" /> : <Save className="w-5 h-5 mr-2" />}
                        Enregistrer les configurations
                    </button>
                </div>

            </form>
        </div>
    );
}
