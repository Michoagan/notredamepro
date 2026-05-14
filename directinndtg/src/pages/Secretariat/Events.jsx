import React, { useState, useEffect } from 'react';
import { Calendar, MapPin, Clock, Plus, Loader2 } from 'lucide-react';
import * as secretariatService from '../../services/secretariat';

export default function Events() {
    const [events, setEvents] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        loadEvents();
    }, []);

    const loadEvents = async () => {
        setLoading(true);
        try {
            const data = await secretariatService.getEvenements();
            // Expected data format from SecretariatController::evenements 
            // is just a JSON array.
            setEvents(data);
        } catch (error) {
            console.error("Erreur chargement événements", error);
        } finally {
            setLoading(false);
        }
    };

    const handleAddEvent = () => {
        alert("Formulaire de création d'événement à implémenter.");
    };

    return (
        <div className="space-y-6">
            <header className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-slate-800">Événements Scolaires</h1>
                    <p className="text-slate-500">Calendrier des activités et sorties</p>
                </div>
                <button
                    onClick={handleAddEvent}
                    className="flex items-center space-x-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition"
                >
                    <Plus className="w-4 h-4" />
                    <span>Ajouter Événement</span>
                </button>
            </header>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <div className="lg:col-span-2 space-y-4">
                    {loading ? (
                        <div className="p-12 flex justify-center text-slate-500">
                            <Loader2 className="w-8 h-8 animate-spin text-blue-600" />
                        </div>
                    ) : events.length === 0 ? (
                        <div className="p-12 text-center text-slate-500 bg-white rounded-xl shadow-sm border border-slate-200">
                            <Calendar className="w-12 h-12 text-slate-300 mx-auto mb-4" />
                            <p>Aucun événement programmé.</p>
                        </div>
                    ) : (
                        events.map(event => (
                            <div key={event.id} className="bg-white p-4 rounded-xl shadow-sm border border-slate-200 flex items-start space-x-4">
                                <div className="bg-blue-50 text-blue-600 p-3 rounded-lg text-center min-w-[70px]">
                                    <div className="text-xs font-bold uppercase">{new Date(event.date_debut).toLocaleString('fr-FR', { month: 'short' })}</div>
                                    <div className="text-2xl font-bold">{new Date(event.date_debut).getDate()}</div>
                                </div>
                                <div className="flex-1">
                                    <div className="flex justify-between items-start">
                                        <h3 className="font-bold text-slate-800 text-lg">{event.titre}</h3>
                                        <span className={`px-2 py-1 text-xs rounded-full font-medium ${event.type === 'pedagogique' ? 'bg-purple-100 text-purple-700' : 'bg-green-100 text-green-700'}`}>
                                            {event.type}
                                        </span>
                                    </div>
                                    <p className="text-sm text-slate-600 mt-1 line-clamp-2">{event.description}</p>
                                    <div className="flex flex-wrap gap-4 mt-3 text-sm text-slate-500">
                                        <div className="flex items-center">
                                            <Clock className="w-4 h-4 mr-1.5" />
                                            {new Date(event.date_debut).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })}
                                        </div>
                                        {event.lieu && (
                                            <div className="flex items-center">
                                                <MapPin className="w-4 h-4 mr-1.5" />
                                                {event.lieu}
                                            </div>
                                        )}
                                    </div>
                                </div>
                            </div>
                        ))
                    )}
                </div>

                <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-200 h-fit">
                    <h3 className="font-semibold text-slate-800 mb-4 flex items-center gap-2">
                        <Calendar className="w-5 h-5 text-blue-500" />
                        Calendrier
                    </h3>
                    <div className="text-center text-slate-400 py-8 text-sm">
                        Composant Calendrier Interactif (Prochainement)
                    </div>
                </div>
            </div>
        </div>
    );
}
