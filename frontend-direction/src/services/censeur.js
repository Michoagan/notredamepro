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
    getNotesValidation: (params) => api.get('/censeur/notes/validation', { params }),
    validateNotes: (data) => api.post('/censeur/notes/validation', data),
};

export default censeurService;
