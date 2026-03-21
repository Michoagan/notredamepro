import React from 'react';
import { Calendar, ArrowRight, BellRing } from 'lucide-react';
import { Link } from 'react-router-dom';

const News = () => {
    const newsItems = [
        {
            id: 1,
            title: "Dates des compositions du 2ème Trimestre",
            date: "15 Janvier 2026",
            category: "Académique",
            excerpt: "Les compositions pour le compte du deuxième trimestre de l'année scolaire débuteront officiellement le 15 Février. Les emplois du temps détaillés seront communiqués via l'espace Élève.",
            image: "https://images.unsplash.com/photo-1434030216411-0b793f4b4173?q=80&w=800"
        },
        {
            id: 2,
            title: "Journée Portes Ouvertes 2026",
            date: "02 Février 2026",
            category: "Événement",
            excerpt: "Venez découvrir nos installations, rencontrer notre équipe pédagogique dynamique et échanger avec nos élèves ambassadeurs lors de notre grande journée portes ouvertes.",
            image: "https://images.unsplash.com/photo-1523050854058-8df90110c9f1?q=80&w=800"
        },
        {
            id: 3,
            title: "Nouveau club d'informatique et de codage",
            date: "10 Décembre 2025",
            category: "Parascolaire",
            excerpt: "L'établissement lance son premier club d'informatique ouvert aux élèves du cycle secondaire. Au programme : initiation au développement web, robotique et enjeux du numérique.",
            image: "https://images.unsplash.com/photo-1504164996022-090807874e45?q=80&w=800"
        }
    ];

    return (
        <div className="animate-fade-in py-12 container">
            <div className="text-center mb-16">
                <h1 style={{ color: 'hsl(var(--primary-dark))', marginBottom: '1rem' }}>Actualités & Événements</h1>
                <p style={{ maxWidth: '700px', margin: '0 auto', color: 'hsl(var(--text-muted))', fontSize: '1.2rem' }}>
                    Restez informé des dernières nouvelles, des annonces importantes et de la vie au sein du complexe scolaire.
                </p>
            </div>

            <div className="grid grid-cols-1 md-grid-cols-3 gap-8">
                {newsItems.map(item => (
                    <div key={item.id} className="card p-0 overflow-hidden flex flex-col" style={{ padding: 0 }}>
                        {/* Image Banner */}
                        <div style={{
                            height: '200px', width: '100%',
                            backgroundImage: `url(${item.image})`,
                            backgroundSize: 'cover', backgroundPosition: 'center',
                            position: 'relative'
                        }}>
                            <span style={{
                                position: 'absolute', top: '1rem', right: '1rem',
                                backgroundColor: 'hsl(var(--primary))', color: 'white',
                                padding: '0.25rem 0.75rem', borderRadius: 'var(--radius-full)', fontSize: '0.8rem', fontWeight: 600
                            }}>
                                {item.category}
                            </span>
                        </div>

                        {/* Content Body */}
                        < div className="p-6 flex flex-col flex-1" >
                            <div className="flex items-center gap-2 mb-3" style={{ color: 'hsl(var(--text-muted))', fontSize: '0.85rem' }}>
                                <Calendar size={14} />
                                <span>{item.date}</span>
                            </div>
                            <h3 style={{ fontSize: '1.25rem', marginBottom: '1rem', color: 'hsl(var(--text-dark))', lineHeight: 1.4 }}>
                                {item.title}
                            </h3>
                            <p style={{ color: 'hsl(var(--text-muted))', marginBottom: '1.5rem', lineHeight: 1.6, flex: 1 }}>
                                {item.excerpt}
                            </p>

                            <Link to="#" className="flex items-center gap-2 font-medium" style={{ color: 'hsl(var(--primary))', marginTop: 'auto' }}>
                                Lire la suite <ArrowRight size={16} />
                            </Link>
                        </div>
                    </div>
                ))
                }
            </div >

            {/* Announcements Banner */}
            < div className="mt-16 bg-primary-dark text-white p-8 rounded-xl flex items-center justify-between"
                style={{
                    background: 'linear-gradient(135deg, hsl(var(--secondary-dark)) 0%, hsl(var(--secondary)) 100%)',
                    color: 'hsl(var(--text-dark))',
                    boxShadow: 'var(--shadow-lg)'
                }}>
                <div className="flex items-center gap-6">
                    <div style={{ backgroundColor: 'white', padding: '1rem', borderRadius: '50%' }}>
                        <BellRing size={32} color="hsl(var(--secondary-dark))" />
                    </div>
                    <div>
                        <h2 style={{ fontSize: '1.5rem', marginBottom: '0.5rem' }}>Avis aux Parents d'Élèves</h2>
                        <p style={{ opacity: 0.9 }}>La réunion de remise des bulletins du 1er trimestre se tiendra ce samedi de 08h à 12h.</p>
                    </div>
                </div>
            </div >

            <style>{`
        @media (min-width: 768px) {
          .md-grid-cols-3 { grid-template-columns: repeat(3, minmax(0, 1fr)) !important; }
        }
      `}</style>
        </div >
    );
};

export default News;
