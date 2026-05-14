import React, { useState, useEffect } from 'react';
import { UserPlus, Edit, Trash2, Power, CheckCircle, XCircle, Search, Filter, X } from 'lucide-react';
import { getPendingAccounts, getAllAccounts, approveAccount, rejectAccount, toggleAccountStatus, createUser } from '../../services/admin';

// Simple Modal Component for Create/Edit
const UserModal = ({ isOpen, onClose, onSubmit, isEditing = false }) => { // Removed 'user' prop to avoid confusion, use form state
    const [formData, setFormData] = useState({
        first_name: '', last_name: '', email: '', phone: '', role: 'surveillant', gender: 'M', password: ''
    });

    if (!isOpen) return null;

    const handleSubmit = (e) => {
        e.preventDefault();
        onSubmit(formData);
    };

    return (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
            <div className="bg-white rounded-xl shadow-lg p-6 w-full max-w-lg">
                <div className="flex justify-between items-center mb-6">
                    <h3 className="text-xl font-bold text-slate-800">{isEditing ? 'Modifier Utilisateur' : 'Nouvel Utilisateur'}</h3>
                    <button onClick={onClose}><X className="w-5 h-5 text-slate-500" /></button>
                </div>
                <form onSubmit={handleSubmit} className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                        <div>
                            <label className="block text-sm font-medium text-slate-700 mb-1">Prénom</label>
                            <input required type="text" className="w-full px-3 py-2 border rounded-lg"
                                value={formData.first_name} onChange={e => setFormData({ ...formData, first_name: e.target.value })} />
                        </div>
                        <div>
                            <label className="block text-sm font-medium text-slate-700 mb-1">Nom</label>
                            <input required type="text" className="w-full px-3 py-2 border rounded-lg"
                                value={formData.last_name} onChange={e => setFormData({ ...formData, last_name: e.target.value })} />
                        </div>
                    </div>
                    <div>
                        <label className="block text-sm font-medium text-slate-700 mb-1">Email</label>
                        <input required type="email" className="w-full px-3 py-2 border rounded-lg"
                            value={formData.email} onChange={e => setFormData({ ...formData, email: e.target.value })} />
                    </div>
                    <div className="grid grid-cols-2 gap-4">
                        <div>
                            <label className="block text-sm font-medium text-slate-700 mb-1">Téléphone</label>
                            <input required type="text" className="w-full px-3 py-2 border rounded-lg"
                                value={formData.phone} onChange={e => setFormData({ ...formData, phone: e.target.value })} />
                        </div>
                        <div>
                            <label className="block text-sm font-medium text-slate-700 mb-1">Genre</label>
                            <select className="w-full px-3 py-2 border rounded-lg" value={formData.gender} onChange={e => setFormData({ ...formData, gender: e.target.value })}>
                                <option value="M">Masculin</option>
                                <option value="F">Féminin</option>
                            </select>
                        </div>
                    </div>
                    <div>
                        <label className="block text-sm font-medium text-slate-700 mb-1">Rôle</label>
                        <select className="w-full px-3 py-2 border rounded-lg" value={formData.role} onChange={e => setFormData({ ...formData, role: e.target.value })}>
                            <option value="directeur">Directeur</option>
                            <option value="censeur">Censeur</option>
                            <option value="surveillant">Surveillant</option>
                            <option value="secretariat">Secrétaire</option>
                            <option value="comptable">Comptable</option>
                            <option value="caisse">Caisse</option>
                        </select>
                    </div>
                    {!isEditing && (
                        <div>
                            <label className="block text-sm font-medium text-slate-700 mb-1">Mot de passe temporaire</label>
                            <input required type="password" className="w-full px-3 py-2 border rounded-lg"
                                value={formData.password} onChange={e => setFormData({ ...formData, password: e.target.value })} />
                        </div>
                    )}
                    <button type="submit" className="w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 font-medium mt-4">
                        {isEditing ? 'Enregistrer' : 'Créer l\'utilisateur'}
                    </button>
                </form>
            </div>
        </div>
    );
};

const UserManagement = () => {
    const [activeTab, setActiveTab] = useState('all'); // 'all' or 'pending'
    const [users, setUsers] = useState([]);
    const [pendingUsers, setPendingUsers] = useState([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');
    const [isModalOpen, setIsModalOpen] = useState(false);

    // Action State
    const [rejectModalOpen, setRejectModalOpen] = useState(false);
    const [selectedUserId, setSelectedUserId] = useState(null);
    const [rejectionReason, setRejectionReason] = useState('');
    const [processing, setProcessing] = useState(false);

    useEffect(() => {
        loadData();
    }, [activeTab]);

    const loadData = async () => {
        setLoading(true);
        try {
            if (activeTab === 'pending') {
                const data = await getPendingAccounts();
                if (data.success) setPendingUsers(data.pendingAccounts);
            } else {
                const data = await getAllAccounts();
                if (data.success) setUsers(data.accounts);
            }
        } catch (error) {
            console.error("Erreur chargement utilisateurs", error);
        } finally {
            setLoading(false);
        }
    };

    const handleCreateUser = async (formData) => {
        setProcessing(true);
        try {
            await createUser(formData);
            setIsModalOpen(false);
            loadData();
            alert("Utilisateur créé avec succès !");
        } catch (error) {
            console.error(error);
            alert(error.response?.data?.message || "Erreur lors de la création de l'utilisateur");
        } finally {
            setProcessing(false);
        }
    };

    const handleApprove = async (id) => {
        if (!window.confirm("Confirmer l'approbation de ce compte ?")) return;

        setProcessing(true);
        try {
            await approveAccount(id);
            loadData(); // Reload list
            alert("Compte approuvé avec succès !");
        } catch (error) {
            alert("Erreur lors de l'approbation");
        } finally {
            setProcessing(false);
        }
    };

    const openRejectModal = (id) => {
        setSelectedUserId(id);
        setRejectionReason('');
        setRejectModalOpen(true);
    };

    const handleReject = async () => {
        if (!rejectionReason.trim()) return alert("Le motif de rejet est requis.");

        setProcessing(true);
        try {
            await rejectAccount(selectedUserId, rejectionReason);
            setRejectModalOpen(false);
            loadData();
            alert("Compte rejeté avec succès.");
        } catch (error) {
            alert("Erreur lors du rejet");
        } finally {
            setProcessing(false);
        }
    };

    const handleToggleStatus = async (id) => {
        try {
            await toggleAccountStatus(id);
            loadData();
        } catch (error) {
            alert("Impossible de changer le statut");
        }
    };

    const filteredUsers = (activeTab === 'pending' ? pendingUsers : users).filter(user =>
        user.last_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        user.first_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        user.email.toLowerCase().includes(searchTerm.toLowerCase())
    );

    return (
        <div className="space-y-6 px-4 py-6">
            <div className="flex justify-between items-center">
                <h1 className="text-2xl font-bold text-slate-800">Gestion des Utilisateurs</h1>
                <button
                    onClick={() => setIsModalOpen(true)}
                    className="bg-blue-600 text-white px-4 py-2 rounded-lg flex items-center space-x-2 hover:bg-blue-700 transition"
                >
                    <UserPlus className="w-4 h-4" />
                    <span>Nouvel Utilisateur</span>
                </button>
            </div>

            {/* Tabs */}
            <div className="flex space-x-4 border-b border-slate-200">
                <button
                    onClick={() => setActiveTab('all')}
                    className={`pb-3 px-4 font-medium transition ${activeTab === 'all' ? 'text-blue-600 border-b-2 border-blue-600' : 'text-slate-500 hover:text-slate-700'}`}
                >
                    Tous les comptes
                </button>
                <button
                    onClick={() => setActiveTab('pending')}
                    className={`pb-3 px-4 font-medium transition ${activeTab === 'pending' ? 'text-blue-600 border-b-2 border-blue-600' : 'text-slate-500 hover:text-slate-700'}`}
                >
                    En attente <span className="ml-2 bg-orange-100 text-orange-600 px-2 py-0.5 rounded-full text-xs">{pendingUsers.length > 0 ? pendingUsers.length : ''}</span>
                </button>
            </div>

            <div className="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
                <div className="p-4 border-b border-slate-100 flex items-center space-x-4">
                    <div className="relative flex-1 md:max-w-xs">
                        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 w-4 h-4" />
                        <input
                            type="text"
                            placeholder="Rechercher..."
                            className="w-full pl-10 pr-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                        />
                    </div>
                </div>

                <div className="overflow-x-auto">
                    {loading ? (
                        <div className="text-center py-12 text-slate-500">Chargement...</div>
                    ) : filteredUsers.length === 0 ? (
                        <div className="text-center py-12 text-slate-500">Aucun utilisateur trouvé.</div>
                    ) : (
                        <table className="w-full text-left">
                            <thead className="bg-slate-50 text-slate-500 font-medium text-sm">
                                <tr>
                                    <th className="p-4">Utilisateur</th>
                                    <th className="p-4">Email / Contact</th>
                                    <th className="p-4">Rôle</th>
                                    <th className="p-4">Date Inscription</th>
                                    <th className="p-4">Statut</th>
                                    <th className="p-4 text-right">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-100">
                                {filteredUsers.map((user) => (
                                    <tr key={user.id} className="hover:bg-slate-50 transition">
                                        <td className="p-4">
                                            <div className="font-medium text-slate-900">{user.last_name} {user.first_name}</div>
                                        </td>
                                        <td className="p-4">
                                            <div className="text-slate-900">{user.email}</div>
                                            <div className="text-xs text-slate-500">{user.phone}</div>
                                        </td>
                                        <td className="p-4">
                                            <span className="px-2 py-1 rounded-full text-xs font-semibold bg-slate-100 text-slate-600 uppercase border border-slate-200">
                                                {user.role}
                                            </span>
                                        </td>
                                        <td className="p-4 text-sm text-slate-500">
                                            {new Date(user.created_at).toLocaleDateString('fr-FR')}
                                        </td>
                                        <td className="p-4">
                                            {activeTab === 'pending' ? (
                                                <span className="px-2 py-1 rounded-full text-xs font-semibold bg-orange-100 text-orange-700">En attente</span>
                                            ) : (
                                                <span className={`px-2 py-1 rounded-full text-xs font-semibold ${user.is_active ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
                                                    {user.is_active ? 'Actif' : 'Inactif'}
                                                </span>
                                            )}
                                        </td>
                                        <td className="p-4 text-right space-x-2">
                                            {activeTab === 'pending' ? (
                                                <>
                                                    <button
                                                        onClick={() => handleApprove(user.id)}
                                                        disabled={processing}
                                                        className="text-green-600 hover:text-green-800 p-1 bg-green-50 rounded hover:bg-green-100 transition"
                                                        title="Approuver"
                                                    >
                                                        <CheckCircle className="w-5 h-5" />
                                                    </button>
                                                    <button
                                                        onClick={() => openRejectModal(user.id)}
                                                        disabled={processing}
                                                        className="text-red-600 hover:text-red-800 p-1 bg-red-50 rounded hover:bg-red-100 transition"
                                                        title="Rejeter"
                                                    >
                                                        <XCircle className="w-5 h-5" />
                                                    </button>
                                                </>
                                            ) : (
                                                <div className="flex space-x-2 justify-end">
                                                    <button
                                                        onClick={() => {
                                                            // Logic for edit to be implemented if needed
                                                            alert("La modification sera bientôt disponible.");
                                                        }}
                                                        className="p-2 text-blue-600 hover:bg-blue-50 rounded transition"
                                                        title="Modifier"
                                                    >
                                                        <Edit className="w-4 h-4" />
                                                    </button>
                                                    <button
                                                        onClick={() => handleToggleStatus(user.id)}
                                                        className={`flex items-center space-x-1 py-1 px-3 text-xs font-semibold rounded-lg transition border ${user.is_active
                                                            ? 'text-red-600 border-red-200 bg-red-50 hover:bg-red-100'
                                                            : 'text-green-600 border-green-200 bg-green-50 hover:bg-green-100'}`}
                                                    >
                                                        <Power className="w-3 h-3" />
                                                        <span>{user.is_active ? 'Désactiver' : 'Activer'}</span>
                                                    </button>
                                                </div>
                                            )}
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    )}
                </div>
            </div>

            {/* Create/Edit Modal */}
            <UserModal
                isOpen={isModalOpen}
                onClose={() => setIsModalOpen(false)}
                onSubmit={handleCreateUser}
            />

            {/* Reject Modal */}
            {rejectModalOpen && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
                    <div className="bg-white rounded-xl shadow-lg p-6 w-full max-w-md">
                        <h3 className="text-lg font-bold mb-4 text-slate-800">Rejeter le compte</h3>
                        <p className="text-sm text-slate-500 mb-4">Veuillez indiquer le motif du rejet. L'utilisateur recevra une notification.</p>

                        <textarea
                            className="w-full border rounded-lg p-3 text-sm focus:ring-2 focus:ring-red-500 outline-none mb-4"
                            rows="4"
                            placeholder="Motif du rejet..."
                            value={rejectionReason}
                            onChange={(e) => setRejectionReason(e.target.value)}
                        ></textarea>

                        <div className="flex justify-end space-x-3">
                            <button
                                onClick={() => setRejectModalOpen(false)}
                                className="px-4 py-2 text-slate-600 hover:bg-slate-100 rounded-lg"
                            >
                                Annuler
                            </button>
                            <button
                                onClick={handleReject}
                                disabled={processing}
                                className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 disabled:opacity-50"
                            >
                                Confirmer le Rejet
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default UserManagement;
