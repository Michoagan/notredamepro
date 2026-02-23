import React from 'react';
import { Link } from 'react-router-dom';
import { ShieldCheck, ArrowRight, Building2, GraduationCap, Lock } from 'lucide-react';

export default function Landing() {
    return (
        <div className="min-h-screen bg-slate-50 font-sans text-slate-900">
            {/* Navbar */}
            <nav className="fixed top-0 z-50 w-full border-b border-white/10 bg-white/80 px-6 py-4 backdrop-blur-md transition-all">
                <div className="mx-auto flex max-w-7xl items-center justify-between">
                    <div className="flex items-center gap-3">
                        <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-blue-600 to-indigo-700 text-white shadow-lg">
                            <Building2 size={24} />
                        </div>
                        <span className="text-xl font-bold tracking-tight text-slate-800">
                            Notre Dame de Grâce
                        </span>
                    </div>
                    <div className="hidden items-center gap-6 md:flex">
                        <Link
                            to="/login"
                            className="text-sm font-medium text-slate-600 transition hover:text-blue-600"
                        >
                            Connexion
                        </Link>
                        <Link
                            to="/register"
                            className="rounded-full bg-slate-900 px-5 py-2.5 text-sm font-semibold text-white shadow-lg transition hover:bg-slate-800 hover:shadow-xl active:scale-95"
                        >
                            Inscription Direction
                        </Link>
                    </div>
                </div>
            </nav>

            {/* Hero Section */}
            <section className="relative flex min-h-screen items-center justify-center overflow-hidden pt-20">
                {/* Background Blobs */}
                <div className="absolute -left-20 top-20 h-96 w-96 rounded-full bg-blue-400/20 blur-3xl filter" />
                <div className="absolute -right-20 bottom-20 h-96 w-96 rounded-full bg-indigo-400/20 blur-3xl filter" />

                <div className="relative z-10 mx-auto max-w-5xl px-6 text-center">
                    <div className="mb-6 inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50/50 px-4 py-1.5 backdrop-blur-sm">
                        <span className="relative flex h-2 w-2">
                            <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-blue-400 opacity-75"></span>
                            <span className="relative inline-flex h-2 w-2 rounded-full bg-blue-500"></span>
                        </span>
                        <span className="text-sm font-medium text-blue-700">Portail Administratif Sécurisé</span>
                    </div>

                    <h1 className="mb-8 text-5xl font-extrabold leading-tight tracking-tight text-slate-900 md:text-7xl">
                        Gérez votre établissement <br />
                        <span className="bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent">
                            avec excellence
                        </span>
                    </h1>

                    <p className="mx-auto mb-10 max-w-2xl text-lg text-slate-600">
                        La plateforme centralisée pour la direction, la comptabilité et la gestion scolaire.
                        Simplifiez vos processus administratifs dès aujourd'hui.
                    </p>

                    <div className="flex flex-col items-center justify-center gap-4 sm:flex-row">
                        <Link
                            to="/login"
                            className="group flex items-center gap-2 rounded-full bg-blue-600 px-8 py-3.5 text-lg font-semibold text-white shadow-xl transition-all hover:bg-blue-700 hover:shadow-2xl active:scale-95"
                        >
                            Accéder au Portail
                            <ArrowRight className="transition-transform group-hover:translate-x-1" size={20} />
                        </Link>
                        <Link
                            to="/register"
                            className="rounded-full bg-white px-8 py-3.5 text-lg font-semibold text-slate-700 shadow-md transition-all hover:bg-slate-50 hover:shadow-lg active:scale-95 ring-1 ring-slate-200"
                        >
                            Créer un compte
                        </Link>
                    </div>

                    {/* Features Grid */}
                    <div className="mt-20 grid grid-cols-1 gap-8 text-left md:grid-cols-3">
                        <FeatureCard
                            icon={<ShieldCheck className="text-blue-600" />}
                            title="Sécurité Maximale"
                            desc="Données cryptées et accès contrôlés par rôles pour protéger les informations sensibles."
                        />
                        <FeatureCard
                            icon={<GraduationCap className="text-indigo-600" />}
                            title="Gestion Scolaire"
                            desc="Suivi des élèves, des inscriptions et des résultats en temps réel."
                        />
                        <FeatureCard
                            icon={<Lock className="text-emerald-600" />}
                            title="Comptabilité"
                            desc="Gestion financière transparente, suivi des paiements et rapports détaillés."
                        />
                    </div>
                </div>
            </section>
        </div>
    );
}

function FeatureCard({ icon, title, desc }) {
    return (
        <div className="rounded-2xl border border-slate-100 bg-white/60 p-6 shadow-sm backdrop-blur-sm transition-all hover:shadow-md hover:-translate-y-1">
            <div className="mb-4 inline-flex h-12 w-12 items-center justify-center rounded-xl bg-slate-50 shadow-inner">
                {icon}
            </div>
            <h3 className="mb-2 text-lg font-bold text-slate-800">{title}</h3>
            <p className="text-sm leading-relaxed text-slate-600">{desc}</p>
        </div>
    );
}
