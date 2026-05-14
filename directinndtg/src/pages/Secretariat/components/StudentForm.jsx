import React, { useState, useEffect } from 'react';
import { X, Save, Upload } from 'lucide-react';
import { createEleve, updateEleve, getClasses } from '../../../services/secretariat';

const StudentForm = ({ isOpen, onClose, student, onSuccess }) => {
    const [formData, setFormData] = useState({
        matricule: '',
        nom: '',
        prenom: '',
        date_naissance: '',
        lieu_naissance: '',
        sexe: 'M',
        adresse: '',
        telephone: '',
        email: '',
        nom_parent: '',
        telephone_parent: '',
        classe_id: '',
        photo: null
    });

    const [classes, setClasses] = useState([]);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');
    const [previewUrl, setPreviewUrl] = useState(null);

    useEffect(() => {
        // Fetch classes for dropdown
        const fetchClasses = async () => {
            try {
                const data = await getClasses();
                // Depending on API structure, getClasses might return { classes: [...] } or just [...]
                // EleveController::create returns { classes: [...] }
                // ClasseController::index returns [...]
                // Let's assume the service calls classes/index which returns array or object.
                // Actually my service calls `classes/index` which usually returns array or paginated object. 
                // Let's check ClasseController::index later. For now assume array or .data
                if (Array.isArray(data)) setClasses(data);
                else if (data.classes) setClasses(data.classes);
                else if (data.data) setClasses(data.data);
            } catch (err) {
                console.error("Error fetching classes", err);
            }
        };
        fetchClasses();

        if (student) {
            setFormData({
                matricule: student.matricule || '',
                nom: student.nom || '',
                prenom: student.prenom || '',
                date_naissance: student.date_naissance ? student.date_naissance.split('T')[0] : '',
                lieu_naissance: student.lieu_naissance || '',
                sexe: student.sexe || 'M',
                adresse: student.adresse || '',
                telephone: student.telephone || '',
                email: student.email || '',
                nom_parent: student.nom_parent || '',
                telephone_parent: student.telephone_parent || '',
                classe_id: student.classe_id || '',
                photo: null
            });
            if (student.photo) {
                setPreviewUrl(`https://schoolndtg.onrender.com/storage/${student.photo}`);
            }
        }
    }, [student]);

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

            if (student) {
                await updateEleve(student.id, data);
            } else {
                await createEleve(data);
            }
            onSuccess();
            onClose();
        } catch (err) {
            console.error(err);
            setError(err.response?.data?.message || 'Une erreur est survenue.');
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
                        {student ? 'Modifier Élève' : 'Nouvel Élève'}
                    </h2>
                    <button onClick={onClose} className="text-slate-400 hover:text-slate-600 transition">
                        <X className="w-6 h-6" />
                    </button>
                </div>

                <form onSubmit={handleSubmit} className="flex-1 overflow-y-auto p-6 space-y-6">
                    {error && (
                        <div className="p-4 bg-red-50 text-red-600 rounded-lg text-sm">
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
                                <div className="text-xs text-center mt-2 text-slate-500">Photo (Optionnel)</div>
                            </div>
                        </div>

                        {/* Identification */}
                        <div className="space-y-4">
                            <h3 className="font-medium text-slate-900 border-b pb-2">Identification</h3>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Matricule</label>
                                <input
                                    type="text"
                                    name="matricule"
                                    value={formData.matricule}
                                    onChange={handleChange}
                                    placeholder="Ex: 2024001"
                                    required
                                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none"
                                />
                            </div>

                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Nom</label>
                                    <input
                                        type="text"
                                        name="nom"
                                        value={formData.nom}
                                        onChange={handleChange}
                                        required
                                        className="w-full px-3 py-2 border border-slate-300 rounded-lg"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Prénom</label>
                                    <input
                                        type="text"
                                        name="prenom"
                                        value={formData.prenom}
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
                                        name="sexe"
                                        value={formData.sexe}
                                        onChange={handleChange}
                                        className="w-full px-3 py-2 border border-slate-300 rounded-lg"
                                    >
                                        <option value="M">Masculin</option>
                                        <option value="F">Féminin</option>
                                    </select>
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Classe</label>
                                    <select
                                        name="classe_id"
                                        value={formData.classe_id}
                                        onChange={handleChange}
                                        required
                                        className="w-full px-3 py-2 border border-slate-300 rounded-lg"
                                    >
                                        <option value="">Sélectionner...</option>
                                        {classes.map(c => (
                                            <option key={c.id} value={c.id}>{c.nom}</option>
                                        ))}
                                    </select>
                                </div>
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Date de Naissance</label>
                                <input
                                    type="date"
                                    name="date_naissance"
                                    value={formData.date_naissance}
                                    onChange={handleChange}
                                    required
                                    className="w-full px-3 py-2 border border-slate-300 rounded-lg"
                                />
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Lieu de Naissance</label>
                                <input
                                    type="text"
                                    name="lieu_naissance"
                                    value={formData.lieu_naissance}
                                    onChange={handleChange}
                                    required
                                    className="w-full px-3 py-2 border border-slate-300 rounded-lg"
                                />
                            </div>
                        </div>

                        {/* Parents & Contact */}
                        <div className="space-y-4">
                            <h3 className="font-medium text-slate-900 border-b pb-2">Parents & Contact</h3>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Nom du Parent/Tuteur</label>
                                <input
                                    type="text"
                                    name="nom_parent"
                                    value={formData.nom_parent}
                                    onChange={handleChange}
                                    required
                                    className="w-full px-3 py-2 border border-slate-300 rounded-lg"
                                />
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Téléphone Parent</label>
                                <input
                                    type="tel"
                                    name="telephone_parent"
                                    value={formData.telephone_parent}
                                    onChange={handleChange}
                                    required
                                    className="w-full px-3 py-2 border border-slate-300 rounded-lg"
                                />
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Adresse</label>
                                <textarea
                                    name="adresse"
                                    value={formData.adresse}
                                    onChange={handleChange}
                                    rows="2"
                                    className="w-full px-3 py-2 border border-slate-300 rounded-lg"
                                ></textarea>
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Email (Optionnel)</label>
                                <input
                                    type="email"
                                    name="email"
                                    value={formData.email}
                                    onChange={handleChange}
                                    className="w-full px-3 py-2 border border-slate-300 rounded-lg"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Téléphone Élève (opt.)</label>
                                <input
                                    type="tel"
                                    name="telephone"
                                    value={formData.telephone}
                                    onChange={handleChange}
                                    className="w-full px-3 py-2 border border-slate-300 rounded-lg"
                                />
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
                            <span>{student ? 'Mettre à jour' : 'Enregistrer'}</span>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
};

export default StudentForm;
