import React, { useState, useEffect } from 'react';
import { getMatieres, createMatiere, deleteMatiere, updateMatiere } from '../../../services/secretariat';
import { Plus, Trash2, Search, Book, Edit, X } from 'lucide-react';

const MatieresList = () => {
    const [matieres, setMatieres] = useState([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');
    const [newMatiere, setNewMatiere] = useState('');
    const [editingMatiere, setEditingMatiere] = useState(null);
    const [creating, setCreating] = useState(false);

    const fetchMatieres = async () => {
        setLoading(true);
        try {
            const data = await getMatieres();
            if (data.success && data.matieres) {
                setMatieres(data.matieres);
            }
        } catch (error) {
            console.error("Erreur chargement matières", error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchMatieres();
    }, []);

    const handleSubmit = async (e) => {
        e.preventDefault();
        if (!newMatiere.trim()) return;

        setCreating(true);
        try {
            if (editingMatiere) {
                await updateMatiere(editingMatiere.id, { nom: newMatiere });
            } else {
                await createMatiere({ nom: newMatiere });
            }
            setNewMatiere('');
            setEditingMatiere(null);
            fetchMatieres();
            // Reset state
        } catch (error) {
            alert(error.response?.data?.message || "Erreur lors de l'enregistrement");
        } finally {
            setCreating(false);
        }
    };

    const handleEdit = (matiere) => {
        setNewMatiere(matiere.nom);
        setEditingMatiere(matiere);
    };

    const handleCancel = () => {
        setNewMatiere('');
        setEditingMatiere(null);
    };

    const handleDelete = async (id) => {
        if (window.confirm('Supprimer cette matière ? Attention, cela échouera si elle est utilisée dans des classes.')) {
            try {
                await deleteMatiere(id);
                fetchMatieres();
            } catch (error) {
                alert(error.response?.data?.message || "Erreur lors de la suppression");
            }
        }
    };

    const filteredMatieres = matieres.filter(m =>
        m.nom.toLowerCase().includes(searchTerm.toLowerCase())
    );

    return (
        <div className="space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                {/* Create Form */}
                <div className="md:col-span-1">
                    <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-200">
                        <h3 className="font-semibold text-lg mb-4 text-slate-900">
                            {editingMatiere ? 'Modifier la Matière' : 'Nouvelle Matière'}
                        </h3>
                        <form onSubmit={handleSubmit} className="space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Nom de la matière</label>
                                <input
                                    type="text"
                                    value={newMatiere}
                                    onChange={(e) => setNewMatiere(e.target.value)}
                                    placeholder="Ex: Mathématiques"
                                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                                    required
                                />
                            </div>
                            <div className="flex gap-2">
                                {editingMatiere && (
                                    <button
                                        type="button"
                                        onClick={handleCancel}
                                        className="flex-1 flex items-center justify-center space-x-2 px-4 py-2 border border-slate-300 text-slate-700 rounded-lg hover:bg-slate-50 transition shadow-sm"
                                    >
                                        <X className="w-4 h-4" />
                                        <span>Annuler</span>
                                    </button>
                                )}
                                <button
                                    type="submit"
                                    disabled={creating || !newMatiere.trim()}
                                    className="flex-1 flex items-center justify-center space-x-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition shadow-sm disabled:opacity-50"
                                >
                                    {creating ? <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" /> : (editingMatiere ? <Edit className="w-4 h-4" /> : <Plus className="w-4 h-4" />)}
                                    <span>{editingMatiere ? 'Modifier' : 'Ajouter'}</span>
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

                {/* List */}
                <div className="md:col-span-2 space-y-4">
                    <div className="bg-white p-4 rounded-xl shadow-sm border border-slate-200">
                        <div className="relative">
                            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 w-5 h-5" />
                            <input
                                type="text"
                                placeholder="Rechercher une matière..."
                                value={searchTerm}
                                onChange={(e) => setSearchTerm(e.target.value)}
                                className="w-full pl-10 pr-4 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 transition"
                            />
                        </div>
                    </div>

                    <div className="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
                        <table className="w-full text-sm text-left">
                            <thead className="text-xs text-slate-500 uppercase bg-slate-50/50">
                                <tr>
                                    <th className="px-6 py-3 font-medium">Nom</th>
                                    <th className="px-6 py-3 font-medium text-right">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-100">
                                {loading ? (
                                    <tr><td colSpan="2" className="px-6 py-8 text-center text-slate-500">Chargement...</td></tr>
                                ) : filteredMatieres.length === 0 ? (
                                    <tr><td colSpan="2" className="px-6 py-8 text-center text-slate-500">Aucune matière trouvée.</td></tr>
                                ) : (
                                    filteredMatieres.map((matiere) => (
                                        <tr key={matiere.id} className="hover:bg-slate-50 transition">
                                            <td className="px-6 py-4 font-medium text-slate-900 flex items-center">
                                                <Book className="w-4 h-4 text-slate-400 mr-3" />
                                                {matiere.nom}
                                            </td>
                                            <td className="px-6 py-4 text-right">
                                                <button
                                                    onClick={() => handleEdit(matiere)}
                                                    className="text-blue-600 hover:bg-blue-50 p-2 rounded-lg transition mr-2"
                                                >
                                                    <Edit className="w-4 h-4" />
                                                </button>
                                                <button
                                                    onClick={() => handleDelete(matiere.id)}
                                                    className="text-red-600 hover:bg-red-50 p-2 rounded-lg transition"
                                                >
                                                    <Trash2 className="w-4 h-4" />
                                                </button>
                                            </td>
                                        </tr>
                                    ))
                                )}
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default MatieresList;
