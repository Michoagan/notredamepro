import React, { useState, useEffect } from 'react';
import { CheckCircle, XCircle, Search, Save } from 'lucide-react';
import api from '../../services/api';

export default function Presence() {
    const [classes, setClasses] = useState([]);
    const [selectedClass, setSelectedClass] = useState('');
    const [eleves, setEleves] = useState([]);
    const [presenceData, setPresenceData] = useState({});
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        api.get('/classes/index')
            .then(res => {
                // Handle both direct array and object with 'classes' property
                const classesData = Array.isArray(res.data) ? res.data : (res.data.classes || []);
                setClasses(classesData);
            })
            .catch(console.error);
    }, []);

    useEffect(() => {
        if (selectedClass) {
            loadEleves(selectedClass);
        }
    }, [selectedClass]);

    const loadEleves = async (classeId) => {
        setLoading(true);
        try {
            const res = await api.get(`/classes/${classeId}/eleves`);
            setEleves(res.data);
            // Initialize presence as 'present' for all
            const initialPresence = {};
            res.data.forEach(e => initialPresence[e.id] = 'present');
            setPresenceData(initialPresence);
        } catch (error) {
            console.error(error);
        } finally {
            setLoading(false);
        }
    };

    const togglePresence = (eleveId) => {
        setPresenceData(prev => ({
            ...prev,
            [eleveId]: prev[eleveId] === 'present' ? 'absent' : 'present'
        }));
    };

    const handleSave = async () => {
        // Mock save for now
        alert("Enregistrement des présences effectué !");
    };

    return (
        <div className="space-y-6">
            <header>
                <h1 className="text-2xl font-bold text-slate-800">Gestion des Présences</h1>
                <p className="text-slate-500">Faire l'appel par classe</p>
            </header>

            <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-200">
                <div className="flex items-center space-x-4 mb-6">
                    <select
                        value={selectedClass}
                        onChange={(e) => setSelectedClass(e.target.value)}
                        className="px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
                    >
                        <option value="">-- Sélectionner une classe --</option>
                        {classes.map(c => <option key={c.id} value={c.id}>{c.nom}</option>)}
                    </select>
                </div>

                {selectedClass && (
                    <div className="space-y-4">
                        <div className="flex justify-between items-center bg-slate-50 p-3 rounded-lg border border-slate-100">
                            <h3 className="font-semibold text-slate-700">Liste des élèves ({eleves.length})</h3>
                            <button
                                onClick={handleSave}
                                className="flex items-center space-x-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition"
                            >
                                <Save className="w-4 h-4" />
                                <span>Enregistrer l'appel</span>
                            </button>
                        </div>

                        {loading ? <p className="text-center py-8">Chargement...</p> : (
                            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                                {eleves.map(eleve => (
                                    <div
                                        key={eleve.id}
                                        onClick={() => togglePresence(eleve.id)}
                                        className={`p-4 rounded-lg border cursor-pointer transition flex items-center justify-between
                                            ${presenceData[eleve.id] === 'absent'
                                                ? 'bg-red-50 border-red-200 hover:bg-red-100'
                                                : 'bg-white border-slate-200 hover:border-blue-300'
                                            }`}
                                    >
                                        <div>
                                            <p className="font-bold text-slate-800">{eleve.nom} {eleve.prenom}</p>
                                            <p className="text-xs text-slate-500">Matricule: {eleve.matricule}</p>
                                        </div>
                                        <div>
                                            {presenceData[eleve.id] === 'absent' ? (
                                                <div className="flex items-center text-red-600 space-x-1">
                                                    <XCircle className="w-5 h-5" />
                                                    <span className="text-xs font-bold uppercase">Absent</span>
                                                </div>
                                            ) : (
                                                <div className="flex items-center text-green-600 space-x-1">
                                                    <CheckCircle className="w-5 h-5" />
                                                    <span className="text-xs font-bold uppercase">Présent</span>
                                                </div>
                                            )}
                                        </div>
                                    </div>
                                ))}
                            </div>
                        )}
                    </div>
                )}
            </div>
        </div>
    );
}
