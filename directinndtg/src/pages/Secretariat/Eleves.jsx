import React, { useState, useEffect } from 'react';
import { getEleves, deleteEleve } from '../../services/secretariat';
import { Plus, Upload, Search, Filter, Trash2, Edit, ChevronDown, ChevronRight, User } from 'lucide-react';
import StudentForm from './components/StudentForm';
import ImportStudent from './components/ImportStudent';
import AffectationModal from './components/AffectationModal';

const Eleves = () => {
    const [classes, setClasses] = useState([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');
    const [isFormOpen, setIsFormOpen] = useState(false);
    const [isImportOpen, setIsImportOpen] = useState(false);
    const [isAffectationOpen, setIsAffectationOpen] = useState(false);
    const [selectedStudent, setSelectedStudent] = useState(null);
    const [expandedClasses, setExpandedClasses] = useState({});

    // Fetch data
    const fetchData = async () => {
        setLoading(true);
        try {
            const data = await getEleves({ search: searchTerm });
            if (data.success) {
                setClasses(data.classes);
                // Auto-expand all if searching
                if (searchTerm) {
                    const allIds = {};
                    data.classes.forEach(c => allIds[c.id] = true);
                    setExpandedClasses(allIds);
                }
            }
        } catch (error) {
            console.error("Erreur chargement élèves", error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        // Debounce search
        const delayDebounceFn = setTimeout(() => {
            fetchData();
        }, 500);

        return () => clearTimeout(delayDebounceFn);
    }, [searchTerm]);

    const toggleClass = (classeId) => {
        setExpandedClasses(prev => ({
            ...prev,
            [classeId]: !prev[classeId]
        }));
    };

    const handleDelete = async (id) => {
        if (window.confirm('Voulez-vous vraiment supprimer cet élève ?')) {
            try {
                await deleteEleve(id);
                fetchData(); // Refresh
            } catch (error) {
                alert('Erreur lors de la suppression');
            }
        }
    };

    const handleEdit = (student) => {
        setSelectedStudent(student);
        setIsFormOpen(true);
    };

    const handleCreate = () => {
        setSelectedStudent(null);
        setIsFormOpen(true);
    };

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-slate-900">Gestion des Élèves</h1>
                    <p className="text-slate-500">Inscriptions, modifications et listes par classe</p>
                </div>
                <div className="flex gap-3">
                    <button
                        onClick={() => setIsImportOpen(true)}
                        className="flex items-center space-x-2 px-4 py-2 bg-white border border-slate-300 rounded-lg text-slate-700 hover:bg-slate-50 transition"
                    >
                        <Upload className="w-4 h-4" />
                        <span className="hidden sm:inline">Importer</span>
                    </button>
                    <button
                        onClick={() => setIsAffectationOpen(true)}
                        className="flex items-center space-x-2 px-4 py-2 bg-amber-50 border border-amber-200 rounded-lg text-amber-700 hover:bg-amber-100 transition shadow-sm"
                    >
                        <User className="w-4 h-4" />
                        <span className="hidden sm:inline">Élèves en attente</span>
                    </button>
                    <button
                        onClick={handleCreate}
                        className="flex items-center space-x-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition shadow-sm"
                    >
                        <Plus className="w-4 h-4" />
                        <span className="hidden sm:inline">Nouveau</span>
                    </button>
                </div>
            </div>

            {/* Filters */}
            <div className="bg-white p-4 rounded-xl shadow-sm border border-slate-200">
                <div className="relative">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 w-5 h-5" />
                    <input
                        type="text"
                        placeholder="Rechercher un élève (Nom, Prénom, Matricule...)"
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                        className="w-full pl-10 pr-4 py-3 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition"
                    />
                </div>
            </div>

            {/* Content */}
            <div className="space-y-4">
                {loading ? (
                    <div className="text-center py-10 text-slate-500">Chargement...</div>
                ) : classes.length === 0 ? (
                    <div className="text-center py-10 bg-white rounded-xl border border-slate-200">
                        <div className="mx-auto w-12 h-12 bg-slate-100 rounded-full flex items-center justify-center mb-3">
                            <User className="w-6 h-6 text-slate-400" />
                        </div>
                        <h3 className="text-lg font-medium text-slate-900">Aucun élève trouvé</h3>
                        <p className="text-slate-500">Essayez de modifier votre recherche ou ajoutez un nouvel élève.</p>
                    </div>
                ) : (
                    classes.map((classe) => (
                        <div key={classe.id} className="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
                            <div
                                onClick={() => toggleClass(classe.id)}
                                className="flex items-center justify-between p-4 cursor-pointer hover:bg-slate-50 transition border-b border-slate-100"
                            >
                                <div className="flex items-center space-x-3">
                                    <div className={`p-1 rounded-md transition ${expandedClasses[classe.id] ? 'bg-blue-100 text-blue-600' : 'text-slate-400'}`}>
                                        {expandedClasses[classe.id] ? <ChevronDown className="w-5 h-5" /> : <ChevronRight className="w-5 h-5" />}
                                    </div>
                                    <h3 className="font-semibold text-lg text-slate-900">{classe.nom}</h3>
                                    <span className="bg-slate-100 text-slate-600 px-2 py-0.5 rounded-full text-xs font-medium">
                                        {classe.eleves ? classe.eleves.length : 0} élèves
                                    </span>
                                </div>
                            </div>

                            {expandedClasses[classe.id] && (
                                <div className="p-4 overflow-x-auto">
                                    <table className="w-full text-sm text-left">
                                        <thead className="text-xs text-slate-500 uppercase bg-slate-50/50">
                                            <tr>
                                                <th className="px-4 py-3 font-medium">Matricule</th>
                                                <th className="px-4 py-3 font-medium">Nom & Prénom</th>
                                                <th className="px-4 py-3 font-medium">Sexe</th>
                                                <th className="px-4 py-3 font-medium">Date Naissance</th>
                                                <th className="px-4 py-3 font-medium">Parent</th>
                                                <th className="px-4 py-3 font-medium text-right">Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody className="divide-y divide-slate-100">
                                            {classe.eleves && classe.eleves.map((eleve) => (
                                                <tr key={eleve.id} className="hover:bg-slate-50/80 transition group">
                                                    <td className="px-4 py-3 font-medium text-slate-900">{eleve.matricule}</td>
                                                    <td className="px-4 py-3">
                                                        <div className="flex items-center">
                                                            {eleve.photo ? (
                                                                <img src={`https://schoolndtg.onrender.com/storage/${eleve.photo}`} alt="" className="w-8 h-8 rounded-full object-cover mr-3" />
                                                            ) : (
                                                                <div className="w-8 h-8 rounded-full bg-slate-100 flex items-center justify-center mr-3 text-slate-400">
                                                                    <User className="w-4 h-4" />
                                                                </div>
                                                            )}
                                                            <span className="font-medium text-slate-700">{eleve.nom} {eleve.prenom}</span>
                                                        </div>
                                                    </td>
                                                    <td className="px-4 py-3">
                                                        <span className={`px-2 py-1 rounded-full text-xs font-medium ${eleve.sexe === 'F' ? 'bg-pink-100 text-pink-700' : 'bg-blue-100 text-blue-700'}`}>
                                                            {eleve.sexe}
                                                        </span>
                                                    </td>
                                                    <td className="px-4 py-3 text-slate-500">
                                                        {new Date(eleve.date_naissance).toLocaleDateString('fr-FR')}
                                                    </td>
                                                    <td className="px-4 py-3">
                                                        <div className="text-slate-700">{eleve.nom_parent}</div>
                                                        <div className="text-xs text-slate-400">{eleve.telephone_parent}</div>
                                                    </td>
                                                    <td className="px-4 py-3 text-right">
                                                        <div className="flex items-center justify-end space-x-1 opacity-0 group-hover:opacity-100 transition">
                                                            <button
                                                                onClick={(e) => { e.stopPropagation(); handleEdit(eleve); }}
                                                                className="p-1.5 text-blue-600 hover:bg-blue-50 rounded-md transition"
                                                                title="Modifier"
                                                            >
                                                                <Edit className="w-4 h-4" />
                                                            </button>
                                                            <button
                                                                onClick={(e) => { e.stopPropagation(); handleDelete(eleve.id); }}
                                                                className="p-1.5 text-red-600 hover:bg-red-50 rounded-md transition"
                                                                title="Supprimer"
                                                            >
                                                                <Trash2 className="w-4 h-4" />
                                                            </button>
                                                        </div>
                                                    </td>
                                                </tr>
                                            ))}
                                            {(!classe.eleves || classe.eleves.length === 0) && (
                                                <tr>
                                                    <td colSpan="6" className="px-4 py-8 text-center text-slate-400 italic">
                                                        Aucun élève dans cette classe.
                                                    </td>
                                                </tr>
                                            )}
                                        </tbody>
                                    </table>
                                </div>
                            )}
                        </div>
                    ))
                )}
            </div>

            {/* Modals */}
            {isFormOpen && (
                <StudentForm
                    isOpen={isFormOpen}
                    onClose={() => setIsFormOpen(false)}
                    student={selectedStudent}
                    onSuccess={fetchData}
                />
            )}

            {isImportOpen && (
                <ImportStudent
                    isOpen={isImportOpen}
                    onClose={() => setIsImportOpen(false)}
                    onSuccess={fetchData}
                />
            )}

            {isAffectationOpen && (
                <AffectationModal
                    isOpen={isAffectationOpen}
                    onClose={() => setIsAffectationOpen(false)}
                    onSuccess={fetchData}
                />
            )}
        </div>
    );
};

export default Eleves;
