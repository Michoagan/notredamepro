import React from 'react';
import { Link } from 'react-router-dom';
import { Facebook, Instagram, Youtube, Phone, Mail, MapPin } from 'lucide-react';

const Footer = () => {
    return (
        <footer style={{ backgroundColor: 'hsl(var(--text-dark))', color: 'hsl(var(--bg-main))', padding: '4rem 0 2rem 0', marginTop: 'auto' }}>
            <div className="container grid grid-cols-1 md:grid-cols-4 gap-8 mb-8">

                {/* Brand & Presentation */}
                <div className="flex flex-col gap-4">
                    <div className="flex items-center gap-2">
                        <div style={{
                            width: '2.5rem', height: '2.5rem',
                            backgroundColor: 'hsl(var(--primary))',
                            borderRadius: 'var(--radius-lg)',
                            display: 'flex', alignItems: 'center', justifyContent: 'center',
                            fontWeight: 'bold', color: 'white'
                        }}>
                            ND
                        </div>
                        <span style={{ fontSize: '1.25rem', fontWeight: 'bold' }}>
                            Notre Dame
                        </span>
                    </div>
                    <p style={{ color: 'hsl(var(--text-muted))', fontSize: '0.9rem' }}>
                        Un établissement d'excellence qui accompagne vos enfants du primaire au secondaire avec un suivi pédagogique rigoureux.
                    </p>
                </div>

                {/* Quick Links */}
                <div className="flex flex-col gap-4">
                    <h3 style={{ color: 'white', fontSize: '1.1rem' }}>Liens Rapides</h3>
                    <ul style={{ listStyle: 'none', display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
                        <li><Link to="/about" style={{ color: 'hsl(var(--text-muted))', transition: 'color 0.2s' }}>À propos de nous</Link></li>
                        <li><Link to="/classes" style={{ color: 'hsl(var(--text-muted))', transition: 'color 0.2s' }}>Nos Classes</Link></li>
                        <li><Link to="/news" style={{ color: 'hsl(var(--text-muted))', transition: 'color 0.2s' }}>Actualités</Link></li>
                        <li><Link to="/rules" style={{ color: 'hsl(var(--text-muted))', transition: 'color 0.2s' }}>Règlement intérieur</Link></li>
                    </ul>
                </div>

                {/* Contact Info */}
                <div className="flex flex-col gap-4">
                    <h3 style={{ color: 'white', fontSize: '1.1rem' }}>Contacts</h3>
                    <ul style={{ listStyle: 'none', display: 'flex', flexDirection: 'column', gap: '1rem' }}>
                        <li className="flex items-center gap-3" style={{ color: 'hsl(var(--text-muted))' }}>
                            <MapPin size={18} color="hsl(var(--primary-light))" />
                            <span>123 Avenue de l'École, Ville</span>
                        </li>
                        <li className="flex items-center gap-3" style={{ color: 'hsl(var(--text-muted))' }}>
                            <Phone size={18} color="hsl(var(--primary-light))" />
                            <span>+123 456 789 000</span>
                        </li>
                        <li className="flex items-center gap-3" style={{ color: 'hsl(var(--text-muted))' }}>
                            <Mail size={18} color="hsl(var(--primary-light))" />
                            <span>contact@notredame.edu</span>
                        </li>
                    </ul>
                </div>

                {/* Socials & WhatsApp */}
                <div className="flex flex-col gap-4">
                    <h3 style={{ color: 'white', fontSize: '1.1rem' }}>Réseaux Sociaux</h3>
                    <div className="flex gap-4">
                        <a href="https://facebook.com" target="_blank" rel="noreferrer" style={{
                            width: '40px', height: '40px', borderRadius: '50%', backgroundColor: 'rgba(255,255,255,0.1)',
                            display: 'flex', alignItems: 'center', justifyContent: 'center', transition: 'var(--transition)'
                        }}>
                            <Facebook size={20} />
                        </a>
                        <a href="https://instagram.com" target="_blank" rel="noreferrer" style={{
                            width: '40px', height: '40px', borderRadius: '50%', backgroundColor: 'rgba(255,255,255,0.1)',
                            display: 'flex', alignItems: 'center', justifyContent: 'center', transition: 'var(--transition)'
                        }}>
                            <Instagram size={20} />
                        </a>
                        <a href="https://youtube.com" target="_blank" rel="noreferrer" style={{
                            width: '40px', height: '40px', borderRadius: '50%', backgroundColor: 'rgba(255,255,255,0.1)',
                            display: 'flex', alignItems: 'center', justifyContent: 'center', transition: 'var(--transition)'
                        }}>
                            <Youtube size={20} />
                        </a>
                    </div>

                    <a href="https://wa.me/123456789000" target="_blank" rel="noreferrer" className="btn mt-2"
                        style={{ backgroundColor: '#25D366', color: 'white', width: 'fit-content' }}>
                        Tchat WhatsApp
                    </a>
                </div>
            </div>

            <div className="container" style={{ borderTop: '1px solid rgba(255,255,255,0.1)', paddingTop: '2rem', textAlign: 'center', color: 'hsl(var(--text-muted))', fontSize: '0.9rem' }}>
                <p>© {new Date().getFullYear()} C.S. Notre Dame de Toutes Graces. Tous droits réservés.</p>
            </div>
        </footer>
    );
};

export default Footer;
