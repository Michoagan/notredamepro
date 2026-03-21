import React, { useState, useEffect } from 'react';
import { getClasses, getMatieres } from '../../services/secretariat';
import censeurService from '../../services/censeur';
import settingsService from '../../services/settings';
import { CheckCircle, XCircle, Search, Filter } from 'lucide-react';

const ValidationNotes = () => {
    const [classes, setClasses] = useState([]);
    const [matieres, setMatieres] = useState([]);

    const [filters, setFilters] = useState({
        classe_id: '',
        matiere_id: '',
        trimestre: '1'
    });

    const [notes, setNotes] = useState([]);
    const [loading, setLoading] = useState(false);
    const [processing, setProcessing] = useState(false);

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
        try {
            const response = await censeurService.getNotesValidation(filters);
            if (response.data && response.data.success) {
                setNotes(response.data.notes || []);
            }
        } catch (err) {
            console.error("Erreur chargement notes", err);
        } finally {
            setLoading(false);
        }
    };

    const handleValidateAll = async () => {
        if (!window.confirm("Valider toutes les notes affichées ?")) return;

        const noteIds = notes.map(n => n.id);
        setProcessing(true);
        try {
            await censeurService.validateNotes(noteIds, 'validate');
            fetchNotes(); // Refresh
        } catch (err) {
            alert("Erreur lors de la validation");
        } finally {
            setProcessing(false);
        }
    };

    return (
        <div className="space-y-6">
            <h1 className="text-2xl font-bold text-slate-900">Validation des Notes</h1>

            <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-200">
                <div className="grid grid-cols-1 md:grid-cols-4 gap-4 items-end">
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
                            <option value="1">1er Trimestre</option>
                            <option value="2">2ème Trimestre</option>
                            <option value="3">3ème Trimestre</option>
                        </select>
                    </div>
                    <button
                        onClick={fetchNotes}
                        disabled={!filters.classe_id || !filters.matiere_id || loading}
                        className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50"
                    >
                        {loading ? 'Chargement...' : 'Afficher Notes'}
                    </button>
                </div>
            </div>

            {notes.length > 0 && (
                <div className="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
                    <div className="p-4 bg-slate-50 border-b border-slate-200 flex justify-between items-center">
                        <h3 className="font-semibold text-slate-800">
                            Résultats ({notes.length} élèves)
                        </h3>
                        <div className="space-x-2">
                            <button
                                onClick={handleValidateAll}
                                disabled={processing}
                                className="text-sm bg-green-600 text-white px-3 py-1.5 rounded hover:bg-green-700 disabled:opacity-50 flex items-center"
                            >
                                <CheckCircle className="w-4 h-4 mr-1" />
                                Tout Valider
                            </button>
                        </div>
                    </div>
                    <div className="overflow-x-auto">
                        <table className="w-full text-sm text-left">
                            <thead className="text-xs text-slate-500 uppercase bg-slate-50">
                                <tr>
                                    <th className="px-6 py-3">Élève</th>
                                    <th className="px-6 py-3 text-center">Moy. Interro</th>
                                    <th className="px-6 py-3 text-center">Devoir 1</th>
                                    <th className="px-6 py-3 text-center">Devoir 2</th>
                                    <th className="px-6 py-3 text-center font-bold">Moyenne</th>
                                    <th className="px-6 py-3 text-center">Statut</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-100">
                                {notes.map(note => (
                                    <tr key={note.id} className="hover:bg-slate-50">
                                        <td className="px-6 py-4 font-medium text-slate-900">
                                            {note.eleve.nom} {note.eleve.prenom}
                                        </td>
                                        <td className="px-6 py-4 text-center">{note.moyenne_interro ?? '-'}</td>
                                        <td className="px-6 py-4 text-center">{note.premier_devoir ?? '-'}</td>
                                        <td className="px-6 py-4 text-center">{note.deuxieme_devoir ?? '-'}</td>
                                        <td className="px-6 py-4 text-center font-bold text-blue-600">
                                            {note.moyenne_trimestrielle ? Number(note.moyenne_trimestrielle).toFixed(2) : '-'}
                                        </td>
                                        <td className="px-6 py-4 text-center">
                                            {note.is_validated ? (
                                                <span className="inline-flex items-center text-green-600 px-2 py-1 bg-green-50 rounded-full text-xs font-medium">
                                                    <CheckCircle className="w-3 h-3 mr-1" /> Validé
                                                </span>
                                            ) : (
                                                <span className="inline-flex items-center text-orange-500 px-2 py-1 bg-orange-50 rounded-full text-xs font-medium">
                                                    En attente
                                                </span>
                                            )}
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                </div>
            )}
        </div>
    );
};

export default ValidationNotes;
