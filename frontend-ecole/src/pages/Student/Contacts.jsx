import React, { useState, useEffect } from 'react';
import { Mail, Phone, Users, ShieldAlert } from 'lucide-react';
import { eleveService } from '../../services/api';

const Contacts = () => {
    const [contacts, setContacts] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchContacts();
    }, []);

    const fetchContacts = async () => {
        try {
            setLoading(true);
            const res = await eleveService.getContacts();
            setContacts(res.data.contacts || []);
        } catch (error) {
            console.error("Erreur chargement contacts", error);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="bg-white rounded-xl shadow-md border" style={{ borderColor: 'hsl(var(--text-dark)/0.05)', overflow: 'hidden' }}>
            <div className="p-6 border-b" style={{ borderColor: 'hsl(var(--text-dark)/0.1)', backgroundColor: 'hsl(var(--bg-main))' }}>
                <h2 style={{ fontSize: '1.5rem', color: 'hsl(var(--text-dark))', display: 'flex', alignItems: 'center', gap: '0.5rem', margin: 0 }}>
                    <Users size={24} color="hsl(var(--primary))" />
                    Mes Contacts
                </h2>
                <p className="mt-2 text-sm" style={{ color: 'hsl(var(--text-muted))' }}>
                    Retrouvez ici les coordonnées de vos professeurs et de la direction.
                </p>
            </div>

            {loading ? (
                <div className="p-12 text-center" style={{ color: 'hsl(var(--text-muted))' }}>
                    <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-primary mb-4"></div>
                    <p>Chargement de vos contacts...</p>
                </div>
            ) : (
                <div className="p-6">
                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                        {contacts.map((contact, idx) => (
                            <div key={idx} className="card hover-shadow flex flex-col p-5 border" style={{ borderColor: 'hsl(var(--text-dark)/0.05)' }}>
                                <div className="flex items-center gap-4 mb-4">
                                    <div className="w-12 h-12 rounded-full flex items-center justify-center text-xl font-bold" 
                                        style={{ 
                                            backgroundColor: contact.role === 'Professeur' ? 'hsl(var(--primary)/0.1)' : 'hsl(var(--secondary)/0.1)', 
                                            color: contact.role === 'Professeur' ? 'hsl(var(--primary))' : 'hsl(var(--secondary-dark))' 
                                        }}>
                                        {contact.prenom ? contact.prenom.charAt(0) : ''}{contact.nom ? contact.nom.charAt(0) : ''}
                                    </div>
                                    <div>
                                        <h3 className="font-bold text-gray-800 leading-tight">
                                            {contact.prenom} {contact.nom}
                                        </h3>
                                        <span className="text-xs font-semibold px-2 py-0.5 rounded-full" 
                                            style={{ 
                                                backgroundColor: contact.role === 'Professeur' ? 'hsl(var(--primary)/0.1)' : 'hsl(var(--secondary)/0.1)', 
                                                color: contact.role === 'Professeur' ? 'hsl(var(--primary))' : 'hsl(var(--secondary-dark))' 
                                            }}>
                                            {contact.role}
                                        </span>
                                    </div>
                                </div>
                                
                                <div className="flex-1 space-y-3 mt-2">
                                    {contact.matieres && contact.matieres.length > 0 && (
                                        <div className="text-sm font-medium" style={{ color: 'hsl(var(--primary-dark))' }}>
                                            {contact.matieres.join(', ')}
                                        </div>
                                    )}
                                    
                                    {contact.email && (
                                        <a href={`mailto:${contact.email}`} className="flex items-center gap-2 text-sm hover:underline" style={{ color: 'hsl(var(--text-muted))' }}>
                                            <Mail size={16} /> {contact.email}
                                        </a>
                                    )}
                                    
                                    {contact.telephone && (
                                        <a href={`tel:${contact.telephone}`} className="flex items-center gap-2 text-sm hover:underline" style={{ color: 'hsl(var(--text-muted))' }}>
                                            <Phone size={16} /> {contact.telephone}
                                        </a>
                                    )}
                                </div>
                                
                                {contact.role !== 'Professeur' && (
                                    <button 
                                        onClick={() => alert("La messagerie interne sera bientôt disponible.")}
                                        className="mt-4 w-full py-2 px-4 rounded-md flex justify-center items-center gap-2 text-sm font-semibold transition-colors"
                                        style={{ backgroundColor: 'hsl(var(--primary))', color: 'white' }}>
                                        <ShieldAlert size={16} /> Contacter
                                    </button>
                                )}
                            </div>
                        ))}
                    </div>
                </div>
            )}
        </div>
    );
};

export default Contacts;
