import React from 'react';
import {
    TrendingUp,
    Users,
    CreditCard,
    ArrowRight,
    Activity,
    Calendar,
    Bell
} from 'lucide-react';
import { Link } from 'react-router-dom';

const StatCard = ({ title, value, change, icon: Icon, color }) => (
    <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-100 hover:shadow-md transition-shadow">
        <div className="flex justify-between items-start">
            <div>
                <p className="text-slate-500 text-sm font-medium mb-1">{title}</p>
                <h3 className="text-2xl font-bold text-slate-800">{value}</h3>
            </div>
            <div className={`p-3 rounded-lg ${color}`}>
                <Icon className="w-6 h-6 text-white" />
            </div>
        </div>
        <div className="mt-4 flex items-center text-sm">
            <span className="text-emerald-500 font-medium flex items-center">
                <TrendingUp className="w-4 h-4 mr-1" />
                {change}
            </span>
            <span className="text-slate-400 ml-2">vs mois dernier</span>
        </div>
    </div>
);

const QuickAction = ({ title, description, to, icon: Icon, gradient }) => (
    <Link
        to={to}
        className={`group relative overflow-hidden p-6 rounded-xl text-white transition-all hover:scale-[1.02] shadow-md ${gradient}`}
    >
        <div className="relative z-10">
            <div className="bg-white/20 w-12 h-12 rounded-lg flex items-center justify-center mb-4 backdrop-blur-sm group-hover:bg-white/30 transition-colors">
                <Icon className="w-6 h-6" />
            </div>
            <h3 className="text-lg font-bold mb-1">{title}</h3>
            <p className="text-white/80 text-sm mb-4">{description}</p>
            <div className="flex items-center text-sm font-medium opacity-0 transform translate-y-2 group-hover:opacity-100 group-hover:translate-y-0 transition-all">
                Accéder <ArrowRight className="w-4 h-4 ml-1" />
            </div>
        </div>
        {/* Decorative circle */}
        <div className="absolute -bottom-6 -right-6 w-32 h-32 bg-white/10 rounded-full blur-2xl group-hover:w-40 group-hover:h-40 transition-all" />
    </Link>
);

const ActivityItem = ({ user, action, time }) => (
    <div className="flex items-start space-x-3 p-3 hover:bg-slate-50 rounded-lg transition-colors">
        <div className="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center flex-shrink-0 text-blue-600 font-bold text-xs">
            {user.substring(0, 2).toUpperCase()}
        </div>
        <div className="flex-1 min-w-0">
            <p className="text-sm font-medium text-slate-800 truncate">
                {user}
            </p>
            <p className="text-sm text-slate-500 truncate">
                {action}
            </p>
        </div>
        <span className="text-xs text-slate-400 whitespace-nowrap">{time}</span>
    </div>
);

const Home = () => {
    const currentDate = new Date().toLocaleDateString('fr-FR', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });

    return (
        <div className="space-y-8 animate-fade-in">
            {/* Hero Section */}
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-3xl font-bold text-slate-800">
                        Bonjour, Administrateur 👋
                    </h1>
                    <p className="text-slate-500 mt-1">
                        Voici ce qui se passe à Notre Dame de Grâce aujourd'hui.
                    </p>
                </div>
                <div className="flex items-center bg-white px-4 py-2 rounded-lg shadow-sm border border-slate-100 text-slate-600 text-sm font-medium">
                    <Calendar className="w-4 h-4 mr-2 text-blue-500" />
                    {currentDate.charAt(0).toUpperCase() + currentDate.slice(1)}
                </div>
            </div>

            {/* Stats Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                <StatCard
                    title="Trésorerie Totale"
                    value="12,450,000 FCFA"
                    change="+12.5%"
                    icon={CreditCard}
                    color="bg-blue-500"
                />
                <StatCard
                    title="Élèves Inscrits"
                    value="1,234"
                    change="+4.2%"
                    icon={Users}
                    color="bg-indigo-500"
                />
                <StatCard
                    title="Opérations du Jour"
                    value="45"
                    change="+8.1%"
                    icon={Activity}
                    color="bg-emerald-500"
                />
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                {/* Quick Actions */}
                <div className="lg:col-span-2 space-y-6">
                    <h2 className="text-xl font-bold text-slate-800 flex items-center">
                        Accès Rapide
                    </h2>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <QuickAction
                            title="Comptabilité"
                            description="Gestion des frais, paiements et factures"
                            to="/comptabilite"
                            icon={CreditCard}
                            gradient="bg-gradient-to-br from-blue-600 to-blue-700"
                        />
                        <QuickAction
                            title="Inscriptions"
                            description="Nouvelles inscriptions et réinscriptions"
                            to="/inscriptions" // Placeholder
                            icon={Users}
                            gradient="bg-gradient-to-br from-indigo-600 to-purple-700"
                        />
                        {/* Add more quick actions as needed */}
                    </div>
                </div>

                {/* Recent Activity */}
                <div className="bg-white rounded-xl shadow-sm border border-slate-100 p-6 h-fit">
                    <div className="flex items-center justify-between mb-6">
                        <h2 className="text-lg font-bold text-slate-800">Activité Récente</h2>
                        <button className="text-blue-600 hover:text-blue-700 text-sm font-medium">
                            Voir tout
                        </button>
                    </div>
                    <div className="space-y-1">
                        <ActivityItem
                            user="Jean Dupont"
                            action="A enregistré un paiement pour Classe 6ème"
                            time="il y a 5 min"
                        />
                        <ActivityItem
                            user="Marie Curie"
                            action="A mis à jour l'inventaire Cantine"
                            time="il y a 2h"
                        />
                        <ActivityItem
                            user="Admin"
                            action="Connexion au système"
                            time="il y a 4h"
                        />
                        <ActivityItem
                            user="Paul Martin"
                            action="Nouveau rapport généré"
                            time="il y a 5h"
                        />
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Home;
