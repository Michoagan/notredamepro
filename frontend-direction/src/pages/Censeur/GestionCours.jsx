import React, { useState, useEffect } from 'react';
import { getClasses } from '../../services/secretariat';
import censeurService from '../../services/censeur';
import { Save, RefreshCw } from 'lucide-react';

const DAYS = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
const HOURS = ['07:00', '08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00'];

const GestionCours = () => {
    const [classes, setClasses] = useState([]);
    const [selectedClassId, setSelectedClassId] = useState('');
    const [selectedClass, setSelectedClass] = useState(null);
    const [timetable, setTimetable] = useState([]); // Array of slots
    const [loading, setLoading] = useState(false);

    // For drag and drop or mock selection
    const [draggedSubject, setDraggedSubject] = useState(null);

    useEffect(() => {
        getClasses().then(res => {
            if (res.success) setClasses(res.classes);
        });
    }, []);

    useEffect(() => {
        if (selectedClassId) {
            fetchTimetable(selectedClassId);
            const cls = classes.find(c => c.id == selectedClassId);
            setSelectedClass(cls);
        } else {
            setTimetable([]);
            setSelectedClass(null);
        }
    }, [selectedClassId]);

    const fetchTimetable = async (id) => {
        setLoading(true);
        try {
            const data = await censeurService.getEmploiDuTemps(id);
            if (data.success) {
                setTimetable(data.slots);
            }
        } catch (err) {
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    const handleSave = async () => {
        if (!selectedClassId) return;
        try {
            await censeurService.updateEmploiDuTemps(selectedClassId, timetable);
            alert("Emploi du temps sauvegardé !");
        } catch (err) {
            alert("Erreur sauvegarde");
        }
    };

    // Simplified interactions for this MVP:
    // User clicks a cell to assign a selected subject
    const [activeSubject, setActiveSubject] = useState(null);

    const handleCellClick = (day, hour) => {
        if (!activeSubject) {
            // If clicking an existing slot without an active subject, remove it
            const newTimetable = timetable.filter(s =>
                !(s.jour === day && s.heure_debut === hour)
            );
            if (newTimetable.length !== timetable.length) {
                setTimetable(newTimetable);
            }
            return;
        }

        // Add or Replace
        const hourEnd = HOURS[HOURS.indexOf(hour) + 1] || '18:00'; // Default 1 hour slot
        const newSlot = {
            matiere_id: activeSubject.id,
            professeur_id: activeSubject.pivot?.professeur_id || activeSubject.professeur_id, // Get from pivot or direct
            jour: day,
            heure_debut: hour,
            heure_fin: hourEnd,
            salle: 'Salle ' + selectedClass.nom,
            // Visual helpers
            nom_matiere: activeSubject.nom,
            color: 'bg-blue-100'
        };

        // Remove overlapping/same-start slot
        const filtered = timetable.filter(s => !(s.jour === day && s.heure_debut === hour));
        setTimetable([...filtered, newSlot]);
    };

    const getSlotAt = (day, hour) => {
        return timetable.find(s => s.jour === day && s.heure_debut === hour);
    };

    return (
        <div className="space-y-6 h-[calc(100vh-100px)] flex flex-col">
            <div className="flex justify-between items-center">
                <h1 className="text-2xl font-bold text-slate-900">Gestion des Cours & Emploi du Temps</h1>
                <div className="flex items-center space-x-4">
                    <select
                        className="px-4 py-2 border rounded-lg min-w-[200px]"
                        value={selectedClassId}
                        onChange={e => setSelectedClassId(e.target.value)}
                    >
                        <option value="">Choisir une classe...</option>
                        {classes.map(c => <option key={c.id} value={c.id}>{c.nom}</option>)}
                    </select>
                    <button
                        onClick={handleSave}
                        disabled={!selectedClassId}
                        className="flex items-center space-x-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50"
                    >
                        <Save className="w-4 h-4" />
                        <span>Sauvegarder</span>
                    </button>
                </div>
            </div>

            {selectedClass ? (
                <div className="flex flex-1 gap-6 overflow-hidden">
                    {/* Sidebar: Available Subjects */}
                    <div className="w-64 bg-white rounded-xl shadow-sm border border-slate-200 p-4 flex flex-col overflow-y-auto">
                        <h3 className="font-semibold text-slate-700 mb-4">Matières Disponibles</h3>
                        <p className="text-xs text-slate-400 mb-4">Cliquez sur une matière puis sur une case du planning.</p>

                        <div className="space-y-2">
                            {selectedClass.matieres && selectedClass.matieres.map(m => (
                                <div
                                    key={m.id}
                                    onClick={() => setActiveSubject(m)}
                                    className={`p-3 rounded-lg border cursor-pointer transition ${activeSubject?.id === m.id ? 'border-blue-500 bg-blue-50 ring-1 ring-blue-500' : 'border-slate-200 hover:border-blue-300'}`}
                                >
                                    <div className="font-medium text-slate-900">{m.nom}</div>
                                    <div className="text-xs text-slate-500">
                                        {m.volume_horaire ? `${m.volume_horaire}h / an` : 'Vol. horaire non défini'}
                                    </div>
                                </div>
                            ))}
                        </div>
                    </div>

                    {/* Main: Calendar Grid */}
                    <div className="flex-1 bg-white rounded-xl shadow-sm border border-slate-200 overflow-auto p-4">
                        <div className="grid grid-cols-7 min-w-[800px]">
                            {/* Header Row */}
                            <div className="p-2 border-b border-r bg-slate-50 text-center font-bold text-slate-500">Heure</div>
                            {DAYS.map(day => (
                                <div key={day} className="p-2 border-b border-slate-200 bg-slate-50 text-center font-bold text-slate-700">
                                    {day}
                                </div>
                            ))}

                            {/* Time Slots */}
                            {HOURS.map(hour => (
                                <React.Fragment key={hour}>
                                    <div className="p-2 border-b border-r border-slate-100 text-xs text-slate-400 text-center">{hour}</div>
                                    {DAYS.map(day => {
                                        const slot = getSlotAt(day, hour);
                                        return (
                                            <div
                                                key={`${day}-${hour}`}
                                                onClick={() => handleCellClick(day, hour)}
                                                className={`p-1 border-b border-l border-slate-100 min-h-[60px] cursor-pointer hover:bg-slate-50 transition relative group`}
                                            >
                                                {slot && (
                                                    <div className="absolute inset-1 bg-blue-100 border border-blue-200 rounded p-1 text-xs overflow-hidden">
                                                        <div className="font-semibold text-blue-800 truncate">
                                                            {slot.matiere?.nom || slot.nom_matiere}
                                                        </div>
                                                        <div className="text-blue-600 text-[10px]">
                                                            {slot.salle || 'Salle ' + selectedClass.nom}
                                                        </div>
                                                    </div>
                                                )}
                                                {!slot && activeSubject && (
                                                    <div className="absolute inset-0 bg-blue-50 opacity-0 group-hover:opacity-100 flex items-center justify-center text-blue-300 text-xs">
                                                        + Ajouter
                                                    </div>
                                                )}
                                            </div>
                                        );
                                    })}
                                </React.Fragment>
                            ))}
                        </div>
                    </div>
                </div>
            ) : (
                <div className="flex-1 flex items-center justify-center bg-white rounded-xl border border-dashed border-slate-300">
                    <div className="text-center text-slate-400">
                        <BookOpen className="w-12 h-12 mx-auto mb-2 opacity-50" />
                        <p>Veuillez sélectionner une classe pour gérer son emploi du temps.</p>
                    </div>
                </div>
            )}
        </div>
    );
};

export default GestionCours;
