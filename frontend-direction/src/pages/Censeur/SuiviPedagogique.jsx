import React, { useState, useEffect } from 'react';
import censeurService from '../../services/censeur';
import { History, FileText, Lock } from 'lucide-react';

const SuiviPedagogique = () => {
    const [logs, setLogs] = useState([]);
    const [loading, setLoading] = useState(true);
    const [activeTab, setActiveTab] = useState('logs'); // 'logs' or 'cahier'

    useEffect(() => {
        if (activeTab === 'logs') {
            loadLogs();
        }
    }, [activeTab]);

    const loadLogs = async () => {
        setLoading(true);
        try {
            const response = await censeurService.getLogs();
            if (response.data && response.data.success) {
                setLogs(response.data.logs?.data || response.data.logs || []);
            }
        } catch (error) {
            console.error(error);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="space-y-6">
            <h1 className="text-2xl font-bold text-slate-900">Suivi Pédagogique</h1>

            <div className="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
                <div className="p-4 border-b border-slate-100">
                    <h2 className="font-semibold text-slate-800 flex items-center gap-2">
                        <History className="w-5 h-5 text-blue-600" />
                        Historique des modifications
                    </h2>
                </div>
                <div className="overflow-x-auto">
                    <table className="w-full text-sm text-left">
                        <thead className="bg-slate-50 text-slate-500 uppercase text-xs">
                            <tr>
                                <th className="px-6 py-3">Date</th>
                                <th className="px-6 py-3">Utilisateur</th>
                                <th className="px-6 py-3">Action</th>
                                <th className="px-6 py-3">Cible</th>
                                <th className="px-6 py-3">Détails</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-slate-100">
                            {loading ? (
                                <tr><td colSpan="5" className="text-center py-8">Chargement...</td></tr>
                            ) : logs.length === 0 ? (
                                <tr><td colSpan="5" className="text-center py-8">Aucun log trouvé.</td></tr>
                            ) : (
                                logs.map(log => (
                                    <tr key={log.id} className="hover:bg-slate-50">
                                        <td className="px-6 py-4 whitespace-nowrap text-slate-500">
                                            {new Date(log.created_at).toLocaleString('fr-FR')}
                                        </td>
                                        <td className="px-6 py-4 font-medium text-slate-900">
                                            {log.user_name}
                                            <span className="block text-xs text-slate-400 font-normal">{log.user_role}</span>
                                        </td>
                                        <td className="px-6 py-4">
                                            <span className={`inline-flex px-2 py-1 rounded text-xs font-semibold
                                                ${log.action === 'update' ? 'bg-blue-100 text-blue-700' :
                                                    log.action === 'create' ? 'bg-green-100 text-green-700' :
                                                        log.action === 'delete' ? 'bg-red-100 text-red-700' : 'bg-gray-100 text-gray-700'}
                                            `}>
                                                {log.action.toUpperCase()}
                                            </span>
                                        </td>
                                        <td className="px-6 py-4 text-slate-600">
                                            {log.model} #{log.model_id || '?'}
                                        </td>
                                        <td className="px-6 py-4">
                                            <pre className="text-xs bg-slate-50 p-2 rounded border border-slate-200 overflow-auto max-w-[200px] max-h-[60px]">
                                                {JSON.stringify(log.changes, null, 2)}
                                            </pre>
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    );
};

export default SuiviPedagogique;
