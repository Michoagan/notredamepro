import React, { useState, useEffect } from 'react';
import surveillantService from '../../services/surveillant';
import { Calendar, Plus, Users, MapPin, Clock, Check } from 'lucide-react';

const Events = () => {
    const [events, setEvents] = useState([]);
    const [loading, setLoading] = useState(true);
    const [showModal, setShowModal] = useState(false);
    const [classes, setClasses] = useState([]);

    // Form State
    const [formData, setFormData] = useState({
        titre: '',
        description: '',
        date_debut: '',
        date_fin: '',
        lieu: '',
        type: 'Reunion',
        pour_tous: false,
        classes: []
    });

    useEffect(() => {
        loadData();
    }, []);

    const loadData = async () => {
        setLoading(true);
        try {
            const [eventsData, classesData] = await Promise.all([
                surveillantService.getEvenements(),
                // Simplification: On suppose qu'on a un endpoint pour les classes ou on utilise un mock/service existant
                // Pour l'instant on va utiliser une liste vide ou importer un service de classes si dispo
                fetchClasses()
            ]);

            if (eventsData.data) {
                setEvents(eventsData.data);
            }
        } catch (error) {
            console.error(error);
        } finally {
            setLoading(false);
        }
    };

    // Placeholder pour Fetch classes (normalement via classeService)
    const fetchClasses = async () => {
        // Mock ou appel réel
        // const response = await api.get('/classes');
        // setClasses(response.data);
        // En attendant le service Classe, on simule des données ou on fait un appel direct
        // TODO: Utiliser le vrai service Classe
        try {
            const response = await fetch('${import.meta.env.VITE_API_BASE_URL}/api/classes/index', { // URL brute temporaire
                headers: { 'Authorization': `Bearer ${localStorage.getItem('token')}` }
            });
            const data = await response.json();
            setClasses(data);
        } catch (e) {
            console.error("Erreur chargement classes", e);
            setClasses([]);
        }
    };

    const handleInputChange = (e) => {
        const { name, value, type, checked } = e.target;
        setFormData(prev => ({
            ...prev,
            [name]: type === 'checkbox' ? checked : value
        }));
    };

    const handleClassToggle = (classId) => {
        setFormData(prev => {
            const currentClasses = prev.classes;
            if (currentClasses.includes(classId)) {
                return { ...prev, classes: currentClasses.filter(id => id !== classId) };
            } else {
                return { ...prev, classes: [...currentClasses, classId] };
            }
        });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const response = await surveillantService.storeEvenement(formData);
            if (response.data.success) {
                setShowModal(false);
                setFormData({
                    titre: '',
                    description: '',
                    date_debut: '',
                    date_fin: '',
                    lieu: '',
                    type: 'Reunion',
                    pour_tous: false,
                    classes: []
                });
                loadData(); // Recharger la liste
            }
        } catch (error) {
            console.error("Erreur création événement", error);
            alert("Erreur lors de la création de l'événement");
        }
    };

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <h1 className="text-2xl font-bold text-slate-900">Événements Scolaires</h1>
                <button
                    onClick={() => setShowModal(true)}
                    className="bg-blue-600 text-white px-4 py-2 rounded-lg flex items-center space-x-2 hover:bg-blue-700 transition"
                >
                    <Plus className="w-4 h-4" />
                    <span>Nouvel Événement</span>
                </button>
            </div>

            {/* Liste des Événements */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {loading ? (
                    <p className="text-slate-500">Chargement des événements...</p>
                ) : events.length === 0 ? (
                    <div className="col-span-full bg-white p-8 rounded-xl border border-slate-200 text-center">
                        <Calendar className="w-12 h-12 text-slate-300 mx-auto mb-3" />
                        <p className="text-slate-500">Aucun événement planifié.</p>
                    </div>
                ) : (
                    events.map(event => (
                        <div key={event.id} className="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden hover:shadow-md transition">
                            <div className="p-5 border-b border-slate-100">
                                <div className="flex justify-between items-start">
                                    <div>
                                        <h3 className="font-semibold text-lg text-slate-900">{event.titre}</h3>
                                        <span className={`inline-block mt-1 px-2 py-0.5 rounded text-xs font-medium 
                                            ${event.type === 'Fête' ? 'bg-purple-100 text-purple-700' :
                                                event.type === 'Examen' ? 'bg-red-100 text-red-700' :
                                                    'bg-blue-100 text-blue-700'}`}>
                                            {event.type}
                                        </span>
                                    </div>
                                    <div className="bg-slate-50 p-2 rounded-lg text-center min-w-[60px]">
                                        <div className="text-xs text-slate-500 uppercase">{new Date(event.date_debut).toLocaleString('default', { month: 'short' })}</div>
                                        <div className="text-xl font-bold text-slate-900">{new Date(event.date_debut).getDate()}</div>
                                    </div>
                                </div>
                            </div>
                            <div className="p-5 space-y-4">
                                <p className="text-slate-600 text-sm line-clamp-2">{event.description}</p>

                                <div className="space-y-2 text-sm text-slate-500">
                                    <div className="flex items-center space-x-2">
                                        <Clock className="w-4 h-4" />
                                        <span>
                                            {new Date(event.date_debut).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                                            -
                                            {new Date(event.date_fin).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                                        </span>
                                    </div>
                                    {event.lieu && (
                                        <div className="flex items-center space-x-2">
                                            <MapPin className="w-4 h-4" />
                                            <span>{event.lieu}</span>
                                        </div>
                                    )}
                                    <div className="flex items-center space-x-2">
                                        <Users className="w-4 h-4" />
                                        <span>
                                            {event.pour_tous ? 'Toute l\'école' :
                                                event.classes && event.classes.length > 0 ?
                                                    `${event.classes.length} Classes` : 'Aucune classe spécifiée'}
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    ))
                )}
            </div>

            {/* Modal Création */}
            {showModal && (
                <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
                    <div className="bg-white rounded-xl shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
                        <div className="p-6 border-b border-slate-100 flex justify-between items-center">
                            <h2 className="text-xl font-bold text-slate-900">Nouvel Événement</h2>
                            <button onClick={() => setShowModal(false)} className="text-slate-400 hover:text-slate-600">
                                &times;
                            </button>
                        </div>
                        <form onSubmit={handleSubmit} className="p-6 space-y-6">
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                                <div className="space-y-2">
                                    <label className="text-sm font-medium text-slate-700">Titre</label>
                                    <input
                                        type="text"
                                        name="titre"
                                        required
                                        value={formData.titre}
                                        onChange={handleInputChange}
                                        className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                    />
                                </div>
                                <div className="space-y-2">
                                    <label className="text-sm font-medium text-slate-700">Type</label>
                                    <select
                                        name="type"
                                        value={formData.type}
                                        onChange={handleInputChange}
                                        className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                    >
                                        <option value="Reunion">Réunion</option>
                                        <option value="Fête">Fête</option>
                                        <option value="Examen">Examen</option>
                                        <option value="Autre">Autre</option>
                                    </select>
                                </div>
                            </div>

                            <div className="space-y-2">
                                <label className="text-sm font-medium text-slate-700">Description</label>
                                <textarea
                                    name="description"
                                    required
                                    rows="3"
                                    value={formData.description}
                                    onChange={handleInputChange}
                                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                ></textarea>
                            </div>

                            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                                <div className="space-y-2">
                                    <label className="text-sm font-medium text-slate-700">Date Début</label>
                                    <input
                                        type="datetime-local"
                                        name="date_debut"
                                        required
                                        value={formData.date_debut}
                                        onChange={handleInputChange}
                                        className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                    />
                                </div>
                                <div className="space-y-2">
                                    <label className="text-sm font-medium text-slate-700">Date Fin</label>
                                    <input
                                        type="datetime-local"
                                        name="date_fin"
                                        required
                                        value={formData.date_fin}
                                        onChange={handleInputChange}
                                        className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                    />
                                </div>
                            </div>

                            <div className="space-y-2">
                                <label className="text-sm font-medium text-slate-700">Lieu (Optionnel)</label>
                                <input
                                    type="text"
                                    name="lieu"
                                    value={formData.lieu}
                                    onChange={handleInputChange}
                                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                />
                            </div>

                            <div className="space-y-4 pt-4 border-t border-slate-100">
                                <div className="flex items-center space-x-2">
                                    <input
                                        type="checkbox"
                                        name="pour_tous"
                                        id="pour_tous"
                                        checked={formData.pour_tous}
                                        onChange={handleInputChange}
                                        className="rounded text-blue-600 focus:ring-blue-500 h-4 w-4 border-slate-300"
                                    />
                                    <label htmlFor="pour_tous" className="text-sm font-medium text-slate-900">
                                        Concerne toute l'école (Toutes les classes)
                                    </label>
                                </div>

                                {!formData.pour_tous && (
                                    <div className="space-y-2">
                                        <label className="text-sm font-medium text-slate-700">Sélectionner les classes concernées</label>
                                        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-2 max-h-40 overflow-y-auto p-2 border border-slate-200 rounded-lg">
                                            {classes.map(classe => (
                                                <div
                                                    key={classe.id}
                                                    onClick={() => handleClassToggle(classe.id)}
                                                    className={`cursor-pointer px-3 py-2 rounded-md text-sm border transition flex items-center justify-between
                                                        ${formData.classes.includes(classe.id)
                                                            ? 'bg-blue-50 border-blue-200 text-blue-700'
                                                            : 'bg-white border-slate-200 text-slate-600 hover:border-slate-300'}`}
                                                >
                                                    <span>{classe.nom}</span>
                                                    {formData.classes.includes(classe.id) && <Check className="w-3 h-3" />}
                                                </div>
                                            ))}
                                        </div>
                                    </div>
                                )}
                            </div>

                            <div className="flex justify-end space-x-3 pt-6">
                                <button
                                    type="button"
                                    onClick={() => setShowModal(false)}
                                    className="px-4 py-2 border border-slate-300 rounded-lg text-slate-700 hover:bg-slate-50 transition"
                                >
                                    Annuler
                                </button>
                                <button
                                    type="submit"
                                    className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition"
                                >
                                    Créer l'événement
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
};

export default Events;
