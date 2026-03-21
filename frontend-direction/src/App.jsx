import React, { useState, useEffect } from 'react';
import { Routes, Route, Navigate, Link, useLocation } from 'react-router-dom';
import Login from './pages/Login';
import Home from './pages/Home'; // Default fallback
import Register from './pages/Register';
import Landing from './pages/Landing';

// Admin Pages
import AdminDashboard from './pages/Admin/Dashboard';
import UserManagement from './pages/Admin/UserManagement';

// Secretariat Pages
import SecretariatDashboard from './pages/Secretariat/Dashboard';
import Eleves from './pages/Secretariat/Eleves';
import Bulletins from './pages/Secretariat/Bulletins';
import Professeurs from './pages/Secretariat/Professeurs';
import Classes from './pages/Secretariat/Classes';
import Communiques from './pages/Secretariat/Communiques';
import SecretariatEvents from './pages/Secretariat/Events';
import GestionEpreuves from './pages/Secretariat/GestionEpreuves';
import NotesExamens from './pages/Secretariat/NotesExamens';

// Censeur Pages
import CenseurDashboard from './pages/Censeur/Dashboard';
import GestionCours from './pages/Censeur/GestionCours';
import ValidationNotes from './pages/Censeur/ValidationNotes';
import ModificationNotes from './pages/Censeur/ModificationNotes';
import SuiviPedagogique from './pages/Censeur/SuiviPedagogique';
import Programmation from './pages/Censeur/Programmation';
import Contacts from './pages/Censeur/Contacts';
import CahiersTexte from './pages/Censeur/CahiersTexte';

// Surveillant Pages
import SurveillantDashboard from './pages/Surveillant/Dashboard';
import Presence from './pages/Surveillant/Presence';
import Discipline from './pages/Surveillant/Discipline';

// Directeur Pages
import DirecteurDashboard from './pages/Directeur/Dashboard';
import Personnel from './pages/Directeur/Personnel';
import TeacherPerformance from './pages/Directeur/TeacherPerformance';
import Rapports from './pages/Directeur/Rapports';

// Comptabilite Pages
import ComptabiliteDashboard from './pages/Comptabilite/Dashboard';
import Depenses from './pages/Comptabilite/Depenses';
import Inventaire from './pages/Comptabilite/Inventaire';
import PaieConfig from './pages/Comptabilite/Paie/PaieConfig'; // Payroll settings
import GenererPaie from './pages/Comptabilite/Paie/GenererPaie'; // Payroll generation
import Tranches from './pages/Comptabilite/Tranches'; // School fee tranches
import Settings from './pages/Directeur/Settings'; // Directeur Settings

// Caisse Pages
import CaisseDashboard from './pages/Caisse/Dashboard';
import CaissePaiements from './pages/Caisse/Paiements';
import CaisseVentes from './pages/Caisse/Ventes';

import { logout, getUser } from './services/auth';
import {
    LayoutDashboard,
    Receipt,
    LogOut,
    Users,
    FileText,
    School,
    BookOpen,
    Megaphone,
    ChevronDown,
    ChevronRight,
    ClipboardList,
    Shield,
    Calendar,
    Briefcase,
    TrendingDown,
    ShoppingBag, // For Ventes
    Box, // For Inventaire
    Settings as SettingsIcon,
    UserCog,
    CheckCircle,
    Activity,
    Calculator,
    FileStack
} from 'lucide-react';

// Protected Route Wrapper
const ProtectedRoute = ({ children, allowedRoles = [] }) => {
    const user = getUser();
    const token = localStorage.getItem('token');

    if (!token || !user) {
        return <Navigate to="/login" replace />;
    }

    // Role Check
    // Assuming user.role is a string. If array, use .some()
    // Roles: 'admin', 'directeur', 'censeur', 'surveillant', 'secretariat', 'comptable'
    if (allowedRoles.length > 0 && !allowedRoles.includes(user.role)) {
        // unauthorized, redirect to their own dashboard
        return <Navigate to="/dashboard" replace />;
    }

    return children;
};

// Sidebar Layout
const DashboardLayout = ({ children }) => {
    const location = useLocation();
    const user = getUser();
    const role = user?.role;

    // Helper to check role access
    const is = (r) => role === r;

    const [menus, setMenus] = useState({});
    // ... (Hooks)

    const toggleMenu = (key) => {
        setMenus(prev => ({ ...prev, [key]: !prev[key] }));
    };

    const renderSubMenu = (title, key, items, borderColor = "border-slate-700", headerBg = "") => (
        <div key={key} className={`border-l-4 ${borderColor} mb-2 bg-slate-800/20 rounded-r-lg overflow-hidden`}>
            <button
                onClick={() => toggleMenu(key)}
                className={`w-full flex items-center justify-between p-3 transition-colors ${headerBg} ${menus[key] ? 'bg-slate-800' : 'hover:bg-slate-800'}`}
            >
                <div className="flex items-center space-x-2 font-bold uppercase text-xs tracking-wider">
                    <span>{title}</span>
                </div>
                {menus[key] ? <ChevronDown className="w-4 h-4" /> : <ChevronRight className="w-4 h-4" />}
            </button>

            {menus[key] && (
                <div className="space-y-1 p-2">
                    {items.map((item, idx) => {
                        const Icon = item.icon;
                        const isActive = location.pathname.startsWith(item.path);
                        return (
                            <Link
                                key={idx}
                                to={item.path}
                                className={`flex items-center space-x-3 px-3 py-2 rounded-lg text-sm transition-all ${isActive
                                    ? 'bg-blue-600 text-white shadow-lg shadow-blue-900/50'
                                    : 'text-slate-400 hover:text-white hover:bg-slate-700'
                                    }`}
                            >
                                <Icon className="w-4 h-4" />
                                <span>{item.label}</span>
                            </Link>
                        );
                    })}
                </div>
            )}
        </div>
    );

    // ... (Secretariat, Censeur, Surveillant items remain same)

    const secretariatItems = [
        { icon: LayoutDashboard, label: 'Tableau de bord', path: '/secretariat/dashboard' },
        { icon: Users, label: 'Élèves', path: '/secretariat/eleves' },
        { icon: FileText, label: 'Bulletins', path: '/secretariat/bulletins' },
        { icon: FileStack, label: 'Anciennes Epreuves', path: '/secretariat/epreuves' },
        { icon: Calculator, label: "Notes d'Examens", path: '/secretariat/notes-examens' },
        { icon: School, label: 'Professeurs', path: '/secretariat/professeurs' },
        { icon: BookOpen, label: 'Classes & Matières', path: '/secretariat/classes' },
        { icon: Megaphone, label: 'Communiqués', path: '/secretariat/communiques' },
        { icon: Calendar, label: 'Événements', path: '/secretariat/events' },
    ];

    const censeurItems = [
        { icon: LayoutDashboard, label: 'Vue d\'ensemble', path: '/censeur/dashboard' },
        { icon: SettingsIcon, label: 'Programmation', path: '/censeur/programmation' },
        { icon: BookOpen, label: 'Emploi du Temps', path: '/censeur/cours' },
        { icon: FileText, label: 'Cahiers de Texte', path: '/censeur/cahiers-texte' },
        { icon: CheckCircle, label: 'Validation Notes', path: '/censeur/validation' },
        { icon: SettingsIcon, label: 'Modification Notes', path: '/censeur/modification-notes' },
        { icon: Activity, label: 'Suivi Pédagogique', path: '/censeur/suivi' },
        { icon: Users, label: 'Annuaire', path: '/censeur/contacts' },
    ];

    const surveillantItems = [
        { icon: LayoutDashboard, label: 'Vue d\'ensemble', path: '/surveillant/dashboard' },
        { icon: ClipboardList, label: 'Présences', path: '/surveillant/presences' },
        { icon: Shield, label: 'Discipline', path: '/surveillant/discipline' },
    ];

    const directeurItems = [
        { icon: LayoutDashboard, label: 'Vue d\'ensemble', path: '/directeur/dashboard' },
        { icon: Users, label: 'Personnel', path: '/directeur/personnel' },
        { icon: Briefcase, label: 'Rapports & Stats', path: '/directeur/rapports' },
        { icon: SettingsIcon, label: 'Paramètres', path: '/directeur/settings' },
    ];

    const comptabiliteItems = [
        { icon: LayoutDashboard, label: 'Vue d\'ensemble', path: '/comptabilite/dashboard' },
        { icon: Calendar, label: 'Délais Scolarité', path: '/comptabilite/tranches' },
        { icon: TrendingDown, label: 'Dépenses', path: '/comptabilite/depenses' },
        { icon: Calculator, label: 'Générer Paies', path: '/comptabilite/generer-paie' },
        { icon: SettingsIcon, label: 'Config. Paie', path: '/comptabilite/paie-config' },
        { icon: Box, label: 'Inventaire', path: '/comptabilite/inventaire' },
    ];

    const caisseItems = [
        { icon: LayoutDashboard, label: 'Vue d\'ensemble', path: '/caisse/dashboard' },
        { icon: Receipt, label: 'Scolarités', path: '/caisse/paiements' },
        { icon: ShoppingBag, label: 'Ventes', path: '/caisse/ventes' },
    ];

    // ... (Admin items and renderSubMenu remain same)

    const adminItems = [
        { icon: LayoutDashboard, label: 'Admin Dashboard', path: '/admin/dashboard' },
        { icon: UserCog, label: 'Utilisateurs', path: '/admin/users' },
    ];

    // ... (Rest of Sidebar Layout)

    return (
        // ... (Return JSX)
        <div className="flex h-screen bg-slate-50">
            {/* Sidebar */}
            <aside className="w-64 bg-slate-900 text-white flex flex-col overflow-y-auto">
                <div className="p-6 border-b border-slate-800 sticky top-0 bg-slate-900 z-10">
                    <h2 className="text-xl font-bold">NDTG Direction</h2>
                    <p className="text-xs text-slate-500 mt-1 uppercase tracking-wider">{role || 'Invité'}</p>
                </div>

                <nav className="flex-1 p-4 space-y-2">

                    {is('admin') && renderSubMenu("Administration", "admin", adminItems, "border-red-800", "bg-red-600/20 text-red-400")}

                    {/* Directeur General sees Directeur Module only */}
                    {is('directeur') && renderSubMenu("Direction Générale", "directeur", directeurItems, "border-emerald-800", "bg-emerald-600/20 text-emerald-400")}

                    {is('secretariat') && renderSubMenu("Secrétariat", "secretariat", secretariatItems)}

                    {is('censeur') && renderSubMenu("Censeur / Études", "censeur", censeurItems, "border-green-800", "bg-green-600/20 text-green-400")}

                    {is('surveillant') && renderSubMenu("Surveillant", "surveillant", surveillantItems, "border-orange-800", "bg-orange-600/20 text-orange-400")}

                    {is('comptable') && renderSubMenu("Comptabilité", "comptabilite", comptabiliteItems, "border-purple-800", "bg-purple-600/20 text-purple-400")}

                    {is('caisse') && renderSubMenu("Caisse / Entrées", "caisse", caisseItems, "border-indigo-800", "bg-indigo-600/20 text-indigo-400")}

                </nav>

                <div className="p-4 border-t border-slate-800 mt-auto sticky bottom-0 bg-slate-900">
                    <button
                        onClick={logout}
                        className="flex w-full items-center space-x-3 px-4 py-3 text-red-400 hover:bg-slate-800 rounded-lg transition"
                    >
                        <LogOut className="w-5 h-5" />
                        <span>Déconnexion</span>
                    </button>
                </div>
            </aside>

            {/* Main Content */}
            <main className="flex-1 overflow-auto bg-slate-50">
                {children}
            </main>
        </div>
    );
};

// ... (DashboardRedirect remains same)

// Component to handle redirection based on role
const DashboardRedirect = () => {
    const user = getUser();
    if (!user) return <Navigate to="/login" replace />;

    switch (user.role) {
        case 'admin': return <Navigate to="/admin/dashboard" replace />;
        case 'directeur': return <Navigate to="/directeur/dashboard" replace />;
        case 'censeur': return <Navigate to="/censeur/dashboard" replace />;
        case 'surveillant': return <Navigate to="/surveillant/dashboard" replace />;
        case 'secretariat': return <Navigate to="/secretariat/dashboard" replace />;
        case 'comptable': return <Navigate to="/comptabilite/dashboard" replace />;
        case 'caisse': return <Navigate to="/caisse/dashboard" replace />;
        default: return <Navigate to="/login" replace />; // Should not happen if logged in
    }
};

function App() {
    return (
        <Routes>
            <Route path="/" element={<Landing />} />
            <Route path="/login" element={<Login />} />
            <Route path="/register" element={<Register />} />

            {/* Main Dashboard Redirection */}
            <Route path="/dashboard" element={<DashboardRedirect />} />

            {/* Admin Routes - Strict */}
            <Route path="/admin/dashboard" element={<ProtectedRoute allowedRoles={['admin']}><DashboardLayout><AdminDashboard /></DashboardLayout></ProtectedRoute>} />
            <Route path="/admin/users" element={<ProtectedRoute allowedRoles={['admin']}><DashboardLayout><UserManagement /></DashboardLayout></ProtectedRoute>} />

            {/* Secretariat Routes - Strict */}
            <Route path="/secretariat/dashboard" element={<ProtectedRoute allowedRoles={['secretariat']}><DashboardLayout><SecretariatDashboard /></DashboardLayout></ProtectedRoute>} />
            <Route path="/secretariat/eleves" element={<ProtectedRoute allowedRoles={['secretariat']}><DashboardLayout><Eleves /></DashboardLayout></ProtectedRoute>} />
            <Route path="/secretariat/bulletins" element={<ProtectedRoute allowedRoles={['secretariat']}><DashboardLayout><Bulletins /></DashboardLayout></ProtectedRoute>} />
            <Route path="/secretariat/professeurs" element={<ProtectedRoute allowedRoles={['secretariat']}><DashboardLayout><Professeurs /></DashboardLayout></ProtectedRoute>} />
            <Route path="/secretariat/classes" element={<ProtectedRoute allowedRoles={['secretariat']}><DashboardLayout><Classes /></DashboardLayout></ProtectedRoute>} />
            <Route path="/secretariat/communiques" element={<ProtectedRoute allowedRoles={['secretariat']}><DashboardLayout><Communiques /></DashboardLayout></ProtectedRoute>} />
            <Route path="/secretariat/events" element={<ProtectedRoute allowedRoles={['secretariat']}><DashboardLayout><SecretariatEvents /></DashboardLayout></ProtectedRoute>} />
            <Route path="/secretariat/epreuves" element={<ProtectedRoute allowedRoles={['secretariat']}><DashboardLayout><GestionEpreuves /></DashboardLayout></ProtectedRoute>} />
            <Route path="/secretariat/notes-examens" element={<ProtectedRoute allowedRoles={['secretariat']}><DashboardLayout><NotesExamens /></DashboardLayout></ProtectedRoute>} />

            {/* Censeur Routes - Strict */}
            <Route path="/censeur/dashboard" element={<ProtectedRoute allowedRoles={['censeur']}><DashboardLayout><CenseurDashboard /></DashboardLayout></ProtectedRoute>} />
            <Route path="/censeur/programmation" element={<ProtectedRoute allowedRoles={['censeur']}><DashboardLayout><Programmation /></DashboardLayout></ProtectedRoute>} />
            <Route path="/censeur/cours" element={<ProtectedRoute allowedRoles={['censeur']}><DashboardLayout><GestionCours /></DashboardLayout></ProtectedRoute>} />
            <Route path="/censeur/cahiers-texte" element={<ProtectedRoute allowedRoles={['censeur']}><DashboardLayout><CahiersTexte /></DashboardLayout></ProtectedRoute>} />
            <Route path="/censeur/validation" element={<ProtectedRoute allowedRoles={['censeur']}><DashboardLayout><ValidationNotes /></DashboardLayout></ProtectedRoute>} />
            <Route path="/censeur/modification-notes" element={<ProtectedRoute allowedRoles={['censeur']}><DashboardLayout><ModificationNotes /></DashboardLayout></ProtectedRoute>} />
            <Route path="/censeur/suivi" element={<ProtectedRoute allowedRoles={['censeur']}><DashboardLayout><SuiviPedagogique /></DashboardLayout></ProtectedRoute>} />
            <Route path="/censeur/contacts" element={<ProtectedRoute allowedRoles={['censeur']}><DashboardLayout><Contacts /></DashboardLayout></ProtectedRoute>} />

            {/* Surveillant Routes - Strict */}
            <Route path="/surveillant/dashboard" element={<ProtectedRoute allowedRoles={['surveillant']}><DashboardLayout><SurveillantDashboard /></DashboardLayout></ProtectedRoute>} />
            <Route path="/surveillant/presences" element={<ProtectedRoute allowedRoles={['surveillant']}><DashboardLayout><Presence /></DashboardLayout></ProtectedRoute>} />
            <Route path="/surveillant/discipline" element={<ProtectedRoute allowedRoles={['surveillant']}><DashboardLayout><Discipline /></DashboardLayout></ProtectedRoute>} />

            {/* Directeur Routes - Strict */}
            <Route path="/directeur/dashboard" element={<ProtectedRoute allowedRoles={['directeur']}><DashboardLayout><DirecteurDashboard /></DashboardLayout></ProtectedRoute>} />
            <Route path="/directeur/personnel" element={<ProtectedRoute allowedRoles={['directeur']}><DashboardLayout><Personnel /></DashboardLayout></ProtectedRoute>} />
            <Route path="/directeur/personnel/:id/performance" element={<ProtectedRoute allowedRoles={['directeur']}><DashboardLayout><TeacherPerformance /></DashboardLayout></ProtectedRoute>} />
            <Route path="/directeur/rapports" element={<ProtectedRoute allowedRoles={['directeur']}><DashboardLayout><Rapports /></DashboardLayout></ProtectedRoute>} />
            <Route path="/directeur/settings" element={<ProtectedRoute allowedRoles={['directeur']}><DashboardLayout><Settings /></DashboardLayout></ProtectedRoute>} />

            {/* Comptabilite Routes - Strict */}
            <Route path="/comptabilite/dashboard" element={<ProtectedRoute allowedRoles={['comptable']}><DashboardLayout><ComptabiliteDashboard /></DashboardLayout></ProtectedRoute>} />
            <Route path="/comptabilite" element={<Navigate to="/comptabilite/dashboard" replace />} />
            <Route path="/comptabilite/depenses" element={<ProtectedRoute allowedRoles={['comptable']}><DashboardLayout><Depenses /></DashboardLayout></ProtectedRoute>} />
            <Route path="/comptabilite/inventaire" element={<ProtectedRoute allowedRoles={['comptable']}><DashboardLayout><Inventaire /></DashboardLayout></ProtectedRoute>} />
            <Route path="/comptabilite/tranches" element={<ProtectedRoute allowedRoles={['comptable']}><DashboardLayout><Tranches /></DashboardLayout></ProtectedRoute>} />
            <Route path="/comptabilite/paie-config" element={<ProtectedRoute allowedRoles={['comptable']}><DashboardLayout><PaieConfig /></DashboardLayout></ProtectedRoute>} />
            <Route path="/comptabilite/generer-paie" element={<ProtectedRoute allowedRoles={['comptable']}><DashboardLayout><GenererPaie /></DashboardLayout></ProtectedRoute>} />

            {/* Caisse Routes - Strict */}
            <Route path="/caisse/dashboard" element={<ProtectedRoute allowedRoles={['caisse']}><DashboardLayout><CaisseDashboard /></DashboardLayout></ProtectedRoute>} />
            <Route path="/caisse" element={<Navigate to="/caisse/dashboard" replace />} />
            <Route path="/caisse/paiements" element={<ProtectedRoute allowedRoles={['caisse']}><DashboardLayout><CaissePaiements /></DashboardLayout></ProtectedRoute>} />
            <Route path="/caisse/ventes" element={<ProtectedRoute allowedRoles={['caisse']}><DashboardLayout><CaisseVentes /></DashboardLayout></ProtectedRoute>} />

            {/* Redirect unknown routes */}
            <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
    );
}

export default App;
