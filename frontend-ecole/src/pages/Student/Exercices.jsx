import React, { useState, useEffect } from 'react';
import { useOutletContext } from 'react-router-dom';
import { BookOpen, Calendar, CheckCircle } from 'lucide-react';
import { eleveService } from '../../services/api';

const Exercices = () => {
    const { studentInfo } = useOutletContext();
    const [exercices, setExercices] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchExercices();
    }, []);

    const fetchExercices = async () => {
        try {
            setLoading(true);
            const res = await eleveService.getExercices();
            setExercices(res.data);
        } catch (error) {
            console.error("Erreur chargement exercices", error);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="bg-white rounded-xl shadow-md border" style={{ borderColor: 'hsl(var(--text-dark)/0.05)', overflow: 'hidden' }}>
            <div className="p-6 border-b" style={{ borderColor: 'hsl(var(--text-dark)/0.1)', backgroundColor: 'hsl(var(--bg-main))' }}>
                <h2 style={{ fontSize: '1.5rem', color: 'hsl(var(--text-dark))', display: 'flex', alignItems: 'center', gap: '0.5rem', margin: 0 }}>
                    <BookOpen size={24} color="hsl(var(--primary))" />
                    Exercices à faire ({studentInfo.classe_nom || studentInfo.classe})
                </h2>
                <p className="mt-2 text-sm" style={{ color: 'hsl(var(--text-muted))' }}>
                    Voici la liste des travaux et devoirs assignés par vos professeurs.
                </p>
            </div>

            {loading ? (
                <div className="p-12 text-center" style={{ color: 'hsl(var(--text-muted))' }}>
                    <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-primary mb-4"></div>
                    <p>Chargement de vos exercices...</p>
                </div>
            ) : (
                <div className="p-6">
                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                        {exercices.length > 0 ? (
                            exercices.map(exo => (
                                <div key={exo.id} className="card hover-shadow relative" style={{ display: 'flex', flexDirection: 'column', padding: '1.5rem', borderTop: '4px solid hsl(var(--primary))' }}>
                                    
                                    <div className="flex justify-between items-start mb-4">
                                        <div style={{ backgroundColor: 'hsl(var(--primary) / 0.1)', color: 'hsl(var(--primary-dark))', padding: '0.4rem 0.8rem', borderRadius: 'var(--radius-md)', fontSize: '0.85rem', fontWeight: 700 }}>
                                            {exo.matiere?.nom || 'Matière Inconnue'}
                                        </div>
                                    </div>

                                    <div className="flex items-center gap-2 mb-3 text-sm font-medium" style={{ color: 'hsl(var(--text-muted))' }}>
                                        <Calendar size={16} />
                                        <span>Donné le : {new Date(exo.date_cours).toLocaleDateString('fr-FR')}</span>
                                    </div>

                                    <div className="bg-gray-50 rounded-lg p-4 flex-1 mb-4 border border-gray-100">
                                        <p style={{ color: 'hsl(var(--text-dark))', fontSize: '0.95rem', whiteSpace: 'pre-wrap', lineHeight: '1.6' }}>
                                            {exo.travail_a_faire}
                                        </p>
                                    </div>

                                </div>
                            ))
                        ) : (
                            <div className="col-span-full py-16 flex flex-col items-center justify-center text-center" style={{ color: 'hsl(var(--text-muted))' }}>
                                <CheckCircle size={64} className="mb-4 text-green-500 opacity-80" />
                                <h3 className="text-xl font-bold text-gray-700 mb-2">Tout est à jour !</h3>
                                <p>Aucun exercice ou travail à faire pour le moment.</p>
                            </div>
                        )}
                    </div>
                </div>
            )}
        </div>
    );
};

export default Exercices;
