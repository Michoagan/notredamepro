import React, { useEffect, useState } from 'react';
import { getParents } from '../../services/directeur';
import { Search, Loader2, Phone, Mail } from 'lucide-react';

export default function Parents() {
    const [parents, setParents] = useState([]);
    const [loading, setLoading] = useState(false);
    const [search, setSearch] = useState('');
    const [toSearch, setToSearch] = useState('');

    useEffect(() => {
        const delayDebounceFn = setTimeout(() => {
            setSearch(toSearch);
        }, 500);
        return () => clearTimeout(delayDebounceFn);
    }, [toSearch]);

    useEffect(() => {
        loadParents();
    }, [search]);

    const loadParents = async () => {
        setLoading(true);
        try {
            const res = await getParents(search);
            // Assuming pagination response structure
            setParents(res.data ? res.data : []);
        } catch (e) {
            console.error(e);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="p-8 space-y-6">
            <header>
                <div className="flex justify-between items-center">
                    <div>
                        <h1 className="text-2xl font-bold text-slate-800">Parents d'élèves</h1>
                        <p className="text-slate-500">Contacts des tuteurs</p>
                    </div>
                </div>
            </header>

            <div className="bg-white p-4 rounded-xl shadow-sm border border-slate-100 flex items-center">
                <Search className="w-5 h-5 text-slate-400 mr-2" />
                <input
                    type="text"
                    placeholder="Rechercher par nom, téléphone..."
                    className="w-full outline-none text-slate-700"
                    value={toSearch}
                    onChange={e => setToSearch(e.target.value)}
                />
            </div>

            <div className="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
                <table className="w-full text-left">
                    <thead className="bg-slate-50 border-b border-slate-200">
                        <tr>
                            <th className="px-6 py-4 font-semibold text-slate-600 text-sm">Nom & Prénom</th>
                            <th className="px-6 py-4 font-semibold text-slate-600 text-sm">Téléphone</th>
                            <th className="px-6 py-4 font-semibold text-slate-600 text-sm">Enfants</th>
                            <th className="px-6 py-4 font-semibold text-slate-600 text-sm">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-100">
                        {loading ? (
                            <tr><td colSpan="4" className="p-8 text-center"><Loader2 className="w-6 h-6 animate-spin mx-auto text-blue-600" /></td></tr>
                        ) : parents.length === 0 ? (
                            <tr><td colSpan="4" className="p-8 text-center text-slate-500">Aucun parent trouvé.</td></tr>
                        ) : (
                            parents.map(parent => (
                                <tr key={parent.id} className="hover:bg-slate-50 transition">
                                    <td className="px-6 py-4 font-medium text-slate-800">
                                        {parent.nom} {parent.prenom}
                                    </td>
                                    <td className="px-6 py-4 text-slate-500">{parent.telephone}</td>
                                    <td className="px-6 py-4 text-slate-500">
                                        <span className="bg-slate-100 px-2 py-1 rounded text-xs font-semibold">
                                            {parent.eleves_count} élève(s)
                                        </span>
                                    </td>
                                    <td className="px-6 py-4 flex space-x-2">
                                        <a href={`tel:${parent.telephone}`} className="p-2 text-green-600 hover:bg-green-50 rounded-lg">
                                            <Phone className="w-4 h-4" />
                                        </a>
                                    </td>
                                </tr>
                            ))
                        )}
                    </tbody>
                </table>
            </div>
        </div>
    );
}
