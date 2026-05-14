import React, { useState, useEffect } from 'react';
import { Users, Shield, Activity, Server, CreditCard, ToggleLeft, ToggleRight, Loader } from 'lucide-react';
import { getDashboardStats, getSettings, updateSetting } from '../../services/admin';

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
        activeSessions: 0,
        systemStatus: 'Optimal'
    });
    const [settings, setSettings] = useState({
        paiement_en_ligne_actif: 'true'
    });
    const [loading, setLoading] = useState(true);
    const [togglingPayment, setTogglingPayment] = useState(false);

    useEffect(() => {
        const fetchData = async () => {
            try {
                const [statsData, settingsData] = await Promise.all([
                    getDashboardStats(),
                    getSettings()
                ]);

                if (statsData.success) {
                    setStats({
                        usersCount: statsData.stats.total,
                        activeSessions: statsData.stats.active,
                        systemStatus: 'En ligne'
                    });
                }

                if (settingsData) {
                    setSettings({
                        paiement_en_ligne_actif: settingsData.paiement_en_ligne_actif !== undefined ? String(settingsData.paiement_en_ligne_actif) : '1'
                    });
                }
            } catch (error) {
                console.error("Error fetching admin data:", error);
            } finally {
                setLoading(false);
            }
        };

        fetchData();
    }, []);

    const handleTogglePayment = async () => {
        setTogglingPayment(true);
        try {
            const isCurrentlyActive = settings.paiement_en_ligne_actif === '1' || settings.paiement_en_ligne_actif === 'true';
            const newValue = isCurrentlyActive ? '0' : '1';

            const response = await updateSetting({
                paiement_en_ligne_actif: newValue
            });

            if (response.success) {
                setSettings({
                    ...settings,
                    paiement_en_ligne_actif: newValue
                });
            }
        } catch (error) {
            console.error("Error updating padding setting:", error);
            alert("Erreur lors de la modification des paramètres.");
        } finally {
            setTogglingPayment(false);
        }
    };

    const isPaymentActive = settings.paiement_en_ligne_actif === '1' || settings.paiement_en_ligne_actif === 'true';

    if (loading) {
        return (
            <div className="flex justify-center items-center h-64">
                <Loader className="w-8 h-8 animate-spin text-blue-600" />
            </div>
        );
    }

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
                <div className="flex items-center justify-between mb-6">
                    <div className="flex items-center space-x-3">
                        <CreditCard className="w-6 h-6 text-indigo-600" />
                        <h2 className="text-lg font-bold text-slate-900">Configuration des Paiements</h2>
                    </div>
                </div>

                <div className="flex items-center justify-between p-4 border border-slate-200 rounded-lg bg-slate-50">
                    <div>
                        <h3 className="font-semibold text-slate-800">Paiements en ligne</h3>
                        <p className="text-sm text-slate-500 mt-1">
                            Autoriser ou bloquer les paiements mobiles et cartes bancaires via l'application Parent.
                            {isPaymentActive ? (
                                <span className="ml-2 text-green-600 font-medium">Actuellement: Activé</span>
                            ) : (
                                <span className="ml-2 text-red-600 font-medium">Actuellement: Désactivé</span>
                            )}
                        </p>
                    </div>

                    <button
                        onClick={handleTogglePayment}
                        disabled={togglingPayment}
                        className={`flex items-center space-x-2 px-4 py-2 rounded-lg font-medium transition-colors ${isPaymentActive
                                ? 'bg-red-50 text-red-700 hover:bg-red-100 border border-red-200'
                                : 'bg-green-50 text-green-700 hover:bg-green-100 border border-green-200'
                            } ${togglingPayment ? 'opacity-50 cursor-not-allowed' : ''}`}
                    >
                        {togglingPayment ? (
                            <Loader className="w-5 h-5 animate-spin" />
                        ) : isPaymentActive ? (
                            <ToggleRight className="w-5 h-5 text-red-600" />
                        ) : (
                            <ToggleLeft className="w-5 h-5 text-green-600" />
                        )}
                        <span>{isPaymentActive ? 'Désactiver' : 'Activer'}</span>
                    </button>
                </div>
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
