import React from 'react';
import { Users, FileText, Megaphone, School } from 'lucide-react';
import { Link } from 'react-router-dom';

const QuickAction = ({ title, description, to, icon: Icon, color }) => (
    <Link to={to} className="group bg-white p-6 rounded-xl shadow-sm border border-slate-200 hover:shadow-md transition-all hover:-translate-y-1">
        <div className={`w-12 h-12 rounded-lg ${color} flex items-center justify-center mb-4 text-white shadow-lg shadow-${color.split('-')[1]}-500/30`}>
            <Icon className="w-6 h-6" />
        </div>
        <h3 className="text-lg font-bold text-slate-900 group-hover:text-blue-600 transition-colors">{title}</h3>
        <p className="text-sm text-slate-500 mt-2">{description}</p>
    </Link>
);

const SecretariatDashboard = () => {
    return (
        <div className="space-y-8 p-6">
            <header>
                <h1 className="text-2xl font-bold text-slate-900">Secrétariat Général</h1>
                <p className="text-slate-500">Bienvenue dans votre espace de gestion administrative.</p>
            </header>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                <QuickAction
                    title="Inscriptions Élèves"
                    description="Gérer les nouvelles inscriptions et les dossiers élèves."
                    to="/secretariat/eleves"
                    icon={Users}
                    color="bg-blue-600"
                />
                <QuickAction
                    title="Bulletins Scolaires"
                    description="Éditer et imprimer les bulletins de notes."
                    to="/secretariat/bulletins"
                    icon={FileText}
                    color="bg-indigo-600"
                />
                <QuickAction
                    title="Communiqués"
                    description="Publier des annonces pour les parents et professeurs."
                    to="/secretariat/communiques"
                    icon={Megaphone}
                    color="bg-orange-500"
                />
                <QuickAction
                    title="Gestion des Classes"
                    description="Organiser les classes, matières et professeurs."
                    to="/secretariat/classes"
                    icon={School}
                    color="bg-emerald-600"
                />
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                {/* Placeholder for future stats or logs */}
                <div className="bg-slate-50 border border-dashed border-slate-300 rounded-xl p-8 text-center text-slate-500">
                    <p>Statistiques des inscriptions (à venir)</p>
                </div>
                <div className="bg-slate-50 border border-dashed border-slate-300 rounded-xl p-8 text-center text-slate-500">
                    <p>Derniers communiqués publiés (à venir)</p>
                </div>
            </div>
        </div>
    );
};

export default SecretariatDashboard;
