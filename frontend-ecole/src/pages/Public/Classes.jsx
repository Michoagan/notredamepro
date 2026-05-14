import React from 'react';
import { Book, LayoutTemplate, Briefcase } from 'lucide-react';

const Classes = () => {
    const levels = [
        {
            category: "Collège (1er Cycle)",
            icon: <Book size={32} color="hsl(var(--primary))" />,
            items: [
                { name: "6ème", description: "Adaptation au cycle secondaire, renforcement des bases acquises au primaire (français, mathématiques)." },
                { name: "5ème", description: "Consolidation des savoirs fondamentaux et ouverture culturelle." },
                { name: "4ème", description: "Cycle d'orientation, approfondissement scientifique et littéraire." },
                { name: "3ème", description: "Préparation au BEPC, détermination des choix d'orientation pour le lycée." }
            ]
        },
        {
            category: "Lycée (2nd Cycle)",
            icon: <Briefcase size={32} color="hsl(var(--secondary-dark))" />,
            items: [
                { name: "Seconde", description: "Cycle de détermination, initiation approfondie aux filières scientifiques (C, D) ou littéraires (A)." },
                { name: "Première", description: "Spécialisation dans la filière choisie, préparation aux épreuves anticipées du BAC." },
                { name: "Terminale", description: "L'année du Baccalauréat. Programme intensif axé sur les épreuves phares de chaque spécialité." }
            ]
        }
    ];

    return (
        <div className="animate-fade-in py-12 container bg-main">
            <div className="text-center mb-16">
                <h1 style={{ color: 'hsl(var(--primary-dark))', marginBottom: '1rem' }}>Nos Classes & Niveaux</h1>
                <p style={{ maxWidth: '700px', margin: '0 auto', color: 'hsl(var(--text-muted))', fontSize: '1.2rem' }}>
                    Un parcours scolaire complet et structuré, pensé pour accompagner l'évolution intellectuelle de chaque enfant.
                </p>
            </div>

            <div className="flex flex-col gap-12">
                {levels.map((level, index) => (
                    <div key={index} style={{ backgroundColor: 'white', borderRadius: 'var(--radius-lg)', padding: '2rem', boxShadow: 'var(--shadow-sm)' }}>
                        <div className="flex items-center gap-4 mb-8 pb-4" style={{ borderBottom: '1px solid hsl(var(--text-dark)/0.1)' }}>
                            <div style={{ padding: '1rem', backgroundColor: 'hsl(var(--bg-main))', borderRadius: 'var(--radius-md)' }}>
                                {level.icon}
                            </div>
                            <h2 style={{ fontSize: '2rem', margin: 0, color: 'hsl(var(--text-dark))' }}>{level.category}</h2>
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            {level.items.map((item, idx) => (
                                <div key={idx} className="card" style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
                                    <div className="flex items-center gap-2">
                                        <LayoutTemplate size={20} color="hsl(var(--primary-light))" />
                                        <h3 style={{ fontSize: '1.3rem', color: 'hsl(var(--primary))' }}>Classe de {item.name}</h3>
                                    </div>
                                    <p style={{ color: 'hsl(var(--text-muted))', lineHeight: 1.6 }}>{item.description}</p>
                                </div>
                            ))}
                        </div>
                    </div>
                ))}
            </div>
        </div>
    );
};

export default Classes;
