import React, { useState, useEffect } from 'react';
import { X, Upload } from 'lucide-react';
import { createProfesseur, updateProfesseur } from '../../../services/secretariat';

const ProfesseurForm = ({ isOpen, onClose, professeur, onSuccess }) => {
    const [formData, setFormData] = useState({
        last_name: '',
        first_name: '',
        gender: 'M',
        birth_date: '',
        email: '',
        phone: '',
        matiere_id: '',
        photo: null
    });

    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');
    const [previewUrl, setPreviewUrl] = useState(null);

    useEffect(() => {
        if (professeur) {
            setFormData({
                last_name: professeur.last_name || '',
                first_name: professeur.first_name || '',
                gender: professeur.gender || 'M',
                birth_date: professeur.birth_date ? professeur.birth_date.split('T')[0] : '', // Adjust date format if needed
                email: professeur.email || '',
                phone: professeur.phone || '',
                matiere: null,
                matiere_id: professeur.matiere_id || '',
                photo: null
            });
            if (professeur.photo) {
                setPreviewUrl(`https://schoolndtg.onrender.com/storage/professeurs/${professeur.photo}`);
            }
        }
    }, [professeur]);

    const [matieres, setMatieres] = useState([]);

    useEffect(() => {
        const fetchMatieres = async () => {
            try {
                const response = await import('../../../services/secretariat').then(module => module.getMatieres());
                if (response.success) {
                    setMatieres(response.matieres);
                }
            } catch (err) {
                console.error("Erreur chargement matières", err);
            }
        };
        fetchMatieres();
    }, []);

    const handleChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => ({ ...prev, [name]: value }));
    };

    const handleFileChange = (e) => {
        const file = e.target.files[0];
        if (file) {
            setFormData(prev => ({ ...prev, photo: file }));
            setPreviewUrl(URL.createObjectURL(file));
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        setError('');

        try {
            const data = new FormData();
            Object.keys(formData).forEach(key => {
                if (formData[key] !== null) {
                    data.append(key, formData[key]);
                }
            });

            if (professeur) {
                await updateProfesseur(professeur.id, data);
            } else {
                await createProfesseur(data);
            }
            onSuccess();
            onClose();
        } catch (err) {
            console.error(err);
            setError(err.response?.data?.message || 'Une erreur est survenue.');
            // Display validation errors if any
            if (err.response?.data?.errors) {
                const errors = Object.values(err.response.data.errors).flat().join('\n');
                setError(errors);
            }
        } finally {
            setLoading(false);
        }
    };

    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4 overflow-y-auto">
            <div className="bg-white rounded-xl shadow-xl w-full max-w-2xl flex flex-col max-h-[90vh]">
                <div className="flex items-center justify-between p-6 border-b border-slate-100">
                    <h2 className="text-xl font-bold text-slate-900">
                        {professeur ? 'Modifier Professeur' : 'Nouveau Professeur'}
                    </h2>
                    <button onClick={onClose} className="text-slate-400 hover:text-slate-600 transition">
                        <X className="w-6 h-6" />
                    </button>
                </div>

                <form onSubmit={handleSubmit} className="flex-1 overflow-y-auto p-6 space-y-6">
                    {error && (
                        <div className="p-4 bg-red-50 text-red-600 rounded-lg text-sm whitespace-pre-wrap">
                            {error}
                        </div>
                    )}

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                        {/* Photo Upload */}
                        <div className="col-span-full flex justify-center">
                            <div className="relative group cursor-pointer">
                                <div className="w-24 h-24 rounded-full bg-slate-100 overflow-hidden border-2 border-slate-200 flex items-center justify-center">
                                    {previewUrl ? (
                                        <img src={previewUrl} alt="Preview" className="w-full h-full object-cover" />
                                    ) : (
                                        <Upload className="w-8 h-8 text-slate-400" />
                                    )}
                                </div>
                                <input
                                    type="file"
                                    accept="image/*"
                                    onChange={handleFileChange}
                                    className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                                />
                                <div className="text-xs text-center mt-2 text-slate-500">Photo (Obligatoire)</div>
                            </div>
                        </div>

                        {/* Identification */}
                        <div className="space-y-4 col-span-full md:col-span-2">
                            <h3 className="font-medium text-slate-900 border-b pb-2">Informations Personnelles</h3>

                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Nom</label>
                                    <input
                                        type="text"
                                        name="last_name"
                                        value={formData.last_name}
                                        onChange={handleChange}
                                        required
                                        className="w-full px-3 py-2 border border-slate-300 rounded-lg"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Prénom</label>
                                    <input
                                        type="text"
                                        name="first_name"
                                        value={formData.first_name}
                                        onChange={handleChange}
                                        required
                                        className="w-full px-3 py-2 border border-slate-300 rounded-lg"
                                    />
                                </div>
                            </div>

                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Sexe</label>
                                    <select
                                        name="gender"
                                        value={formData.gender}
                                        onChange={handleChange}
                                        className="w-full px-3 py-2 border border-slate-300 rounded-lg"
                                    >
                                        <option value="M">Masculin</option>
                                        <option value="F">Féminin</option>
                                    </select>
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Date de Naissance</label>
                                    <input
                                        type="date"
                                        name="birth_date"
                                        value={formData.birth_date}
                                        onChange={handleChange}
                                        required
                                        className="w-full px-3 py-2 border border-slate-300 rounded-lg"
                                    />
                                </div>
                            </div>
                        </div>

                        <div className="space-y-4 col-span-full md:col-span-2">
                            <h3 className="font-medium text-slate-900 border-b pb-2">Contact & Professionnel</h3>

                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Email</label>
                                    <input
                                        type="email"
                                        name="email"
                                        value={formData.email}
                                        onChange={handleChange}
                                        required
                                        className="w-full px-3 py-2 border border-slate-300 rounded-lg"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Téléphone</label>
                                    <input
                                        type="tel"
                                        name="phone"
                                        value={formData.phone}
                                        onChange={handleChange}
                                        required
                                        className="w-full px-3 py-2 border border-slate-300 rounded-lg"
                                    />
                                </div>
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Matière Principale</label>
                                <select
                                    name="matiere_id"
                                    value={formData.matiere_id}
                                    onChange={handleChange}
                                    required
                                    className="w-full px-3 py-2 border border-slate-300 rounded-lg"
                                >
                                    <option value="">Sélectionner une matière</option>
                                    {matieres.map(m => (
                                        <option key={m.id} value={m.id}>{m.nom}</option>
                                    ))}
                                </select>
                            </div>
                        </div>
                    </div>

                    <div className="flex justify-end space-x-3 pt-6 border-t border-slate-100">
                        <button
                            type="button"
                            onClick={onClose}
                            className="px-6 py-2 border border-slate-300 rounded-lg text-slate-700 hover:bg-slate-50 transition"
                        >
                            Annuler
                        </button>
                        <button
                            type="submit"
                            disabled={loading}
                            className="flex items-center space-x-2 px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition shadow-sm disabled:opacity-50"
                        >
                            {loading && <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />}
                            <span>{professeur ? 'Mettre à jour' : 'Enregistrer'}</span>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
};

export default ProfesseurForm;
