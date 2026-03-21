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
    const [timetable, setTimetable] = useState([]);
    const [loading, setLoading] = useState(false);

    // Compositions State
    const [activeTab, setActiveTab] = useState('cours');
    const [compLibelle, setCompLibelle] = useState('Composition du Premier Trimestre');
    const [compTrimestre, setCompTrimestre] = useState(1);
    const [compNumeroDevoir, setCompNumeroDevoir] = useState(1);
    const [compCible, setCompCible] = useState('toute_lecole');
    const [compClasseId, setCompClasseId] = useState('');
    const [compHoraires, setCompHoraires] = useState([]);
    const [sessions, setSessions] = useState([]); // List of past/existing sessions


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
            const [classesRes, matieresRes, profsRes, sessionsRes] = await Promise.all([
                api.get('/classes/index'),
                api.get('/classes/matieres'),
                api.get('/professeurs'),
                api.get('/censeur/session-compositions') // Add this to your api.php if needed or use try-catch specifically
                    .catch(() => ({ data: [] }))
            ]);
            setClasses(Array.isArray(classesRes.data) ? classesRes.data : (classesRes.data.data || classesRes.data.classes || []));
            setMatieres(Array.isArray(matieresRes.data) ? matieresRes.data : (matieresRes.data.data || matieresRes.data.matieres || []));
            setProfesseurs(Array.isArray(profsRes.data) ? profsRes.data : (profsRes.data.professeurs || profsRes.data.data || []));
            setSessions(Array.isArray(sessionsRes.data) ? sessionsRes.data : (sessionsRes.data.data || sessionsRes.data.sessions || []));
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


            const timetableData = await censeurService.getEmploiDuTemps(classeId);
            const data = timetableData?.data || timetableData;
            if (data && data.success) {
                setTimetable(data.slots || []);
            } else {
                setTimetable([]);
            }

            // Fetch Prof Principal and populate programmation
            const currentClass = classes.find(c => c.id === parseInt(classeId));
            if (currentClass) {
                setProfPrincipal(currentClass.professeur_principal_id || '');
                if (currentClass.matieres) {
                    const existingProg = currentClass.matieres.map(m => ({
                        matiere_id: m.id,
                        coefficient: m.pivot?.coefficient || 1,
                        volume_horaire: m.pivot?.volume_horaire || 1,
                        professeur_id: m.pivot?.professeur_id || ''
                    }));
                    setProgrammation(existingProg);
                } else {
                    setProgrammation([]);
                }
            } else {
                setProgrammation([]);
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

    const handleAddHoraireComp = () => {
        setCompHoraires([...compHoraires, {
            matiere_id: '',
            date_composition: '',
            heure_debut: '08:00',
            heure_fin: '10:00'
        }]);
    };

    const handleRemoveHoraireComp = (idx) => {
        const newHoraires = [...compHoraires];
        newHoraires.splice(idx, 1);
        setCompHoraires(newHoraires);
    };

    const handleChangeHoraireComp = (idx, field, value) => {
        const newHoraires = [...compHoraires];
        newHoraires[idx][field] = value;
        setCompHoraires(newHoraires);
    };

    const handleSaveComposition = async () => {
        if (compCible === 'classe' && !compClasseId) {
            alert('Veuillez sélectionner une classe.');
            return;
        }
        if (compHoraires.length === 0) {
            alert('Veuillez ajouter au moins une matière à composer.');
            return;
        }

        try {
            const payload = {
                libelle: compLibelle,
                trimestre: compTrimestre,
                numero_devoir: compNumeroDevoir,
                cible: compCible,
                classe_id: compCible === 'classe' ? compClasseId : null,
                horaires: compHoraires
            };

            const res = await api.post('/censeur/session-compositions', payload);
            if (res.data.success) {
                alert('Session de composition programmée avec succès.');
                setSessions([res.data.session, ...sessions]);
                // Reset form
                setCompLibelle('Composition Trimestre');
                setCompHoraires([]);
            }
        } catch (error) {
            console.error(error);
            alert(error.response?.data?.message || 'Erreur d\'enregistrement de la composition.');
        }
    };

    const handleDeleteComposition = async (id) => {
        if (!window.confirm('Voulez-vous vraiment supprimer cette session ?')) return;
        try {
            await api.delete('/censeur/session-compositions/' + id);
            setSessions(sessions.filter(s => s.id !== id));
        } catch (error) {
            console.error(error);
            alert('Erreur lors de la suppression');
        }
    };

    return (
        <div className="space-y-6">
            <h1 className="text-2xl font-bold text-slate-900">Programmation Pédagogique</h1>

            <div className="flex space-x-4 border-b border-slate-200">
                <button
                    onClick={() => setActiveTab('cours')}
                    className={`py-2 px-4 border-b-2 font-medium ${activeTab === 'cours' ? 'border-blue-500 text-blue-600' : 'border-transparent text-slate-500 hover:text-slate-700'}`}
                >
                    Emploi du Temps / Cours
                </button>
                <button
                    onClick={() => setActiveTab('compositions')}
                    className={`py-2 px-4 border-b-2 font-medium ${activeTab === 'compositions' ? 'border-blue-500 text-blue-600' : 'border-transparent text-slate-500 hover:text-slate-700'}`}
                >
                    Sessions de Composition
                </button>
            </div>

            {activeTab === 'cours' && (
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
                                        {professeurs.map(p => <option key={p.id} value={p.id}>{p.last_name} {p.first_name}</option>)}
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
                                                                {professeurs.map(p => <option key={p.id} value={p.id}>{p.last_name} {p.first_name}</option>)}
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

                            {/* Timetable View */}
                            <div className="pt-6 mt-6 border-t border-slate-200">
                                <h3 className="font-semibold text-lg text-slate-800 mb-4">Aperçu de l'Emploi du Temps</h3>
                                {timetable && timetable.length > 0 ? (
                                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                                        {['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'].map(jour => {
                                            const slotsForDay = timetable.filter(t => t.jour === jour).sort((a, b) => (a.heure_debut || '').localeCompare(b.heure_debut || ''));
                                            if (slotsForDay.length === 0) return null;

                                            return (
                                                <div key={jour} className="bg-slate-50 p-4 rounded-lg border border-slate-200 shadow-sm">
                                                    <h4 className="font-semibold text-slate-700 mb-3 pb-2 border-b border-slate-200">{jour}</h4>
                                                    <div className="space-y-3">
                                                        {slotsForDay.map((slot, idx) => {
                                                            const matiere = matieres.find(m => m.id === slot.matiere_id);
                                                            const prof = professeurs.find(p => p.id === slot.professeur_id);
                                                            return (
                                                                <div key={idx} className="bg-white p-2 rounded border border-slate-100 shadow-sm flex flex-col text-sm">
                                                                    <div className="flex justify-between font-medium text-slate-800 mb-1">
                                                                        <span>{slot.heure_debut ? slot.heure_debut.substring(0, 5) : ''} - {slot.heure_fin ? slot.heure_fin.substring(0, 5) : ''}</span>
                                                                        <span className="text-blue-600">{matiere ? matiere.nom : 'Non définie'}</span>
                                                                    </div>
                                                                    <div className="text-slate-500 text-xs flex justify-between">
                                                                        <span>{prof ? `${prof.last_name} ${prof.first_name}` : 'Aucun prof'}</span>
                                                                        <span>{slot.salle ? `Salle: ${slot.salle}` : ''}</span>
                                                                    </div>
                                                                </div>
                                                            );
                                                        })}
                                                    </div>
                                                </div>
                                            );
                                        })}
                                    </div>
                                ) : (
                                    <div className="text-center py-8 text-slate-500 bg-slate-50 rounded-lg border border-slate-200 border-dashed">
                                        <p>Aucun emploi du temps configuré pour cette classe.</p>
                                    </div>
                                )}
                            </div>
                        </div>
                    )}
                </div>
            )}

            {activeTab === 'compositions' && (
                <div className="space-y-6">
                    {/* Formulaire de création de Session */}
                    <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm">
                        <h2 className="text-xl font-bold text-slate-800 mb-4">Programmer une Composition (Devoir)</h2>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Libellé</label>
                                <input
                                    type="text"
                                    value={compLibelle}
                                    onChange={(e) => setCompLibelle(e.target.value)}
                                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                                    placeholder="Ex: Devoir du 1er Trimestre"
                                />
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Trimestre</label>
                                    <select
                                        value={compTrimestre}
                                        onChange={(e) => setCompTrimestre(parseInt(e.target.value))}
                                        className="w-full px-3 py-2 border border-slate-300 rounded-lg"
                                    >
                                        <option value={1}>1er Trimestre</option>
                                        <option value={2}>2ème Trimestre</option>
                                        <option value={3}>3ème Trimestre</option>
                                    </select>
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Devoir N°</label>
                                    <select
                                        value={compNumeroDevoir}
                                        onChange={(e) => setCompNumeroDevoir(parseInt(e.target.value))}
                                        className="w-full px-3 py-2 border border-slate-300 rounded-lg"
                                    >
                                        <option value={1}>Devoir 1</option>
                                        <option value={2}>Devoir 2</option>
                                    </select>
                                </div>
                            </div>
                            <div className="col-span-1 md:col-span-2">
                                <label className="block text-sm font-medium text-slate-700 mb-1">Cible de la programmation</label>
                                <select
                                    value={compCible}
                                    onChange={(e) => setCompCible(e.target.value)}
                                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                                >
                                    <option value="toute_lecole">Toute l'école</option>
                                    <option value="1er_cycle">1er Cycle (6ème à 3ème)</option>
                                    <option value="2nd_cycle">2nd Cycle (2nde à Terminale)</option>
                                    <option value="classe">Classe Spécifique</option>
                                </select>
                            </div>
                            {compCible === 'classe' && (
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Classe ciblée</label>
                                    <select
                                        value={compClasseId}
                                        onChange={(e) => setCompClasseId(e.target.value)}
                                        className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                                    >
                                        <option value="">-- Choisir une classe --</option>
                                        {classes.map(c => <option key={c.id} value={c.id}>{c.nom}</option>)}
                                    </select>
                                </div>
                            )}
                        </div>

                        {/* Emploi du temps des examens */}
                        <div className="mb-4">
                            <div className="flex justify-between items-center mb-4">
                                <h3 className="font-semibold text-lg text-slate-800">Emploi du temps des examens</h3>
                                <button
                                    onClick={handleAddHoraireComp}
                                    className="flex items-center space-x-1 text-sm bg-blue-50 text-blue-700 px-3 py-1.5 rounded-md hover:bg-blue-100 transition"
                                >
                                    <Plus className="w-4 h-4" />
                                    <span>Ajouter Matière</span>
                                </button>
                            </div>
                            <div className="overflow-x-auto border border-slate-200 rounded-lg">
                                <table className="w-full text-sm text-left">
                                    <thead className="bg-slate-50 text-slate-500 font-medium whitespace-nowrap">
                                        <tr>
                                            <th className="px-4 py-3">Matière</th>
                                            <th className="px-4 py-3">Date</th>
                                            <th className="px-4 py-3">Heure Début</th>
                                            <th className="px-4 py-3">Heure Fin</th>
                                            <th className="px-4 py-3 text-center w-16"></th>
                                        </tr>
                                    </thead>
                                    <tbody className="divide-y divide-slate-100 bg-white">
                                        {compHoraires.length === 0 ? (
                                            <tr><td colSpan="5" className="px-4 py-8 text-center text-slate-400">Aucune matière programmée.</td></tr>
                                        ) : (
                                            compHoraires.map((item, idx) => (
                                                <tr key={idx}>
                                                    <td className="px-2 py-2">
                                                        <select
                                                            value={item.matiere_id}
                                                            onChange={(e) => handleChangeHoraireComp(idx, 'matiere_id', e.target.value)}
                                                            className="w-full border-slate-200 rounded px-2 py-1 focus:ring-0 text-sm"
                                                        >
                                                            <option value="">Sélectionner...</option>
                                                            {matieres.map(m => <option key={m.id} value={m.id}>{m.nom}</option>)}
                                                        </select>
                                                    </td>
                                                    <td className="px-2 py-2">
                                                        <input
                                                            type="date"
                                                            value={item.date_composition}
                                                            onChange={(e) => handleChangeHoraireComp(idx, 'date_composition', e.target.value)}
                                                            className="w-full border-slate-200 rounded px-2 py-1 text-sm text-center"
                                                        />
                                                    </td>
                                                    <td className="px-2 py-2">
                                                        <input
                                                            type="time"
                                                            value={item.heure_debut}
                                                            onChange={(e) => handleChangeHoraireComp(idx, 'heure_debut', e.target.value)}
                                                            className="w-full border-slate-200 rounded px-2 py-1 text-sm text-center"
                                                        />
                                                    </td>
                                                    <td className="px-2 py-2">
                                                        <input
                                                            type="time"
                                                            value={item.heure_fin}
                                                            onChange={(e) => handleChangeHoraireComp(idx, 'heure_fin', e.target.value)}
                                                            className="w-full border-slate-200 rounded px-2 py-1 text-sm text-center"
                                                        />
                                                    </td>
                                                    <td className="px-2 py-2 text-center">
                                                        <button onClick={() => handleRemoveHoraireComp(idx)} className="text-red-400 hover:text-red-600">
                                                            <Trash2 className="w-4 h-4 mx-auto" />
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
                                onClick={handleSaveComposition}
                                className="flex items-center space-x-2 bg-green-600 text-white px-6 py-2 rounded-lg hover:bg-green-700 transition"
                            >
                                <Save className="w-4 h-4" />
                                <span>Puglier la session</span>
                            </button>
                        </div>
                    </div>

                    {/* Liste des sessions */}
                    <div>
                        <h3 className="font-semibold text-lg text-slate-800 mb-4">Sessions Programmées</h3>
                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                            {sessions.length === 0 ? (
                                <p className="text-slate-500">Aucune session n'a été programmée.</p>
                            ) : (
                                sessions.map(s => (
                                    <div key={s.id} className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm relative">
                                        <button onClick={() => handleDeleteComposition(s.id)} className="absolute top-4 right-4 text-red-400 hover:text-red-600">
                                            <Trash2 className="w-4 h-4" />
                                        </button>
                                        <h4 className="font-bold text-slate-800 pr-6">{s.libelle}</h4>
                                        <div className="text-sm text-slate-500 mt-1 mb-3">
                                            Trimestre {s.trimestre} - Devoir n°{s.numero_devoir}<br />
                                            {s.cible === 'toute_lecole' && <span className="text-blue-600 font-medium">Toute l'école</span>}
                                            {s.cible === '1er_cycle' && <span className="text-indigo-600 font-medium">1er Cycle</span>}
                                            {s.cible === '2nd_cycle' && <span className="text-purple-600 font-medium">2nd Cycle</span>}
                                            {s.cible === 'classe' && <span>Classe: {s.classe?.nom || s.classe_id}</span>}
                                        </div>
                                        <hr className="my-2 border-slate-100" />
                                        <p className="text-xs font-semibold text-slate-700 mb-2">Examen(s) ({s.horaires?.length || 0}):</p>
                                        <ul className="text-xs space-y-1 text-slate-600 max-h-32 overflow-y-auto pr-1">
                                            {s.horaires?.map(h => (
                                                <li key={h.id} className="flex justify-between border-b border-slate-50 pb-1">
                                                    <span>{h.matiere ? h.matiere.nom : 'Matière'}</span>
                                                    <span>{h.date_composition} ({h.heure_debut?.substring(0, 5)})</span>
                                                </li>
                                            ))}
                                        </ul>
                                    </div>
                                ))
                            )}
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default Programmation;
