import api from './api';

const paieService = {
    // Récupère la liste des professeurs avec leurs taux horaires configurés
    getConfiguration: () => api.get('/comptabilite/paie-professeurs/config'),

    // Sauvegarde les taux horaires et primes pour un professeur
    saveConfiguration: (data) => api.post('/comptabilite/paie-professeurs/config', data),

    // Génère la fiche de paie pour un mois donné (et optionnellement un prof spécifique)
    genererPaie: (data) => api.post('/comptabilite/paie-professeurs/generer', data),
};

export default paieService;
