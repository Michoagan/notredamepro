import React, { useState, useEffect } from 'react';
import { getClasses } from '../../services/secretariat';
import censeurService from '../../services/censeur';
import { Save, Plus, Trash2, Clock, BookOpen } from 'lucide-react';

const DAYS = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];

const GestionCours = () => {
    const [classes, setClasses] = useState([]);
    const [selectedClassId, setSelectedClassId] = useState('');
    const [selectedClass, setSelectedClass] = useState(null);
    const [timetable, setTimetable] = useState([]);
    const [loading, setLoading] = useState(false);

    // UI state
    const [activeDay, setActiveDay] = useState('Lundi');

    useEffect(() => {
        getClasses().then(res => {
            if (res.success) setClasses(res.classes);
        });
    }, []);

    useEffect(() => {
        if (selectedClassId) {
            const cls = classes.find(c => c.id == selectedClassId);
            setSelectedClass(cls);
            fetchTimetable(selectedClassId, cls);
        } else {
            setTimetable([]);
            setSelectedClass(null);
        }
    }, [selectedClassId]);

    const fetchTimetable = async (id, cls) => {
        setLoading(true);
        try {
            const response = await censeurService.getEmploiDuTemps(id);
            const data = response?.data || response;
            if (data && data.success) {
                // Map API slots to form slots
                const mappedSlots = (data.slots || []).map(s => {
                    // Find assigned prof based on programmed matieres if none directly set
                    let profId = s.professeur_id;
                    if (!profId && cls?.matieres) {
                        const programmed = cls.matieres.find(m => m.id === s.matiere_id);
                        if (programmed && (programmed.pivot?.professeur_id || programmed.professeur_id)) {
                            profId = programmed.pivot?.professeur_id || programmed.professeur_id;
                        }
                    }

                    // Format times for input
                    const startStr = s.heure_debut ? s.heure_debut.substring(0, 5) : '';
                    const endStr = s.heure_fin ? s.heure_fin.substring(0, 5) : '';

                    return {
                        id: s.id || Math.random().toString(),
                        jour: s.jour,
                        matiere_id: s.matiere_id || '',
                        professeur_id: profId || '',
                        heure_debut: startStr,
                        heure_fin: endStr,
                        salle: s.salle || ''
                    };
                });
                setTimetable(mappedSlots);
            }
        } catch (err) {
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    const handleSave = async () => {
        if (!selectedClassId) return;

        // Validate inputs before saving
        const invalid = timetable.find(t => !t.matiere_id || !t.heure_debut || !t.heure_fin);
        if (invalid) {
            alert("Veuillez remplir toutes les informations (Heures et Matière) pour chaque cours.");
            return;
        }

        const payload = timetable.map(t => ({
            ...t,
            professeur_id: t.professeur_id || null,
            salle: t.salle || null,
        }));

        try {
            await censeurService.updateEmploiDuTemps(selectedClassId, { slots: payload });
            alert("Emploi du temps sauvegardé !");
        } catch (err) {
            alert("Erreur lors de la sauvegarde.");
        }
    };
    const addSlot = (day) => {
        setTimetable([...timetable, {
            id: Math.random().toString(),
            jour: day,
            matiere_id: '',
            professeur_id: '',
            heure_debut: '08:00',
            heure_fin: '10:00',
            salle: ''
        }]);
    };

    const removeSlot = (idToRemove) => {
        setTimetable(timetable.filter(s => s.id !== idToRemove));
    };

    const handleSlotChange = (slotId, field, value) => {
        setTimetable(timetable.map(slot => {
            if (slot.id === slotId) {
                const updated = { ...slot, [field]: value };

                // If subject changes, auto-assign the professor based on class programming
                if (field === 'matiere_id' && selectedClass?.matieres) {
                    const programmed = selectedClass.matieres.find(m => m.id === parseInt(value));
                    if (programmed && (programmed.pivot?.professeur_id || programmed.professeur_id)) {
                        updated.professeur_id = programmed.pivot?.professeur_id || programmed.professeur_id;
                    } else {
                        updated.professeur_id = '';
                    }
                }

                return updated;
            }
            return slot;
        }));
    };

    // Filter slots by currently selected tab/day
    const activeSlots = timetable.filter(s => s.jour === activeDay).sort((a, b) => a.heure_debut.localeCompare(b.heure_debut));

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center bg-white p-4 rounded-xl shadow-sm border border-slate-200">
                <div>
                    <h1 className="text-xl font-bold text-slate-900">Emploi du Temps Manuel</h1>
                    <p className="text-sm text-slate-500">Programmer spécifiquement les heures de chaque cours</p>
                </div>
                <div className="flex items-center space-x-4">
                    <select
                        className="px-4 py-2 border border-slate-300 rounded-lg min-w-[250px] focus:ring-2 focus:ring-blue-500 outline-none"
                        value={selectedClassId}
                        onChange={e => setSelectedClassId(e.target.value)}
                    >
                        <option value="">-- Choisir une classe --</option>
                        {classes.map(c => <option key={c.id} value={c.id}>{c.nom}</option>)}
                    </select>
                    <button
                        onClick={handleSave}
                        disabled={!selectedClassId}
                        className="flex items-center space-x-2 bg-blue-600 text-white px-5 py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50 transition"
                    >
                        <Save className="w-4 h-4" />
                        <span>Enregistrer</span>
                    </button>
                </div>
            </div>

            {selectedClass ? (
                <div className="bg-white border flex flex-col md:flex-row border-slate-200 shadow-sm rounded-xl overflow-hidden min-h-[500px]">
                    {/* Sidebar / Tabs for Days */}
                    <div className="w-full md:w-48 bg-slate-50 border-r border-slate-200 flex flex-row md:flex-col overflow-x-auto">
                        {DAYS.map(day => {
                            const count = timetable.filter(s => s.jour === day).length;
                            return (
                                <button
                                    key={day}
                                    onClick={() => setActiveDay(day)}
                                    className={`px-4 py-3 text-left font-medium transition whitespace-nowrap border-b border-transparent md:border-b-slate-200 flex justify-between items-center ${activeDay === day ? 'bg-white text-blue-600 border-l-4 border-l-blue-600' : 'text-slate-600 hover:bg-slate-100'}`}
                                >
                                    <span>{day}</span>
                                    {count > 0 && <span className="bg-slate-200 text-slate-600 px-2 py-0.5 rounded-full text-xs">{count}</span>}
                                </button>
                            );
                        })}
                    </div>

                    {/* Main Content Form */}
                    <div className="flex-1 p-6">
                        <div className="flex justify-between items-center mb-6">
                            <h2 className="text-lg font-bold text-slate-800 flex items-center">
                                {activeDay}
                                <span className="ml-2 text-sm font-normal text-slate-500">({selectedClass.nom})</span>
                            </h2>
                            <button
                                onClick={() => addSlot(activeDay)}
                                className="flex items-center space-x-1 text-sm bg-blue-50 text-blue-700 px-3 py-1.5 rounded-md hover:bg-blue-100 transition font-medium"
                            >
                                <Plus className="w-4 h-4" />
                                <span>Ajouter un cours</span>
                            </button>
                        </div>

                        {activeSlots.length === 0 ? (
                            <div className="text-center py-16 text-slate-500 border-2 border-dashed border-slate-200 rounded-xl">
                                <Clock className="w-12 h-12 mx-auto mb-3 text-slate-300" />
                                <p>Aucun cours programmé le {activeDay}.</p>
                                <button onClick={() => addSlot(activeDay)} className="mt-3 text-blue-600 text-sm font-medium hover:underline">
                                    + Mettre en place un cours
                                </button>
                            </div>
                        ) : (
                            <div className="space-y-4">
                                {activeSlots.map((slot, index) => (
                                    <div key={slot.id} className="grid grid-cols-12 gap-4 items-center bg-slate-50 p-4 rounded-xl border border-slate-200 relative group">
                                        <div className="col-span-12 md:col-span-3 flex items-center space-x-2">
                                            <div className="flex flex-col w-full">
                                                <label className="text-xs text-slate-500 mb-1 font-medium">De (Heure)</label>
                                                <input
                                                    type="time"
                                                    value={slot.heure_debut}
                                                    onChange={e => handleSlotChange(slot.id, 'heure_debut', e.target.value)}
                                                    className="border border-slate-300 rounded-md p-2 w-full text-sm outline-none focus:ring-1 focus:ring-blue-500"
                                                />
                                            </div>
                                            <span className="text-slate-400 mt-5">-</span>
                                            <div className="flex flex-col w-full">
                                                <label className="text-xs text-slate-500 mb-1 font-medium">À (Heure)</label>
                                                <input
                                                    type="time"
                                                    value={slot.heure_fin}
                                                    onChange={e => handleSlotChange(slot.id, 'heure_fin', e.target.value)}
                                                    className="border border-slate-300 rounded-md p-2 w-full text-sm outline-none focus:ring-1 focus:ring-blue-500"
                                                />
                                            </div>
                                        </div>

                                        <div className="col-span-12 md:col-span-4 flex flex-col">
                                            <label className="text-xs text-slate-500 mb-1 font-medium">Matière</label>
                                            <select
                                                value={slot.matiere_id}
                                                onChange={e => handleSlotChange(slot.id, 'matiere_id', e.target.value)}
                                                className="border border-slate-300 rounded-md p-2 text-sm outline-none focus:ring-1 focus:ring-blue-500 bg-white"
                                            >
                                                <option value="">Sélectionner une matière...</option>
                                                {selectedClass.matieres && selectedClass.matieres.map(m => (
                                                    <option key={m.id} value={m.id}>{m.nom}</option>
                                                ))}
                                            </select>
                                        </div>

                                        <div className="col-span-12 md:col-span-4 flex flex-col">
                                            <label className="text-xs text-slate-500 mb-1 font-medium">Professeur (Auto)</label>
                                            <div className="border border-slate-200 rounded-md p-2 text-sm bg-slate-100 text-slate-600 truncate flex items-center h-[38px]">
                                                {slot.professeur_id && selectedClass.matieres ? (
                                                    (() => {
                                                        const stum = selectedClass.matieres.find(m => m.id == slot.matiere_id);
                                                        return stum?.professeur?.last_name ? `${stum.professeur.first_name} ${stum.professeur.last_name}` : 'Professeur assigné (ID: ' + slot.professeur_id + ')';
                                                    })()
                                                ) : (
                                                    <span className="italic text-slate-400">Aucun prof...</span>
                                                )}
                                            </div>
                                        </div>

                                        <div className="col-span-12 md:col-span-1 flex justify-end md:mt-5">
                                            <button
                                                onClick={() => removeSlot(slot.id)}
                                                className="text-red-400 hover:text-red-600 hover:bg-red-50 p-2 rounded-lg transition"
                                                title="Supprimer ce créneau"
                                            >
                                                <Trash2 className="w-5 h-5" />
                                            </button>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        )}
                    </div>
                </div>
            ) : (
                <div className="bg-white border border-dashed border-slate-300 rounded-xl p-16 text-center text-slate-500">
                    <BookOpen className="w-12 h-12 mx-auto mb-4 opacity-50" />
                    <h3 className="text-lg font-medium text-slate-700 mb-2">Aucune classe sélectionnée</h3>
                    <p>Veuillez choisir une classe dans le menu déroulant ci-dessus pour gérer son emploi du temps.</p>
                </div>
            )}
        </div>
    );
};

export default GestionCours;
