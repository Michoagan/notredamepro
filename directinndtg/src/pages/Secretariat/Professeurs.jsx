import React, { useState, useEffect } from 'react';
import { getProfesseurs, deleteProfesseur } from '../../services/secretariat';
import { Plus, Search, Trash2, Edit, User, GraduationCap, Phone, Mail } from 'lucide-react';
import ProfesseurForm from './components/ProfesseurForm';

const Professeurs = () => {
    const [professeurs, setProfesseurs] = useState([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');
    const [isFormOpen, setIsFormOpen] = useState(false);
    const [selectedProfesseur, setSelectedProfesseur] = useState(null);

    const fetchData = async () => {
        setLoading(true);
        try {
            const data = await getProfesseurs();
            if (data.success) {
                setProfesseurs(data.professeurs);
            }
        } catch (error) {
            console.error("Erreur chargement professeurs", error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchData();
    }, []);

    const handleDelete = async (id) => {
        if (window.confirm('Voulez-vous vraiment supprimer ce professeur ?')) {
            try {
                await deleteProfesseur(id);
                fetchData();
            } catch (error) {
                alert('Erreur lors de la suppression');
            }
        }
    };

    const handleEdit = (prof) => {
        setSelectedProfesseur(prof);
        setIsFormOpen(true);
    };

    const handleCreate = () => {
        setSelectedProfesseur(null);
        setIsFormOpen(true);
    };

    const filteredProfesseurs = professeurs.filter(p =>
        p.last_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        p.first_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        (p.matiere?.nom || '').toLowerCase().includes(searchTerm.toLowerCase())
    );

    return (
        <div className="space-y-6">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-slate-900">Gestion des Professeurs</h1>
                    <p className="text-slate-500">Inscriptions et gestion du corps enseignant</p>
                </div>
                <button
                    onClick={handleCreate}
                    className="flex items-center space-x-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition shadow-sm"
                >
                    <Plus className="w-4 h-4" />
                    <span>Nouveau Professeur</span>
                </button>
            </div>

            <div className="bg-white p-4 rounded-xl shadow-sm border border-slate-200">
                <div className="relative">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 w-5 h-5" />
                    <input
                        type="text"
                        placeholder="Rechercher un professeur (Nom, Matière...)"
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                        className="w-full pl-10 pr-4 py-3 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition"
                    />
                </div>
            </div>

            <div className="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
                <div className="overflow-x-auto">
                    <table className="w-full text-sm text-left">
                        <thead className="text-xs text-slate-500 uppercase bg-slate-50/50">
                            <tr>
                                <th className="px-6 py-3 font-medium">Professeur</th>
                                <th className="px-6 py-3 font-medium">Spécialité</th>
                                <th className="px-6 py-3 font-medium">Contacts</th>
                                <th className="px-6 py-3 font-medium">Code Personnel</th>
                                <th className="px-6 py-3 font-medium text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-slate-100">
                            {loading ? (
                                <tr>
                                    <td colSpan="5" className="px-6 py-8 text-center text-slate-500">Chargement...</td>
                                </tr>
                            ) : filteredProfesseurs.length === 0 ? (
                                <tr>
                                    <td colSpan="5" className="px-6 py-8 text-center text-slate-500">Aucun professeur trouvé.</td>
                                </tr>
                            ) : (
                                filteredProfesseurs.map((prof) => (
                                    <tr key={prof.id} className="hover:bg-slate-50/80 transition group">
                                        <td className="px-6 py-4">
                                            <div className="flex items-center">
                                                {prof.photo ? (
                                                    <img src={`https://schoolndtg.onrender.com/storage/professeurs/${prof.photo}`} alt="" className="w-10 h-10 rounded-full object-cover mr-4" />
                                                ) : (
                                                    <div className="w-10 h-10 rounded-full bg-slate-100 flex items-center justify-center mr-4 text-slate-400">
                                                        <User className="w-5 h-5" />
                                                    </div>
                                                )}
                                                <div>
                                                    <div className="font-medium text-slate-900">{prof.last_name} {prof.first_name}</div>
                                                    <div className="text-xs text-slate-500">{prof.gender === 'M' ? 'Masculin' : 'Féminin'}</div>
                                                </div>
                                            </div>
                                        </td>
                                        <td className="px-6 py-4">
                                            <div className="flex items-center text-slate-700">
                                                <GraduationCap className="w-4 h-4 mr-2 text-slate-400" />
                                                {prof.matiere?.nom || 'Non assignée'}
                                            </div>
                                        </td>
                                        <td className="px-6 py-4">
                                            <div className="space-y-1">
                                                <div className="flex items-center text-slate-600 text-xs">
                                                    <Mail className="w-3 h-3 mr-2" />
                                                    {prof.email}
                                                </div>
                                                <div className="flex items-center text-slate-600 text-xs">
                                                    <Phone className="w-3 h-3 mr-2" />
                                                    {prof.phone}
                                                </div>
                                            </div>
                                        </td>
                                        <td className="px-6 py-4">
                                            {/* Code is hashed, so maybe don't show or show placeholder? 
                                                The backend generates it. Just showing if account active/exist. 
                                            */}
                                            <span className="bg-slate-100 text-slate-600 px-2 py-1 rounded text-xs">Masqué</span>
                                        </td>
                                        <td className="px-6 py-4 text-right">
                                            <div className="flex items-center justify-end space-x-2">
                                                <button
                                                    onClick={() => handleEdit(prof)}
                                                    className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition"
                                                >
                                                    <Edit className="w-4 h-4" />
                                                </button>
                                                <button
                                                    onClick={() => handleDelete(prof.id)}
                                                    className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition"
                                                >
                                                    <Trash2 className="w-4 h-4" />
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>
            </div>

            {isFormOpen && (
                <ProfesseurForm
                    isOpen={isFormOpen}
                    onClose={() => setIsFormOpen(false)}
                    professeur={selectedProfesseur}
                    onSuccess={fetchData}
                />
            )}
        </div>
    );
};

export default Professeurs;
