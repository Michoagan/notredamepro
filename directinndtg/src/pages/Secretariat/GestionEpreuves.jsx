import React, { useState, useEffect } from 'react';
import {
    FileText, Plus, Search, Trash2, Edit, CheckCircle,
    XCircle, Upload, AlertCircle, Calendar, BookOpen
} from 'lucide-react';
import axios from 'axios';
import api from '../../services/api';

const GestionEpreuves = () => {
    const [epreuves, setEpreuves] = useState([]);
    const [matieres, setMatieres] = useState([]);
    const [classes, setClasses] = useState([]);
    const [loading, setLoading] = useState(true);
    const [submitting, setSubmitting] = useState(false);
    const [searchTerm, setSearchTerm] = useState('');
    const [error, setError] = useState(null);
    const [success, setSuccess] = useState(null);

    // Form State
    const [showForm, setShowForm] = useState(false);
    const [formData, setFormData] = useState({
        titre: '',
        matiere_id: '',
        classe_id: '',
        annee: new Date().getFullYear().toString(),
        type: 'Devoir',
        fichier: null
    });

    const token = localStorage.getItem('token');

    useEffect(() => {
        fetchInitialData();
    }, []);

    const fetchInitialData = async () => {
        try {
            setLoading(true);

            // On récupère les épreuves
            const epreuvesRes = await api.get('/secretaire/epreuves');
            setEpreuves(epreuvesRes.data);

            // On récupère aussi matières et classes pour le formulaire
            const matieresRes = await api.get('/classes/matieres');
            const classesRes = await api.get('/classes/index');

            // Handle both possible response structures depending on how the backend returns data
            setMatieres(matieresRes.data?.data || matieresRes.data?.matieres || matieresRes.data || []);
            setClasses(classesRes.data?.data || classesRes.data?.classes || classesRes.data || []);

            setError(null);
        } catch (err) {
            setError("Erreur lors du chargement des données.");
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    const handleFileChange = (e) => {
        if (e.target.files && e.target.files[0]) {
            setFormData({ ...formData, fichier: e.target.files[0] });
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setSubmitting(true);
        setError(null);
        setSuccess(null);

        try {
            const data = new FormData();
            data.append('titre', formData.titre);
            data.append('matiere_id', formData.matiere_id);
            data.append('classe_id', formData.classe_id);
            data.append('annee', formData.annee);
            data.append('type', formData.type);
            data.append('fichier', formData.fichier);

            const response = await api.post('/secretaire/epreuves', data, {
                headers: { 'Content-Type': 'multipart/form-data' }
            });

            setSuccess("Épreuve ajoutée avec succès !");
            setShowForm(false);
            setFormData({
                titre: '',
                matiere_id: '',
                classe_id: '',
                annee: new Date().getFullYear().toString(),
                type: 'Devoir',
                fichier: null
            });
            fetchInitialData(); // Refresh list

        } catch (err) {
            setError(err.response?.data?.message || "Erreur lors de l'ajout de l'épreuve.");
            console.error(err);
        } finally {
            setSubmitting(false);
            setTimeout(() => setSuccess(null), 3000);
        }
    };

    const handleDelete = async (id) => {
        if (!window.confirm("Voulez-vous vraiment supprimer cette épreuve ?")) return;

        try {
            await api.delete(`/secretaire/epreuves/${id}`);
            setSuccess("Épreuve supprimée avec succès.");
            fetchInitialData();
            setTimeout(() => setSuccess(null), 3000);
        } catch (err) {
            setError("Erreur lors de la suppression.");
        }
    };

    const filteredEpreuves = epreuves.filter(e =>
        (e.titre || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
        (e.matiere?.nom || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
        (e.classe?.nom || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
        (e.annee || '').includes(searchTerm)
    );

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-slate-800">Anciennes Épreuves</h1>
                    <p className="text-slate-500">Gérez les anciens sujets visibles par les élèves</p>
                </div>
                <button
                    onClick={() => setShowForm(!showForm)}
                    className="flex items-center space-x-2 bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition"
                >
                    {showForm ? <XCircle size={20} /> : <Plus size={20} />}
                    <span>{showForm ? 'Annuler' : 'Ajouter une Épreuve'}</span>
                </button>
            </div>

            {error && (
                <div className="bg-red-50 text-red-600 p-4 rounded-lg flex items-center gap-2">
                    <AlertCircle size={20} />
                    {error}
                </div>
            )}

            {success && (
                <div className="bg-green-50 text-green-600 p-4 rounded-lg flex items-center gap-2">
                    <CheckCircle size={20} />
                    {success}
                </div>
            )}

            {showForm && (
                <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-100">
                    <h2 className="text-lg font-bold mb-4 flex items-center gap-2 text-slate-800">
                        <Upload size={20} className="text-blue-600" />
                        Téléverser un nouveau sujet
                    </h2>

                    <form onSubmit={handleSubmit} className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                            <label className="block text-sm font-medium text-slate-700 mb-1">Titre (optionnel)</label>
                            <input
                                type="text"
                                className="w-full border rounded-lg p-2.5 focus:ring-2 focus:ring-blue-500 outline-none"
                                placeholder="Ex: Devoir de fin de trimestre..."
                                value={formData.titre}
                                onChange={(e) => setFormData({ ...formData, titre: e.target.value })}
                            />
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-slate-700 mb-1">Type d'évaluation</label>
                            <select
                                className="w-full border rounded-lg p-2.5 focus:ring-2 focus:ring-blue-500 outline-none"
                                value={formData.type}
                                onChange={(e) => setFormData({ ...formData, type: e.target.value })}
                                required
                            >
                                <option value="Devoir">Devoir</option>
                                <option value="Interrogation">Interrogation</option>
                                <option value="Composition Trimestre 1">Composition Trimestre 1</option>
                                <option value="Composition Trimestre 2">Composition Trimestre 2</option>
                                <option value="Composition Trimestre 3">Composition Trimestre 3</option>
                                <option value="Examen Blanc">Examen Blanc</option>
                            </select>
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-slate-700 mb-1">Matière *</label>
                            <select
                                className="w-full border rounded-lg p-2.5 focus:ring-2 focus:ring-blue-500 outline-none"
                                value={formData.matiere_id}
                                onChange={(e) => setFormData({ ...formData, matiere_id: e.target.value })}
                                required
                            >
                                <option value="">-- Sélectionner une matière --</option>
                                {matieres.map(m => <option key={m.id} value={m.id}>{m.nom}</option>)}
                            </select>
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-slate-700 mb-1">Classe *</label>
                            <select
                                className="w-full border rounded-lg p-2.5 focus:ring-2 focus:ring-blue-500 outline-none"
                                value={formData.classe_id}
                                onChange={(e) => setFormData({ ...formData, classe_id: e.target.value })}
                                required
                            >
                                <option value="">-- Sélectionner une classe --</option>
                                {classes.map(c => <option key={c.id} value={c.id}>{c.nom}</option>)}
                            </select>
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-slate-700 mb-1">Année *</label>
                            <input
                                type="number"
                                className="w-full border rounded-lg p-2.5 focus:ring-2 focus:ring-blue-500 outline-none"
                                placeholder="Ex: 2023"
                                value={formData.annee}
                                onChange={(e) => setFormData({ ...formData, annee: e.target.value })}
                                required
                            />
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-slate-700 mb-1">Fichier (PDF/Doc) *</label>
                            <input
                                type="file"
                                accept=".pdf,.doc,.docx"
                                className="w-full border rounded-lg p-2 focus:ring-2 focus:ring-blue-500 outline-none file:mr-4 file:py-1 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100"
                                onChange={handleFileChange}
                                required
                            />
                        </div>

                        <div className="col-span-full mt-2">
                            <button
                                type="submit"
                                disabled={submitting}
                                className="w-full bg-blue-600 hover:bg-blue-700 text-white py-3 rounded-lg font-bold transition flex justify-center items-center gap-2"
                            >
                                {submitting ? (
                                    <><div className="animate-spin h-5 w-5 border-2 border-white border-t-transparent rounded-full"></div> Téléversement...</>
                                ) : (
                                    <><Upload size={20} /> Valider l'ajout</>
                                )}
                            </button>
                        </div>
                    </form>
                </div>
            )}

            <div className="bg-white rounded-xl shadow-sm border border-slate-100 overflow-hidden">
                <div className="p-4 border-b border-slate-100 bg-slate-50 flex flex-col sm:flex-row justify-between items-center gap-4">
                    <h2 className="font-bold text-slate-700 flex items-center gap-2">
                        <FileText size={18} className="text-blue-600" />
                        Liste des fichiers partagés
                    </h2>

                    <div className="relative w-full sm:w-64">
                        <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-400 w-4 h-4" />
                        <input
                            type="text"
                            placeholder="Rechercher..."
                            className="w-full pl-9 pr-4 py-2 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                        />
                    </div>
                </div>

                <div className="overflow-x-auto">
                    <table className="w-full text-left border-collapse">
                        <thead>
                            <tr className="bg-slate-50 text-slate-500 text-sm uppercase tracking-wider">
                                <th className="p-4 border-b">Document</th>
                                <th className="p-4 border-b">Classe & Matière</th>
                                <th className="p-4 border-b">Année</th>
                                <th className="p-4 border-b text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-slate-100">
                            {loading ? (
                                <tr>
                                    <td colSpan="4" className="p-8 text-center text-slate-500">
                                        Chargement en cours...
                                    </td>
                                </tr>
                            ) : filteredEpreuves.length > 0 ? (
                                filteredEpreuves.map(epreuve => (
                                    <tr key={epreuve.id} className="hover:bg-slate-50 transition-colors">
                                        <td className="p-4">
                                            <div className="font-medium text-slate-800">{epreuve.titre || epreuve.type}</div>
                                            <div className="text-xs text-slate-500">{epreuve.type}</div>
                                        </td>
                                        <td className="p-4">
                                            <div className="font-medium text-blue-600">{epreuve.classe?.nom}</div>
                                            <div className="text-sm text-slate-500">{epreuve.matiere?.nom}</div>
                                        </td>
                                        <td className="p-4">
                                            <span className="bg-slate-100 text-slate-700 py-1 px-3 rounded-full text-xs font-semibold">
                                                {epreuve.annee}
                                            </span>
                                        </td>
                                        <td className="p-4 text-right">
                                            <div className="flex justify-end gap-2">
                                                <a
                                                    href={`${api.defaults.baseURL.replace('/api', '')}/storage/${epreuve.file_path}`}
                                                    target="_blank"
                                                    rel="noopener noreferrer"
                                                    className="p-2 text-blue-600 bg-blue-50 hover:bg-blue-100 rounded-lg transition"
                                                    title="Ouvrir le document"
                                                >
                                                    <BookOpen size={16} />
                                                </a>
                                                <button
                                                    onClick={() => handleDelete(epreuve.id)}
                                                    className="p-2 text-red-600 bg-red-50 hover:bg-red-100 rounded-lg transition"
                                                    title="Supprimer"
                                                >
                                                    <Trash2 size={16} />
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                ))
                            ) : (
                                <tr>
                                    <td colSpan="4" className="p-8 text-center text-slate-500">
                                        Aucun document trouvé.
                                    </td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>
            </div>

        </div >
    );
};

export default GestionEpreuves;
