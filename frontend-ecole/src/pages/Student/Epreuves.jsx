import React, { useState, useEffect } from 'react';
import { useOutletContext } from 'react-router-dom';
import { FileText, Download, Eye, Search } from 'lucide-react';
import { eleveService } from '../../services/api';

const Epreuves = () => {
    const { studentInfo } = useOutletContext();
    const [epreuves, setEpreuves] = useState([]);
    const [searchTerm, setSearchTerm] = useState('');
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchEpreuves();
    }, []);

    const fetchEpreuves = async () => {
        try {
            setLoading(true);
            const res = await eleveService.getEpreuves();
            setEpreuves(res.data);
        } catch (error) {
            console.error("Erreur chargement épreuves", error);
        } finally {
            setLoading(false);
        }
    };

    const filteredEpreuves = epreuves.filter(e =>
        (e.matiere?.nom || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
        (e.annee || '').includes(searchTerm)
    );

    return (
        <div className="bg-white rounded-xl shadow-md border" style={{ borderColor: 'hsl(var(--text-dark)/0.05)', overflow: 'hidden' }}>
            {/* Toolbar */}
            <div className="p-6 border-b flex flex-col md:flex-row justify-between items-center gap-4" style={{ borderColor: 'hsl(var(--text-dark)/0.1)', backgroundColor: 'hsl(var(--bg-main))' }}>
                <h2 style={{ fontSize: '1.5rem', color: 'hsl(var(--text-dark))', display: 'flex', alignItems: 'center', gap: '0.5rem', margin: 0 }}>
                    <FileText size={24} color="hsl(var(--primary))" />
                    Épreuves ({studentInfo.classe_nom || studentInfo.classe})
                </h2>

                <div style={{ position: 'relative', width: '100%', maxWidth: '300px' }}>
                    <Search size={18} style={{ position: 'absolute', left: '1rem', top: '50%', transform: 'translateY(-50%)', color: 'hsl(var(--text-muted))' }} />
                    <input
                        type="text"
                        placeholder="Rechercher par matière ou année..."
                        className="w-full form-input"
                        style={{ paddingLeft: '2.5rem' }}
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                    />
                </div>
            </div>

            {loading ? (
                <div className="p-12 text-center" style={{ color: 'hsl(var(--text-muted))' }}>
                    <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-primary mb-4"></div>
                    <p>Chargement de vos épreuves...</p>
                </div>
            ) : (
                <div className="p-6">
                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
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
                                        <a href={`${import.meta.env.VITE_API_BASE_URL || 'https://schoolndtg.onrender.com/api'}/storage/${epreuve.file_path}`} target="_blank" rel="noopener noreferrer" className="flex-1 btn btn-secondary text-center" style={{ padding: '0.5rem', fontSize: '0.9rem', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '5px' }}>
                                            <Eye size={16} /> Voir
                                        </a>
                                        <a href={`${import.meta.env.VITE_API_BASE_URL || 'https://schoolndtg.onrender.com/api'}/storage/${epreuve.file_path}`} download className="flex-1 btn btn-outline text-center" style={{ padding: '0.5rem', fontSize: '0.9rem', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '5px' }}>
                                            <Download size={16} /> PDF
                                        </a>
                                    </div>
                                </div>
                            ))
                        ) : (
                            <div className="col-span-full py-12 text-center" style={{ color: 'hsl(var(--text-muted))' }}>
                                {searchTerm ? "Aucune épreuve ne correspond à votre recherche." : "Aucune épreuve trouvée pour cette classe."}
                            </div>
                        )}
                    </div>
                </div>
            )}
        </div>
    );
};

export default Epreuves;
