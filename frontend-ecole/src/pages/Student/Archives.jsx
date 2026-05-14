import React, { useState, useEffect } from 'react';
import { Archive, FileText } from 'lucide-react';
import api from '../../services/api';

const Archives = () => {
    const [archives, setArchives] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        fetchArchives();
    }, []);

    const fetchArchives = async () => {
        try {
            setLoading(true);
            const response = await api.get('/eleve/archives');
            if (response.data.success) {
                setArchives(response.data.archives);
            } else {
                setError("Erreur lors du chargement des archives.");
            }
        } catch (err) {
            setError("Erreur de connexion.");
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    if (loading) {
        return (
            <div className="flex justify-center items-center h-64">
                <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-primary"></div>
            </div>
        );
    }

    if (error) {
        return (
            <div className="bg-red-50 text-red-500 p-4 rounded-xl shadow-sm">
                {error}
            </div>
        );
    }

    return (
        <div className="space-y-6">
            <div className="flex items-center gap-3">
                <div className="p-3 bg-primary/10 rounded-xl text-primary">
                    <Archive size={28} />
                </div>
                <div>
                    <h1 className="text-2xl font-bold text-gray-800">Mes Archives</h1>
                    <p className="text-gray-500">Consultez vos moyennes annuelles des années précédentes</p>
                </div>
            </div>

            {archives.length === 0 ? (
                <div className="bg-white p-8 rounded-2xl shadow-sm text-center border border-gray-100">
                    <div className="mx-auto w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mb-4 text-gray-400">
                        <Archive size={32} />
                    </div>
                    <h3 className="text-lg font-bold text-gray-700 mb-2">Aucune archive disponible</h3>
                    <p className="text-gray-500">Vous n'avez pas encore de données d'archives pour les années précédentes.</p>
                </div>
            ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    {archives.map((archive) => (
                        <div key={archive.annee_scolaire} className="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 flex flex-col justify-between">
                            <div className="flex items-center gap-4 mb-4">
                                <div className="p-3 bg-blue-50 text-blue-600 rounded-xl">
                                    <FileText size={24} />
                                </div>
                                <div className="text-left">
                                    <h3 className="text-xl font-bold text-gray-800">Année {archive.annee_scolaire}</h3>
                                    <p className="text-sm text-gray-500">Classe: {archive.classe}</p>
                                </div>
                            </div>
                            
                            <div className="grid grid-cols-2 gap-4 mt-auto">
                                <div className="bg-gray-50 p-3 rounded-xl border border-gray-100 text-center">
                                    <div className="text-xs text-gray-500 mb-1">Moyenne</div>
                                    <div className={`font-bold text-xl ${archive.moyenne_annuelle >= 10 ? 'text-green-600' : 'text-red-500'}`}>
                                        {archive.moyenne_annuelle ? Number(archive.moyenne_annuelle).toFixed(2) : '-'} / 20
                                    </div>
                                </div>
                                <div className="bg-gray-50 p-3 rounded-xl border border-gray-100 text-center">
                                    <div className="text-xs text-gray-500 mb-1">Décision</div>
                                    <div className={`font-bold mt-1 px-3 py-1 rounded-full text-xs inline-block ${archive.decision === 'Admis' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
                                        {archive.decision || '-'}
                                    </div>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>
            )}
        </div>
    );
};

export default Archives;
