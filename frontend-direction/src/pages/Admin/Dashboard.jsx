import React, { useState, useEffect } from 'react';
import { Users, Shield, Activity, Server } from 'lucide-react';
import { getDashboardStats } from '../../services/admin';

const StatCard = ({ title, value, icon: Icon, color }) => (
    <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-200 flex items-center justify-between">
        <div>
            <p className="text-slate-500 text-sm font-medium uppercase tracking-wide">{title}</p>
            <h3 className="text-3xl font-bold text-slate-900 mt-2">{value}</h3>
        </div>
        <div className={`p-4 rounded-full ${color}`}>
            <Icon className="w-8 h-8 text-white" />
        </div>
    </div>
);

const AdminDashboard = () => {
    const [stats, setStats] = useState({
        usersCount: 0,
        activeSessions: 0, // Not provided by API yet
        systemStatus: 'Optimal'
    });
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchStats = async () => {
            try {
                const data = await getDashboardStats();
                if (data.success) {
                    setStats({
                        usersCount: data.stats.total,
                        activeSessions: data.stats.active, // Using active users as a proxy for now
                        systemStatus: 'En ligne'
                    });
                }
            } catch (error) {
                console.error("Error fetching admin stats:", error);
            } finally {
                setLoading(false);
            }
        };

        fetchStats();
    }, []);

    return (
        <div className="space-y-8">
            <div className="flex justify-between items-center">
                <h1 className="text-2xl font-bold text-slate-900">Administration Système</h1>
                <span className="bg-green-100 text-green-800 px-3 py-1 rounded-full text-sm font-medium flex items-center">
                    <div className="w-2 h-2 bg-green-500 rounded-full mr-2"></div>
                    Système Opérationnel
                </span>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <StatCard
                    title="Utilisateurs Staff"
                    value={stats.usersCount}
                    icon={Users}
                    color="bg-blue-600"
                />
                <StatCard
                    title="Sessions Actives"
                    value={stats.activeSessions}
                    icon={Activity}
                    color="bg-purple-600"
                />
                <StatCard
                    title="État Serveur"
                    value={stats.systemStatus}
                    icon={Server}
                    color="bg-emerald-600"
                />
            </div>

            <div className="bg-white rounded-xl shadow-sm border border-slate-200 p-6">
                <div className="flex items-center space-x-3 mb-6">
                    <Shield className="w-6 h-6 text-slate-700" />
                    <h2 className="text-lg font-bold text-slate-900">Actions Rapides</h2>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                    <button className="p-4 border border-slate-200 rounded-lg hover:bg-slate-50 text-left transition group">
                        <h3 className="font-semibold text-slate-800 group-hover:text-blue-600">Gérer les Utilisateurs</h3>
                        <p className="text-sm text-slate-500 mt-1">Créer, modifier ou suspendre des comptes d'accès.</p>
                    </button>
                    <button className="p-4 border border-slate-200 rounded-lg hover:bg-slate-50 text-left transition group">
                        <h3 className="font-semibold text-slate-800 group-hover:text-blue-600">Journaux de Sécurité</h3>
                        <p className="text-sm text-slate-500 mt-1">Voir les tentatives de connexion et actions critiques.</p>
                    </button>
                    <button className="p-4 border border-slate-200 rounded-lg hover:bg-slate-50 text-left transition group">
                        <h3 className="font-semibold text-slate-800 group-hover:text-blue-600">Configuration Globale</h3>
                        <p className="text-sm text-slate-500 mt-1">Paramètres de l'application et maintenance.</p>
                    </button>
                </div>
            </div>
        </div>
    );
};

export default AdminDashboard;
