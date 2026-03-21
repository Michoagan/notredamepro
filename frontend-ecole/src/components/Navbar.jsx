import React, { useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { Menu, X, User, LogIn } from 'lucide-react';

const Navbar = () => {
    const [isOpen, setIsOpen] = useState(false);
    const location = useLocation();

    const navLinks = [
        { name: 'Accueil', path: '/' },
        { name: 'À Propos', path: '/about' },
        { name: 'Classes', path: '/classes' },
        { name: 'Actualités', path: '/news' },
        { name: 'Règlement', path: '/rules' },
        { name: 'Contact', path: '/contact' },
    ];

    const isActive = (path) => location.pathname === path;

    return (
        <nav style={{ backgroundColor: 'white', borderBottom: '1px solid hsl(var(--text-dark) / 0.1)', position: 'sticky', top: 0, zIndex: 50 }}>
            <div className="container flex justify-between items-center" style={{ height: '4rem' }}>

                {/* Logo Section */}
                <Link to="/" className="flex items-center gap-2">
                    <div style={{
                        width: '2.5rem', height: '2.5rem',
                        backgroundColor: 'hsl(var(--primary))',
                        borderRadius: 'var(--radius-lg)',
                        display: 'flex', alignItems: 'center', justifyContent: 'center',
                        color: 'white', fontWeight: 'bold'
                    }}>
                        ND
                    </div>
                    <span style={{ fontSize: '1.25rem', fontWeight: 'bold', color: 'hsl(var(--primary-dark))' }}>
                        Notre Dame
                    </span>
                </Link>

                {/* Desktop Menu */}
                <div style={{ display: 'none' }} className="md-flex items-center gap-6">
                    {navLinks.map((link) => (
                        <Link
                            key={link.name}
                            to={link.path}
                            style={{
                                color: isActive(link.path) ? 'hsl(var(--primary))' : 'hsl(var(--text-dark))',
                                fontWeight: isActive(link.path) ? '600' : '400',
                                transition: 'var(--transition)'
                            }}
                            onMouseEnter={(e) => e.currentTarget.style.color = 'hsl(var(--primary))'}
                            onMouseLeave={(e) => e.currentTarget.style.color = isActive(link.path) ? 'hsl(var(--primary))' : 'hsl(var(--text-dark))'}
                        >
                            {link.name}
                        </Link>
                    ))}

                    <Link to="/student/dashboard" className="btn btn-primary">
                        <User size={18} />
                        Espace Élève
                    </Link>
                </div>

                {/* Mobile Menu Button */}
                <button
                    className="md-none"
                    onClick={() => setIsOpen(!isOpen)}
                    style={{ color: 'hsl(var(--text-dark))' }}
                >
                    {isOpen ? <X size={24} /> : <Menu size={24} />}
                </button>
            </div>

            {/* Mobile Menu */}
            {isOpen && (
                <div style={{ padding: '1rem', backgroundColor: 'white', borderTop: '1px solid hsl(var(--text-dark) / 0.1)' }}>
                    <div className="flex flex-col gap-4">
                        {navLinks.map((link) => (
                            <Link
                                key={link.name}
                                to={link.path}
                                onClick={() => setIsOpen(false)}
                                style={{
                                    color: isActive(link.path) ? 'hsl(var(--primary))' : 'hsl(var(--text-dark))',
                                    fontWeight: isActive(link.path) ? '600' : '400',
                                    padding: '0.5rem',
                                    borderRadius: 'var(--radius-sm)',
                                    backgroundColor: isActive(link.path) ? 'hsl(var(--primary) / 0.1)' : 'transparent'
                                }}
                            >
                                {link.name}
                            </Link>
                        ))}
                        <Link
                            to="/student/dashboard"
                            onClick={() => setIsOpen(false)}
                            className="btn btn-primary mt-2 flex justify-center"
                        >
                            <LogIn size={18} />
                            Connexion Élève
                        </Link>
                    </div>
                </div>
            )}
            <style>{`
        @media (min-width: 768px) {
          .md-flex { display: flex !important; }
          .md-none { display: none !important; }
        }
      `}</style>
        </nav>
    );
};

export default Navbar;
