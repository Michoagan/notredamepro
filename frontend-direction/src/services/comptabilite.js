import api from './api';

// ----------------------
// DASHBOARD & DEPENSES
// ----------------------

const COMPTA_API = '/direction/comptabilite';

// Dashboard
export const getComptaDashboard = async (startDate, endDate) => {
    const params = new URLSearchParams();
    if (startDate) params.append('start_date', startDate);
    if (endDate) params.append('end_date', endDate);

    const response = await api.get(`${COMPTA_API}/dashboard?${params.toString()}`);
    return response.data;
};

// ----------------------
export const getDepenses = async () => {
    const response = await api.get(`${COMPTA_API}/depenses`);
    return response.data;
};

export const createDepense = async (data) => {
    const response = await api.post(`${COMPTA_API}/depenses`, data);
    return response.data;
};

// Salaires
export const getSalaires = async (mois, annee) => {
    const params = new URLSearchParams({ mois, annee }).toString();
    const response = await api.get(`${COMPTA_API}/salaires?${params}`);
    return response.data;
};

export const generateSalaires = async (mois, annee) => {
    const response = await api.post(`${COMPTA_API}/salaires/generate`, { mois, annee });
    return response.data;
};

export const updateSalaire = async (id, data) => {
    const response = await api.put(`${COMPTA_API}/salaires/${id}`, data);
    return response.data;
};

export const payerSalaire = async (id) => {
    const response = await api.post(`${COMPTA_API}/salaires/${id}/payer`);
    return response.data;
};

// Inventaire
export const getArticles = async () => {
    const response = await api.get(`${COMPTA_API}/articles`);
    return response.data;
};

export const createArticle = async (data) => {
    const response = await api.post(`${COMPTA_API}/articles`, data);
    return response.data;
};

export const updateArticle = async (id, data) => {
    const response = await api.put(`${COMPTA_API}/articles/${id}`, data);
    return response.data;
};

export const addStock = async (id, data) => {
    const response = await api.post(`${COMPTA_API}/articles/${id}/stock`, data);
    return response.data;
};

export const correctStock = async (id, data) => {
    const response = await api.post(`${COMPTA_API}/articles/${id}/correction`, data);
    return response.data;
};

export const getArticleHistory = async (id) => {
    const response = await api.get(`${COMPTA_API}/articles/${id}/historique`);
    return response.data;
};

// Ventes ont été déplacés vers Caisse

// Tranches de Scolarité
export const getTranchesScolarite = async () => {
    const response = await api.get(`${COMPTA_API}/tranches-scolarite`);
    return response.data;
};

export const saveTranchesScolarite = async (tranchesData) => {
    const response = await api.post(`${COMPTA_API}/tranches-scolarite`, { tranches: tranchesData });
    return response.data;
};
