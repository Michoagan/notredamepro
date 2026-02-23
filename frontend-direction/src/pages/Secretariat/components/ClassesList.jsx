import React, { useState, useEffect } from 'react';
import { getClasses, deleteClasse } from '../../../services/secretariat';
import { Plus, Search, Trash2, Edit, ChevronDown, ChevronRight, Layers, Users } from 'lucide-react';
import ClassForm from './ClassForm';

const ClassesList = () => {
    const [classes, setClasses] = useState([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');
    const [isFormOpen, setIsFormOpen] = useState(false);
    const [selectedClass, setSelectedClass] = useState(null);
    const [expandedClasses, setExpandedClasses] = useState({});

    const fetchClasses = async () => {
        setLoading(true);
        try {
            const data = await getClasses();
            if (data.success && data.classes) {
                setClasses(data.classes);
            }
        } catch (error) {
            console.error("Erreur chargement classes", error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchClasses();
    }, []);

    const toggleClass = (id) => {
        setExpandedClasses(prev => ({
            ...prev,
            [id]: !prev[id]
        }));
    };

    const handleDelete = async (id) => {
        if (window.confirm('Voulez-vous vraiment supprimer cette classe ? Cette action supprimera également les associations avec les matières.')) {
            try {
                await deleteClasse(id);
                fetchClasses();
            } catch (error) {
                alert('Erreur: ' + (error.response?.data?.message || 'Impossible de supprimer.'));
            }
        }
    };

    const handleEdit = (classe) => {
        setSelectedClass(classe);
        setIsFormOpen(true);
    };

    const handleCreate = () => {
        setSelectedClass(null);
        setIsFormOpen(true);
    };

    const filteredClasses = classes.filter(c =>
        c.nom.toLowerCase().includes(searchTerm.toLowerCase())
    );

    return (
        <div className="space-y-6">
            <div className="flex justify-between gap-4">
                <div className="relative flex-1 max-w-md">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 w-5 h-5" />
                    <input
                        type="text"
                        placeholder="Rechercher une classe..."
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                        className="w-full pl-10 pr-4 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 transition"
                    />
                </div>
                <button
                    onClick={handleCreate}
                    className="flex items-center space-x-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition shadow-sm"
                >
                    <Plus className="w-4 h-4" />
                    <span>Nouvelle Classe</span>
                </button>
            </div>

            <div className="space-y-4">
                {loading ? (
                    <div className="text-center py-10 text-slate-500">Chargement...</div>
                ) : filteredClasses.length === 0 ? (
                    <div className="text-center py-10 bg-white rounded-xl border border-slate-200 text-slate-500">
                        Aucune classe trouvée.
                    </div>
                ) : (
                    filteredClasses.map((classe) => (
                        <div key={classe.id} className="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
                            <div className="flex items-center justify-between p-4 border-b border-slate-100 hover:bg-slate-50 transition cursor-pointer" onClick={() => toggleClass(classe.id)}>
                                <div className="flex items-center space-x-4">
                                    <div className={`p-1 rounded-md transition ${expandedClasses[classe.id] ? 'bg-blue-100 text-blue-600' : 'text-slate-400'}`}>
                                        {expandedClasses[classe.id] ? <ChevronDown className="w-5 h-5" /> : <ChevronRight className="w-5 h-5" />}
                                    </div>
                                    <div>
                                        <h3 className="font-semibold text-lg text-slate-900 flex items-center">
                                            <Layers className="w-4 h-4 mr-2 text-slate-400" />
                                            {classe.nom}
                                            <span className="ml-3 text-xs font-normal bg-slate-100 text-slate-500 px-2 py-0.5 rounded-full border border-slate-200">
                                                Niveau: {classe.niveau}
                                            </span>
                                        </h3>
                                        <div className="mt-1 flex items-center text-sm text-slate-500 space-x-4">
                                            <span className="flex items-center">
                                                <Users className="w-3 h-3 mr-1" />
                                                {classe.eleves_count || 0} Élèves
                                            </span>
                                            <span>
                                                Prof. Principal: <span className="text-slate-700 font-medium">
                                                    {classe.professeur_principal
                                                        ? `${classe.professeur_principal.first_name} ${classe.professeur_principal.last_name}`
                                                        : 'Non défini'}
                                                </span>
                                            </span>
                                        </div>
                                    </div>
                                </div>
                                <div className="flex items-center space-x-2" onClick={(e) => e.stopPropagation()}>
                                    <button
                                        onClick={() => handleEdit(classe)}
                                        className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition"
                                    >
                                        <Edit className="w-4 h-4" />
                                    </button>
                                    <button
                                        onClick={() => handleDelete(classe.id)}
                                        className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition"
                                    >
                                        <Trash2 className="w-4 h-4" />
                                    </button>
                                </div>
                            </div>

                            {expandedClasses[classe.id] && (
                                <div className="p-4 bg-slate-50/50">
                                    <h4 className="text-xs font-semibold text-slate-500 uppercase tracking-wider mb-3">Matières & Coefficients</h4>
                                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
                                        {classe.matieres && classe.matieres.map((matiere) => (
                                            <div key={matiere.id} className="bg-white p-3 rounded-lg border border-slate-200 shadow-sm text-sm">
                                                <div className="font-medium text-slate-900 flex justify-between">
                                                    <span>{matiere.nom}</span>
                                                    <span className="bg-blue-50 text-blue-700 px-1.5 rounded text-xs">Coef: {matiere.pivot?.coefficient || matiere.coefficient}</span>
                                                </div>
                                                <div className="text-slate-500 text-xs mt-1 truncate">
                                                    Prof: {matiere.professeur
                                                        ? `${matiere.professeur.first_name} ${matiere.professeur.last_name}`
                                                        : (matiere.pivot?.professeur_id ? 'Assigné (ID ' + matiere.pivot.professeur_id + ')' : 'Non assigné')}
                                                </div>
                                            </div>
                                        ))}
                                    </div>
                                </div>
                            )}
                        </div>
                    ))
                )}
            </div>

            {isFormOpen && (
                <ClassForm
                    isOpen={isFormOpen}
                    onClose={() => setIsFormOpen(false)}
                    classe={selectedClass}
                    onSuccess={fetchClasses}
                />
            )}
        </div>
    );
};

export default ClassesList;
