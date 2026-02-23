import React, { useEffect, useState } from 'react';
import { getSettings, updateSettings } from '../../services/directeur';
import { Loader2, Save, Calendar } from 'lucide-react';

export default function Settings() {
    const [settings, setSettings] = useState({});
    const [loading, setLoading] = useState(true);
    const [saving, setSaving] = useState(false);
    const [message, setMessage] = useState(null);

    useEffect(() => {
        loadSettings();
    }, []);

    const loadSettings = async () => {
        try {
            const data = await getSettings();
            setSettings(data);
        } catch (error) {
            console.error(error);
        } finally {
            setLoading(false);
        }
    };

    const handleChange = (e) => {
        setSettings({ ...settings, [e.target.name]: e.target.value });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setSaving(true);
        setMessage(null);
        try {
            await updateSettings(settings);
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

                {/* Année Scolaire */}
                <div>
                    <h2 className="text-lg font-semibold text-slate-800 mb-4 flex items-center">
                        <Calendar className="w-5 h-5 mr-2 text-blue-600" />
                        Année Scolaire
                    </h2>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                            <label className="block text-sm font-medium text-slate-700 mb-1">Début de l'année</label>
                            <input
                                type="date"
                                name="annee_scolaire_debut"
                                required
                                className="w-full p-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                                value={settings.annee_scolaire_debut || ''}
                                onChange={handleChange}
                            />
                        </div>
                        <div>
                            <label className="block text-sm font-medium text-slate-700 mb-1">Fin de l'année</label>
                            <input
                                type="date"
                                name="annee_scolaire_fin"
                                required
                                className="w-full p-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                                value={settings.annee_scolaire_fin || ''}
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
                                    value={settings.trimestre_1_debut || ''}
                                    onChange={handleChange}
                                />
                            </div>
                            <div>
                                <label className="block text-xs text-slate-500 mb-1">Fin</label>
                                <input
                                    type="date"
                                    name="trimestre_1_fin"
                                    className="w-full p-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                                    value={settings.trimestre_1_fin || ''}
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
                                    value={settings.trimestre_2_debut || ''}
                                    onChange={handleChange}
                                />
                            </div>
                            <div>
                                <label className="block text-xs text-slate-500 mb-1">Fin</label>
                                <input
                                    type="date"
                                    name="trimestre_2_fin"
                                    className="w-full p-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                                    value={settings.trimestre_2_fin || ''}
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
                                    value={settings.trimestre_3_debut || ''}
                                    onChange={handleChange}
                                />
                            </div>
                            <div>
                                <label className="block text-xs text-slate-500 mb-1">Fin</label>
                                <input
                                    type="date"
                                    name="trimestre_3_fin"
                                    className="w-full p-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                                    value={settings.trimestre_3_fin || ''}
                                    onChange={handleChange}
                                />
                            </div>
                        </div>
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
