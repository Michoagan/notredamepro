import React, { useState } from 'react';
import { BookOpen, Layers } from 'lucide-react';
import ClassesList from './components/ClassesList';
import MatieresList from './components/MatieresList';

const Classes = () => {
    const [activeTab, setActiveTab] = useState('classes');

    return (
        <div className="space-y-6">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-slate-900">Gestion des Classes & Matières</h1>
                    <p className="text-slate-500">Configuration de la structure pédagogique</p>
                </div>
            </div>

            {/* Tabs */}
            <div className="border-b border-slate-200">
                <nav className="-mb-px flex space-x-8">
                    <button
                        onClick={() => setActiveTab('classes')}
                        className={`
                            group inline-flex items-center py-4 px-1 border-b-2 font-medium text-sm transition
                            ${activeTab === 'classes'
                                ? 'border-blue-500 text-blue-600'
                                : 'border-transparent text-slate-500 hover:text-slate-700 hover:border-slate-300'}
                        `}
                    >
                        <Layers className={`
                            -ml-0.5 mr-2 h-5 w-5
                            ${activeTab === 'classes' ? 'text-blue-500' : 'text-slate-400 group-hover:text-slate-500'}
                        `} />
                        <span>Classes</span>
                    </button>

                    <button
                        onClick={() => setActiveTab('matieres')}
                        className={`
                            group inline-flex items-center py-4 px-1 border-b-2 font-medium text-sm transition
                            ${activeTab === 'matieres'
                                ? 'border-blue-500 text-blue-600'
                                : 'border-transparent text-slate-500 hover:text-slate-700 hover:border-slate-300'}
                        `}
                    >
                        <BookOpen className={`
                            -ml-0.5 mr-2 h-5 w-5
                            ${activeTab === 'matieres' ? 'text-blue-500' : 'text-slate-400 group-hover:text-slate-500'}
                        `} />
                        <span>Matières</span>
                    </button>
                </nav>
            </div>

            {/* Content */}
            <div className="min-h-[500px]">
                {activeTab === 'classes' ? <ClassesList /> : <MatieresList />}
            </div>
        </div>
    );
};

export default Classes;
