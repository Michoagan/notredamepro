import React, { useEffect, useState } from 'react';
import { getArticles } from '../../services/comptabilite';
import { storeVente, getVenteQrCode } from '../../services/caisse';
import { getEleves } from '../../services/secretariat';
import { Loader2, ShoppingCart, Search, User, Trash2, CheckCircle, Download, FileText } from 'lucide-react';
import { generateReceiptPDF } from '../../utils/pdfGenerator';

export default function Ventes() {
    const [articles, setArticles] = useState([]);
    const [cart, setCart] = useState([]);
    const [loading, setLoading] = useState(true);
    const [processing, setProcessing] = useState(false);

    // Client Search
    const [searchStudent, setSearchStudent] = useState('');
    const [students, setStudents] = useState([]);
    const [selectedStudent, setSelectedStudent] = useState(null);
    const [clientName, setClientName] = useState('');
    const [showStudentResults, setShowStudentResults] = useState(false);

    const [message, setMessage] = useState(null);
    const [venteSuccessData, setVenteSuccessData] = useState(null);

    useEffect(() => {
        loadData();
    }, []);

    const loadData = async () => {
        try {
            const data = await getArticles();
            setArticles(data);
        } catch (error) {
            console.error(error);
        } finally {
            setLoading(false);
        }
    };

    // Student Search Logic
    useEffect(() => {
        const delayDebounceFn = setTimeout(() => {
            if (searchStudent.length > 2) {
                searchEleves();
            } else {
                setStudents([]);
                setShowStudentResults(false);
            }
        }, 500);

        return () => clearTimeout(delayDebounceFn);
    }, [searchStudent]);

    const searchEleves = async () => {
        try {
            const response = await getEleves({ search: searchStudent });
            // The API returns { success: true, classes: [{...eleves: []}] }
            if (response.classes) {
                const flatStudents = response.classes.flatMap(c =>
                    c.eleves.map(e => ({ ...e, classe: { nom: c.nom } }))
                );
                setStudents(flatStudents);
            } else {
                setStudents([]);
            }
            setShowStudentResults(true);
        } catch (err) {
            console.error('Erreur recherche elèves', err);
        }
    };

    const addToCart = (article) => {
        const existing = cart.find(item => item.article_id === article.id);
        if (existing) {
            setCart(cart.map(item =>
                item.article_id === article.id
                    ? { ...item, quantite: item.quantite + 1 }
                    : item
            ));
        } else {
            setCart([...cart, {
                article_id: article.id,
                designation: article.designation,
                prix: article.prix_unitaire,
                quantite: 1
            }]);
        }
    };

    const removeFromCart = (id) => {
        setCart(cart.filter(item => item.article_id !== id));
    };

    const updateQuantity = (id, delta) => {
        setCart(cart.map(item => {
            if (item.article_id === id) {
                const newQty = Math.max(1, item.quantite + delta);
                return { ...item, quantite: newQty };
            }
            return item;
        }));
    };

    const cartTotal = cart.reduce((acc, item) => acc + (item.prix * item.quantite), 0);

    const handleCheckout = async () => {
        if (cart.length === 0) return;
        setProcessing(true);
        setMessage(null);

        const payload = {
            items: cart.map(item => ({ article_id: item.article_id, quantite: item.quantite })),
            eleve_id: selectedStudent?.id || null,
            nom_client: selectedStudent ? `${selectedStudent.nom} ${selectedStudent.prenom}` : clientName
        };

        try {
            const response = await storeVente(payload);
            setMessage({ type: 'success', text: 'Vente enregistrée avec succès !' });
            setVenteSuccessData(response.vente);
            setCart([]);
            setSelectedStudent(null);
            setClientName('');
            setSearchStudent('');
        } catch (error) {
            setMessage({ type: 'error', text: error.response?.data?.message || 'Erreur lors de la vente.' });
        } finally {
            setProcessing(false);
        }
    };

    const handleDownloadReceipt = async (vente) => {
        try {
            // 1. Fetch QR Code from Backend
            const qrResponse = await getVenteQrCode(vente.id);
            const qrBase64 = qrResponse.qrCodeBase64;

            // 2. Generate PDF locally in React
            generateReceiptPDF(vente, 'vente', qrBase64);

        } catch (error) {
            console.error("Erreur PDF:", error);
            alert("Erreur lors de la génération du reçu de vente.");
        }
    };

    const selectStudent = (student) => {
        setSelectedStudent(student);
        setSearchStudent(`${student.nom} ${student.prenom}`);
        setShowStudentResults(false);
    };

    return (
        <div className="p-6 h-[calc(100vh-theme(spacing.16))] flex flex-col md:flex-row gap-6">

            {/* Left Col: Articles */}
            <div className="flex-1 flex flex-col space-y-4 bg-white p-6 rounded-xl shadow-sm border border-slate-100 overflow-hidden">
                <header>
                    <h2 className="text-xl font-bold text-slate-800">Articles en vente</h2>
                    <input
                        type="text"
                        placeholder="Rechercher un article..."
                        className="mt-2 w-full p-2 border border-slate-200 rounded-lg bg-slate-50"
                    />
                </header>

                <div className="flex-1 overflow-y-auto grid grid-cols-2 lg:grid-cols-3 gap-4 content-start">
                    {loading ? <Loader2 className="animate-spin text-blue-600" /> : articles.map((article) => (
                        <button
                            key={article.id}
                            onClick={() => addToCart(article)}
                            className="flex flex-col items-start p-4 border border-slate-100 rounded-lg hover:border-blue-500 hover:bg-blue-50 transition text-left group"
                        >
                            <span className="font-semibold text-slate-700 group-hover:text-blue-700">{article.designation}</span>
                            <span className="text-sm text-slate-500 capitalize">{article.type}</span>
                            <span className="mt-2 font-bold text-blue-600">{article.prix_unitaire.toLocaleString()} F</span>
                            {article.type === 'physique' && (
                                <span className={`text-xs mt-1 ${article.stock_actuel > 0 ? 'text-green-600' : 'text-red-600'}`}>
                                    Stock: {article.stock_actuel}
                                </span>
                            )}
                        </button>
                    ))}
                </div>
            </div>

            {/* Right Col: Cart & Checkout */}
            <div className="w-full md:w-96 bg-white p-6 rounded-xl shadow-sm border border-slate-100 flex flex-col">
                <h2 className="text-xl font-bold text-slate-800 mb-4 flex items-center">
                    <ShoppingCart className="w-5 h-5 mr-2" />
                    {venteSuccessData ? 'Vente Réussie' : 'Panier'}
                </h2>

                {venteSuccessData ? (
                    <div className="flex-1 flex flex-col items-center justify-center p-6 text-center">
                        <CheckCircle className="w-16 h-16 text-green-500 mb-4" />
                        <h3 className="text-xl font-bold text-slate-800 mb-2">Paiement Validé</h3>
                        <p className="text-slate-600 mb-6">
                            Réf: <span className="font-mono font-medium">{venteSuccessData.reference}</span>
                        </p>

                        <div className="flex flex-col w-full gap-3">
                            <button
                                onClick={() => handleDownloadReceipt(venteSuccessData)}
                                className="flex justify-center items-center gap-2 w-full px-4 py-3 bg-blue-600 text-white rounded hover:bg-blue-700 transition font-medium"
                            >
                                <Download className="w-5 h-5" />
                                Télécharger le Reçu PDF
                            </button>

                            <button
                                onClick={() => setVenteSuccessData(null)}
                                className="w-full px-4 py-3 bg-slate-100 text-slate-700 rounded hover:bg-slate-200 transition font-medium border border-slate-200"
                            >
                                <ShoppingCart className="w-5 h-5 inline-block mr-2" />
                                Nouvelle Vente
                            </button>
                        </div>
                    </div>
                ) : (
                    <>
                        {/* Client Selection */}
                        <div className="mb-4 relative">
                            <label className="block text-xs font-semibold text-slate-500 uppercase mb-1">Client (Élève ou Autre)</label>
                            <div className="relative">
                                <input
                                    type="text"
                                    placeholder="Rechercher élève..."
                                    className="w-full p-2 pl-8 border border-slate-200 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                                    value={searchStudent}
                                    onChange={(e) => { setSearchStudent(e.target.value); setSelectedStudent(null); }}
                                />
                                <Search className="w-4 h-4 text-slate-400 absolute left-2.5 top-3" />
                            </div>

                            {/* Autocomplete Results */}
                            {showStudentResults && students.length > 0 && (
                                <ul className="absolute z-10 w-full bg-white border border-slate-200 rounded-lg shadow-lg max-h-48 overflow-y-auto mt-1">
                                    {students.map(student => (
                                        <li
                                            key={student.id}
                                            onClick={() => selectStudent(student)}
                                            className="p-2 hover:bg-blue-50 cursor-pointer text-sm"
                                        >
                                            <div className="font-medium text-slate-700">{student.nom} {student.prenom}</div>
                                            <div className="text-xs text-slate-500">{student.classe?.nom || 'Sans classe'}</div>
                                        </li>
                                    ))}
                                </ul>
                            )}

                            {!selectedStudent && (
                                <input
                                    type="text"
                                    placeholder="Ou Nom du client externe"
                                    className="mt-2 w-full p-2 border border-slate-200 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                                    value={clientName}
                                    onChange={(e) => setClientName(e.target.value)}
                                />
                            )}

                            {selectedStudent && (
                                <div className="mt-2 p-2 bg-blue-50 text-blue-700 rounded-lg text-sm flex justify-between items-center">
                                    <div className="flex items-center">
                                        <User className="w-4 h-4 mr-2" />
                                        {selectedStudent.nom} {selectedStudent.prenom}
                                    </div>
                                    <button onClick={() => { setSelectedStudent(null); setSearchStudent(''); }} className="text-blue-400 hover:text-blue-600">&times;</button>
                                </div>
                            )}
                        </div>

                        {/* Cart Items */}
                        <div className="flex-1 overflow-y-auto space-y-2 mb-4">
                            {cart.length === 0 ? (
                                <div className="text-center text-slate-400 py-8">Panier vide</div>
                            ) : (
                                cart.map((item) => (
                                    <div key={item.article_id} className="flex justify-between items-center bg-slate-50 p-3 rounded-lg">
                                        <div className="flex-1">
                                            <div className="text-sm font-medium text-slate-700">{item.designation}</div>
                                            <div className="text-xs text-slate-500">{item.prix} F x {item.quantite}</div>
                                        </div>
                                        <div className="flex items-center space-x-2">
                                            <button onClick={() => updateQuantity(item.article_id, -1)} className="w-6 h-6 bg-white border rounded text-slate-600 text-sm">-</button>
                                            <span className="text-sm font-medium w-4 text-center">{item.quantite}</span>
                                            <button onClick={() => updateQuantity(item.article_id, 1)} className="w-6 h-6 bg-white border rounded text-slate-600 text-sm">+</button>
                                            <button onClick={() => removeFromCart(item.article_id)} className="ml-1 text-red-500 hover:text-red-700"><Trash2 className="w-4 h-4" /></button>
                                        </div>
                                    </div>
                                ))
                            )}
                        </div>

                        {/* Footer */}
                        <div className="pt-4 border-t border-slate-100">
                            <div className="flex justify-between items-center mb-4 text-lg font-bold text-slate-800">
                                <span>Total</span>
                                <span>{cartTotal.toLocaleString()} FCFA</span>
                            </div>

                            {message && (
                                <div className={`mb-4 p-2 rounded text-sm text-center ${message.type === 'success' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
                                    {message.text}
                                </div>
                            )}

                            <button
                                onClick={handleCheckout}
                                disabled={cart.length === 0 || processing}
                                className="w-full bg-blue-600 text-white py-3 rounded-xl font-bold hover:bg-blue-700 transition shadow-lg shadow-blue-200 disabled:opacity-50 disabled:shadow-none flex justify-center items-center"
                            >
                                {processing ? <Loader2 className="animate-spin w-5 h-5" /> : <><CheckCircle className="w-5 h-5 mr-2" /> Valider la Vente</>}
                            </button>
                        </div>
                    </>
                )}
            </div>
        </div>
    );
}
