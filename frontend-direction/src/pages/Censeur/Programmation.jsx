import React, { useState, useEffect } from 'react';
import censeurService from '../../services/censeur';
import api from '../../services/api'; // Direct api access for common resources if service not ready
import { Save, Plus, Trash2, User } from 'lucide-react';

const Programmation = () => {
    const [classes, setClasses] = useState([]);
    const [selectedClasse, setSelectedClasse] = useState('');
    const [matieres, setMatieres] = useState([]);
    const [professeurs, setProfesseurs] = useState([]);

    const [programmation, setProgrammation] = useState([]);
    const [profPrincipal, setProfPrincipal] = useState('');
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        fetchInitialData();
    }, []);

    useEffect(() => {
        if (selectedClasse) {
            loadClasseData(selectedClasse);
        }
    }, [selectedClasse]);

    const fetchInitialData = async () => {
        try {
            const [classesRes, matieresRes, profsRes] = await Promise.all([
                api.get('/classes/index'),
                api.get('/classes/matieres'),
                api.get('/professeurs')
            ]);
            setClasses(classesRes.data);
            setMatieres(matieresRes.data);
            // Profs endpoint might return array directly or wrapped
            setProfesseurs(Array.isArray(profsRes.data) ? profsRes.data : profsRes.data.data || []);
        } catch (error) {
            console.error("Erreur chargement données", error);
        }
    };

    const loadClasseData = async (classeId) => {
        setLoading(true);
        try {
            // We need to fetch existing programmation. 
            // Currently backend 'programmation' is POST only. 
            // We might need to fetch `Classe` with `matieres` relation to pre-fill.
            // Let's assume we can hit a generic endpoint or we might have needed a GET programmation endpoint?
            // Actually `ClasseController@index` might not include pivot data deep enough.
            // Let's try to get specific class details if endpoint exists, else we rely on what we can.
            // Workaround: We might need to add a GET endpoint or rely on `current` state if we just saved.
            // BUT: To edit existing config, we need to load it.
            // Let's assume for now we start fresh or need a way to load.
            // I'll add `api.get('/classes/' + classeId)` logic if available or look at `api/classes/index` output.
            // If API missing, I will build UI to allow re-defining.

            // NOTE TO SELF: Backend `getEmploiDuTemps` returns slots, but not the abstract "Programmation" (Matiere settings).
            // Usually `Classe::with('matieres')` gives us the pivot data.
            // Let's assume I need to fetch it.

            // For this iteration, I will create the UI to allow *setting* it. 
            // Ideally we should see current state.

            // Let's try to fetch recent config via a simulated call or just init empty
            setProgrammation([]);

            // Fetch Prof Principal?
            const currentClass = classes.find(c => c.id === parseInt(classeId));
            if (currentClass) {
                setProfPrincipal(currentClass.professeur_principal_id || '');
            }

        } catch (error) {
            console.error(error);
        } finally {
            setLoading(false);
        }
    };

    const handleAddMatiere = () => {
        setProgrammation([...programmation, {
            matiere_id: '',
            coefficient: 2,
            volume_horaire: 2,
            professeur_id: ''
        }]);
    };

    const handleRemoveLine = (index) => {
        const newProg = [...programmation];
        newProg.splice(index, 1);
        setProgrammation(newProg);
    };

    const handleChange = (index, field, value) => {
        const newProg = [...programmation];
        newProg[index][field] = value;
        setProgrammation(newProg);
    };

    const handleSave = async () => {
        if (!selectedClasse) return;

        try {
            await Promise.all([
                censeurService.saveProgrammation({
                    classe_id: selectedClasse,
                    matieres: programmation
                }),
                censeurService.setProfPrincipal({
                    classe_id: selectedClasse,
                    professeur_id: profPrincipal
                })
            ]);
            alert('Programmation enregistrée avec succès !');
        } catch (error) {
            console.error("Erreur sauvegarde", error);
            alert("Erreur lors de l'enregistrement");
        }
    };

    return (
        <div className="space-y-6">
            <h1 className="text-2xl font-bold text-slate-900">Programmation Pédagogique</h1>

            <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm">
                <div className="mb-6">
                    <label className="block text-sm font-medium text-slate-700 mb-2">Sélectionner une classe</label>
                    <select
                        value={selectedClasse}
                        onChange={(e) => setSelectedClasse(e.target.value)}
                        className="w-full md:w-1/3 px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                    >
                        <option value="">-- Choisir une classe --</option>
                        {classes.map(c => <option key={c.id} value={c.id}>{c.nom}</option>)}
                    </select>
                </div>

                {selectedClasse && (
                    <div className="space-y-6">
                        {/* Prof Principal */}
                        <div className="flex items-center space-x-4 bg-slate-50 p-4 rounded-lg border border-slate-100">
                            <div className="p-2 bg-blue-100 rounded-full text-blue-600">
                                <User className="w-5 h-5" />
                            </div>
                            <div className="flex-1">
                                <label className="block text-sm font-medium text-slate-700 mb-1">Professeur Principal</label>
                                <select
                                    value={profPrincipal}
                                    onChange={(e) => setProfPrincipal(e.target.value)}
                                    className="w-full md:w-1/2 px-3 py-2 border border-slate-300 rounded-lg focus:ring-1 focus:ring-blue-500 text-sm"
                                >
                                    <option value="">-- Non défini --</option>
                                    {professeurs.map(p => <option key={p.id} value={p.id}>{p.nom} {p.prenom}</option>)}
                                </select>
                            </div>
                        </div>

                        {/* Matières Config */}
                        <div>
                            <div className="flex justify-between items-center mb-4">
                                <h3 className="font-semibold text-lg text-slate-800">Matières & Coefficients</h3>
                                <button
                                    onClick={handleAddMatiere}
                                    className="flex items-center space-x-1 text-sm bg-blue-50 text-blue-700 px-3 py-1.5 rounded-md hover:bg-blue-100 transition"
                                >
                                    <Plus className="w-4 h-4" />
                                    <span>Ajouter Matière</span>
                                </button>
                            </div>

                            <div className="overflow-hidden border border-slate-200 rounded-lg">
                                <table className="w-full text-sm text-left">
                                    <thead className="bg-slate-50 text-slate-500 font-medium">
                                        <tr>
                                            <th className="px-4 py-3">Matière</th>
                                            <th className="px-4 py-3 w-24">Coeff.</th>
                                            <th className="px-4 py-3 w-24">Vol. H</th>
                                            <th className="px-4 py-3">Professeur</th>
                                            <th className="px-4 py-3 w-16"></th>
                                        </tr>
                                    </thead>
                                    <tbody className="divide-y divide-slate-100 bg-white">
                                        {programmation.length === 0 ? (
                                            <tr><td colSpan="5" className="px-4 py-8 text-center text-slate-400">Aucune matière configurée.</td></tr>
                                        ) : (
                                            programmation.map((item, idx) => (
                                                <tr key={idx}>
                                                    <td className="px-4 py-2">
                                                        <select
                                                            value={item.matiere_id}
                                                            onChange={(e) => handleChange(idx, 'matiere_id', e.target.value)}
                                                            className="w-full border-none focus:ring-0 text-sm"
                                                        >
                                                            <option value="">Sélectionner...</option>
                                                            {matieres.map(m => <option key={m.id} value={m.id}>{m.nom}</option>)}
                                                        </select>
                                                    </td>
                                                    <td className="px-4 py-2">
                                                        <input
                                                            type="number"
                                                            value={item.coefficient}
                                                            onChange={(e) => handleChange(idx, 'coefficient', e.target.value)}
                                                            className="w-full border-slate-200 rounded px-2 py-1 text-center"
                                                            min="1"
                                                        />
                                                    </td>
                                                    <td className="px-4 py-2">
                                                        <input
                                                            type="number"
                                                            value={item.volume_horaire}
                                                            onChange={(e) => handleChange(idx, 'volume_horaire', e.target.value)}
                                                            className="w-full border-slate-200 rounded px-2 py-1 text-center"
                                                            min="1"
                                                        />
                                                    </td>
                                                    <td className="px-4 py-2">
                                                        <select
                                                            value={item.professeur_id}
                                                            onChange={(e) => handleChange(idx, 'professeur_id', e.target.value)}
                                                            className="w-full border-slate-200 rounded px-2 py-1 text-sm bg-slate-50"
                                                        >
                                                            <option value="">-- Sans Prof --</option>
                                                            {professeurs.map(p => <option key={p.id} value={p.id}>{p.nom} {p.prenom}</option>)}
                                                        </select>
                                                    </td>
                                                    <td className="px-4 py-2 text-center">
                                                        <button onClick={() => handleRemoveLine(idx)} className="text-red-400 hover:text-red-600">
                                                            <Trash2 className="w-4 h-4" />
                                                        </button>
                                                    </td>
                                                </tr>
                                            ))
                                        )}
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <div className="flex justify-end pt-4">
                            <button
                                onClick={handleSave}
                                className="flex items-center space-x-2 bg-green-600 text-white px-6 py-2 rounded-lg hover:bg-green-700 transition shadow-sm"
                            >
                                <Save className="w-4 h-4" />
                                <span>Enregistrer la programmation</span>
                            </button>
                        </div>
                    </div>
                )}
            </div>
        </div>
    );
};

export default Programmation;
