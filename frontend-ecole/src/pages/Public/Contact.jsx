import React from 'react';
import { MapPin, Phone, Mail, Send, Facebook, Instagram, Youtube } from 'lucide-react';

const Contact = () => {
    return (
        <div className="animate-fade-in py-12 container">

            <div className="text-center mb-16">
                <h1 style={{ color: 'hsl(var(--primary-dark))', marginBottom: '1rem' }}>Contactez-Nous</h1>
                <p style={{ maxWidth: '700px', margin: '0 auto', color: 'hsl(var(--text-muted))', fontSize: '1.2rem' }}>
                    Une question ? Besoin d'informations sur les inscriptions ? N'hésitez pas à nous contacter ou à nous rendre visite.
                </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-12 mb-16">

                {/* Contact Information */}
                <div className="flex flex-col gap-8">
                    <div>
                        <h2 style={{ fontSize: '1.8rem', color: 'hsl(var(--text-dark))', marginBottom: '1.5rem' }}>
                            Nos Coordonnées
                        </h2>
                        <div className="flex flex-col gap-6">

                            <div className="flex items-start gap-4">
                                <div style={{ backgroundColor: 'hsl(var(--primary) / 0.1)', padding: '0.75rem', borderRadius: '50%', color: 'hsl(var(--primary))' }}>
                                    <MapPin size={24} />
                                </div>
                                <div>
                                    <h3 style={{ fontSize: '1.1rem', color: 'hsl(var(--text-dark))', marginBottom: '0.25rem' }}>Adresse</h3>
                                    <p style={{ color: 'hsl(var(--text-muted))' }}>123 Avenue de l'École<br />Quartier de l'Excellence, B.P. 456<br />Ville, Pays</p>
                                </div>
                            </div>

                            <div className="flex items-start gap-4">
                                <div style={{ backgroundColor: 'hsl(var(--primary) / 0.1)', padding: '0.75rem', borderRadius: '50%', color: 'hsl(var(--primary))' }}>
                                    <Phone size={24} />
                                </div>
                                <div>
                                    <h3 style={{ fontSize: '1.1rem', color: 'hsl(var(--text-dark))', marginBottom: '0.25rem' }}>Téléphone</h3>
                                    <p style={{ color: 'hsl(var(--text-muted))' }}>Secrétariat : +123 456 789 000<br />Direction : +123 456 789 001</p>
                                </div>
                            </div>

                            <div className="flex items-start gap-4">
                                <div style={{ backgroundColor: 'hsl(var(--primary) / 0.1)', padding: '0.75rem', borderRadius: '50%', color: 'hsl(var(--primary))' }}>
                                    <Mail size={24} />
                                </div>
                                <div>
                                    <h3 style={{ fontSize: '1.1rem', color: 'hsl(var(--text-dark))', marginBottom: '0.25rem' }}>Email</h3>
                                    <p style={{ color: 'hsl(var(--text-muted))' }}>contact@notredame.edu<br />inscriptions@notredame.edu</p>
                                </div>
                            </div>

                        </div>
                    </div>

                    <div>
                        <h2 style={{ fontSize: '1.5rem', color: 'hsl(var(--text-dark))', marginBottom: '1rem' }}>
                            Suivez-Nous
                        </h2>
                        <div className="flex gap-4">
                            <a href="https://facebook.com" target="_blank" rel="noreferrer" className="flex items-center justify-center p-3 rounded-full hover-bg-primary text-primary hover-text-white border-primary transition-all decoration-none">
                                <Facebook size={24} />
                            </a>
                            <a href="https://instagram.com" target="_blank" rel="noreferrer" className="flex items-center justify-center p-3 rounded-full hover-bg-primary text-primary hover-text-white border-primary transition-all decoration-none">
                                <Instagram size={24} />
                            </a>
                            <a href="https://youtube.com" target="_blank" rel="noreferrer" className="flex items-center justify-center p-3 rounded-full hover-bg-primary text-primary hover-text-white border-primary transition-all decoration-none">
                                <Youtube size={24} />
                            </a>
                        </div>
                    </div>
                </div>

                {/* Contact Form */}
                <div className="bg-white p-8 rounded-xl shadow-md border" style={{ borderColor: 'hsl(var(--text-dark)/0.05)' }}>
                    <h2 style={{ fontSize: '1.8rem', color: 'hsl(var(--text-dark))', marginBottom: '1.5rem' }}>
                        Laissez-nous un message
                    </h2>
                    <form className="flex flex-col gap-4" onSubmit={(e) => { e.preventDefault(); alert('Message envoyé !'); }}>

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label className="block text-sm font-medium mb-1" style={{ color: 'hsl(var(--text-dark))' }}>Nom complet</label>
                                <input type="text" className="w-full form-input" required placeholder="Ex: Jean Dupont" />
                            </div>
                            <div>
                                <label className="block text-sm font-medium mb-1" style={{ color: 'hsl(var(--text-dark))' }}>Email</label>
                                <input type="email" className="w-full form-input" required placeholder="Ex: jean@example.com" />
                            </div>
                        </div>

                        <div>
                            <label className="block text-sm font-medium mb-1" style={{ color: 'hsl(var(--text-dark))' }}>Objet</label>
                            <input type="text" className="w-full form-input" required placeholder="Ex: Renseignement inscription" />
                        </div>

                        <div>
                            <label className="block text-sm font-medium mb-1" style={{ color: 'hsl(var(--text-dark))' }}>Message</label>
                            <textarea className="w-full form-input" rows="5" required placeholder="Comment pouvons-nous vous aider ?"></textarea>
                        </div>

                        <button type="submit" className="btn btn-primary mt-2">
                            Envoyer le message <Send size={18} />
                        </button>

                    </form>
                </div>

            </div>

            {/* Map */}
            <div className="w-full h-96 rounded-xl overflow-hidden shadow-md">
                <iframe
                    title="Google Maps"
                    src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3979.970222013144!2d1.0601445152504625!3d6.130985295551325!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x1023e1c667a74799%3A0xcda8d0d540003bde!2sLom%C3%A9%2C%20Togo!5e0!3m2!1sfr!2sfr!4v1620000000000!5m2!1sfr!2sfr"
                    width="100%"
                    height="100%"
                    style={{ border: 0 }}
                    allowFullScreen=""
                    loading="lazy"
                ></iframe>
            </div>

            <style>{`
        .form-input {
          padding: 0.75rem;
          border-radius: var(--radius-md);
          border: 1px solid hsl(var(--text-dark) / 0.2);
          outline: none;
          transition: border-color 0.2s;
          font-family: inherit;
        }
        .form-input:focus { border-color: hsl(var(--primary)); box-shadow: 0 0 0 2px hsl(var(--primary)/0.2); }
        .w-full { width: 100%; }
        
        .hover-bg-primary:hover { background-color: hsl(var(--primary)); }
        .text-primary { color: hsl(var(--primary)); }
        .hover-text-white:hover { color: white; }
        .border-primary { border: 2px solid hsl(var(--primary)); }
      `}</style>
        </div>
    );
};

export default Contact;
