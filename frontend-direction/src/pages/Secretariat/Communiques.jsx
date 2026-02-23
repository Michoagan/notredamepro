import React, { useState, useEffect } from 'react';
import { getCommuniques, createCommunique, deleteCommunique, updateCommunique } from '../../services/secretariat';
import { Megaphone, Trash2, Send, Users, User, Bell, Pencil, X } from 'lucide-react';

const Communiques = () => {
    const [communiques, setCommuniques] = useState([]);
    const [loading, setLoading] = useState(true);
    const [isCreating, setIsCreating] = useState(false);

    // Form state
    const [formData, setFormData] = useState({
        titre: '',
        contenu: '',
        type: 'general'
    });
    const [editingId, setEditingId] = useState(null);

    const fetchCommuniques = async () => {
        setLoading(true);
        try {
            const data = await getCommuniques();
            if (data.success) {
                setCommuniques(data.communiques);
            }
        } catch (error) {
            console.error("Erreur chargement communiqués", error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchCommuniques();
    }, []);

    const handleChange = (e) => {
        setFormData({ ...formData, [e.target.name]: e.target.value });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setIsCreating(true);
        try {
            if (editingId) {
                await updateCommunique(editingId, formData);
            } else {
                await createCommunique(formData);
            }
            setFormData({ titre: '', contenu: '', type: 'general' });
            setEditingId(null);
            fetchCommuniques();
        } catch (error) {
            alert("Erreur lors de la publication");
        } finally {
            setIsCreating(false);
        }
    };

    const handleEdit = (communique) => {
        setFormData({
            titre: communique.titre,
            contenu: communique.contenu,
            type: communique.type
        });
        setEditingId(communique.id);
    };

    const handleCancel = () => {
        setFormData({ titre: '', contenu: '', type: 'general' });
        setEditingId(null);
    };

    const handleDelete = async (id) => {
        if (window.confirm('Supprimer ce communiqué ?')) {
            try {
                await deleteCommunique(id);
                fetchCommuniques();
            } catch (error) {
                alert("Impossible de supprimer");
            }
        }
    };

    const getTypeLabel = (type) => {
        switch (type) {
            case 'professeurs': return { label: 'Professeurs', icon: User, color: 'bg-indigo-100 text-indigo-700' };
            case 'eleves': return { label: 'Élèves', icon: Users, color: 'bg-green-100 text-green-700' };
            case 'parents': return { label: 'Parents', icon: Users, color: 'bg-orange-100 text-orange-700' };
            default: return { label: 'Général', icon: Bell, color: 'bg-slate-100 text-slate-700' };
        }
    };

    return (
        <div className="space-y-6">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-slate-900">Communiqués & Annonces</h1>
                    <p className="text-slate-500">Diffusion d'informations aux élèves, parents et professeurs</p>
                </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Create Form */}
                <div className="lg:col-span-1">
                    <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-200 sticky top-6">
                        <h2 className="text-lg font-semibold mb-4 flex items-center justify-between">
                            <div className="flex items-center space-x-2">
                                <Send className="w-5 h-5 text-blue-600" />
                                <span>{editingId ? 'Modifier l\'annonce' : 'Nouvelle Annonce'}</span>
                            </div>
                            {editingId && (
                                <button onClick={handleCancel} className="text-sm text-red-500 flex items-center hover:bg-red-50 px-2 py-1 rounded">
                                    <X className="w-4 h-4 mr-1" /> Annuler
                                </button>
                            )}
                        </h2>

                        <form onSubmit={handleSubmit} className="space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Titre</label>
                                <input
                                    type="text"
                                    name="titre"
                                    value={formData.titre}
                                    onChange={handleChange}
                                    required
                                    placeholder="Ex: Réunion des professeurs"
                                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                                />
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Destinataires</label>
                                <select
                                    name="type"
                                    value={formData.type}
                                    onChange={handleChange}
                                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                                >
                                    <option value="general">Tout le monde (Général)</option>
                                    <option value="professeurs">Professeurs uniquement</option>
                                    <option value="eleves">Élèves uniquement</option>
                                    <option value="parents">Parents uniquement</option>
                                </select>
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Contenu</label>
                                <textarea
                                    name="contenu"
                                    value={formData.contenu}
                                    onChange={handleChange}
                                    required
                                    rows="6"
                                    placeholder="Écrivez votre message ici..."
                                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none resize-none"
                                ></textarea>
                            </div>

                            <button
                                type="submit"
                                disabled={isCreating}
                                className="w-full flex items-center justify-center space-x-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition shadow-sm disabled:opacity-50"
                            >
                                {isCreating ? (
                                    <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                                ) : (
                                    <Megaphone className="w-4 h-4" />
                                )}
                                <span>{editingId ? 'Mettre à jour' : 'Publier l\'annonce'}</span>
                            </button>
                        </form>
                    </div>
                </div>

                {/* List */}
                <div className="lg:col-span-2 space-y-4">
                    {loading ? (
                        <div className="text-center py-12 text-slate-500">Chargement des communiqués...</div>
                    ) : communiques.length === 0 ? (
                        <div className="text-center py-12 bg-white rounded-xl border border-slate-200">
                            <div className="bg-slate-50 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-3">
                                <Megaphone className="w-8 h-8 text-slate-400" />
                            </div>
                            <h3 className="text-lg font-medium text-slate-900">Aucune annonce</h3>
                            <p className="text-slate-500">Publiez votre première annonce pour qu'elle apparaisse ici.</p>
                        </div>
                    ) : (
                        communiques.map((communique) => {
                            const typeInfo = getTypeLabel(communique.type);
                            const Icon = typeInfo.icon;

                            return (
                                <div key={communique.id} className="bg-white p-6 rounded-xl shadow-sm border border-slate-200 hover:shadow-md transition group">
                                    <div className="flex justify-between items-start mb-3">
                                        <div className="flex items-center space-x-3">
                                            <span className={`px-2.5 py-0.5 rounded-full text-xs font-medium flex items-center ${typeInfo.color}`}>
                                                <Icon className="w-3 h-3 mr-1" />
                                                {typeInfo.label}
                                            </span>
                                            <span className="text-xs text-slate-400">
                                                {new Date(communique.created_at).toLocaleDateString('fr-FR', { day: 'numeric', month: 'long', year: 'numeric', hour: '2-digit', minute: '2-digit' })}
                                            </span>
                                        </div>
                                        <div className="flex space-x-1">
                                            <button
                                                onClick={() => handleEdit(communique)}
                                                className="text-slate-300 hover:text-blue-500 opacity-0 group-hover:opacity-100 transition p-1"
                                                title="Modifier"
                                            >
                                                <Pencil className="w-4 h-4" />
                                            </button>
                                            <button
                                                onClick={() => handleDelete(communique.id)}
                                                className="text-slate-300 hover:text-red-500 opacity-0 group-hover:opacity-100 transition p-1"
                                                title="Supprimer"
                                            >
                                                <Trash2 className="w-4 h-4" />
                                            </button>
                                        </div>
                                    </div>

                                    <h3 className="text-lg font-semibold text-slate-900 mb-2">{communique.titre}</h3>
                                    <div className="text-slate-600 text-sm whitespace-pre-wrap leading-relaxed">
                                        {communique.contenu}
                                    </div>
                                </div>
                            );
                        })
                    )}
                </div>
            </div>
        </div>
    );
};

export default Communiques;
