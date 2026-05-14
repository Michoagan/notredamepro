import React from 'react';
import { useOutletContext, Link } from 'react-router-dom';
import { BookOpen, BarChart2, FileText, ArrowRight } from 'lucide-react';

const Dashboard = () => {
    const { studentInfo } = useOutletContext();

    return (
        <div className="space-y-6">
            {/* Welcome Banner */}
            <div className="relative overflow-hidden rounded-2xl bg-primary text-white p-8 md:p-12 shadow-lg" style={{ backgroundColor: 'hsl(var(--primary))' }}>
                <div className="relative z-10">
                    <h1 className="text-3xl md:text-4xl font-bold mb-2">Bonjour, {studentInfo.nom} !</h1>
                    <p className="text-primary-100 text-lg opacity-90">
                        Bienvenue dans votre espace élève. Retrouvez ici vos notes, épreuves et exercices.
                    </p>
                </div>
                {/* Decorative Elements */}
                <div className="absolute top-0 right-0 -translate-y-12 translate-x-1/3 w-64 h-64 rounded-full bg-white opacity-10 blur-3xl"></div>
                <div className="absolute bottom-0 left-0 translate-y-1/3 -translate-x-1/4 w-48 h-48 rounded-full bg-white opacity-10 blur-2xl"></div>
            </div>

            {/* Quick Actions / Shortcuts */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                
                {/* Card Notes */}
                <div className="card hover-shadow bg-white rounded-xl p-6 border" style={{ borderColor: 'hsl(var(--text-dark)/0.05)' }}>
                    <div className="flex items-center justify-between mb-4">
                        <div className="w-12 h-12 rounded-full flex items-center justify-center" style={{ backgroundColor: 'hsl(var(--primary)/0.1)', color: 'hsl(var(--primary))' }}>
                            <BarChart2 size={24} />
                        </div>
                    </div>
                    <h3 className="text-xl font-bold mb-2 text-gray-800">Mes Notes</h3>
                    <p className="text-gray-500 text-sm mb-6">
                        Consultez vos notes d'interrogations et de devoirs par trimestre.
                    </p>
                    <Link to="/student/notes" className="flex items-center gap-2 text-sm font-semibold hover:underline" style={{ color: 'hsl(var(--primary))' }}>
                        Voir mes notes <ArrowRight size={16} />
                    </Link>
                </div>

                {/* Card Epreuves */}
                <div className="card hover-shadow bg-white rounded-xl p-6 border" style={{ borderColor: 'hsl(var(--text-dark)/0.05)' }}>
                    <div className="flex items-center justify-between mb-4">
                        <div className="w-12 h-12 rounded-full flex items-center justify-center" style={{ backgroundColor: 'hsl(var(--accent)/0.1)', color: 'hsl(var(--accent))' }}>
                            <FileText size={24} />
                        </div>
                    </div>
                    <h3 className="text-xl font-bold mb-2 text-gray-800">Anciennes Épreuves</h3>
                    <p className="text-gray-500 text-sm mb-6">
                        Téléchargez les anciennes épreuves pour vous entraîner.
                    </p>
                    <Link to="/student/epreuves" className="flex items-center gap-2 text-sm font-semibold hover:underline" style={{ color: 'hsl(var(--accent))' }}>
                        Accéder aux épreuves <ArrowRight size={16} />
                    </Link>
                </div>

                {/* Card Exercices */}
                <div className="card hover-shadow bg-white rounded-xl p-6 border" style={{ borderColor: 'hsl(var(--text-dark)/0.05)' }}>
                    <div className="flex items-center justify-between mb-4">
                        <div className="w-12 h-12 rounded-full flex items-center justify-center" style={{ backgroundColor: 'hsl(var(--secondary)/0.1)', color: 'hsl(var(--secondary-dark))' }}>
                            <BookOpen size={24} />
                        </div>
                    </div>
                    <h3 className="text-xl font-bold mb-2 text-gray-800">Exercices à faire</h3>
                    <p className="text-gray-500 text-sm mb-6">
                        Vérifiez le travail à faire donné par vos professeurs.
                    </p>
                    <Link to="/student/exercices" className="flex items-center gap-2 text-sm font-semibold hover:underline" style={{ color: 'hsl(var(--secondary-dark))' }}>
                        Voir les exercices <ArrowRight size={16} />
                    </Link>
                </div>

            </div>

        </div>
    );
};

export default Dashboard;
