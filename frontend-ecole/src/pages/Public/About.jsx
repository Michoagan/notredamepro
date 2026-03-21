import React from 'react';
import { Target, Heart, History, Award } from 'lucide-react';

const About = () => {
    return (
        <div className="animate-fade-in py-12 container">

            <div className="text-center mb-16">
                <h1 style={{ color: 'hsl(var(--primary-dark))', marginBottom: '1rem' }}>À Propos de Nous</h1>
                <p style={{ maxWidth: '700px', margin: '0 auto', color: 'hsl(var(--text-muted))', fontSize: '1.2rem' }}>
                    Découvrez l'histoire, la vision et les valeurs qui animent le Complexe Scolaire Notre Dame au quotidien.
                </p>
            </div>

            {/* History */}
            <section className="mb-20 grid grid-cols-1 md-grid-cols-2 gap-12 items-center">
                <div>
                    <div className="flex items-center gap-3 mb-4">
                        <div style={{ backgroundColor: 'hsl(var(--primary) / 0.1)', padding: '0.75rem', borderRadius: '50%', color: 'hsl(var(--primary))' }}>
                            <History size={28} />
                        </div>
                        <h2 style={{ fontSize: '1.8rem', color: 'hsl(var(--text-dark))' }}>Notre Histoire</h2>
                    </div>
                    <p style={{ fontSize: '1.1rem', lineHeight: 1.7, color: 'hsl(var(--text-dark)/0.8)', marginBottom: '1rem' }}>
                        Fondé il y a plus de 20 ans, le Complexe Scolaire Notre Dame a démarré comme une petite école primaire avec la volonté d'offrir une éducation de qualité aux enfants du quartier.
                    </p>
                    <p style={{ fontSize: '1.1rem', lineHeight: 1.7, color: 'hsl(var(--text-dark)/0.8)' }}>
                        Au fil des années, l'établissement s'est agrandi pour inclure le cycle secondaire, devenant ainsi un acteur incontournable de l'éducation dans la région. Des milliers d'élèves ont franchi nos portes et poursuivent aujourd'hui de brillantes carrières à travers le monde.
                    </p>
                </div>
                <div style={{
                    height: '350px', borderRadius: 'var(--radius-lg)',
                    backgroundImage: 'url(https://images.unsplash.com/photo-1577896851231-70ef18881754?q=80&w=1000)',
                    backgroundSize: 'cover', backgroundPosition: 'center',
                    boxShadow: 'var(--shadow-xl)'
                }}></div>
            </section>

            {/* Vision & Mission */}
            <section className="mb-20 bg-white p-10 rounded-xl" style={{ border: '1px solid hsl(var(--text-dark)/0.05)', boxShadow: 'var(--shadow-sm)' }}>
                <div className="grid grid-cols-1 md-grid-cols-2 gap-12">

                    <div>
                        <div className="flex items-center gap-3 mb-4">
                            <div style={{ backgroundColor: 'hsl(var(--secondary) / 0.1)', padding: '0.75rem', borderRadius: '50%', color: 'hsl(var(--secondary-dark))' }}>
                                <Target size={28} />
                            </div>
                            <h2 style={{ fontSize: '1.8rem', color: 'hsl(var(--text-dark))' }}>Notre Vision</h2>
                        </div>
                        <p style={{ fontSize: '1.1rem', lineHeight: 1.7, color: 'hsl(var(--text-dark)/0.8)' }}>
                            Être l'établissement de référence nationale, reconnu pour l'excellence de son enseignement, l'innovation de ses méthodes pédagogiques et la qualité morale de ses diplômés. Nous aspirons à former des citoyens du monde, responsables et créatifs.
                        </p>
                    </div>

                    <div>
                        <div className="flex items-center gap-3 mb-4">
                            <div style={{ backgroundColor: 'hsl(var(--accent) / 0.1)', padding: '0.75rem', borderRadius: '50%', color: 'hsl(var(--accent))' }}>
                                <Award size={28} />
                            </div>
                            <h2 style={{ fontSize: '1.8rem', color: 'hsl(var(--text-dark))' }}>Notre Mission</h2>
                        </div>
                        <p style={{ fontSize: '1.1rem', lineHeight: 1.7, color: 'hsl(var(--text-dark)/0.8)' }}>
                            Fournir une éducation intégrale qui favorise le développement intellectuel, physique et social de chaque élève. Nous nous engageons à offrir un environnement sécurisant et stimulant où chaque enfant peut découvrir et maximiser son potentiel.
                        </p>
                    </div>

                </div>
            </section>

            {/* Core Values */}
            <section>
                <div className="text-center mb-10">
                    <div className="flex items-center justify-center gap-2 mb-2">
                        <Heart color="hsl(var(--delete))" fill="hsl(var(--delete))" size={24} />
                    </div>
                    <h2 style={{ fontSize: '2rem', color: 'hsl(var(--primary-dark))' }}>Nos Valeurs Fondamentales</h2>
                </div>

                <div className="grid grid-cols-1 md-grid-cols-3 gap-6">
                    <div className="card text-center flex flex-col items-center">
                        <h3 style={{ color: 'hsl(var(--primary))', marginBottom: '1rem' }}>Excellence</h3>
                        <p style={{ color: 'hsl(var(--text-muted))' }}>
                            Nous visons les plus hauts standards académiques et encourageons le dépassement de soi dans tous les domaines d'apprentissage.
                        </p>
                    </div>
                    <div className="card text-center flex flex-col items-center">
                        <h3 style={{ color: 'hsl(var(--primary))', marginBottom: '1rem' }}>Discipline</h3>
                        <p style={{ color: 'hsl(var(--text-muted))' }}>
                            Le respect des règles de vie en communauté, l'assiduité et le travail rigoureux sont les piliers de notre structure éducative.
                        </p>
                    </div>
                    <div className="card text-center flex flex-col items-center">
                        <h3 style={{ color: 'hsl(var(--primary))', marginBottom: '1rem' }}>Intégrité</h3>
                        <p style={{ color: 'hsl(var(--text-muted))' }}>
                            Nous formons nos élèves au sens de l'honneur, à l'honnêteté et au respect d'autrui pour devenir des citoyens responsables.
                        </p>
                    </div>
                </div>
            </section>

            <style>{`
        @media (min-width: 768px) {
          .md-grid-cols-2 { grid-template-columns: repeat(2, minmax(0, 1fr)) !important; }
          .md-grid-cols-3 { grid-template-columns: repeat(3, minmax(0, 1fr)) !important; }
        }
      `}</style>
        </div>
    );
};

export default About;
