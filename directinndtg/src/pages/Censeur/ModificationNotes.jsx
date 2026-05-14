import React, { useState, useEffect } from 'react';
import { getClasses, getMatieres } from '../../services/secretariat';
import censeurService from '../../services/censeur';
import settingsService from '../../services/settings';
import { Save, CheckCircle, AlertCircle } from 'lucide-react';

const ModificationNotes = () => {
    const [classes, setClasses] = useState([]);
    const [matieres, setMatieres] = useState([]);

    const [filters, setFilters] = useState({
        classe_id: '',
        matiere_id: '',
        trimestre: '1',
        type_note: 'interro',
        numero: '1',
    });

    const [eleves, setEleves] = useState([]);
    const [notesExistantes, setNotesExistantes] = useState({});
    const [newNotes, setNewNotes] = useState({});
    const [loading, setLoading] = useState(false);
    const [saving, setSaving] = useState(false);
    const [feedback, setFeedback] = useState(null);

    useEffect(() => {
        const loadRefs = async () => {
            try {
                const [classesRes, matieresRes, currentTrim] = await Promise.all([
                    getClasses(),
                    getMatieres(),
                    settingsService.getCurrentTerm()
                ]);

                if (classesRes.success) setClasses(classesRes.classes);
                if (matieresRes.success) setMatieres(matieresRes.matieres);
                if (currentTrim) {
                    setFilters(prev => ({ ...prev, trimestre: currentTrim.toString() }));
                }
            } catch (err) {
                console.error("Erreur chargement références", err);
            }
        };
        loadRefs();
    }, []);

    const fetchNotes = async () => {
        if (!filters.classe_id || !filters.matiere_id) return;

        setLoading(true);
        setFeedback(null);
        try {
            const response = await censeurService.getNotesForModification(filters);
            if (response.data && response.data.success) {
                setEleves(response.data.eleves || []);
                setNotesExistantes(response.data.notes_existantes || {});

                // Pre-fill inputs with existing values
                const initialNotes = {};
                const noteTypeField = filters.type_note === 'interro'
                    ? (filters.numero === '1' ? 'premier_interro' : filters.numero === '2' ? 'deuxieme_interro' : filters.numero === '3' ? 'troisieme_interro' : 'quatrieme_interro')
                    : (filters.numero === '1' ? 'premier_devoir' : 'deuxieme_devoir');

                (response.data.eleves || []).forEach(eleve => {
                    const existingNote = response.data.notes_existantes?.[eleve.id]?.[noteTypeField];
                    if (existingNote !== null && existingNote !== undefined) {
                        initialNotes[eleve.id] = existingNote.toString();
                    }
                });
                setNewNotes(initialNotes);
            }
        } catch (err) {
            console.error("Erreur chargement notes", err);
            setFeedback({ type: 'error', message: 'Erreur lors du chargement des élèves.' });
        } finally {
            setLoading(false);
        }
    };

    const handleNoteChange = (eleveId, value) => {
        // Allow formatting like "12.5" or empty string
        if (value === '' || (/^\d*\.?\d*$/.test(value) && parseFloat(value) <= 20)) {
            setNewNotes(prev => ({
                ...prev,
                [eleveId]: value
            }));
        }
    };

    const handleSave = async () => {
        setSaving(true);
        setFeedback(null);

        // Filter out empty notes
        const notesToSave = {};
        Object.entries(newNotes).forEach(([eleveId, value]) => {
            if (value !== '' && value !== null && !isNaN(parseFloat(value))) {
                notesToSave[eleveId] = parseFloat(value);
            }
        });

        const payload = {
            classe_id: parseInt(filters.classe_id),
            matiere_id: parseInt(filters.matiere_id),
            trimestre: parseInt(filters.trimestre),
            type_note: filters.type_note,
            numero: parseInt(filters.numero),
            notes: notesToSave
        };

        try {
            const response = await censeurService.storeNotesModification(payload);
            if (response.data && response.data.success) {
                setFeedback({ type: 'success', message: 'Notes modifiées et validées avec succès !' });
                fetchNotes(); // Refresh to get updated is_validated flags
            } else {
                setFeedback({ type: 'error', message: response.data.message || 'Erreur lors de la sauvegarde.' });
            }
        } catch (err) {
            console.error("Erreur sauvegarde notes", err);
            setFeedback({ type: 'error', message: 'Une erreur est survenue lors de l\'enregistrement.' });
        } finally {
            setSaving(false);
        }
    };

    const getExistingNoteStatus = (eleveId) => {
        const noteTypeField = filters.type_note === 'interro'
            ? (filters.numero === '1' ? 'premier_interro' : filters.numero === '2' ? 'deuxieme_interro' : filters.numero === '3' ? 'troisieme_interro' : 'quatrieme_interro')
            : (filters.numero === '1' ? 'premier_devoir' : 'deuxieme_devoir');

        const existingNote = notesExistantes[eleveId];
        if (!existingNote || existingNote[noteTypeField] === null) return null;

        return {
            valeur: existingNote[noteTypeField],
            isValidated: existingNote.is_validated
        };
    };

    return (
        <div className="space-y-6 p-6">
            <h1 className="text-2xl font-bold text-slate-900">Modification des Notes (Mode Censeur)</h1>
            <p className="text-slate-600">
                Vous avez les privilèges requis pour écraser des notes déjà saisies par les professeurs.
                Toute modification appliquera automatiquement le statut "Validé".
            </p>

            <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-200">
                <div className="grid grid-cols-1 md:grid-cols-5 gap-4 items-end">
                    <div>
                        <label className="block text-sm font-medium text-slate-700 mb-1">Classe</label>
                        <select
                            className="w-full px-3 py-2 border rounded-lg"
                            value={filters.classe_id}
                            onChange={e => setFilters({ ...filters, classe_id: e.target.value })}
                        >
                            <option value="">Sélectionner...</option>
                            {classes.map(c => <option key={c.id} value={c.id}>{c.nom}</option>)}
                        </select>
                    </div>
                    <div>
                        <label className="block text-sm font-medium text-slate-700 mb-1">Matière</label>
                        <select
                            className="w-full px-3 py-2 border rounded-lg"
                            value={filters.matiere_id}
                            onChange={e => setFilters({ ...filters, matiere_id: e.target.value })}
                        >
                            <option value="">Sélectionner...</option>
                            {matieres.map(m => <option key={m.id} value={m.id}>{m.nom}</option>)}
                        </select>
                    </div>
                    <div>
                        <label className="block text-sm font-medium text-slate-700 mb-1">Trimestre</label>
                        <select
                            className="w-full px-3 py-2 border rounded-lg"
                            value={filters.trimestre}
                            onChange={e => setFilters({ ...filters, trimestre: e.target.value })}
                        >
                            <option value="1">1er</option>
                            <option value="2">2ème</option>
                            <option value="3">3ème</option>
                        </select>
                    </div>
                    <div>
                        <label className="block text-sm font-medium text-slate-700 mb-1">Type de Note</label>
                        <select
                            className="w-full px-3 py-2 border rounded-lg"
                            value={filters.type_note}
                            onChange={e => setFilters({ ...filters, type_note: e.target.value, numero: '1' })}
                        >
                            <option value="interro">Interrogation</option>
                            <option value="devoir">Devoir</option>
                        </select>
                    </div>
                    <div>
                        <label className="block text-sm font-medium text-slate-700 mb-1">Numéro</label>
                        <select
                            className="w-full px-3 py-2 border rounded-lg"
                            value={filters.numero}
                            onChange={e => setFilters({ ...filters, numero: e.target.value })}
                        >
                            {filters.type_note === 'interro' ? (
                                <>
                                    <option value="1">1</option>
                                    <option value="2">2</option>
                                    <option value="3">3</option>
                                    <option value="4">4</option>
                                </>
                            ) : (
                                <>
                                    <option value="1">1</option>
                                    <option value="2">2</option>
                                </>
                            )}
                        </select>
                    </div>
                </div>
                <div className="mt-4 flex justify-end">
                    <button
                        onClick={fetchNotes}
                        disabled={!filters.classe_id || !filters.matiere_id || loading}
                        className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50 transition-colors shadow-md flex items-center"
                    >
                        {loading ? 'Chargement...' : 'Afficher Saisie'}
                    </button>
                </div>
            </div>

            {feedback && (
                <div className={`p-4 rounded-lg flex items-center ${feedback.type === 'error' ? 'bg-red-50 text-red-800' : 'bg-green-50 text-green-800'}`}>
                    {feedback.type === 'error' ? <AlertCircle className="w-5 h-5 mr-2" /> : <CheckCircle className="w-5 h-5 mr-2" />}
                    {feedback.message}
                </div>
            )}

            {eleves.length > 0 && (
                <div className="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
                    <div className="p-4 bg-slate-50 border-b border-slate-200 flex justify-between items-center">
                        <h3 className="font-semibold text-slate-800">
                            Saisie des Notes ({eleves.length} élèves)
                        </h3>
                        <div className="space-x-2">
                            <button
                                onClick={handleSave}
                                disabled={saving}
                                className="text-sm bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 disabled:opacity-50 flex items-center shadow-md transition-colors"
                            >
                                <Save className="w-4 h-4 mr-2" />
                                {saving ? "Enregistrement..." : "Enregistrer les modifications"}
                            </button>
                        </div>
                    </div>
                    <div className="overflow-x-auto">
                        <table className="w-full text-sm text-left">
                            <thead className="text-xs text-slate-500 uppercase bg-slate-50">
                                <tr>
                                    <th className="px-6 py-3">Élève</th>
                                    <th className="px-6 py-3 text-center w-64">Saisie de la Note (/20)</th>
                                    <th className="px-6 py-3 text-center">Statut Actuel</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-100">
                                {eleves.map(eleve => {
                                    const statusObj = getExistingNoteStatus(eleve.id);

                                    return (
                                        <tr key={eleve.id} className="hover:bg-slate-50">
                                            <td className="px-6 py-4 font-medium text-slate-900">
                                                {eleve.nom} {eleve.prenom}
                                            </td>
                                            <td className="px-6 py-4 text-center">
                                                <input
                                                    type="text"
                                                    value={newNotes[eleve.id] || ''}
                                                    onChange={(e) => handleNoteChange(eleve.id, e.target.value)}
                                                    className="w-24 text-center px-3 py-2 border border-slate-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none"
                                                    placeholder="-"
                                                />
                                            </td>
                                            <td className="px-6 py-4 text-center">
                                                {statusObj ? (
                                                    statusObj.isValidated ? (
                                                        <span className="inline-flex items-center text-green-600 px-2 py-1 bg-green-50 rounded-full text-xs font-medium">
                                                            <CheckCircle className="w-3 h-3 mr-1" /> Validé
                                                        </span>
                                                    ) : (
                                                        <span className="inline-flex items-center text-orange-500 px-2 py-1 bg-orange-50 rounded-full text-xs font-medium">
                                                            En attente
                                                        </span>
                                                    )
                                                ) : (
                                                    <span className="text-slate-400 italic text-xs">Non saisie</span>
                                                )}
                                            </td>
                                        </tr>
                                    );
                                })}
                            </tbody>
                        </table>
                    </div>
                </div>
            )}
        </div>
    );
};

export default ModificationNotes;
