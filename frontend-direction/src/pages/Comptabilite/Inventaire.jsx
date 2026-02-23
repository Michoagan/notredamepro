import React, { useEffect, useState } from 'react';
import { getArticles, createArticle, updateArticle, addStock, correctStock, getArticleHistory } from '../../services/comptabilite';
import { Loader2, Plus, Box, RefreshCw, History, AlertCircle } from 'lucide-react';
import { format } from 'date-fns';
import { fr } from 'date-fns/locale';

export default function Inventaire() {
    const [articles, setArticles] = useState([]);
    const [loading, setLoading] = useState(true);
    const [selectedArticle, setSelectedArticle] = useState(null);
    const [modalMode, setModalMode] = useState(null); // 'create', 'edit', 'add_stock', 'correct_stock', 'history'
    const [formData, setFormData] = useState({});
    const [history, setHistory] = useState([]);
    const [error, setError] = useState(null);

    useEffect(() => {
        loadArticles();
    }, []);

    const loadArticles = async () => {
        try {
            const data = await getArticles();
            setArticles(data);
        } catch (err) {
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    const handleOpenModal = (mode, article = null) => {
        setModalMode(mode);
        setSelectedArticle(article);
        setFormData(article ? { ...article } : {});
        setError(null);
        if (mode === 'history' && article) {
            loadHistory(article.id);
        }
    };

    const loadHistory = async (id) => {
        try {
            const data = await getArticleHistory(id);
            setHistory(data);
        } catch (err) {
            console.error(err);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        setError(null);
        try {
            if (modalMode === 'create') {
                await createArticle(formData);
            } else if (modalMode === 'edit') {
                await updateArticle(selectedArticle.id, formData);
            } else if (modalMode === 'add_stock') {
                await addStock(selectedArticle.id, formData);
            } else if (modalMode === 'correct_stock') {
                await correctStock(selectedArticle.id, formData);
            }
            await loadArticles();
            setModalMode(null);
        } catch (err) {
            setError(err.response?.data?.message || 'Une erreur est survenue.');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="p-8 space-y-6">
            <header className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-slate-800">Gestion de Stock</h1>
                    <p className="text-slate-500">Suivi des articles et inventaire</p>
                </div>
                <button
                    onClick={() => handleOpenModal('create')}
                    className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center shadow-sm"
                >
                    <Plus className="w-5 h-5 mr-2" />
                    Nouvel Article
                </button>
            </header>

            <div className="bg-white rounded-xl shadow-sm border border-slate-100 overflow-hidden">
                <table className="w-full text-left border-collapse">
                    <thead>
                        <tr className="bg-slate-50 text-slate-600 text-sm font-semibold border-b border-slate-100">
                            <th className="p-4">Désignation</th>
                            <th className="p-4">Type</th>
                            <th className="p-4 text-right">Prix Unitaire</th>
                            <th className="p-4 text-center">Stock Actuel</th>
                            <th className="p-4 text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-100">
                        {articles.map((article) => (
                            <tr key={article.id} className="hover:bg-slate-50 transition-colors">
                                <td className="p-4 font-medium text-slate-800">{article.designation}</td>
                                <td className="p-4 text-slate-500 capitalize">{article.type}</td>
                                <td className="p-4 text-right font-medium text-slate-700">{article.prix_unitaire.toLocaleString()} FCFA</td>
                                <td className="p-4 text-center">
                                    <span className={`px-2 py-1 rounded-full text-xs font-semibold ${article.stock_actuel <= article.stock_min ? 'bg-red-100 text-red-700' : 'bg-green-100 text-green-700'
                                        }`}>
                                        {article.stock_actuel}
                                    </span>
                                </td>
                                <td className="p-4 text-right space-x-2">
                                    <button onClick={() => handleOpenModal('edit', article)} className="text-blue-600 hover:text-blue-800 text-sm font-medium">Modifier</button>
                                    {article.type === 'physique' && (
                                        <>
                                            <button onClick={() => handleOpenModal('add_stock', article)} className="text-emerald-600 hover:text-emerald-800 text-sm font-medium">Approvisionner</button>
                                            <button onClick={() => handleOpenModal('correct_stock', article)} className="text-orange-600 hover:text-orange-800 text-sm font-medium">Corriger</button>
                                        </>
                                    )}
                                    <button onClick={() => handleOpenModal('history', article)} className="text-slate-500 hover:text-slate-700"><History className="w-4 h-4" /></button>
                                </td>
                            </tr>
                        ))}
                        {articles.length === 0 && !loading && (
                            <tr>
                                <td colSpan="5" className="p-8 text-center text-slate-400">Aucun article trouvé.</td>
                            </tr>
                        )}
                    </tbody>
                </table>
            </div>

            {/* Modals */}
            {modalMode && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                    <div className="bg-white rounded-xl shadow-xl w-full max-w-md overflow-hidden">
                        <div className="p-6 border-b border-slate-100 flex justify-between items-center">
                            <h3 className="text-lg font-bold text-slate-800">
                                {modalMode === 'create' && 'Nouvel Article'}
                                {modalMode === 'edit' && 'Modifier Article'}
                                {modalMode === 'add_stock' && 'Approvisionnement'}
                                {modalMode === 'correct_stock' && 'Correction de Stock'}
                                {modalMode === 'history' && 'Historique des Mouvements'}
                            </h3>
                            <button onClick={() => setModalMode(null)} className="text-slate-400 hover:text-slate-600">&times;</button>
                        </div>

                        {modalMode === 'history' ? (
                            <div className="p-0 max-h-96 overflow-y-auto">
                                <table className="w-full text-sm">
                                    <thead className="bg-slate-50 text-xs text-slate-500 uppercase">
                                        <tr>
                                            <th className="p-3 text-left">Date</th>
                                            <th className="p-3 text-left">Type</th>
                                            <th className="p-3 text-right">Qté</th>
                                            <th className="p-3 text-right">Stock</th>
                                        </tr>
                                    </thead>
                                    <tbody className="divide-y divide-slate-100">
                                        {history.map((mvt) => (
                                            <tr key={mvt.id}>
                                                <td className="p-3 text-slate-600">{format(new Date(mvt.created_at), 'dd/MM/yy HH:mm')}</td>
                                                <td className="p-3 capitalize">
                                                    <span className={`px-2 py-0.5 rounded text-xs ${mvt.type === 'entree' ? 'bg-green-100 text-green-700' :
                                                            mvt.type === 'vente' ? 'bg-blue-100 text-blue-700' :
                                                                'bg-orange-100 text-orange-700'
                                                        }`}>{mvt.type}</span>
                                                </td>
                                                <td className="p-3 text-right font-medium">{mvt.quantite}</td>
                                                <td className="p-3 text-right text-slate-500">{mvt.nouveau_stock}</td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>
                        ) : (
                            <form onSubmit={handleSubmit} className="p-6 space-y-4">
                                {error && <div className="p-3 bg-red-50 text-red-600 text-sm rounded-lg flex items-center"><AlertCircle className="w-4 h-4 mr-2" />{error}</div>}

                                {(modalMode === 'create' || modalMode === 'edit') && (
                                    <>
                                        <div>
                                            <label className="block text-sm font-medium text-slate-700 mb-1">Désignation</label>
                                            <input
                                                type="text"
                                                required
                                                className="w-full p-2 border border-slate-300 rounded-lg"
                                                value={formData.designation || ''}
                                                onChange={(e) => setFormData({ ...formData, designation: e.target.value })}
                                            />
                                        </div>
                                        <div className="grid grid-cols-2 gap-4">
                                            <div>
                                                <label className="block text-sm font-medium text-slate-700 mb-1">Type</label>
                                                <select
                                                    className="w-full p-2 border border-slate-300 rounded-lg"
                                                    value={formData.type || 'physique'}
                                                    onChange={(e) => setFormData({ ...formData, type: e.target.value })}
                                                    disabled={modalMode === 'edit'}
                                                >
                                                    <option value="physique">Physique</option>
                                                    <option value="service">Service</option>
                                                </select>
                                            </div>
                                            <div>
                                                <label className="block text-sm font-medium text-slate-700 mb-1">Prix Unitaire</label>
                                                <input
                                                    type="number"
                                                    required
                                                    className="w-full p-2 border border-slate-300 rounded-lg"
                                                    value={formData.prix_unitaire || ''}
                                                    onChange={(e) => setFormData({ ...formData, prix_unitaire: e.target.value })}
                                                />
                                            </div>
                                        </div>
                                        <div>
                                            <label className="block text-sm font-medium text-slate-700 mb-1">Stock Min (Alerte)</label>
                                            <input
                                                type="number"
                                                className="w-full p-2 border border-slate-300 rounded-lg"
                                                value={formData.stock_min || 0}
                                                onChange={(e) => setFormData({ ...formData, stock_min: e.target.value })}
                                            />
                                        </div>
                                    </>
                                )}

                                {(modalMode === 'add_stock') && (
                                    <>
                                        <p className="text-sm text-slate-600 mb-2">Ajouter du stock pour <strong>{selectedArticle.designation}</strong></p>
                                        <div>
                                            <label className="block text-sm font-medium text-slate-700 mb-1">Quantité à ajouter</label>
                                            <input
                                                type="number"
                                                required
                                                min="1"
                                                className="w-full p-2 border border-slate-300 rounded-lg"
                                                value={formData.quantite || ''}
                                                onChange={(e) => setFormData({ ...formData, quantite: e.target.value })}
                                            />
                                        </div>
                                        <div>
                                            <label className="block text-sm font-medium text-slate-700 mb-1">Motif / Source</label>
                                            <input
                                                type="text"
                                                required
                                                placeholder="Ex: Livraison Fournisseur X"
                                                className="w-full p-2 border border-slate-300 rounded-lg"
                                                value={formData.motif || ''}
                                                onChange={(e) => setFormData({ ...formData, motif: e.target.value })}
                                            />
                                        </div>
                                    </>
                                )}

                                {(modalMode === 'correct_stock') && (
                                    <>
                                        <p className="text-sm text-slate-600 mb-2">Correction stock pour <strong>{selectedArticle.designation}</strong></p>
                                        <div className="bg-orange-50 p-3 rounded-lg mb-4 text-orange-800 text-sm">
                                            Stock actuel : <strong>{selectedArticle.stock_actuel}</strong>
                                        </div>
                                        <div>
                                            <label className="block text-sm font-medium text-slate-700 mb-1">Nouveau Stock Réel</label>
                                            <input
                                                type="number"
                                                required
                                                min="0"
                                                className="w-full p-2 border border-slate-300 rounded-lg"
                                                value={formData.stock_reel || ''}
                                                onChange={(e) => setFormData({ ...formData, stock_reel: e.target.value })}
                                            />
                                        </div>
                                        <div>
                                            <label className="block text-sm font-medium text-slate-700 mb-1">Motif de la correction</label>
                                            <input
                                                type="text"
                                                required
                                                placeholder="Ex: Perte, Vol, Erreur comptage"
                                                className="w-full p-2 border border-slate-300 rounded-lg"
                                                value={formData.motif || ''}
                                                onChange={(e) => setFormData({ ...formData, motif: e.target.value })}
                                            />
                                        </div>
                                    </>
                                )}

                                <div className="pt-4 flex justify-end gap-3">
                                    <button type="button" onClick={() => setModalMode(null)} className="px-4 py-2 text-slate-600 hover:bg-slate-100 rounded-lg">Annuler</button>
                                    <button type="submit" disabled={loading} className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50">
                                        {loading ? <Loader2 className="w-5 h-5 animate-spin" /> : 'Enregistrer'}
                                    </button>
                                </div>
                            </form>
                        )}
                    </div>
                </div>
            )}
        </div>
    );
}
