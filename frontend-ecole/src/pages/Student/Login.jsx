import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { LogIn, User, Lock, AlertCircle } from 'lucide-react';
import { authService } from '../../services/api';

const Login = () => {
    const navigate = useNavigate();
    const [credentials, setCredentials] = useState({ matricule: '', password: '' });
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(false);

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError('');
        setLoading(true);

        try {
            const response = await authService.login(credentials);
            localStorage.setItem('eleve_token', response.data.token);
            localStorage.setItem('eleve_info', JSON.stringify(response.data.eleve));
            navigate('/student/dashboard');
        } catch (err) {
            setError(err.response?.data?.message || 'Identifiants incorrects.');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="animate-fade-in flex justify-center items-center py-20" style={{ backgroundColor: 'hsl(var(--bg-main))', minHeight: 'calc(100vh - 200px)' }}>

            <div className="bg-white p-8 rounded-xl shadow-lg border border-slate-100 w-full" style={{ maxWidth: '400px' }}>
                <div className="text-center mb-8">
                    <div className="inline-flex justify-center items-center p-3 rounded-full mb-4" style={{ backgroundColor: 'hsl(var(--primary) / 0.1)', color: 'hsl(var(--primary))' }}>
                        <LogIn size={32} />
                    </div>
                    <h1 style={{ fontSize: '1.8rem', color: 'hsl(var(--primary-dark))', marginBottom: '0.5rem' }}>Espace Élève</h1>
                    <p style={{ color: 'hsl(var(--text-muted))', fontSize: '0.9rem' }}>Connectez-vous pour accéder à vos épreuves, notes et exercices</p>
                </div>

                {error && (
                    <div className="flex items-center gap-2 p-3 rounded-lg mb-6" style={{ backgroundColor: 'hsl(var(--delete) / 0.1)', color: 'hsl(var(--delete))', fontSize: '0.9rem' }}>
                        <AlertCircle size={18} />
                        {error}
                    </div>
                )}

                <form onSubmit={handleSubmit} className="flex flex-col gap-5">

                    <div>
                        <label className="block text-sm font-medium mb-1" style={{ color: 'hsl(var(--text-dark))' }}>Matricule Élève</label>
                        <div style={{ position: 'relative' }}>
                            <User size={18} style={{ position: 'absolute', left: '1rem', top: '50%', transform: 'translateY(-50%)', color: 'hsl(var(--text-muted))' }} />
                            <input
                                type="text"
                                className="w-full form-input"
                                style={{ paddingLeft: '2.5rem' }}
                                placeholder="Ex: 20230145"
                                required
                                value={credentials.matricule}
                                onChange={(e) => setCredentials({ ...credentials, matricule: e.target.value })}
                            />
                        </div>
                    </div>

                    <div>
                        <label className="block text-sm font-medium mb-1" style={{ color: 'hsl(var(--text-dark))' }}>Numéro de téléphone du Parent (Mot de passe)</label>
                        <div style={{ position: 'relative' }}>
                            <Lock size={18} style={{ position: 'absolute', left: '1rem', top: '50%', transform: 'translateY(-50%)', color: 'hsl(var(--text-muted))' }} />
                            <input
                                type="password"
                                className="w-full form-input"
                                style={{ paddingLeft: '2.5rem' }}
                                placeholder="Ex: 90000000"
                                required
                                value={credentials.password}
                                onChange={(e) => setCredentials({ ...credentials, password: e.target.value })}
                            />
                        </div>
                    </div>

                    <button
                        type="submit"
                        className="btn btn-primary"
                        style={{ width: '100%', marginTop: '0.5rem' }}
                        disabled={loading}
                    >
                        {loading ? 'Connexion...' : 'Se Connecter'}
                    </button>

                </form>

                <div className="mt-6 text-center text-sm" style={{ color: 'hsl(var(--text-muted))' }}>
                    Mot de passe oublié ? <a href="#" style={{ color: 'hsl(var(--primary))', fontWeight: 600 }}>Contacter le secrétariat</a>
                </div>
            </div>

            <style>{`
        .form-input {
          padding: 0.75rem;
          border-radius: var(--radius-md);
          border: 1px solid hsl(var(--text-dark) / 0.2);
          outline: none;
          transition: border-color 0.2s;
          font-family: inherit;
        }
        .form-input:focus { border-color: hsl(var(--primary)); box-shadow: 0 0 0 2px hsl(var(--primary)/0.2); }
      `}</style>
        </div>
    );
};

export default Login;
