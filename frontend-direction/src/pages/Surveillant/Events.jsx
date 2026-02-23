import React, { useState } from 'react';
import { Calendar, MapPin, Clock, Plus } from 'lucide-react';

export default function Events() {
    // Mock events
    const [events, setEvents] = useState([
        { id: 1, title: 'Conseil de Classe 6ème A', date: '2024-03-15', time: '14:00', location: 'Salle des Profs' },
        { id: 2, title: 'Réunion Parents-Profs', date: '2024-03-20', time: '09:00', location: 'Amphithéâtre' },
    ]);

    return (
        <div className="space-y-6">
            <header className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-slate-800">Événements Scolaires</h1>
                    <p className="text-slate-500">Calendrier des activités et sorties</p>
                </div>
                <button className="flex items-center space-x-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition">
                    <Plus className="w-4 h-4" />
                    <span>Ajouter Événement</span>
                </button>
            </header>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <div className="lg:col-span-2 space-y-4">
                    {events.map(event => (
                        <div key={event.id} className="bg-white p-4 rounded-xl shadow-sm border border-slate-200 flex items-start space-x-4">
                            <div className="bg-blue-50 text-blue-600 p-3 rounded-lg text-center min-w-[70px]">
                                <div className="text-xs font-bold uppercase">{new Date(event.date).toLocaleString('fr-FR', { month: 'short' })}</div>
                                <div className="text-2xl font-bold">{new Date(event.date).getDate()}</div>
                            </div>
                            <div className="flex-1">
                                <h3 className="font-bold text-slate-800 text-lg">{event.title}</h3>
                                <div className="flex flex-wrap gap-4 mt-2 text-sm text-slate-500">
                                    <div className="flex items-center">
                                        <Clock className="w-4 h-4 mr-1.5" />
                                        {event.time}
                                    </div>
                                    <div className="flex items-center">
                                        <MapPin className="w-4 h-4 mr-1.5" />
                                        {event.location}
                                    </div>
                                </div>
                            </div>
                        </div>
                    ))}
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
