import React, { useState, useEffect } from 'react';
import { X, CheckCircle, Search, AlertCircle } from 'lucide-react';
import { getElevesEnAttente, affecterClasses, getClasses } from '../../../services/secretariat';

const AffectationModal = ({ isOpen, onClose, onSuccess }) => {
    const [eleves, setEleves] = useState([]);
    const [classes, setClasses] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [selectedIds, setSelectedIds] = useState(new Set());
    const [searchTerm, setSearchTerm] = useState('');
    const [selectedClasseId, setSelectedClasseId] = useState('');
    const [isSubmitting, setIsSubmitting] = useState(false);

    useEffect(() => {
        if (isOpen) {
            fetchData();
        } else {
            // Reset states when closed
            setSelectedIds(new Set());
            setSelectedClasseId('');
            setSearchTerm('');
            setError(null);
        }
    }, [isOpen]);

    const fetchData = async () => {
        setLoading(true);
        setError(null);
        try {
            const [elevesRes, classesRes] = await Promise.all([
                getElevesEnAttente(),
                getClasses()
            ]);
            
            if (elevesRes.success) {
                setEleves(elevesRes.eleves);
            }
            if (classesRes.success) {
                setClasses(classesRes.classes);
            }
        } catch (err) {
            setError("Erreur lors du chargement des données.");
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    const handleSelectAll = (e) => {
        if (e.target.checked) {
            setSelectedIds(new Set(filteredEleves.map(el => el.id)));
        } else {
            setSelectedIds(new Set());
        }
    };

    const handleSelectOne = (id) => {
        const newSelected = new Set(selectedIds);
        if (newSelected.has(id)) {
            newSelected.delete(id);
        } else {
            newSelected.add(id);
        }
        setSelectedIds(newSelected);
    };

    const handleSubmit = async () => {
        if (selectedIds.size === 0) {
            setError("Veuillez sélectionner au moins un élève.");
            return;
        }
        if (!selectedClasseId) {
            setError("Veuillez sélectionner une classe de destination.");
            return;
        }

        setIsSubmitting(true);
        setError(null);
        
        try {
            const result = await affecterClasses({
                eleve_ids: Array.from(selectedIds),
                classe_id: selectedClasseId
            });

            if (result.success) {
                onSuccess();
                onClose();
            } else {
                setError(result.message || "Erreur lors de l'affectation");
            }
        } catch (err) {
            setError("Erreur de connexion au serveur.");
            console.error(err);
        } finally {
            setIsSubmitting(false);
        }
    };

    if (!isOpen) return null;

    const filteredEleves = eleves.filter(el => 
        el.nom.toLowerCase().includes(searchTerm.toLowerCase()) || 
        el.prenom.toLowerCase().includes(searchTerm.toLowerCase()) ||
        (el.classe && el.classe.nom.toLowerCase().includes(searchTerm.toLowerCase()))
    );

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/50 backdrop-blur-sm">
            <div className="bg-white rounded-xl shadow-xl w-full max-w-4xl flex flex-col max-h-[90vh]">
                
                {/* Header */}
                <div className="flex items-center justify-between p-6 border-b border-slate-100">
                    <div>
                        <h2 className="text-xl font-bold text-slate-800">Passation de Classe</h2>
                        <p className="text-sm text-slate-500 mt-1">Affecter les élèves en attente à leur nouvelle classe</p>
                    </div>
                    <button 
                        onClick={onClose}
                        className="p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-full transition"
                    >
                        <X className="w-5 h-5" />
                    </button>
                </div>

                {/* Content */}
                <div className="p-6 flex-1 overflow-y-auto bg-slate-50">
                    {loading ? (
                        <div className="flex justify-center py-12">
                            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
                        </div>
                    ) : (
                        <div className="space-y-6">
                            
                            {/* Controls */}
                            <div className="flex flex-col md:flex-row gap-4 justify-between bg-white p-4 rounded-lg shadow-sm border border-slate-200">
                                <div className="relative flex-1">
                                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
                                    <input 
                                        type="text" 
                                        placeholder="Filtrer par nom ou ancienne classe..."
                                        value={searchTerm}
                                        onChange={(e) => setSearchTerm(e.target.value)}
                                        className="w-full pl-9 pr-4 py-2 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                                    />
                                </div>
                                <div className="flex items-center gap-3">
                                    <span className="text-sm font-medium text-slate-700 whitespace-nowrap">Affecter à :</span>
                                    <select 
                                        value={selectedClasseId}
                                        onChange={(e) => setSelectedClasseId(e.target.value)}
                                        className="border border-slate-300 rounded-lg py-2 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 min-w-[200px]"
                                    >
                                        <option value="">-- Choisir la classe --</option>
                                        {classes.map(c => (
                                            <option key={c.id} value={c.id}>{c.nom} ({c.niveau})</option>
                                        ))}
                                    </select>
                                </div>
                            </div>

                            {/* Error Alert */}
                            {error && (
                                <div className="flex items-center gap-2 p-4 bg-red-50 text-red-700 rounded-lg border border-red-100">
                                    <AlertCircle className="w-5 h-5 flex-shrink-0" />
                                    <p className="text-sm">{error}</p>
                                </div>
                            )}

                            {/* Table */}
                            <div className="bg-white rounded-lg shadow-sm border border-slate-200 overflow-hidden">
                                <div className="overflow-x-auto">
                                    <table className="w-full text-sm text-left">
                                        <thead className="text-xs text-slate-500 uppercase bg-slate-50 border-b border-slate-200">
                                            <tr>
                                                <th className="px-4 py-3 w-10">
                                                    <input 
                                                        type="checkbox" 
                                                        onChange={handleSelectAll}
                                                        checked={filteredEleves.length > 0 && selectedIds.size === filteredEleves.length}
                                                        className="w-4 h-4 rounded border-slate-300 text-blue-600 focus:ring-blue-500"
                                                    />
                                                </th>
                                                <th className="px-4 py-3 font-medium">Élève</th>
                                                <th className="px-4 py-3 font-medium">Ancienne Classe</th>
                                                <th className="px-4 py-3 font-medium text-center">Status</th>
                                            </tr>
                                        </thead>
                                        <tbody className="divide-y divide-slate-100">
                                            {filteredEleves.length === 0 ? (
                                                <tr>
                                                    <td colSpan="4" className="px-4 py-8 text-center text-slate-500">
                                                        Aucun élève en attente d'affectation trouvé.
                                                    </td>
                                                </tr>
                                            ) : (
                                                filteredEleves.map(eleve => (
                                                    <tr 
                                                        key={eleve.id} 
                                                        className={`hover:bg-slate-50 transition cursor-pointer ${selectedIds.has(eleve.id) ? 'bg-blue-50/50' : ''}`}
                                                        onClick={() => handleSelectOne(eleve.id)}
                                                    >
                                                        <td className="px-4 py-3">
                                                            <input 
                                                                type="checkbox" 
                                                                checked={selectedIds.has(eleve.id)}
                                                                onChange={() => {}} // handled by row click
                                                                className="w-4 h-4 rounded border-slate-300 text-blue-600 focus:ring-blue-500"
                                                            />
                                                        </td>
                                                        <td className="px-4 py-3">
                                                            <div className="font-medium text-slate-900">{eleve.nom} {eleve.prenom}</div>
                                                            <div className="text-xs text-slate-500">Mat: {eleve.matricule}</div>
                                                        </td>
                                                        <td className="px-4 py-3">
                                                            <span className="bg-slate-100 text-slate-700 px-2.5 py-1 rounded-md text-xs font-medium">
                                                                {eleve.classe ? eleve.classe.nom : 'Inconnue'}
                                                            </span>
                                                        </td>
                                                        <td className="px-4 py-3 text-center">
                                                            <span className="inline-flex items-center gap-1.5 bg-amber-100 text-amber-700 px-2.5 py-1 rounded-full text-xs font-medium">
                                                                En attente
                                                            </span>
                                                        </td>
                                                    </tr>
                                                ))
                                            )}
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            
                            <div className="flex justify-between items-center text-sm text-slate-500">
                                <span>{selectedIds.size} élève(s) sélectionné(s) sur {filteredEleves.length}</span>
                            </div>
                        </div>
                    )}
                </div>

                {/* Footer */}
                <div className="p-6 border-t border-slate-100 flex justify-end gap-3 bg-white">
                    <button 
                        onClick={onClose}
                        className="px-5 py-2 text-slate-600 font-medium hover:bg-slate-100 rounded-lg transition"
                        disabled={isSubmitting}
                    >
                        Annuler
                    </button>
                    <button 
                        onClick={handleSubmit}
                        disabled={isSubmitting || selectedIds.size === 0 || !selectedClasseId}
                        className="flex items-center gap-2 px-6 py-2 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 transition disabled:opacity-50 disabled:cursor-not-allowed shadow-sm"
                    >
                        {isSubmitting ? (
                            <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                        ) : (
                            <CheckCircle className="w-5 h-5" />
                        )}
                        <span>Affecter les élèves</span>
                    </button>
                </div>
            </div>
        </div>
    );
};

export default AffectationModal;
