import React, { forwardRef } from 'react';
import { QRCodeSVG } from 'qrcode.react';

const BulletinTemplate = forwardRef(({ data, trimestre, anneeScolaire }, ref) => {
    if (!data) return null;

    const {
        eleve,
        notes,
        moyenne_generale,
        moyenne_annuelle,
        conduite,
        rang,
        effectif_classe,
        minAverage,
        maxAverage,
        classAverage
    } = data;

    // QR Code data
    const qrData = JSON.stringify({
        eleve_id: eleve.id,
        nom: eleve.nom,
        prenom: eleve.prenom,
        classe: eleve.classe?.nom,
        trimestre: trimestre,
        moyenne: moyenne_generale,
        annee_scolaire: anneeScolaire,
        type: 'Bulletin_Authentique'
    });

    return (
        <div ref={ref} className="bg-white p-8 w-full max-w-4xl mx-auto text-black" style={{ fontFamily: 'sans-serif' }}>
            {/* Header */}
            <div className="flex justify-between items-start border-b-2 border-black pb-4 mb-6">
                <div className="text-center flex-1">
                    <h1 className="text-xl font-bold uppercase">COMPLEXE SCOLAIRE NOTRE DAME DE DE GRÂCE</h1>
                    <p className="text-sm">BP: 1234 Lomé - TOGO | Tél: 90 00 00 00</p>
                    <p className="text-sm font-semibold mt-1">Année Scolaire: {anneeScolaire || '2025-2026'}</p>
                </div>
                <div className="ml-4 flex flex-col items-center">
                    <QRCodeSVG value={qrData} size={70} level="L" />
                </div>
            </div>

            <div className="bg-slate-100 text-center py-2 mb-6 font-bold text-lg uppercase border border-slate-300">
                Bulletin du {trimestre}{String(trimestre) === '1' ? 'er' : 'ème'} Trimestre
            </div>

            {/* Student Info & Photo */}
            <div className="flex justify-between items-start mb-6">
                <div className="flex-1">
                    <table className="w-full text-sm mt-2">
                        <tbody>
                            <tr>
                                <td className="font-bold py-1 w-40">Nom & Prénoms:</td>
                                <td className="py-1 uppercase font-semibold">{eleve.nom} {eleve.prenom}</td>
                            </tr>
                            <tr>
                                <td className="font-bold py-1">Classe:</td>
                                <td className="py-1">{eleve.classe?.nom}</td>
                            </tr>
                            <tr>
                                <td className="font-bold py-1">Matricule:</td>
                                <td className="py-1">{eleve.matricule || 'N/A'}</td>
                            </tr>
                            <tr>
                                <td className="font-bold py-1">Effectif:</td>
                                <td className="py-1">{effectif_classe} élèves</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                {/* Photo de l'élève */}
                {eleve.photo ? (
                    <div className="ml-6 flex-shrink-0">
                        <img
                            src={`${import.meta.env.VITE_API_BASE_URL}/storage/${eleve.photo}`}
                            alt="Photo élève"
                            className="w-24 h-28 object-cover border-2 border-slate-300 rounded shadow-sm"
                        />
                    </div>
                ) : (
                    <div className="ml-6 flex-shrink-0 w-24 h-28 bg-slate-100 border-2 border-slate-300 rounded flex flex-col items-center justify-center text-xs text-slate-400">
                        <span className="text-2xl mb-1">👤</span>
                        Photo
                    </div>
                )}
            </div>

            {/* Grades Table */}
            <table className="w-full text-sm border-collapse border border-black mb-6">
                <thead className="bg-slate-100">
                    <tr>
                        <th className="border border-black px-2 py-3 text-left">Matière</th>
                        <th className="border border-black px-2 py-3 text-center">Coeff.</th>
                        <th className="border border-black px-2 py-3 text-center">Moyenne</th>
                        <th className="border border-black px-2 py-3 text-center">Moy. Coeff</th>
                        <th className="border border-black px-2 py-3 text-center w-16">Rang</th>
                        <th className="border border-black px-2 py-3 text-left">Appréciation</th>
                    </tr>
                </thead>
                <tbody>
                    {notes && notes.map((note, index) => {
                        const moyEnum = Number(note.moyenne_trimestrielle) || 0;
                        const coeff = Number(note.coefficient) || 1;
                        const moyCoeff = moyEnum * coeff;
                        return (
                            <tr key={index}>
                                <td className="border border-black px-2 py-1 font-semibold">{note.matiere?.nom}</td>
                                <td className="border border-black px-2 py-1 text-center">{coeff}</td>
                                <td className="border border-black px-2 py-1 text-center font-medium">{moyEnum.toFixed(2)}</td>
                                <td className="border border-black px-2 py-1 text-center">{moyCoeff.toFixed(2)}</td>
                                <td className="border border-black px-2 py-1 text-center font-bold text-blue-800">{note.rang_matiere || '-'}</td>
                                <td className="border border-black px-2 py-1 text-xs italic">{note.appreciation || '-'}</td>
                            </tr>
                        );
                    })}
                    {/* Totals */}
                    <tr className="bg-slate-50 font-bold border-t-2 border-black">
                        <td className="border border-black p-2 text-right uppercase">Total</td>
                        <td className="border border-black p-2 text-center">
                            {notes && notes.reduce((acc, note) => acc + (Number(note.coefficient) || 1), 0)}
                        </td>
                        <td className="border border-black p-2 text-center bg-slate-200"></td>
                        <td className="border border-black p-2 text-center">
                            {notes && notes.reduce((acc, note) => acc + ((Number(note.moyenne_trimestrielle) || 0) * (Number(note.coefficient) || 1)), 0).toFixed(2)}
                        </td>
                        <td className="border border-black p-2 text-center bg-slate-200" colSpan={2}></td>
                    </tr>
                </tbody>
            </table>

            {/* Summaries */}
            <div className="flex border-2 border-black p-4 gap-4 mb-8 bg-[#fdfdfd]">
                <div className="flex-1 text-center">
                    <div className="font-bold mb-2 uppercase text-sm">Moyenne Trimestrielle</div>
                    <div className="text-2xl font-bold bg-slate-200 py-3 rounded border border-slate-300">
                        {Number(moyenne_generale).toFixed(2)} / 20
                    </div>
                    <div className="mt-3 text-sm">
                        Rang: <span className="font-bold text-xl">{rang}<sup>{rang === 1 ? 'er' : 'ème'}</sup></span> / {effectif_classe}
                    </div>
                </div>
                <div className="flex-1 text-sm flex flex-col justify-center border-l border-r border-slate-300 px-4">
                    <div className="font-bold mb-3 uppercase text-center text-sm">Statistiques Classe</div>
                    <div className="flex justify-between py-1 border-b border-dashed border-slate-300">
                        <span className="text-slate-600">Moyenne Min:</span> <span className="font-bold">{Number(minAverage).toFixed(2)}</span>
                    </div>
                    <div className="flex justify-between py-1 border-b border-dashed border-slate-300">
                        <span className="text-slate-600">Moyenne Max:</span> <span className="font-bold">{Number(maxAverage).toFixed(2)}</span>
                    </div>
                    <div className="flex justify-between py-1">
                        <span className="text-slate-600">Moyenne Classe:</span> <span className="font-bold">{Number(classAverage).toFixed(2)}</span>
                    </div>
                </div>
                <div className="flex-1 justify-center flex flex-col items-center">
                    <div className="font-bold mb-2 uppercase text-center text-sm w-full">Décision du Conseil</div>
                    <div className={`text-center font-bold px-4 py-2 rounded-lg border w-full ${Number(moyenne_generale) >= 10 ? 'bg-green-50 text-green-700 border-green-200' : 'bg-red-50 text-red-700 border-red-200'}`}>
                        {Number(moyenne_generale) >= 10 ? 'Travail Satisfaisant' : 'Doit faire des efforts'}
                    </div>
                </div>
            </div>

            {/* Signatures */}
            <div className="grid grid-cols-3 gap-6 mt-4 text-center text-sm">
                <div className="flex flex-col h-32 justify-start border p-2 rounded relative">
                    <div className="font-bold uppercase underline mb-1">Le Parent</div>
                </div>
                <div className="flex flex-col h-32 justify-start border p-2 rounded relative bg-slate-50">
                    <div className="font-bold uppercase underline mb-1 w-full">Le Professeur Principal</div>
                    <div className="text-[10px] text-slate-500 italic mt-1">(Avis & Signature)</div>
                </div>
                <div className="flex flex-col h-32 justify-start border p-2 rounded relative border-black">
                    <div className="font-bold uppercase underline mb-1">Le Directeur</div>
                    <div className="absolute bottom-2 left-0 right-0 text-[10px] text-slate-400 italic">Cachet & Signature</div>
                </div>
            </div>

            <div className="text-center text-[10px] text-slate-400 mt-6 border-t pt-2 max-w-sm mx-auto">
                Bulletin authentifié électroniquement par notre plateforme de gestion. Ce QR code garantit l'intégrité de ces données.
            </div>
        </div>
    );
});

export default BulletinTemplate;
