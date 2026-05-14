import React, { useState, useEffect } from 'react';
import { Shield, Activity, RefreshCw, Server, PlusCircle, Edit3, Trash2, User, Globe, FileText, ChevronLeft, ChevronRight } from 'lucide-react';
import { getSystemLogs } from '../../services/admin';

const AdminLogs = () => {
    const [logs, setLogs] = useState([]);
    const [loading, setLoading] = useState(true);
    const [page, setPage] = useState(1);
    const [totalPages, setTotalPages] = useState(1);

    const fetchLogs = async (p = 1) => {
        setLoading(true);
        try {
            const res = await getSystemLogs(p);
            if (res.success && res.data) {
                setLogs(res.data.data);
                setTotalPages(res.data.last_page || 1);
            }
        } catch (error) {
            console.error('Failed to fetch logs:', error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchLogs(page);
    }, [page]);

    const getActionProps = (action) => {
        switch (action) {
            case 'create':
                return { 
                    icon: PlusCircle, 
                    color: 'text-emerald-500', 
                    bg: 'bg-emerald-100/50 border-emerald-500', 
                    shadow: 'shadow-[0_0_15px_rgba(16,185,129,0.3)]',
                    label: 'Création' 
                };
            case 'update':
                return { 
                    icon: Edit3, 
                    color: 'text-blue-500', 
                    bg: 'bg-blue-100/50 border-blue-500', 
                    shadow: 'shadow-[0_0_15px_rgba(59,130,246,0.3)]',
                    label: 'Modification' 
                };
            case 'delete':
                return { 
                    icon: Trash2, 
                    color: 'text-red-500', 
                    bg: 'bg-red-100/50 border-red-500', 
                    shadow: 'shadow-[0_0_15px_rgba(239,68,68,0.3)]',
                    label: 'Suppression' 
                };
            default:
                return { 
                    icon: Activity, 
                    color: 'text-slate-500', 
                    bg: 'bg-slate-100/50 border-slate-500', 
                    shadow: 'shadow-sm',
                    label: 'Action' 
                };
        }
    };

    return (
        <div className="max-w-6xl mx-auto space-y-8 animate-fade-in p-4 sm:p-6 pb-20">
            {/* Hero Header */}
            <div className="relative overflow-hidden rounded-3xl bg-gradient-to-r from-slate-900 via-slate-800 to-indigo-950 p-8 sm:p-10 shadow-2xl shadow-indigo-900/20 border border-white/10">
                <div className="absolute top-0 right-0 -mt-20 -mr-20 w-72 h-72 bg-purple-500 rounded-full mix-blend-screen filter blur-[90px] opacity-40 animate-pulse"></div>
                <div className="absolute bottom-0 left-0 -mb-20 -ml-20 w-72 h-72 bg-blue-500 rounded-full mix-blend-screen filter blur-[90px] opacity-30"></div>
                
                <div className="relative z-10 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-6">
                    <div>
                        <h1 className="text-3xl sm:text-4xl font-extrabold text-white font-jakarta tracking-tight flex items-center gap-3 mb-2">
                            <Shield className="w-8 h-8 text-purple-400" />
                            Journaux Globaux
                        </h1>
                        <p className="text-indigo-200/80 max-w-xl text-sm md:text-base leading-relaxed">
                            Surveillez en temps réel toutes les activités de l'écosystème : ajouts de notes, paiements, connexions et configurations.
                        </p>
                    </div>
                    <button 
                        onClick={() => fetchLogs(page)}
                        className="flex items-center gap-2 bg-white/10 hover:bg-white/20 text-white px-5 py-2.5 rounded-xl border border-white/10 transition-all font-medium backdrop-blur-md hover:shadow-[0_0_20px_rgba(255,255,255,0.1)]"
                    >
                        <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
                        Rafraîchir
                    </button>
                </div>
            </div>

            {/* Timeline UI */}
            <div className="relative">
                {/* Visual Line */}
                <div className="absolute left-[28px] sm:left-[36px] top-4 bottom-0 w-0.5 bg-gradient-to-b from-purple-500/50 via-slate-300/50 to-transparent"></div>

                {loading && logs.length === 0 ? (
                    <div className="pl-16 sm:pl-24 py-8">
                        <div className="flex items-center gap-3 text-slate-500 font-medium">
                            <div className="w-5 h-5 border-2 border-purple-500 border-t-transparent rounded-full animate-spin"></div>
                            Vérification des systèmes...
                        </div>
                    </div>
                ) : logs.length === 0 ? (
                    <div className="pl-16 sm:pl-24 py-12 text-slate-500 font-medium flex items-center gap-3 bg-white/50 rounded-2xl border border-slate-200 backdrop-blur-md">
                        <Server className="w-5 h-5 opacity-50" />
                        Aucune activité récente recensée sur le serveur.
                    </div>
                ) : (
                    <div className="space-y-6">
                        {logs.map((log) => {
                            const props = getActionProps(log.action);
                            const Icon = props.icon;
                            
                            return (
                                <div key={log.id} className="relative pl-16 sm:pl-24 group">
                                    {/* Timeline Node */}
                                    <div className={`absolute left-[29px] sm:left-[37px] top-6 w-3 h-3 rounded-full border-2 transform -translate-x-1/2 
                                        ${props.bg} ${props.shadow} group-hover:scale-125 transition-transform duration-300
                                    `}></div>

                                    {/* Glassmorphism Card */}
                                    <div className="bg-white/70 backdrop-blur-xl border border-slate-200 shadow-[0_4px_20px_rgb(0,0,0,0.03)] hover:shadow-[0_8px_30px_rgb(0,0,0,0.06)] rounded-2xl overflow-hidden transition-all duration-300 group-hover:-translate-y-1">
                                        
                                        {/* Card Header */}
                                        <div className="p-4 sm:p-5 border-b border-slate-100 flex flex-wrap items-center justify-between gap-4 bg-gradient-to-br from-white/90 to-transparent">
                                            <div className="flex items-center gap-3">
                                                <div className={`p-2 rounded-xl bg-slate-50 border border-slate-100 ${props.color}`}>
                                                    <Icon className="w-5 h-5" />
                                                </div>
                                                <div>
                                                    <h3 className="font-bold text-slate-800 font-jakarta flex items-center gap-2">
                                                        {props.label} / {log.model}
                                                    </h3>
                                                    <div className="flex items-center gap-2 text-xs font-semibold mt-1">
                                                        <span className="bg-slate-100 text-slate-600 px-2 py-0.5 rounded-md flex items-center gap-1">
                                                            <User className="w-3 h-3" />
                                                            {log.user_name}
                                                        </span>
                                                        <span className="bg-indigo-50 text-indigo-600 px-2 py-0.5 rounded-md flex items-center gap-1 truncate max-w-[120px] sm:max-w-[200px]">
                                                            {log.user_role}
                                                        </span>
                                                    </div>
                                                </div>
                                            </div>

                                            <div className="flex flex-col items-end text-right">
                                                <div className="text-sm font-semibold text-slate-700">
                                                    {new Date(log.created_at).toLocaleDateString('fr-FR', { weekday: 'short', day: 'numeric', month: 'short', year: 'numeric' })}
                                                </div>
                                                <div className="text-xs text-slate-500 mt-0.5">
                                                    {new Date(log.created_at).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit', second: '2-digit' })}
                                                </div>
                                            </div>
                                        </div>

                                        {/* Card Body (Changes) */}
                                        <div className="p-4 sm:p-5 bg-slate-50/50">
                                            <div className="flex items-start gap-2 mb-3">
                                                <Globe className="w-4 h-4 text-slate-400 mt-0.5 shrink-0" />
                                                <span className="text-xs font-mono text-slate-500 bg-white px-2 py-1 rounded-md border border-slate-200">
                                                    IP: {log.ip_address || 'N/A'}
                                                </span>
                                            </div>

                                            {/* Details formatting JSON */}
                                            {log.changes && Object.keys(log.changes).length > 0 ? (
                                                <div className="bg-white rounded-xl p-3 border border-slate-200 shadow-inner font-mono text-xs overflow-x-auto text-slate-600">
                                                    <pre>{JSON.stringify(log.changes, null, 2)}</pre>
                                                </div>
                                            ) : (
                                                <p className="text-sm text-slate-500 italic">Aucun détail supplémentaire.</p>
                                            )}
                                        </div>

                                    </div>
                                </div>
                            );
                        })}
                    </div>
                )}
            </div>

            {/* Pagination */}
            {totalPages > 1 && (
                <div className="flex items-center justify-center gap-4 pt-10 pb-4">
                    <button 
                        onClick={() => setPage(p => Math.max(1, p - 1))}
                        disabled={page === 1}
                        className="p-2 border border-slate-200 rounded-xl bg-white text-slate-600 hover:bg-slate-50 disabled:opacity-50 disabled:cursor-not-allowed transition"
                    >
                        <ChevronLeft className="w-5 h-5" />
                    </button>
                    <span className="font-semibold text-slate-700 text-sm">
                        Page {page} <span className="text-slate-400 font-normal">sur {totalPages}</span>
                    </span>
                    <button 
                        onClick={() => setPage(p => Math.min(totalPages, p + 1))}
                        disabled={page === totalPages}
                        className="p-2 border border-slate-200 rounded-xl bg-white text-slate-600 hover:bg-slate-50 disabled:opacity-50 disabled:cursor-not-allowed transition"
                    >
                        <ChevronRight className="w-5 h-5" />
                    </button>
                </div>
            )}
        </div>
    );
};

export default AdminLogs;
