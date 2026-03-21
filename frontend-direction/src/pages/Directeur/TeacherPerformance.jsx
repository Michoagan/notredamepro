import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { getTeacherPerformance } from '../../services/directeur';
import {
    BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer,
    PieChart, Pie, Cell
} from 'recharts';

const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042'];

const TeacherPerformance = () => {
    const { id } = useParams();
    const [performance, setPerformance] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');

    useEffect(() => {
        fetchPerformance();
    }, [id]);

    const fetchPerformance = async () => {
        try {
            setLoading(true);
            const data = await getTeacherPerformance(id);
            setPerformance(data);
        } catch (err) {
            setError("Erreur lors du chargement des performances du professeur.");
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    if (loading) return <div className="flex justify-center p-8"><span className="loading loading-spinner loading-lg text-primary"></span></div>;
    if (error) return <div className="alert alert-error shadow-lg my-4">{error}</div>;
    if (!performance) return null;

    const { professeur, assiduite, programme, impact_pedagogique } = performance;

    const assiduiteData = [
        { name: 'Assurées', value: assiduite.heures_assurees },
        { name: 'Manquées', value: assiduite.heures_prevues - assiduite.heures_assurees },
    ];

    const impactData = [
        { name: 'Taux Réussite', value: impact_pedagogique.taux_reussite },
        { name: 'Échecs', value: 100 - impact_pedagogique.taux_reussite },
    ];

    return (
        <div className="container mx-auto p-4 space-y-6">
            {/* Header */}
            <div className="flex justify-between items-center bg-base-100 p-6 rounded-box shadow">
                <div>
                    <h1 className="text-2xl font-bold">{professeur.nom_complet}</h1>
                    <p className="text-gray-500">Matière: {professeur.matiere}</p>
                </div>
                <Link to="/direction/personnel" className="btn btn-outline">
                    Retour à la liste
                </Link>
            </div>

            {/* KPI Cards */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div className="stat bg-base-100 shadow rounded-box">
                    <div className="stat-title">Assiduité</div>
                    <div className={`stat-value ${assiduite.taux >= 80 ? 'text-success' : 'text-error'}`}>
                        {assiduite.taux}%
                    </div>
                    <div className="stat-desc">{assiduite.heures_assurees} / {assiduite.heures_prevues} heures assurées</div>
                </div>

                <div className="stat bg-base-100 shadow rounded-box">
                    <div className="stat-title">Avancement du Programme</div>
                    <div className="stat-value text-primary">{programme.taux_progression}%</div>
                    <div className="stat-desc">{programme.heures_enseignees}h enseignées ({programme.cahiers_remplis} sessions)</div>
                </div>

                <div className="stat bg-base-100 shadow rounded-box">
                    <div className="stat-title">Impact Pédagogique (Excellence)</div>
                    <div className="stat-value text-secondary">{impact_pedagogique.taux_reussite}%</div>
                    <div className="stat-desc">Moyenne Globale: {impact_pedagogique.moyenne_globale}/20</div>
                </div>
            </div>

            {/* Charts Section */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {/* Assiduité Chart */}
                <div className="bg-base-100 p-6 rounded-box shadow flex flex-col items-center">
                    <h3 className="text-lg font-bold mb-4">Répartition des heures (Assiduité)</h3>
                    <ResponsiveContainer width="100%" height={300}>
                        <PieChart>
                            <Pie
                                data={assiduiteData}
                                cx="50%"
                                cy="50%"
                                innerRadius={60}
                                outerRadius={80}
                                fill="#8884d8"
                                paddingAngle={5}
                                dataKey="value"
                                label
                            >
                                {assiduiteData.map((entry, index) => (
                                    <Cell key={`cell-${index}`} fill={index === 0 ? COLORS[1] : COLORS[3]} />
                                ))}
                            </Pie>
                            <Tooltip />
                            <Legend />
                        </PieChart>
                    </ResponsiveContainer>
                </div>

                {/* Impact Pédagogique Chart */}
                <div className="bg-base-100 p-6 rounded-box shadow flex flex-col items-center">
                    <h3 className="text-lg font-bold mb-4">Efficacité Pédagogique</h3>
                    <ResponsiveContainer width="100%" height={300}>
                        {impact_pedagogique.total_evaluations > 0 ? (
                            <BarChart data={[impact_pedagogique]}>
                                <CartesianGrid strokeDasharray="3 3" />
                                <XAxis dataKey="name" hide />
                                <YAxis domain={[0, 100]} />
                                <Tooltip />
                                <Legend />
                                <Bar dataKey="taux_reussite" name="% Réussite (≥10/20)" fill={COLORS[0]} />
                                <Bar dataKey="moyenne_globale" name="Moy. Globale (x5 pour échelle)" fill={COLORS[2]}
                                    activeBar={{ fill: 'gold' }} />
                            </BarChart>
                        ) : (
                            <div className="flex h-full items-center justify-center text-gray-500">
                                Aucune évaluation enregistrée
                            </div>
                        )}
                    </ResponsiveContainer>
                </div>
            </div>
        </div>
    );
};

export default TeacherPerformance;
