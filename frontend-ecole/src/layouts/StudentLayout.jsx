import React, { useState, useEffect } from 'react';
import { NavLink, Outlet, useNavigate, useLocation } from 'react-router-dom';
import { 
    LayoutDashboard, 
    FileText, 
    BookOpen, 
    BarChart2, 
    LogOut, 
    Menu, 
    X,
    Award,
    Users,
    Archive
} from 'lucide-react';

const StudentLayout = () => {
    const navigate = useNavigate();
    const location = useLocation();
    const [isSidebarOpen, setIsSidebarOpen] = useState(false);
    const [studentInfo, setStudentInfo] = useState({ nom: '', classe: '', matricule: '' });

    useEffect(() => {
        const info = localStorage.getItem('eleve_info');
        const token = localStorage.getItem('eleve_token');

        if (!token) {
            navigate('/student/login');
            return;
        }

        if (info) {
            setStudentInfo(JSON.parse(info));
        }
    }, [navigate]);

    const handleLogout = () => {
        localStorage.removeItem('eleve_token');
        localStorage.removeItem('eleve_info');
        navigate('/student/login');
    };

    const navItems = [
        { path: '/student/dashboard', icon: <LayoutDashboard size={20} />, label: 'Tableau de bord' },
        { path: '/student/notes', icon: <BarChart2 size={20} />, label: 'Mes Notes' },
        { path: '/student/epreuves', icon: <FileText size={20} />, label: 'Anciennes Épreuves' },
        { path: '/student/archives', icon: <Archive size={20} />, label: 'Archives (Bulletins)' },
        { path: '/student/exercices', icon: <BookOpen size={20} />, label: 'Exercices à faire' },
        { path: '/student/contacts', icon: <Users size={20} />, label: 'Contacts' },
    ];

    const closeSidebar = () => {
        if (window.innerWidth < 1024) {
            setIsSidebarOpen(false);
        }
    };

    return (
        <div className="flex h-[100dvh] overflow-hidden bg-main">
            {/* Mobile Sidebar Overlay */}
            {isSidebarOpen && (
                <div 
                    className="fixed inset-0 z-40 bg-black/50 lg:hidden"
                    onClick={closeSidebar}
                />
            )}

            {/* Sidebar */}
            <aside 
                className={`fixed inset-y-0 left-0 z-50 w-64 bg-white border-r border-gray-200 transform transition-transform duration-300 ease-in-out lg:translate-x-0 lg:static lg:inset-0 ${
                    isSidebarOpen ? 'translate-x-0' : '-translate-x-full'
                }`}
                style={{ borderColor: 'hsl(var(--text-dark)/0.1)' }}
            >
                <div className="flex items-center justify-between h-16 px-6 border-b" style={{ borderColor: 'hsl(var(--text-dark)/0.1)' }}>
                    <div className="flex items-center gap-2">
                        <div style={{
                            width: '2rem', height: '2rem',
                            backgroundColor: 'hsl(var(--primary))',
                            borderRadius: 'var(--radius-md)',
                            display: 'flex', alignItems: 'center', justifyContent: 'center',
                            color: 'white', fontWeight: 'bold'
                        }}>
                            ND
                        </div>
                        <span className="text-lg font-bold" style={{ color: 'hsl(var(--primary-dark))' }}>Espace Élève</span>
                    </div>
                    <button onClick={closeSidebar} className="lg:hidden" style={{ color: 'hsl(var(--text-muted))' }}>
                        <X size={20} />
                    </button>
                </div>

                <div className="p-4 border-b" style={{ borderColor: 'hsl(var(--text-dark)/0.1)' }}>
                    <div className="flex items-center gap-3 mb-2">
                        <div style={{ width: '45px', height: '45px', borderRadius: '50%', backgroundColor: 'hsl(var(--primary)/0.1)', color: 'hsl(var(--primary))', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '1.2rem', fontWeight: 'bold' }}>
                            {studentInfo.nom ? studentInfo.nom.substring(0, 2).toUpperCase() : 'ST'}
                        </div>
                        <div className="overflow-hidden">
                            <p className="font-semibold truncate" style={{ color: 'hsl(var(--text-dark))' }}>{studentInfo.nom}</p>
                            <p className="text-xs truncate flex items-center gap-1" style={{ color: 'hsl(var(--text-muted))' }}>
                                <Award size={12} /> {studentInfo.classe_nom || studentInfo.classe}
                            </p>
                        </div>
                    </div>
                </div>

                <nav className="p-4 space-y-1 overflow-y-auto" style={{ height: 'calc(100vh - 160px)' }}>
                    {navItems.map((item) => (
                        <NavLink
                            key={item.path}
                            to={item.path}
                            onClick={closeSidebar}
                            className={({ isActive }) => 
                                `flex items-center gap-3 px-4 py-3 rounded-lg transition-colors duration-200 ${
                                    isActive 
                                    ? 'bg-primary/10 text-primary font-semibold' 
                                    : 'text-gray-600 hover:bg-gray-100'
                                }`
                            }
                            style={({ isActive }) => ({
                                backgroundColor: isActive ? 'hsl(var(--primary)/0.1)' : 'transparent',
                                color: isActive ? 'hsl(var(--primary-dark))' : 'hsl(var(--text-muted))'
                            })}
                        >
                            {item.icon}
                            <span>{item.label}</span>
                        </NavLink>
                    ))}
                </nav>

                <div className="absolute bottom-0 w-full p-4 border-t" style={{ borderColor: 'hsl(var(--text-dark)/0.1)', backgroundColor: 'white' }}>
                    <button 
                        onClick={handleLogout}
                        className="flex items-center gap-3 px-4 py-3 w-full rounded-lg transition-colors duration-200"
                        style={{ color: 'hsl(var(--delete))' }}
                        onMouseEnter={(e) => e.currentTarget.style.backgroundColor = 'hsl(var(--delete)/0.1)'}
                        onMouseLeave={(e) => e.currentTarget.style.backgroundColor = 'transparent'}
                    >
                        <LogOut size={20} />
                        <span className="font-semibold">Déconnexion</span>
                    </button>
                </div>
            </aside>

            {/* Main Content */}
            <div className="flex flex-col flex-1 min-w-0 bg-gray-50/50">
                {/* Header */}
                <header className="flex items-center justify-between h-16 px-4 bg-white border-b lg:px-8" style={{ borderColor: 'hsl(var(--text-dark)/0.1)' }}>
                    <button
                        onClick={() => setIsSidebarOpen(true)}
                        className="p-2 lg:hidden"
                        style={{ color: 'hsl(var(--text-dark))' }}
                    >
                        <Menu size={24} />
                    </button>
                    <div className="flex-1 lg:hidden text-center font-bold" style={{ color: 'hsl(var(--primary-dark))' }}>
                        Notre Dame
                    </div>
                    <div className="hidden lg:flex items-center gap-4 ml-auto text-sm">
                        <span className="px-3 py-1 rounded-full font-medium" style={{ backgroundColor: 'hsl(var(--primary)/0.1)', color: 'hsl(var(--primary-dark))' }}>
                            Matricule: {studentInfo.matricule}
                        </span>
                        <span style={{ color: 'hsl(var(--text-muted))' }}>
                            Année Scolaire 2025-2026
                        </span>
                    </div>
                </header>

                {/* Page Content */}
                <main className="flex-1 p-4 lg:p-8 overflow-y-auto animate-fade-in">
                    <Outlet context={{ studentInfo }} />
                </main>
            </div>
        </div>
    );
};

export default StudentLayout;
