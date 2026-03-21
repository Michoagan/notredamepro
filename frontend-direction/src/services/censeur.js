import api from './api';

const censeurService = {
    // Dashboard & Stats
    getDashboardStats: () => api.get('/censeur/dashboard'),
    getLogs: () => api.get('/censeur/logs'),

    // Programmation (Matières & Classes)
    getEmploiDuTemps: (classeId) => api.get(`/censeur/emplois-du-temps/${classeId}`),
    updateEmploiDuTemps: (classeId, data) => api.post(`/censeur/emplois-du-temps/${classeId}`, data),
    saveProgrammation: (data) => api.post('/censeur/programmation', data),
    setProfPrincipal: (data) => api.post('/censeur/prof-principal', data),

    // Pédagogie
    getContacts: () => api.get('/censeur/contacts'),
    getCahiersTexte: (filters = {}) => api.get('/censeur/cahiers-texte', { params: filters }),

    // Validation Notes
    // Modification Notes
    getNotesForModification: (params) => api.get('/notes', { params }),
    storeNotesModification: (data) => api.post('/notes', data),
};

export default censeurService;
