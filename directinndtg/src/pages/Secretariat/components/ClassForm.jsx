import React, { useState, useEffect } from 'react';
import { X, Plus, Trash2 } from 'lucide-react';
import { createClasse, updateClasse, getProfesseurs, getMatieres } from '../../../services/secretariat';
import axios from 'axios';

const ClassForm = ({ isOpen, onClose, classe, onSuccess }) => {
    // Basic Info
    const [formData, setFormData] = useState({
        nom: '',
        niveau: '',
        professeur_principal_id: '',
        cout_contribution: '',
        capacite_max: 40,
        is_active: true
    });

    // Dynamic Subjects List
    const [subjects, setSubjects] = useState([]); // Array of { nom, coefficient, professeur_id }

    // Dropdowns data
    const [professeurs, setProfesseurs] = useState([]);
    const [availableMatieres, setAvailableMatieres] = useState([]);

    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');

    useEffect(() => {
        // Fetch dependencies independently to avoid blocking if one fails
        const fetchProfesseurs = async () => {
            try {
                const response = await getProfesseurs();
                console.log("Professeurs loaded:", response);
                if (response && response.professeurs) {
                    setProfesseurs(response.professeurs);
                } else if (Array.isArray(response)) {
                    setProfesseurs(response);
                }
            } catch (err) {
                console.error("Erreur chargement professeurs", err);
            }
        };

        const fetchMatieres = async () => {
            try {
                const response = await getMatieres();
                console.log("Matieres loaded:", response);
                if (response && response.matieres) {
                    setAvailableMatieres(response.matieres);
                } else if (Array.isArray(response)) {
                    setAvailableMatieres(response);
                }
            } catch (err) {
                console.error("Erreur chargement matières", err);
            }
        };

        fetchProfesseurs();
        fetchMatieres();
    }, []);

    useEffect(() => {
        if (classe) {
            setFormData({
                nom: classe.nom || '',
                niveau: classe.niveau || '',
                professeur_principal_id: classe.professeur_principal_id || '',
                cout_contribution: classe.cout_contribution || '',
                capacite_max: classe.capacite_max || 40,
                is_active: classe.is_active !== undefined ? classe.is_active : true
            });

            // Map subjects if they exist
            if (classe.matieres) {
                const mappedSubjects = classe.matieres.map(m => ({
                    nom: m.nom, // Use name as ID since that's what API expects in 'nom'
                    coefficient: m.pivot.coefficient,
                    volume_horaire: m.pivot.volume_horaire || '',
                    professeur_id: m.pivot.professeur_id || ''
                }));
                setSubjects(mappedSubjects);
            }
        } else {
            // Default subjects for a new class (optional convenience)
            setSubjects([
                { nom: '', coefficient: 2, volume_horaire: '', professeur_id: '' }
            ]);
        }
    }, [classe]);

    const handleChange = (e) => {
        const { name, value, type, checked } = e.target;
        setFormData(prev => ({
            ...prev,
            [name]: type === 'checkbox' ? checked : value
        }));
    };

    const handleSubjectChange = (index, field, value) => {
        const newSubjects = [...subjects];
        newSubjects[index][field] = value;
        setSubjects(newSubjects);
    };

    const addSubject = () => {
        setSubjects([...subjects, { nom: '', coefficient: 2, volume_horaire: '', professeur_id: '' }]);
    };

    const removeSubject = (index) => {
        const newSubjects = [...subjects];
        newSubjects.splice(index, 1);
        setSubjects(newSubjects);
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        setError('');

        try {
            // Prepare payload
            const payload = {
                ...formData,
                matieres: subjects.filter(s => s.nom) // Filter out empty subjects
            };

            if (classe) {
                await updateClasse(classe.id, payload);
            } else {
                await createClasse(payload);
            }
            onSuccess();
            onClose();
        } catch (err) {
            console.error(err);
            setError(err.response?.data?.message || 'Une erreur est survenue.');
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
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
            <div className="bg-white rounded-xl shadow-xl w-full max-w-4xl flex flex-col max-h-[90vh]">
                <div className="flex items-center justify-between p-6 border-b border-slate-100">
                    <h2 className="text-xl font-bold text-slate-900">
                        {classe ? 'Modifier la Classe' : 'Nouvelle Classe'}
                    </h2>
                    <button onClick={onClose} className="text-slate-400 hover:text-slate-600 transition">
                        <X className="w-6 h-6" />
                    </button>
                </div>

                <form onSubmit={handleSubmit} className="flex-1 overflow-y-auto p-6 space-y-8">
                    {error && (
                        <div className="p-4 bg-red-50 text-red-600 rounded-lg text-sm whitespace-pre-wrap">
                            {error}
                        </div>
                    )}

                    {/* Basic Info */}
                    <div className="space-y-4">
                        <h3 className="font-medium text-slate-900 border-b pb-2">Informations Générales</h3>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Nom de la Classe</label>
                                <input
                                    type="text"
                                    name="nom"
                                    value={formData.nom}
                                    onChange={handleChange}
                                    required
                                    placeholder="Ex: 6ème A"
                                    className="w-full px-3 py-2 border border-slate-300 rounded-lg"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Niveau</label>
                                <select
                                    name="niveau"
                                    value={formData.niveau}
                                    onChange={handleChange}
                                    required
                                    className="w-full px-3 py-2 border border-slate-300 rounded-lg"
                                >
                                    <option value="">Sélectionner...</option>
                                    <option value="6eme">6ème</option>
                                    <option value="5eme">5ème</option>
                                    <option value="4eme">4ème</option>
                                    <option value="3eme">3ème</option>
                                    <option value="2nd">2nde</option>
                                    <option value="1ere">1ère</option>
                                    <option value="Tle">Terminale</option>
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Professeur Principal</label>
                                <select
                                    name="professeur_principal_id"
                                    value={formData.professeur_principal_id}
                                    onChange={handleChange}
                                    required
                                    className="w-full px-3 py-2 border border-slate-300 rounded-lg"
                                >
                                    <option value="">Sélectionner...</option>
                                    {professeurs.map(p => (
                                        <option key={p.id} value={p.id}>{p.last_name} {p.first_name}</option>
                                    ))}
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Contribution (FCFA)</label>
                                <input
                                    type="number"
                                    name="cout_contribution"
                                    value={formData.cout_contribution}
                                    onChange={handleChange}
                                    required
                                    className="w-full px-3 py-2 border border-slate-300 rounded-lg"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Capacité Max</label>
                                <input
                                    type="number"
                                    name="capacite_max"
                                    value={formData.capacite_max}
                                    onChange={handleChange}
                                    className="w-full px-3 py-2 border border-slate-300 rounded-lg"
                                />
                            </div>
                        </div>
                    </div>

                    {/* Subjects */}
                    <div className="space-y-4">
                        <div className="flex items-center justify-between border-b pb-2">
                            <h3 className="font-medium text-slate-900">Matières & Coefficients</h3>
                            <button
                                type="button"
                                onClick={addSubject}
                                className="text-sm text-blue-600 hover:text-blue-700 font-medium flex items-center"
                            >
                                <Plus className="w-4 h-4 mr-1" />
                                Ajouter une matière
                            </button>
                        </div>

                        <div className="space-y-3">
                            {subjects.map((subject, index) => {
                                // Filter professors who teach the selected subject
                                const selectedMatiere = availableMatieres.find(m => m.nom === subject.nom);

                                // Strict filtering: Only show professors teaching THIS subject
                                const filteredProfesseurs = selectedMatiere
                                    ? professeurs.filter(p => Number(p.matiere_id) === Number(selectedMatiere.id))
                                    : []; // If no subject selected, show no professors (or all, but user requested strict)

                                return (
                                    <div key={index} className="grid grid-cols-12 gap-2 items-end bg-slate-50 p-3 rounded-lg border border-slate-200">
                                        <div className="col-span-4">
                                            <label className="text-xs text-slate-500 block mb-1">Matière</label>
                                            <select
                                                value={subject.nom}
                                                onChange={(e) => handleSubjectChange(index, 'nom', e.target.value)}
                                                required
                                                className="w-full text-sm px-2 py-1.5 border border-slate-300 rounded"
                                            >
                                                <option value="">Choisir...</option>
                                                {availableMatieres.map(m => (
                                                    <option key={m.id} value={m.nom}>{m.nom}</option>
                                                ))}
                                            </select>
                                        </div>
                                        <div className="col-span-2">
                                            <label className="text-xs text-slate-500 block mb-1">Coef.</label>
                                            <input
                                                type="number"
                                                value={subject.coefficient}
                                                onChange={(e) => handleSubjectChange(index, 'coefficient', e.target.value)}
                                                required
                                                min="1"
                                                className="w-full text-sm px-2 py-1.5 border border-slate-300 rounded"
                                            />
                                        </div>
                                        <div className="col-span-2">
                                            <label className="text-xs text-slate-500 block mb-1">Vol. H.</label>
                                            <input
                                                type="number"
                                                value={subject.volume_horaire || ''}
                                                onChange={(e) => handleSubjectChange(index, 'volume_horaire', e.target.value)}
                                                required
                                                min="1"
                                                placeholder="H"
                                                className="w-full text-sm px-2 py-1.5 border border-slate-300 rounded"
                                            />
                                        </div>
                                        <div className="col-span-3">
                                            <label className="text-xs text-slate-500 block mb-1">Professeur</label>
                                            <select
                                                value={subject.professeur_id}
                                                onChange={(e) => handleSubjectChange(index, 'professeur_id', e.target.value)}
                                                className="w-full text-sm px-2 py-1.5 border border-slate-300 rounded"
                                            >
                                                <option value="">Non assigné</option>
                                                {filteredProfesseurs.length > 0 ? (
                                                    filteredProfesseurs.map(p => (
                                                        <option key={p.id} value={p.id}>{p.last_name} {p.first_name}</option>
                                                    ))
                                                ) : (
                                                    <option value="" disabled>Aucun professeur pour cette matière</option>
                                                )}
                                            </select>
                                        </div>
                                        <div className="col-span-1 flex justify-center pb-1">
                                            <button
                                                type="button"
                                                onClick={() => removeSubject(index)}
                                                className="text-red-500 hover:text-red-700"
                                            >
                                                <Trash2 className="w-4 h-4" />
                                            </button>
                                        </div>
                                    </div>
                                );
                            })}
                            {subjects.length === 0 && (
                                <div className="text-center text-slate-400 py-4 text-sm font-normal italic">
                                    Aucune matière ajoutée. Veuillez ajouter au moins une matière.
                                </div>
                            )}
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
                            <span>{classe ? 'Mettre à jour' : 'Créer la classe'}</span>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
};

export default ClassForm;
