import React, { useState } from 'react';
import { AlertTriangle, CheckCircle, RefreshCcw, Save } from 'lucide-react';
import api from '../../services/api';

const ClotureAnnee = () => {
    const [nouvelleAnnee, setNouvelleAnnee] = useState('');
    const [loading, setLoading] = useState(false);
    const [result, setResult] = useState(null);
    const [error, setError] = useState(null);
    const [showConfirm, setShowConfirm] = useState(false);

    const handleCloture = async () => {
        if (!nouvelleAnnee) {
            setError("Veuillez saisir la nouvelle année scolaire (ex: 2026-2027)");
            return;
        }

        try {
            setLoading(true);
            setError(null);
            
            const response = await api.post('/direction/cloturer-annee', {
                nouvelle_annee: nouvelleAnnee
            });

            if (response.data.success) {
                setResult(response.data.stats);
                setShowConfirm(false);
            } else {
                setError(response.data.message);
            }
        } catch (err) {
            setError(err.response?.data?.message || "Une erreur critique s'est produite lors de la clôture.");
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-gray-800">Clôture de l'Année Scolaire</h1>
                    <p className="text-gray-500">Gérez le passage des élèves en classe supérieure et archivez les bulletins.</p>
                </div>
            </div>

            {error && (
                <div className="bg-red-50 text-red-600 p-4 rounded-xl border border-red-200 flex items-start gap-3">
                    <AlertTriangle className="mt-0.5 flex-shrink-0" size={20} />
                    <p>{error}</p>
                </div>
            )}

            {result ? (
                <div className="bg-green-50 p-8 rounded-2xl border border-green-200 text-center space-y-6 animate-fade-in">
                    <div className="mx-auto w-16 h-16 bg-green-100 text-green-600 rounded-full flex items-center justify-center">
                        <CheckCircle size={32} />
                    </div>
                    <div>
                        <h2 className="text-2xl font-bold text-green-800 mb-2">Clôture réussie !</h2>
                        <p className="text-green-700">Le système est maintenant configuré pour l'année scolaire <strong>{result.nouvelle_annee}</strong>.</p>
                    </div>

                    <div className="grid grid-cols-3 gap-4 max-w-2xl mx-auto">
                        <div className="bg-white p-4 rounded-xl shadow-sm border border-green-100">
                            <div className="text-sm text-gray-500">Élèves traités</div>
                            <div className="text-2xl font-bold text-gray-800">{result.eleves_traites}</div>
                        </div>
                        <div className="bg-white p-4 rounded-xl shadow-sm border border-green-100">
                            <div className="text-sm text-gray-500">Admis (Passage)</div>
                            <div className="text-2xl font-bold text-green-600">{result.promus}</div>
                        </div>
                        <div className="bg-white p-4 rounded-xl shadow-sm border border-green-100">
                            <div className="text-sm text-gray-500">Redoublants</div>
                            <div className="text-2xl font-bold text-orange-500">{result.redoublants}</div>
                        </div>
                    </div>
                    
                    <div className="pt-4 text-sm text-gray-600">
                        Les élèves admis ont été mis "en attente d'affectation". Le secrétariat doit maintenant les inscrire dans leurs nouvelles classes respectives.
                    </div>
                </div>
            ) : (
                <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 max-w-3xl">
                    <div className="bg-amber-50 p-4 rounded-xl border border-amber-200 mb-6 flex gap-3 text-amber-800">
                        <AlertTriangle className="flex-shrink-0" size={24} />
                        <div>
                            <h3 className="font-bold mb-1">Attention : Opération Critique</h3>
                            <ul className="list-disc pl-5 space-y-1 text-sm text-amber-700">
                                <li>Cette opération va calculer la moyenne annuelle de tous les élèves.</li>
                                <li>Les élèves avec une moyenne ≥ 10 seront promus et mis en attente d'affectation de classe.</li>
                                <li>Les élèves avec une moyenne &lt; 10 seront marqués comme redoublants.</li>
                                <li>Toutes les notes actuelles seront archivées et n'apparaitront plus dans les tableaux de bord quotidiens.</li>
                                <li><strong>Cette action est irréversible.</strong></li>
                            </ul>
                        </div>
                    </div>

                    <div className="space-y-4">
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">
                                Saisissez la nouvelle année scolaire cible
                            </label>
                            <input
                                type="text"
                                className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all"
                                placeholder="ex: 2026-2027"
                                value={nouvelleAnnee}
                                onChange={(e) => setNouvelleAnnee(e.target.value)}
                            />
                        </div>

                        {!showConfirm ? (
                            <button
                                onClick={() => setShowConfirm(true)}
                                disabled={!nouvelleAnnee}
                                className="w-full py-3 bg-primary text-white rounded-xl font-medium hover:bg-primary-dark transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                            >
                                <RefreshCcw size={20} />
                                Préparer la clôture
                            </button>
                        ) : (
                            <div className="bg-red-50 p-4 rounded-xl border border-red-200 space-y-4">
                                <p className="text-red-800 font-medium text-center">
                                    Êtes-vous absolument sûr de vouloir clôturer l'année et passer à {nouvelleAnnee} ?
                                </p>
                                <div className="flex gap-3">
                                    <button
                                        onClick={() => setShowConfirm(false)}
                                        className="flex-1 py-3 bg-white text-gray-700 rounded-xl font-medium border border-gray-200 hover:bg-gray-50 transition-colors"
                                    >
                                        Annuler
                                    </button>
                                    <button
                                        onClick={handleCloture}
                                        disabled={loading}
                                        className="flex-1 py-3 bg-red-600 text-white rounded-xl font-medium hover:bg-red-700 transition-colors disabled:opacity-50 flex justify-center items-center gap-2"
                                    >
                                        {loading ? (
                                            <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
                                        ) : (
                                            <>
                                                <Save size={20} />
                                                Confirmer la clôture
                                            </>
                                        )}
                                    </button>
                                </div>
                            </div>
                        )}
                    </div>
                </div>
            )}
        </div>
    );
};

export default ClotureAnnee;
