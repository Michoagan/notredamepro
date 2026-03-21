import React from 'react';
import { Link } from 'react-router-dom';
import { Users, BookOpen, GraduationCap, ArrowRight, ShieldCheck, Clock } from 'lucide-react';

const Home = () => {
    return (
        <div className="animate-fade-in">
            {/* Hero Section */}
            <section style={{
                position: 'relative',
                backgroundColor: 'hsl(var(--primary-dark))',
                color: 'white',
                padding: '6rem 1.5rem',
                overflow: 'hidden'
            }}>
                <div style={{
                    position: 'absolute', top: 0, left: 0, right: 0, bottom: 0,
                    background: 'linear-gradient(135deg, hsl(var(--primary-dark)) 0%, hsl(var(--primary)) 100%)',
                    opacity: 0.9, zIndex: 1
                }}></div>
                <div className="container" style={{ position: 'relative', zIndex: 2, textAlign: 'center' }}>
                    <h1 style={{ color: 'white', marginBottom: '1.5rem', fontSize: '3rem' }}>
                        Bienvenue au C.S. Notre Dame
                    </h1>
                    <p style={{ fontSize: '1.25rem', maxWidth: '800px', margin: '0 auto 2.5rem auto', color: 'hsl(var(--text-light) / 0.9)' }}>
                        L'excellence académique alliée à des valeurs morales fortes pour former les leaders de demain, du primaire au secondaire.
                    </p>
                    <div className="flex justify-center gap-4 flex-col md-flex-row">
                        <Link to="/about" className="btn" style={{ backgroundColor: 'white', color: 'hsl(var(--primary-dark))' }}>
                            Découvrir l'école
                        </Link>
                        <Link to="/student/login" className="btn btn-secondary">
                            Espace Élève <ArrowRight size={18} />
                        </Link>
                    </div>
                </div>
            </section>

            {/* Stats Section */}
            <section className="py-12 bg-white">
                <div className="container">
                    <div className="grid grid-cols-1 md-grid-cols-3 gap-8 text-center">
                        <div className="flex flex-col items-center">
                            <div style={{ backgroundColor: 'hsl(var(--primary) / 0.1)', padding: '1.5rem', borderRadius: '50%', color: 'hsl(var(--primary))', marginBottom: '1rem' }}>
                                <Users size={40} />
                            </div>
                            <h3 style={{ fontSize: '2.5rem', color: 'hsl(var(--primary-dark))', marginBottom: '0.5rem' }}>1200+</h3>
                            <p style={{ color: 'hsl(var(--text-muted))', fontSize: '1.1rem', fontWeight: 500 }}>Élèves Inscrits</p>
                        </div>
                        <div className="flex flex-col items-center">
                            <div style={{ backgroundColor: 'hsl(var(--secondary) / 0.1)', padding: '1.5rem', borderRadius: '50%', color: 'hsl(var(--secondary-dark))', marginBottom: '1rem' }}>
                                <GraduationCap size={40} />
                            </div>
                            <h3 style={{ fontSize: '2.5rem', color: 'hsl(var(--primary-dark))', marginBottom: '0.5rem' }}>85+</h3>
                            <p style={{ color: 'hsl(var(--text-muted))', fontSize: '1.1rem', fontWeight: 500 }}>Enseignants Qualifiés</p>
                        </div>
                        <div className="flex flex-col items-center">
                            <div style={{ backgroundColor: 'hsl(var(--accent) / 0.1)', padding: '1.5rem', borderRadius: '50%', color: 'hsl(var(--accent))', marginBottom: '1rem' }}>
                                <BookOpen size={40} />
                            </div>
                            <h3 style={{ fontSize: '2.5rem', color: 'hsl(var(--primary-dark))', marginBottom: '0.5rem' }}>30+</h3>
                            <p style={{ color: 'hsl(var(--text-muted))', fontSize: '1.1rem', fontWeight: 500 }}>Classes (Primaire & Secondaire)</p>
                        </div>
                    </div>
                </div>
            </section>

            {/* Mot du Directeur */}
            <section className="py-20" style={{ backgroundColor: 'hsl(var(--bg-main))' }}>
                <div className="container grid grid-cols-1 gap-12 items-center" style={{ gridTemplateColumns: 'minmax(0,1fr) minmax(0,2fr)' }}>
                    <div style={{
                        height: '400px', backgroundColor: 'hsl(var(--primary) / 0.1)', borderRadius: 'var(--radius-lg)',
                        display: 'flex', alignItems: 'center', justifyContent: 'center', backgroundImage: 'url(https://images.unsplash.com/photo-1546410531-bea5aad43fdc?q=80&w=1000)', backgroundSize: 'cover', backgroundPosition: 'center'
                    }}>
                        {/* Placeholder for Director Photo */}
                    </div>
                    <div>
                        <h2 style={{ color: 'hsl(var(--primary-dark))', marginBottom: '1.5rem' }}>Mot du Directeur</h2>
                        <div style={{
                            width: '4rem', height: '4px', backgroundColor: 'hsl(var(--secondary))', marginBottom: '2rem', borderRadius: '2px'
                        }}></div>
                        <p style={{ fontSize: '1.1rem', lineHeight: 1.8, marginBottom: '1.5rem', color: 'hsl(var(--text-dark) / 0.8)' }}>
                            "C'est avec une immense joie que je vous souhaite la bienvenue sur le portail numérique du Complexe Scolaire Notre Dame. Notre établissement, fort de son expérience et de son dévouement à l'éducation, s'engage à offrir à chaque élève un cadre propice à l'épanouissement intellectuel et personnel.
                        </p>
                        <p style={{ fontSize: '1.1rem', lineHeight: 1.8, marginBottom: '2rem', color: 'hsl(var(--text-dark) / 0.8)' }}>
                            Nous croyons fermement que l'éducation est la clé de voûte de notre société. C'est pourquoi nous mettons un point d'honneur à allier tradition et modernité, en intégrant les nouvelles technologies tout en préservant nos valeurs fondamentales de respect, d'excellence et de discipline."
                        </p>
                        <div className="flex items-center gap-4">
                            <div>
                                <strong style={{ display: 'block', fontSize: '1.2rem', color: 'hsl(var(--primary-dark))' }}>M. Jean Dupont</strong>
                                <span style={{ color: 'hsl(var(--text-muted))' }}>Directeur Général</span>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            {/* Latest News Preview & CTA */}
            <section className="py-20 bg-white">
                <div className="container text-center">
                    <h2 style={{ color: 'hsl(var(--primary-dark))', marginBottom: '1rem' }}>Pourquoi nous choisir ?</h2>
                    <p style={{ maxWidth: '600px', margin: '0 auto 3rem auto', color: 'hsl(var(--text-muted))' }}>
                        Un environnement sécurisé et une pédagogie innovante pour la réussite de vos enfants.
                    </p>

                    <div className="grid grid-cols-1 md-grid-cols-2 gap-8 text-left mb-12">
                        <div className="card flex gap-4">
                            <ShieldCheck size={32} color="hsl(var(--primary))" style={{ flexShrink: 0 }} />
                            <div>
                                <h3 style={{ fontSize: '1.25rem', marginBottom: '0.5rem' }}>Cadre Sécurisé</h3>
                                <p style={{ color: 'hsl(var(--text-muted))' }}>Notre campus est entièrement sécurisé, offrant un espace de vie et d'apprentissage serein pour tous nos élèves.</p>
                            </div>
                        </div>
                        <div className="card flex gap-4">
                            <Clock size={32} color="hsl(var(--secondary-dark))" style={{ flexShrink: 0 }} />
                            <div>
                                <h3 style={{ fontSize: '1.25rem', marginBottom: '0.5rem' }}>Suivi Rigoureux</h3>
                                <p style={{ color: 'hsl(var(--text-muted))' }}>Un suivi personnalisé et des bilans réguliers permettent d'accompagner chaque enfant selon son propre rythme.</p>
                            </div>
                        </div>
                    </div>

                    <Link to="/about" className="btn btn-outline" style={{ padding: '1rem 2rem', fontSize: '1.1rem' }}>
                        En savoir plus sur l'école
                    </Link>
                </div>
            </section>

            <style>{`
        @media (min-width: 768px) {
          .md-flex-row { flex-direction: row !important; }
          .md-grid-cols-3 { grid-template-columns: repeat(3, minmax(0, 1fr)) !important; }
          .md-grid-cols-2 { grid-template-columns: repeat(2, minmax(0, 1fr)) !important; }
        }
      `}</style>
        </div>
    );
};

export default Home;
