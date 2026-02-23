import React, { useState } from 'react';
import api from '../../../services/api';
import { X, Upload, FileSpreadsheet, CheckCircle, AlertCircle } from 'lucide-react';
import { getClasses } from '../../../services/secretariat'; // Assuming create/import is handled here or manually using axios

const ImportStudent = ({ isOpen, onClose, onSuccess }) => {
    const [file, setFile] = useState(null);
    const [loading, setLoading] = useState(false);
    const [status, setStatus] = useState(null); // { type: 'success' | 'error', message: '' }

    const handleFileChange = (e) => {
        const selectedFile = e.target.files[0];
        setFile(selectedFile);
        setStatus(null);
    };

    const handleImport = async () => {
        if (!file) return;

        setLoading(true);
        setStatus(null);

        try {
            const formData = new FormData();
            formData.append('fichier_excel', file);

            // Using centralized api service which handles baseURL and Authorization token
            const response = await api.post('/secretaire/eleves/import', formData, {
                headers: {
                    'Content-Type': 'multipart/form-data'
                }
            });

            if (response.data.success) {
                setStatus({ type: 'success', message: response.data.message });
                setTimeout(() => {
                    onSuccess();
                    onClose();
                }, 2000);
            }
        } catch (error) {
            console.error("Import error", error);
            setStatus({
                type: 'error',
                message: error.response?.data?.message || 'Erreur lors de l\'importation. Vérifiez le format du fichier CSV.'
            });
        } finally {
            setLoading(false);
        }
    };

    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
            <div className="bg-white rounded-xl shadow-xl w-full max-w-md">
                <div className="flex items-center justify-between p-6 border-b border-slate-100">
                    <h2 className="text-xl font-bold text-slate-900">Importer des Élèves</h2>
                    <button onClick={onClose} className="text-slate-400 hover:text-slate-600 transition">
                        <X className="w-6 h-6" />
                    </button>
                </div>

                <div className="p-6 space-y-6">
                    <div className="bg-blue-50 p-4 rounded-lg flex items-start space-x-3">
                        <FileSpreadsheet className="w-6 h-6 text-blue-600 flex-shrink-0 mt-1" />
                        <div className="text-sm text-blue-800">
                            <p className="font-medium mb-1">Format attendu (CSV uniquement)</p>
                            <p>Merci de convertir vos fichiers Excel en CSV avant l'importation. Le fichier doit contenir les colonnes : Matricule, Nom, Prénom, Date Naissance, Lieu, Sexe, Adresse, Téléphone, Email, Parent, Tel Parent, Classe.</p>
                        </div>
                    </div>

                    <div className="border-2 border-dashed border-slate-300 rounded-xl p-8 text-center hover:bg-slate-50 transition cursor-pointer relative">
                        <input
                            type="file"
                            onChange={handleFileChange}
                            accept=".csv, .txt"
                            className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                        />
                        <div className="flex flex-col items-center">
                            <Upload className="w-10 h-10 text-slate-400 mb-3" />
                            {file ? (
                                <p className="font-medium text-slate-900">{file.name}</p>
                            ) : (
                                <>
                                    <p className="font-medium text-slate-900">Cliquez pour sélectionner un fichier</p>
                                    <p className="text-sm text-slate-500 mt-1">Format CSV requis</p>
                                </>
                            )}
                        </div>
                    </div>

                    {status && (
                        <div className={`p-4 rounded-lg flex items-center space-x-2 ${status.type === 'success' ? 'bg-green-50 text-green-700' : 'bg-red-50 text-red-700'
                            }`}>
                            {status.type === 'success' ? <CheckCircle className="w-5 h-5" /> : <AlertCircle className="w-5 h-5" />}
                            <span>{status.message}</span>
                        </div>
                    )}

                    <div className="flex justify-end space-x-3 pt-2">
                        <button
                            onClick={onClose}
                            className="px-4 py-2 text-slate-600 hover:bg-slate-100 rounded-lg transition"
                        >
                            Annuler
                        </button>
                        <button
                            onClick={handleImport}
                            disabled={!file || loading}
                            className="flex items-center space-x-2 px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition shadow-sm disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                            {loading && <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />}
                            <span>Importer</span>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default ImportStudent;
