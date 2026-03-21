import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { login } from '../services/auth';
import { KeyRound, User, Loader2 } from 'lucide-react';

export default function Login() {
    const [identifier, setIdentifier] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState(null);
    const [loading, setLoading] = useState(false);
    const navigate = useNavigate();

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError(null);
        setLoading(true);

        try {
            const data = await login(identifier, password);
            // Redirect based on role
            const role = data.user.role;
            switch (role) {
                case 'admin': navigate('/admin/dashboard'); break;
                case 'directeur': navigate('/directeur/dashboard'); break;
                case 'censeur': navigate('/censeur/dashboard'); break;
                case 'surveillant': navigate('/surveillant/dashboard'); break;
                case 'secretariat': navigate('/secretariat/dashboard'); break;
                case 'comptable': navigate('/comptabilite/dashboard'); break;
                case 'caisse': navigate('/caisse/dashboard'); break;
                default: navigate('/dashboard');
            }
        } catch (err) {
            console.error(err);
            setError(err.response?.data?.message || 'Erreur de connexion');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="flex min-h-screen items-center justify-center bg-slate-100 p-4">
            <div className="w-full max-w-md rounded-2xl bg-white p-8 shadow-xl">
                <div className="mb-6 text-center">
                    <h1 className="text-2xl font-bold text-slate-800">Espace Direction</h1>
                    <p className="text-slate-500">Connectez-vous pour accéder au portail</p>
                </div>

                {error && (
                    <div className="mb-4 rounded-lg bg-red-50 p-3 text-sm text-red-600">
                        {error}
                    </div>
                )}

                <form onSubmit={handleSubmit} className="space-y-4">
                    <div>
                        <label className="mb-1 block text-sm font-medium text-slate-700">Email ou Identifiant</label>
                        <div className="relative">
                            <User className="absolute left-3 top-2.5 h-5 w-5 text-slate-400" />
                            <input
                                type="text"
                                required
                                value={identifier}
                                onChange={(e) => setIdentifier(e.target.value)}
                                className="w-full rounded-lg border border-slate-300 py-2.5 pl-10 pr-3 focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
                                placeholder="admin ou admin@ecole.com"
                            />
                        </div>
                    </div>

                    <div>
                        <label className="mb-1 block text-sm font-medium text-slate-700">Mot de passe</label>
                        <div className="relative">
                            <KeyRound className="absolute left-3 top-2.5 h-5 w-5 text-slate-400" />
                            <input
                                type="password"
                                required
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                className="w-full rounded-lg border border-slate-300 py-2.5 pl-10 pr-3 focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
                                placeholder="••••••••"
                            />
                        </div>
                    </div>

                    <button
                        type="submit"
                        disabled={loading}
                        className="flex w-full items-center justify-center rounded-lg bg-blue-600 py-2.5 font-semibold text-white transition hover:bg-blue-700 disabled:bg-blue-400"
                    >
                        {loading ? <Loader2 className="animate-spin" /> : 'Se connecter'}
                    </button>
                </form>
            </div>
        </div>
    );
}
