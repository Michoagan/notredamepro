import React from 'react';
import { AlertCircle, Clock, CheckCircle, Smartphone, UserX, Download } from 'lucide-react';

const Rules = () => {
    const rules = [
        {
            title: "Respect Mutuel",
            icon: <CheckCircle size={28} className="text-primary" />,
            content: "Le respect envers les enseignants, le personnel administratif et les autres élèves est la règle d'or. Aucune forme de violence physique ou verbale ne sera tolérée au sein de l'établissement."
        },
        {
            title: "Assiduité et Ponctualité",
            icon: <Clock size={28} className="text-secondary-dark" />,
            content: "La présence à tous les cours inscrits à l'emploi du temps est obligatoire. Les retards doivent être justifiés au bureau du surveillant général avant d'accéder en classe."
        },
        {
            title: "Tenue Vestimentaire",
            icon: <UserX size={28} className="text-accent" />,
            content: "La tenue de l'école (uniforme complet) est strictement exigée tous les jours. Une tenue correcte, propre et soignée est de rigueur. Le maquillage outrancier et les coiffures extravagantes sont interdits."
        },
        {
            title: "Usage des Téléphones",
            icon: <Smartphone size={28} className="text-delete" />,
            content: "L'utilisation des téléphones portables est formellement interdite dans les salles de classe, lors des examens et dans les couloirs. En cas de manquement, l'appareil sera confisqué par le Censeur."
        },
        {
            title: "Respect du Matériel",
            icon: <AlertCircle size={28} className="text-primary-dark" />,
            content: "Les élèves doivent prendre soin du matériel commun (tables, chaises, ordinateurs, matériel de laboratoire). Toute dégradation volontaire sera facturée aux parents de l'élève fautif."
        }
    ];

    return (
        <div className="animate-fade-in py-12 container">
            <div className="text-center mb-16">
                <h1 style={{ color: 'hsl(var(--primary-dark))', marginBottom: '1rem' }}>Règlement Intérieur</h1>
                <p style={{ maxWidth: '700px', margin: '0 auto', color: 'hsl(var(--text-muted))', fontSize: '1.2rem' }}>
                    Pour garantir un environnement d'apprentissage serein, sécurisé et respectueux pour tous, les élèves s'engagent à respecter ces règles fondamentales.
                </p>
            </div>

            <div className="bg-white p-8 rounded-xl shadow-md border" style={{ borderColor: 'hsl(var(--text-dark)/0.05)' }}>
                <div className="flex justify-between items-center mb-8 pb-4 border-b" style={{ borderColor: 'hsl(var(--text-dark)/0.1)' }}>
                    <h2 style={{ fontSize: '1.8rem', color: 'hsl(var(--text-dark))' }}>Les 5 Piliers de la Discipline</h2>
                    {/* Mock download button */}
                    <button className="btn btn-outline flex items-center gap-2">
                        <Download size={18} /> Version PDF
                    </button>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                    {rules.map((rule, idx) => (
                        <div key={idx} className="flex gap-4 p-4 rounded-lg bg-slate-50 hover-shadow transition-all" style={{ backgroundColor: 'hsl(var(--bg-main))' }}>
                            <div className="flex-shrink-0 mt-1" style={{ color: 'hsl(var(--primary))' }}>
                                {rule.icon}
                            </div>
                            <div>
                                <h3 style={{ fontSize: '1.25rem', marginBottom: '0.5rem', color: 'hsl(var(--text-dark))' }}>
                                    {rule.title}
                                </h3>
                                <p style={{ color: 'hsl(var(--text-muted))', lineHeight: 1.6 }}>
                                    {rule.content}
                                </p>
                            </div>
                        </div>
                    ))}
                </div>
            </div>

            <style>{`
        .hover-shadow:hover { box-shadow: var(--shadow-md); transform: translateY(-2px); }
      `}</style>
        </div>
    );
};

export default Rules;
