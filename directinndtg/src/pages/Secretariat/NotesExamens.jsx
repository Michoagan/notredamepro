import React, { useState, useEffect } from 'react';
import axios from 'axios';
import {
    CheckCircle, XCircle, AlertCircle, Save, BookOpen, User,
    Filter, Search, Calculator
} from 'lucide-react';
import api from '../../services/api';

const NotesExamens = () => {
    const [classes, setClasses] = useState([]);
    const [matieres, setMatieres] = useState([]);

    // Filtres Actuels
    const [selectedClasse, setSelectedClasse] = useState('');
    const [typeExamen, setTypeExamen] = useState('Examen Blanc');
    const [selectedMatiere, setSelectedMatiere] = useState('');
    const [anneeScolaire, setAnneeScolaire] = useState('2023-2024'); // Ex: format textuel ou généré auto

    // Données des Eleves
    const [eleves, setEleves] = useState([]);

    // Etats de Chargement & Messages
    const [loading, setLoading] = useState(false);
    const [saving, setSaving] = useState(false);
    const [error, setError] = useState(null);
    const [success, setSuccess] = useState(null);

    const token = localStorage.getItem('token');

    // Initialiser Classes & Matieres
    useEffect(() => {
        const fetchInitialData = async () => {
            try {
                const headers = { Authorization: `Bearer ${token}` };
                const resClasses = await axios.get('${import.meta.env.VITE_API_BASE_URL}/api/classes/index', { headers }); // Or wherever classes are fetched
                const resMatieres = await axios.get('${import.meta.env.VITE_API_BASE_URL}/api/classes/matieres', { headers });

                // Assuming standard formats based on previous patterns
                setClasses(resClasses.data.data || resClasses.data || []);
                setMatieres(resMatieres.data.data || resMatieres.data || []);
            } catch (err) {
                console.error("Erreur chargement données de base", err);
            }
        };
        fetchInitialData();
    }, []);

    // Charger les élèves selon les filtres
    const fetchEleves = async () => {
        if (!selectedClasse) {
            setError("Veuillez sélectionner une classe.");
            return;
        }

        // Si Examen Blanc et pas de matière choisie, on alerte (Moyenne ou Matière ?)
        // Le Backend accepte matiere_id null pour Moyenne Globale.

        setLoading(true);
        setError(null);
        setSuccess(null);

        try {
            const headers = { Authorization: `Bearer ${token}` };
            const params = {
                classe_id: selectedClasse,
                type_examen: typeExamen,
                annee_scolaire: anneeScolaire,
                ...(selectedMatiere && { matiere_id: selectedMatiere })
            };

            const response = await axios.get('${import.meta.env.VITE_API_BASE_URL}/api/secretaire/notes-examens', {
                headers, params
            });

            // Expected format: [{eleve_id, nom_complet, matricule, valeur}]
            setEleves(response.data);

        } catch (err) {
            setError(err.response?.data?.message || "Erreur de récupération des élèves");
        } finally {
            setLoading(false);
        }
    };

    // Gérer la modification locale d'une note
    const handleNoteChange = (eleveId, val) => {
        setEleves(eleves.map(el => {
            if (el.eleve_id === eleveId) {
                return { ...el, valeur: val };
            }
            return el;
        }));
    };

    // Sauvegarder toutes les notes en lot
    const handleSave = async () => {
        if (eleves.length === 0) return;

        setSaving(true);
        setError(null);
        setSuccess(null);

        try {
            const payload = {
                classe_id: selectedClasse,
                type_examen: typeExamen,
                annee_scolaire: anneeScolaire,
                matiere_id: selectedMatiere || null,
                notes: eleves.map(e => ({
                    eleve_id: e.eleve_id,
                    valeur: e.valeur === '' ? null : e.valeur
                }))
            };

            const headers = { Authorization: `Bearer ${token}` };

            const response = await axios.post('${import.meta.env.VITE_API_BASE_URL}/api/secretaire/notes-examens', payload, { headers });

            setSuccess(`${response.data.count} notes enregistrées avec succès !`);

            // Retirer le message de succès après 3s
            setTimeout(() => setSuccess(null), 3000);

        } catch (err) {
            setError(err.response?.data?.message || "Erreur lors de la sauvegarde.");
        } finally {
            setSaving(false);
        }
    };

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-slate-800 flex items-center gap-2">
                        <Calculator className="text-blue-600" />
                        Notes d'Examens
                    </h1>
                    <p className="text-slate-500">Saisie des Examens Blancs et Examens Nationaux</p>
                </div>

                {eleves.length > 0 && (
                    <button
                        onClick={handleSave}
                        disabled={saving}
                        className="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-5 py-2.5 rounded-lg font-medium transition disabled:bg-blue-300"
                    >
                        {saving ? (
                            <><div className="animate-spin h-5 w-5 border-2 border-white border-t-transparent rounded-full"></div> Enregistrement...</>
                        ) : (
                            <><Save size={20} /> Enregistrer la Grille</>
                        )}
                    </button>
                )}
            </div>

            {/* PANNEAU DE FILTRES */}
            <div className="bg-white p-5 rounded-xl shadow-sm border border-slate-100">
                <h2 className="text-sm font-bold text-slate-800 uppercase tracking-wider mb-4 flex items-center gap-2">
                    <Filter size={16} /> Panneau de Configuration
                </h2>

                <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                    {/* Examen Type */}
                    <div>
                        <label className="block text-sm font-medium text-slate-700 mb-1">Type d'Examen</label>
                        <select
                            className="w-full border rounded-lg p-2.5 focus:ring-2 focus:ring-blue-500 outline-none text-sm bg-slate-50"
                            value={typeExamen}
                            onChange={(e) => setTypeExamen(e.target.value)}
                        >
                            <option value="Examen Blanc">Examen Blanc</option>
                            <option value="Examen National">Examen National (Moyenne)</option>
                        </select>
                    </div>

                    {/* Classe */}
                    <div>
                        <label className="block text-sm font-medium text-slate-700 mb-1">Classe</label>
                        <select
                            className="w-full border rounded-lg p-2.5 focus:ring-2 focus:ring-blue-500 outline-none text-sm bg-slate-50"
                            value={selectedClasse}
                            onChange={(e) => setSelectedClasse(e.target.value)}
                        >
                            <option value="">-- Sélectionner --</option>
                            {classes.map(c => <option key={c.id} value={c.id}>{c.nom}</option>)}
                        </select>
                    </div>

                    {/* Matiere (Optionnelle) */}
                    <div>
                        <label className="block text-sm font-medium text-slate-700 mb-1">
                            Matière <span className="text-xs text-slate-400 font-normal">(Vide = Moyenne G.)</span>
                        </label>
                        <select
                            className="w-full border rounded-lg p-2.5 focus:ring-2 focus:ring-blue-500 outline-none text-sm bg-slate-50"
                            value={selectedMatiere}
                            onChange={(e) => setSelectedMatiere(e.target.value)}
                            disabled={typeExamen === 'Examen National'} // Generalement on bloque sur "National" si on veut juste la MG
                        >
                            <option value="">-- Moyenne Générale --</option>
                            {matieres.map(m => <option key={m.id} value={m.id}>{m.nom}</option>)}
                        </select>
                    </div>

                    {/* Bouton de Charge */}
                    <div className="flex items-end">
                        <button
                            onClick={fetchEleves}
                            disabled={loading || !selectedClasse}
                            className="w-full bg-slate-800 hover:bg-slate-900 text-white p-2.5 rounded-lg text-sm font-medium transition flex items-center justify-center gap-2 disabled:bg-slate-300"
                        >
                            {loading ? 'Chargement...' : <><Search size={16} /> Afficher les élèves</>}
                        </button>
                    </div>
                </div>
            </div>

            {/* MESSAGES */}
            {error && (
                <div className="bg-red-50 text-red-600 p-4 rounded-lg flex items-center gap-2 text-sm border border-red-100">
                    <AlertCircle size={18} /> {error}
                </div>
            )}

            {success && (
                <div className="bg-green-50 text-green-700 p-4 rounded-lg flex items-center gap-2 text-sm border border-green-200 shadow-sm">
                    <CheckCircle size={18} /> {success}
                </div>
            )}

            {/* TABLEAU DE SAISIE */}
            {eleves.length > 0 && (
                <div className="bg-white rounded-xl shadow-sm border border-slate-100 overflow-hidden">
                    <div className="p-4 border-b border-slate-100 bg-slate-50 flex justify-between items-center">
                        <h3 className="font-semibold text-slate-700 flex items-center gap-2">
                            <User size={18} className="text-blue-600" />
                            Grille de saisie ({eleves.length} élèves)
                        </h3>
                        <span className="text-xs font-medium px-3 py-1 bg-blue-100 text-blue-700 rounded-full">
                            {typeExamen} - {selectedMatiere ? 'Matière spécifique' : 'Moyenne Générale'}
                        </span>
                    </div>

                    <div className="overflow-x-auto">
                        <table className="w-full text-left border-collapse">
                            <thead>
                                <tr className="bg-slate-50 text-slate-500 text-xs uppercase tracking-wider">
                                    <th className="p-4 border-b w-16 text-center">N°</th>
                                    <th className="p-4 border-b">Élève (Nom, Postnom, Prénom)</th>
                                    <th className="p-4 border-b w-40 text-center">Matricule</th>
                                    <th className="p-4 border-b w-48 text-center">Note /20</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-100">
                                {eleves.map((eleve, index) => (
                                    <tr key={eleve.eleve_id} className="hover:bg-slate-50 transition-colors">
                                        <td className="p-4 text-center text-sm text-slate-400 font-medium">
                                            {index + 1}
                                        </td>
                                        <td className="p-4">
                                            <div className="font-medium text-slate-800">{eleve.nom_complet}</div>
                                        </td>
                                        <td className="p-4 text-center">
                                            <span className="text-xs font-mono bg-slate-100 text-slate-600 px-2 py-1 rounded">
                                                {eleve.matricule}
                                            </span>
                                        </td>
                                        <td className="p-4">
                                            <input
                                                type="number"
                                                min="0"
                                                max="20"
                                                step="0.01"
                                                className="w-full text-center border border-slate-300 rounded-lg p-2 focus:ring-2 focus:ring-blue-500 outline-none font-bold text-slate-700 placeholder:font-normal placeholder:text-slate-300"
                                                placeholder="Vide"
                                                value={eleve.valeur !== null ? eleve.valeur : ''}
                                                onChange={(e) => handleNoteChange(eleve.eleve_id, e.target.value)}
                                            />
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                </div>
            )}

            {!loading && eleves.length === 0 && selectedClasse && !error && (
                <div className="text-center p-12 bg-white rounded-xl border border-slate-100 text-slate-500 shadow-sm">
                    <BookOpen size={40} className="mx-auto text-slate-200 mb-4" />
                    <p className="font-medium">Aucun élève trouvé pour cette classe ou recherche vide.</p>
                    <p className="text-sm mt-1">Sélectionnez une classe et cliquez sur "Afficher les élèves".</p>
                </div>
            )}

        </div>
    );
};

export default NotesExamens;
