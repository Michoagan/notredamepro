import api from './api';

const SURVEILLANT_API = '/surveillant';

// Dashboard / Stats
// Dashboard (Comprehensive)
export const getDashboard = async () => {
    const response = await api.get(`${SURVEILLANT_API}/dashboard`);
    return response.data;
};

// Stats only
export const getSurveillantStats = async () => {
    const response = await api.get(`${SURVEILLANT_API}/stats`);
    return response.data;
};

// Plaintes / Discipline
export const getPlaintes = async (filters = {}) => {
    const params = new URLSearchParams(filters).toString();
    const response = await api.get(`${SURVEILLANT_API}/plaintes?${params}`);
    return response.data;
};

export const createPlainte = async (data) => {
    const response = await api.post(`${SURVEILLANT_API}/plaintes`, data);
    return response.data;
};

// Evénements
export const getEvenements = async () => {
    const response = await api.get(`${SURVEILLANT_API}/evenements`);
    return response.data;
};

export const createEvenement = async (data) => {
    const response = await api.post(`${SURVEILLANT_API}/evenements`, data);
    return response.data;
};

// Présences
export const getPresencesEleves = async (date, classeId) => {
    const params = new URLSearchParams();
    if (date) params.append('date', date);
    if (classeId) params.append('classe_id', classeId);

    const response = await api.get(`${SURVEILLANT_API}/presences/eleves?${params.toString()}`);
    return response.data;
};

export const getPresencesProfesseurs = async (date) => {
    const params = new URLSearchParams();
    if (date) params.append('date', date);

    const response = await api.get(`${SURVEILLANT_API}/presences/professeurs?${params.toString()}`);
    return response.data;
};

// Helpers for dropdowns (reusing other services or direct calls if endpoints exist in SurveillantController)
// Based on SurveillantController::dashboard, we get classes and profs there, but for specific pages we might need dedicated calls.
// Using generic endpoints for now or assuming the component will load necessary lookups.
export const getClasses = async () => {
    const response = await api.get('/classes/index'); // Reuse existing route
    return response.data;
};

export const getElevesByClasse = async (classeId) => {
    // Assuming backend has this, otherwise we might filter on client side if list is small, 
    // or use the 'professeurs/presences/eleves/{classe}' endpoint which returns students.
    const response = await api.get(`/professeurs/presences/eleves/${classeId}`);
    return response.data;
};

const surveillantService = {
    getDashboard,
    getSurveillantStats,
    getPlaintes,
    createPlainte,
    getEvenements,
    createEvenement,
    getPresencesEleves,
    getPresencesProfesseurs,
    getClasses,
    getElevesByClasse
};

export default surveillantService;
