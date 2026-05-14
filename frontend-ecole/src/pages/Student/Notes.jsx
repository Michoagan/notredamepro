import React, { useState, useEffect } from 'react';
import { useOutletContext } from 'react-router-dom';
import { BarChart2 } from 'lucide-react';
import { eleveService } from '../../services/api';

const Notes = () => {
    const { studentInfo } = useOutletContext();
    const [notesTrims, setNotesTrims] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchNotes();
    }, []);

    const fetchNotes = async () => {
        try {
            setLoading(true);
            const res = await eleveService.getNotes();
            setNotesTrims(res.data.notes_par_trimestre || res.data);
        } catch (error) {
            console.error("Erreur chargement notes", error);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="bg-white rounded-xl shadow-md border" style={{ borderColor: 'hsl(var(--text-dark)/0.05)', overflow: 'hidden' }}>
            <div className="p-6 border-b" style={{ borderColor: 'hsl(var(--text-dark)/0.1)', backgroundColor: 'hsl(var(--bg-main))' }}>
                <h2 style={{ fontSize: '1.5rem', color: 'hsl(var(--text-dark))', display: 'flex', alignItems: 'center', gap: '0.5rem', margin: 0 }}>
                    <BarChart2 size={24} color="hsl(var(--primary))" />
                    Mes Notes ({studentInfo.classe_nom || studentInfo.classe})
                </h2>
            </div>

            {loading ? (
                <div className="p-12 text-center" style={{ color: 'hsl(var(--text-muted))' }}>
                    <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-primary mb-4"></div>
                    <p>Chargement de vos notes...</p>
                </div>
            ) : (
                <div className="p-6">
                    {notesTrims.length > 0 ? notesTrims.map((trim, idx) => (
                        <div key={idx} className="mb-8 last:mb-0">
                            <h3 className="font-bold text-lg mb-4" style={{ color: 'hsl(var(--primary-dark))', borderBottom: '2px solid hsl(var(--primary)/0.2)', paddingBottom: '0.5rem' }}>
                                Trimestre {trim.trimestre}
                            </h3>
                            <div className="overflow-x-auto rounded-lg border border-gray-200">
                                <table className="w-full text-left border-collapse">
                                    <thead>
                                        <tr style={{ backgroundColor: 'hsl(var(--bg-main))' }}>
                                            <th className="p-4 border-b text-sm font-semibold whitespace-nowrap">Matière</th>
                                            <th className="p-4 border-b text-sm font-semibold">Interrogations</th>
                                            <th className="p-4 border-b text-sm font-semibold">Devoirs</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {trim.matieres.map((mat, midx) => (
                                            <tr key={midx} className="border-b last:border-0 hover:bg-slate-50 transition-colors">
                                                <td className="p-4 font-medium whitespace-nowrap" style={{ color: 'hsl(var(--text-dark))' }}>{mat.matiere}</td>
                                                <td className="p-4">
                                                    <div className="flex flex-wrap gap-2">
                                                        {mat.interros.map((n, i) => (
                                                            <span key={i} className="px-3 py-1.5 rounded-md text-sm font-bold shadow-sm"
                                                                style={{
                                                                    backgroundColor: n.is_validated ? (n.valeur >= 10 ? 'hsl(var(--accent)/0.15)' : 'hsl(var(--delete)/0.1)') : 'hsl(var(--text-muted)/0.1)',
                                                                    color: n.is_validated ? (n.valeur >= 10 ? 'hsl(var(--accent))' : 'hsl(var(--delete))') : 'hsl(var(--text-muted))',
                                                                    border: `1px solid ${n.is_validated ? (n.valeur >= 10 ? 'hsl(var(--accent)/0.3)' : 'hsl(var(--delete)/0.3)') : 'transparent'}`,
                                                                    opacity: n.is_validated ? 1 : 0.6
                                                                }}
                                                                title={!n.is_validated ? "En attente de validation" : ""}
                                                            >
                                                                {n.valeur}/20
                                                            </span>
                                                        ))}
                                                        {mat.interros.length === 0 && <span className="text-gray-400 text-sm italic">Aucune note</span>}
                                                    </div>
                                                </td>
                                                <td className="p-4">
                                                    <div className="flex flex-wrap gap-2">
                                                        {mat.devoirs.map((n, i) => (
                                                            <span key={i} className="px-3 py-1.5 rounded-md text-sm font-bold shadow-sm"
                                                                style={{
                                                                    backgroundColor: n.is_validated ? (n.valeur >= 10 ? 'hsl(var(--accent)/0.15)' : 'hsl(var(--delete)/0.1)') : 'hsl(var(--text-muted)/0.1)',
                                                                    color: n.is_validated ? (n.valeur >= 10 ? 'hsl(var(--accent))' : 'hsl(var(--delete))') : 'hsl(var(--text-muted))',
                                                                    border: `1px solid ${n.is_validated ? (n.valeur >= 10 ? 'hsl(var(--accent)/0.3)' : 'hsl(var(--delete)/0.3)') : 'transparent'}`,
                                                                    opacity: n.is_validated ? 1 : 0.6
                                                                }}
                                                                title={!n.is_validated ? "En attente de validation" : ""}
                                                            >
                                                                {n.valeur}/20
                                                            </span>
                                                        ))}
                                                        {mat.devoirs.length === 0 && <span className="text-gray-400 text-sm italic">Aucune note</span>}
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
                            <BarChart2 size={48} className="mx-auto mb-4 opacity-20" />
                            <p>Aucune note disponible pour le moment.</p>
                        </div>
                    )}
                </div>
            )}
        </div>
    );
};

export default Notes;
