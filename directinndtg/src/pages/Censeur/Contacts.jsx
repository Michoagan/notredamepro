import React, { useState, useEffect } from 'react';
import censeurService from '../../services/censeur';
import { Phone, Mail, Search, Users } from 'lucide-react';

const Contacts = () => {
    const [professeurs, setProfesseurs] = useState([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');

    useEffect(() => {
        loadContacts();
    }, []);

    const loadContacts = async () => {
        try {
            const response = await censeurService.getContacts();
            if (response.data && response.data.success) {
                setProfesseurs(response.data.professeurs);
            }
        } catch (error) {
            console.error(error);
        } finally {
            setLoading(false);
        }
    };

    const filteredProfs = professeurs.filter(p => {
        const nom = p.last_name || '';
        const prenom = p.first_name || '';
        return nom.toLowerCase().includes(searchTerm.toLowerCase()) ||
            prenom.toLowerCase().includes(searchTerm.toLowerCase());
    });

    return (
        <div className="space-y-6">
            <h1 className="text-2xl font-bold text-slate-900">Annuaire des Contacts</h1>

            {/* Barre de recherche */}
            <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-400 w-5 h-5" />
                <input
                    type="text"
                    placeholder="Rechercher un professeur..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="w-full pl-10 pr-4 py-3 border border-slate-200 rounded-xl shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {loading ? (
                    <p className="text-slate-500 col-span-full text-center">Chargement...</p>
                ) : filteredProfs.length === 0 ? (
                    <p className="text-slate-500 col-span-full text-center">Aucun contact trouvé.</p>
                ) : (
                    filteredProfs.map(prof => (
                        <div key={prof.id} className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm hover:shadow-md transition">
                            <div className="flex items-center space-x-4 mb-4">
                                <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center text-blue-600 font-bold text-lg">
                                    {(prof.last_name && prof.last_name[0]) || ''}{(prof.first_name && prof.first_name[0]) || ''}
                                </div>
                                <div>
                                    <h3 className="font-bold text-slate-900">{prof.last_name} {prof.first_name}</h3>
                                    <span className="text-xs font-semibold px-2 py-0.5 bg-slate-100 text-slate-600 rounded-full uppercase">
                                        {prof.matiere ? prof.matiere.nom : (prof.specialite || 'Professeur')}
                                    </span>
                                </div>
                            </div>

                            <div className="space-y-3">
                                {prof.telephone && (
                                    <div className="flex items-center space-x-3 text-slate-600">
                                        <Phone className="w-4 h-4 text-green-500" />
                                        <div className="flex flex-col">
                                            <span className="text-sm font-medium">{prof.telephone}</span>
                                            <a
                                                href={`https://wa.me/${prof.telephone.replace(/\s+/g, '')}`}
                                                target="_blank"
                                                rel="noreferrer"
                                                className="text-xs text-green-600 hover:underline"
                                            >
                                                Contacter sur WhatsApp
                                            </a>
                                        </div>
                                    </div>
                                )}
                                {prof.email && (
                                    <div className="flex items-center space-x-3 text-slate-600">
                                        <Mail className="w-4 h-4 text-slate-400" />
                                        <a href={`mailto:${prof.email}`} className="text-sm hover:text-blue-600 transition">
                                            {prof.email}
                                        </a>
                                    </div>
                                )}
                            </div>
                        </div>
                    ))
                )}
            </div>
        </div>
    );
};

export default Contacts;
