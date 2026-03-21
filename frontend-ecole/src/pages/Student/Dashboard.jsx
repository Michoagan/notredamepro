import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { LogOut, FileText, Download, Eye, Award, BookOpen, Search, BarChart2 } from 'lucide-react';
import { eleveService } from '../../services/api';

const Dashboard = () => {
    const navigate = useNavigate();
    const [studentInfo, setStudentInfo] = useState({ nom: '', classe: '', matricule: '' });
    const [searchTerm, setSearchTerm] = useState('');
    const [activeTab, setActiveTab] = useState('epreuves'); // 'epreuves' | 'notes' | 'exercices'

    const [epreuves, setEpreuves] = useState([]);
    const [notesTrims, setNotesTrims] = useState([]);
    const [exercices, setExercices] = useState([]);
    const [loading, setLoading] = useState(true);

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

        fetchData();
    }, [navigate]);

    const fetchData = async () => {
        try {
            setLoading(true);
            const [epreuvesRes, notesRes, exercicesRes] = await Promise.all([
                eleveService.getEpreuves(),
                eleveService.getNotes(),
                eleveService.getExercices()
            ]);
            setEpreuves(epreuvesRes.data);
            setNotesTrims(notesRes.data.notes_par_trimestre || notesRes.data);
            setExercices(exercicesRes.data);
        } catch (error) {
            console.error("Erreur chargement données", error);
            if (error.response?.status === 401) {
                handleLogout();
            }
        } finally {
            setLoading(false);
        }
    };

    const handleLogout = () => {
        localStorage.removeItem('eleve_token');
        localStorage.removeItem('eleve_info');
        navigate('/student/login');
    };

    const filteredEpreuves = epreuves.filter(e =>
        (e.matiere?.nom || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
        (e.annee || '').includes(searchTerm)
    );

    const getAppreciation = (note) => {
        if (!note && note !== 0) return '-';
        if (note >= 16) return { text: 'Très Bien', color: 'hsl(142, 71%, 45%)' };
        if (note >= 14) return { text: 'Bien', color: 'hsl(142, 71%, 45%)' };
        if (note >= 12) return { text: 'Assez Bien', color: 'hsl(45, 93%, 47%)' };
        if (note >= 10) return { text: 'Passable', color: 'hsl(45, 93%, 47%)' };
        return { text: 'Insuffisant', color: 'hsl(348, 83%, 47%)' };
    };

    return (
        <div className="animate-fade-in bg-main" style={{ minHeight: 'calc(100vh - 8rem)', paddingBottom: '3rem' }}>

            {/* Dashboard Header */}
            <div style={{ backgroundColor: 'hsl(var(--primary-dark))', color: 'white', padding: '3rem 0', marginBottom: '2rem' }}>
                <div className="container flex flex-col md-flex-row justify-between items-center gap-4">

                    <div className="flex items-center gap-4">
                        <div style={{ width: '60px', height: '60px', borderRadius: '50%', backgroundColor: 'white', color: 'hsl(var(--primary-dark))', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '1.5rem', fontWeight: 'bold' }}>
                            {studentInfo.nom ? studentInfo.nom.substring(0, 2).toUpperCase() : 'ST'}
                        </div>
                        <div>
                            <h1 style={{ fontSize: '1.8rem', color: 'white', margin: 0 }}>Bonjour, {studentInfo.nom}</h1>
                            <div className="flex items-center gap-3 mt-1" style={{ color: 'hsl(var(--primary-light))', fontSize: '0.95rem' }}>
                                <span className="flex items-center gap-1"><BookOpen size={16} /> Classe : {studentInfo.classe_nom || studentInfo.classe}</span>
                                <span className="flex items-center gap-1"><Award size={16} /> Matricule : {studentInfo.matricule}</span>
                            </div>
                        </div>
                    </div>

                    <button onClick={handleLogout} className="btn" style={{ backgroundColor: 'rgba(255,255,255,0.1)', color: 'white', border: '1px solid rgba(255,255,255,0.2)' }}>
                        <LogOut size={18} /> Déconnexion
                    </button>
                </div>
            </div>

            <div className="container">
                {/* Tabs */}
                <div className="flex gap-4 mb-6 border-b" style={{ borderColor: 'hsl(var(--text-dark)/0.1)' }}>
                    <button
                        onClick={() => setActiveTab('epreuves')}
                        className={`pb-3 px-2 font-medium border-b-2 transition-colors flex items-center gap-2 \${activeTab === 'epreuves' ? 'text-primary' : ''}`}
                        style={{
                            borderColor: activeTab === 'epreuves' ? 'hsl(var(--primary))' : 'transparent',
                            color: activeTab === 'epreuves' ? 'hsl(var(--primary))' : 'hsl(var(--text-muted))'
                        }}
                    >
                        <FileText size={18} />
                        Anciennes Épreuves
                    </button>
                    <button
                        onClick={() => setActiveTab('notes')}
                        className={`pb-3 px-2 font-medium border-b-2 transition-colors flex items-center gap-2 \${activeTab === 'notes' ? 'text-primary' : ''}`}
                        style={{
                            borderColor: activeTab === 'notes' ? 'hsl(var(--primary))' : 'transparent',
                            color: activeTab === 'notes' ? 'hsl(var(--primary))' : 'hsl(var(--text-muted))'
                        }}
                    </button>
                    <button
                        onClick={() => setActiveTab('exercices')}
                        className={`pb-3 px-2 font-medium border-b-2 transition-colors flex items-center gap-2 \${activeTab === 'exercices' ? 'text-primary' : ''}`}
                        style={{
                            borderColor: activeTab === 'exercices' ? 'hsl(var(--primary))' : 'transparent',
                            color: activeTab === 'exercices' ? 'hsl(var(--primary))' : 'hsl(var(--text-muted))'
                        }}
                    >
                        <BookOpen size={18} />
                        Exercices (Travail à faire)
                    </button>
                </div>

                {/* Main Content Area */}
                <div className="bg-white rounded-xl shadow-md border" style={{ borderColor: 'hsl(var(--text-dark)/0.05)', overflow: 'hidden' }}>

                    {loading ? (
                        <div className="p-12 text-center" style={{ color: 'hsl(var(--text-muted))' }}>
                            <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-primary mb-4"></div>
                            <p>Chargement de vos données...</p>
                        </div>
                    ) : activeTab === 'epreuves' ? (
                        <>
                            {/* Toolbar */}
                            <div className="p-6 border-b flex flex-col md-flex-row justify-between items-center gap-4" style={{ borderColor: 'hsl(var(--text-dark)/0.1)', backgroundColor: 'hsl(var(--bg-main))' }}>
                                <h2 style={{ fontSize: '1.5rem', color: 'hsl(var(--text-dark))', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                                    <FileText size={24} color="hsl(var(--primary))" />
                                    Épreuves ({studentInfo.classe_nom || studentInfo.classe})
                                </h2>

                                <div style={{ position: 'relative', width: '100%', maxWidth: '300px' }}>
                                    <Search size={18} style={{ position: 'absolute', left: '1rem', top: '50%', transform: 'translateY(-50%)', color: 'hsl(var(--text-muted))' }} />
                                    <input
                                        type="text"
                                        placeholder="Rechercher..."
                                        className="w-full form-input"
                                        style={{ paddingLeft: '2.5rem' }}
                                        value={searchTerm}
                                        onChange={(e) => setSearchTerm(e.target.value)}
                                    />
                                </div>
                            </div>

                            {/* Grid of Exams */}
                            <div className="p-6">
                                <div className="grid grid-cols-1 md-grid-cols-2 lg-grid-cols-3 gap-6">
                                    {filteredEpreuves.length > 0 ? (
                                        filteredEpreuves.map(epreuve => (
                                            <div key={epreuve.id} className="card hover-shadow" style={{ display: 'flex', flexDirection: 'column', padding: '1.5rem' }}>
                                                <div className="flex justify-between items-start mb-4">
                                                    <div style={{ backgroundColor: 'hsl(var(--primary) / 0.1)', color: 'hsl(var(--primary))', padding: '0.5rem 1rem', borderRadius: 'var(--radius-full)', fontSize: '0.85rem', fontWeight: 600 }}>
                                                        {epreuve.annee}
                                                    </div>
                                                    <FileText size={24} color="hsl(var(--text-muted))" />
                                                </div>

                                                <h3 style={{ fontSize: '1.25rem', color: 'hsl(var(--text-dark))', marginBottom: '0.25rem' }}>{epreuve.matiere?.nom}</h3>
                                                <p style={{ color: 'hsl(var(--text-muted))', fontSize: '0.9rem', marginBottom: '1.5rem', flex: 1 }}>{epreuve.titre || epreuve.type}</p>

                                                <div className="flex gap-2 mt-auto pt-4 border-t" style={{ borderColor: 'hsl(var(--text-dark)/0.1)' }}>
                                                    <a href={`http://localhost:8000/storage/${epreuve.file_path}`} target="_blank" rel="noopener noreferrer" className="flex-1 btn btn-secondary text-center" style={{ padding: '0.5rem', fontSize: '0.9rem', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '5px' }}>
                                                        <Eye size={16} /> Voir
                                                    </a>
                                                    <a href={`http://localhost:8000/storage/${epreuve.file_path}`} download className="flex-1 btn btn-outline text-center" style={{ padding: '0.5rem', fontSize: '0.9rem', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '5px' }}>
                                                        <Download size={16} /> PDF
                                                    </a>
                                                </div>
                                            </div>
                                        ))
                                    ) : (
                                        <div className="col-span-full py-12 text-center" style={{ color: 'hsl(var(--text-muted))' }}>
                                            Aucune épreuve trouvée pour cette classe.
                                        </div>
                                    )}
                                </div>
                            </div>
                        </>
                    ) : (
                        <div className="p-6">
                            <h2 style={{ fontSize: '1.5rem', color: 'hsl(var(--text-dark))', display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '1.5rem' }}>
                                <BarChart2 size={24} color="hsl(var(--primary))" />
                                Mes Notes
                            </h2>

                            {notesTrims.length > 0 ? notesTrims.map((trim, idx) => (
                                <div key={idx} className="mb-8 last:mb-0">
                                    <h3 className="font-bold text-lg mb-4" style={{ color: 'hsl(var(--primary-dark))', borderBottom: '2px solid hsl(var(--primary)/0.2)', paddingBottom: '0.5rem' }}>
                                        Trimestre {trim.trimestre}
                                    </h3>
                                    <div className="overflow-x-auto">
                                        <table className="w-full text-left border-collapse">
                                            <thead>
                                                <tr style={{ backgroundColor: 'hsl(var(--bg-main))' }}>
                                                    <th className="p-3 border-b text-sm font-semibold">Matière</th>
                                                    <th className="p-3 border-b text-sm font-semibold">Interrogations</th>
                                                    <th className="p-3 border-b text-sm font-semibold">Devoirs</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                {trim.matieres.map((mat, midx) => (
                                                    <tr key={midx} className="border-b last:border-0 hover:bg-slate-50 transition-colors">
                                                        <td className="p-3 font-medium" style={{ color: 'hsl(var(--text-dark))' }}>{mat.matiere}</td>
                                                        <td className="p-3">
                                                            <div className="flex flex-wrap gap-2">
                                                                {mat.interros.map((n, i) => (
                                                                    <span key={i} className="px-2 py-1 rounded text-sm font-medium"
                                                                        style={{
                                                                            backgroundColor: n.is_validated ? 'hsl(var(--primary)/0.1)' : 'hsl(var(--text-muted)/0.1)',
                                                                            color: n.is_validated ? 'hsl(var(--primary-dark))' : 'hsl(var(--text-muted))',
                                                                            opacity: n.is_validated ? 1 : 0.6
                                                                        }}
                                                                        title={!n.is_validated ? "En attente de validation" : ""}
                                                                    >
                                                                        {n.valeur}/20
                                                                    </span>
                                                                ))}
                                                                {mat.interros.length === 0 && <span className="text-gray-400 text-sm">-</span>}
                                                            </div>
                                                        </td>
                                                        <td className="p-3">
                                                            <div className="flex flex-wrap gap-2">
                                                                {mat.devoirs.map((n, i) => (
                                                                    <span key={i} className="px-2 py-1 rounded text-sm font-medium"
                                                                        style={{
                                                                            backgroundColor: n.is_validated ? 'hsl(var(--secondary)/0.1)' : 'hsl(var(--text-muted)/0.1)',
                                                                            color: n.is_validated ? 'hsl(var(--secondary-dark))' : 'hsl(var(--text-muted))',
                                                                            opacity: n.is_validated ? 1 : 0.6
                                                                        }}
                                                                        title={!n.is_validated ? "En attente de validation" : ""}
                                                                    >
                                                                        {n.valeur}/20
                                                                    </span>
                                                                ))}
                                                                {mat.devoirs.length === 0 && <span className="text-gray-400 text-sm">-</span>}
                                                            </div>
                                                        </td>
                                                    </tr>
                                                ))}
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            )) : (
                                <div className="py-12 text-center" style={{ color: 'hsl(var(--text-muted))' }}>
                                    Aucune note disponible pour le moment.
                                </div>
                            )}
                        </div>
                    ) : (
                        <div className="p-6">
                            <h2 style={{ fontSize: '1.5rem', color: 'hsl(var(--text-dark))', display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '1.5rem' }}>
                                <BookOpen size={24} color="hsl(var(--primary))" />
                                Exercices et Travail à faire
                            </h2>

                            <div className="grid grid-cols-1 md-grid-cols-2 gap-6">
                                {exercices.length > 0 ? (
                                    exercices.map(exo => (
                                        <div key={exo.id} className="card hover-shadow" style={{ display: 'flex', flexDirection: 'column', padding: '1.5rem', borderLeft: '4px solid hsl(var(--primary))' }}>
                                            <div className="flex justify-between items-start mb-3">
                                                <div style={{ backgroundColor: 'hsl(var(--primary) / 0.1)', color: 'hsl(var(--primary-dark))', padding: '0.4rem 0.8rem', borderRadius: 'var(--radius-md)', fontSize: '0.85rem', fontWeight: 600 }}>
                                                    {exo.matiere?.nom || 'Matière Inconnue'}
                                                </div>
                                                <span style={{ fontSize: '0.8rem', color: 'hsl(var(--text-muted))' }}>
                                                    {new Date(exo.date_cours).toLocaleDateString()}
                                                </span>
                                            </div>

                                            <p style={{ color: 'hsl(var(--text-dark))', fontSize: '1rem', marginTop: '0.5rem', flex: 1, whiteSpace: 'pre-wrap' }}>
                                                {exo.travail_a_faire}
                                            </p>
                                        </div>
                                    ))
                                ) : (
                                    <div className="col-span-full py-12 text-center" style={{ color: 'hsl(var(--text-muted))' }}>
                                        Aucun exercice donné par les professeurs pour l'instant.
                                    </div>
                                )}
                            </div>
                        </div>
                    )}
                </div>

            </div >

            <style>{`
        @media (min-width: 768px) {
          .md-flex-row { flex-direction: row !important; }
          .md-grid-cols-2 { grid-template-columns: repeat(2, minmax(0, 1fr)) !important; }
        }
        @media (min-width: 1024px) {
          .lg-grid-cols-3 { grid-template-columns: repeat(3, minmax(0, 1fr)) !important; }
        }
        .form-input {
          padding: 0.5rem 0.75rem;
          border-radius: var(--radius-full);
          border: 1px solid hsl(var(--text-dark) / 0.2);
          outline: none;
          transition: border-color 0.2s;
          font-family: inherit;
        }
        .form-input:focus { border-color: hsl(var(--primary)); box-shadow: 0 0 0 2px hsl(var(--primary)/0.2); }
        .hover-shadow { transition: all 0.2s; }
        .hover-shadow:hover { transform: translateY(-4px); box-shadow: var(--shadow-md); border-color: hsl(var(--primary)/0.3); }
        .col-span-full { grid-column: 1 / -1; }
      `}</style>
        </div >
    );
};

export default Dashboard;
