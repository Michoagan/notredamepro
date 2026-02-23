import React, { useState, useEffect } from 'react';
import { getClasses, getEleves, downloadBulletin } from '../../services/secretariat';
import { FileText, Download, Printer, Search, School, User, Calendar } from 'lucide-react';
import axios from 'axios';

const Bulletins = () => {
    const [classes, setClasses] = useState([]);
    const [students, setStudents] = useState([]);
    const [selectedClasse, setSelectedClasse] = useState('');
    const [selectedStudent, setSelectedStudent] = useState('');
    const [trimestre, setTrimestre] = useState('1');
    const [loading, setLoading] = useState(false);
    const [downloading, setDownloading] = useState(false);

    useEffect(() => {
        fetchClasses();
    }, []);

    useEffect(() => {
        if (selectedClasse) {
            fetchStudents(selectedClasse);
        } else {
            setStudents([]);
            setSelectedStudent('');
        }
    }, [selectedClasse]);

    const fetchClasses = async () => {
        try {
            const data = await getClasses();
            // Assuming getClasses returns available classes
            // Adjust based on actual API response structure
            if (Array.isArray(data)) setClasses(data);
            else if (data.classes) setClasses(data.classes);
            else if (data.data) setClasses(data.data);
        } catch (error) {
            console.error("Erreur chargement classes", error);
        }
    };

    const fetchStudents = async (classeId) => {
        setLoading(true);
        try {
            // Using getEleves with filter, or byClasse endpoint
            // getEleves service uses /secretaire/eleves?classe_id=...
            const data = await getEleves({ classe_id: classeId });

            // data.classes is returned by EleveController::index, filtered by class
            // It returns classes with eleves relation.
            if (data.success && data.classes && data.classes.length > 0) {
                // Flatten students from the class(es)
                const classData = data.classes.find(c => c.id == classeId);
                if (classData && classData.eleves) {
                    setStudents(classData.eleves);
                } else {
                    setStudents([]);
                }
            }
        } catch (error) {
            console.error("Erreur chargement élèves", error);
            setStudents([]);
        } finally {
            setLoading(false);
        }
    };

    const handleDownload = async () => {
        if (!selectedStudent || !trimestre) return;

        setDownloading(true);
        try {
            const blob = await downloadBulletin(selectedStudent, trimestre);

            // Create blob link to download
            const url = window.URL.createObjectURL(new Blob([blob]));
            const link = document.createElement('a');
            link.href = url;

            // Find student name for filename
            const student = students.find(s => s.id == selectedStudent);
            const studentName = student ? `${student.nom}_${student.prenom}` : 'bulletin';

            link.setAttribute('download', `Bulletin_${studentName}_T${trimestre}.pdf`);
            document.body.appendChild(link);
            link.click();
            link.parentNode.removeChild(link);
        } catch (error) {
            console.error("Erreur téléchargement bulletin", error);
            alert("Impossible de générer le bulletin. Vérifiez que les notes sont saisies.");
        } finally {
            setDownloading(false);
        }
    };

    return (
        <div className="space-y-6">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-slate-900">Bulletins Scolaires</h1>
                    <p className="text-slate-500">Génération et impression des bulletins par élève</p>
                </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Selection Panel */}
                <div className="lg:col-span-1 space-y-6">
                    <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-200">
                        <h2 className="text-lg font-semibold mb-4 flex items-center space-x-2">
                            <Search className="w-5 h-5 text-blue-600" />
                            <span>Sélection</span>
                        </h2>

                        <div className="space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Classe</label>
                                <div className="relative">
                                    <School className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 w-4 h-4" />
                                    <select
                                        value={selectedClasse}
                                        onChange={(e) => setSelectedClasse(e.target.value)}
                                        className="w-full pl-10 pr-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none appearance-none bg-white"
                                    >
                                        <option value="">Choisir une classe...</option>
                                        {classes.map(c => (
                                            <option key={c.id} value={c.id}>{c.nom}</option>
                                        ))}
                                    </select>
                                </div>
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Élève</label>
                                <div className="relative">
                                    <User className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 w-4 h-4" />
                                    <select
                                        value={selectedStudent}
                                        onChange={(e) => setSelectedStudent(e.target.value)}
                                        disabled={!selectedClasse || loading}
                                        className="w-full pl-10 pr-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none appearance-none bg-white disabled:bg-slate-50 disabled:text-slate-400"
                                    >
                                        <option value="">
                                            {loading ? 'Chargement...' : 'Choisir un élève...'}
                                        </option>
                                        {students.map(s => (
                                            <option key={s.id} value={s.id}>{s.nom} {s.prenom}</option>
                                        ))}
                                    </select>
                                </div>
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Trimestre</label>
                                <div className="relative">
                                    <Calendar className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 w-4 h-4" />
                                    <select
                                        value={trimestre}
                                        onChange={(e) => setTrimestre(e.target.value)}
                                        className="w-full pl-10 pr-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none appearance-none bg-white"
                                    >
                                        <option value="1">1er Trimestre</option>
                                        <option value="2">2ème Trimestre</option>
                                        <option value="3">3ème Trimestre</option>
                                    </select>
                                </div>
                            </div>

                            <button
                                onClick={handleDownload}
                                disabled={!selectedStudent || downloading}
                                className="w-full flex items-center justify-center space-x-2 px-4 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition shadow-sm disabled:opacity-50 disabled:cursor-not-allowed mt-6"
                            >
                                {downloading ? (
                                    <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                                ) : (
                                    <Download className="w-5 h-5" />
                                )}
                                <span>Générer le Bulletin PDF</span>
                            </button>
                        </div>
                    </div>
                </div>

                {/* Preview/Info Panel */}
                <div className="lg:col-span-2">
                    <div className="bg-white p-8 rounded-xl shadow-sm border border-slate-200 h-full flex flex-col items-center justify-center text-center">
                        <div className="w-20 h-20 bg-blue-50 text-blue-600 rounded-full flex items-center justify-center mb-6">
                            <FileText className="w-10 h-10" />
                        </div>
                        <h3 className="text-xl font-semibold text-slate-900 mb-2">Génération de Documents</h3>
                        <p className="text-slate-500 max-w-md mx-auto mb-8">
                            Sélectionnez une classe, un élève et un trimestre pour générer et télécharger le bulletin scolaire officiel au format PDF.
                        </p>

                        <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4 text-left max-w-lg w-full">
                            <h4 className="font-medium text-yellow-800 text-sm mb-2 flex items-center">
                                <span className="w-2 h-2 bg-yellow-500 rounded-full mr-2"></span>
                                Note Importante
                            </h4>
                            <p className="text-sm text-yellow-700">
                                Assurez-vous que toutes les notes ont été saisies par les professeurs avant de générer les bulletins. Les moyennes sont calculées automatiquement en fonction des coefficients.
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Bulletins;
