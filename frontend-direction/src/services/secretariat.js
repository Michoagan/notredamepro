import api from './api';

// --- ELEVES ---
export const getEleves = async (filters = {}) => {
    const params = new URLSearchParams(filters).toString();
    const response = await api.get(`/secretaire/eleves?${params}`);
    return response.data;
};

export const createEleve = async (data) => {
    // data should be FormData if containing files (photo)
    const config = {};
    if (data instanceof FormData) {
        config.headers = { 'Content-Type': 'multipart/form-data' };
    }
    const response = await api.post('/secretaire/eleves', data, config);
    return response.data;
};

export const updateEleve = async (id, data) => {
    const config = {};
    // Use POST with _method: 'PUT' if sending FormData (files)
    if (data instanceof FormData) {
        data.append('_method', 'PUT');
        config.headers = { 'Content-Type': 'multipart/form-data' };
        const response = await api.post(`/secretaire/eleves/${id}`, data, config);
        return response.data;
    } else {
        const response = await api.put(`/secretaire/eleves/${id}`, data);
        return response.data;
    }
};

export const deleteEleve = async (id) => {
    const response = await api.delete(`/secretaire/eleves/${id}`);
    return response.data;
};

// --- CLASSES ---
export const getClasses = async () => {
    const response = await api.get('/classes/index');
    return response.data;
};

export const createClasse = async (data) => {
    const response = await api.post('/classes', data);
    return response.data;
};

export const updateClasse = async (id, data) => {
    const response = await api.put(`/classes/${id}`, data);
    return response.data;
};

export const deleteClasse = async (id) => {
    const response = await api.delete(`/classes/${id}`);
    return response.data;
};

// --- COMMUNIQUES ---
export const getCommuniques = async () => {
    const response = await api.get('/communiques');
    return response.data;
};

export const createCommunique = async (data) => {
    const response = await api.post('/communiques', data);
    return response.data;
};

export const deleteCommunique = async (id) => {
    const response = await api.delete(`/communiques/${id}`);
    return response.data;
};

export const updateCommunique = async (id, data) => {
    const response = await api.put(`/communiques/${id}`, data);
    return response.data;
};

// --- PROFESSEURS ---
export const getProfesseurs = async () => {
    const response = await api.get('/professeurs');
    return response.data;
};

export const createProfesseur = async (data) => {
    const config = { headers: { 'Content-Type': 'multipart/form-data' } };
    const response = await api.post('/professeurs', data, config);
    return response.data;
};

export const updateProfesseur = async (id, data) => {
    const config = {};
    if (data instanceof FormData) {
        data.append('_method', 'PUT');
        config.headers = { 'Content-Type': 'multipart/form-data' };
        const response = await api.post(`/professeurs/${id}`, data, config);
        return response.data;
    }
    const response = await api.put(`/professeurs/${id}`, data);
    return response.data;
};

export const deleteProfesseur = async (id) => {
    const response = await api.delete(`/professeurs/${id}`);
    return response.data;
};

// --- BULLETINS ---
export const getBulletins = async () => {
    const response = await api.get('/secretaire/bulletins');
    return response.data;
};

export const fetchBulletinData = async (eleveId, trimestre, classeId) => {
    const response = await api.get(`/bulletins?eleve_id=${eleveId}&trimestre=${trimestre}&classe_id=${classeId}`);
    return response.data;
};

export const downloadBulletin = async (eleveId, trimestre) => {
    const response = await api.get(`/secretaire/bulletin/eleve/${eleveId}/${trimestre}`, {
        responseType: 'blob', // Important for PDF
    });
    return response.data;
};

// --- MATIERES (Subjects) ---
export const getMatieres = async () => {
    const response = await api.get('/classes/matieres');
    return response.data;
};

export const createMatiere = async (data) => {
    const response = await api.post('/classes/matieres', data);
    return response.data;
};

export const updateMatiere = async (id, data) => {
    const response = await api.put(`/classes/matieres/${id}`, data);
    return response.data;
};

export const deleteMatiere = async (id) => {
    const response = await api.delete(`/classes/matieres/${id}`);
    return response.data;
};

// --- EVENEMENTS ---
export const getEvenements = async () => {
    const response = await api.get('/secretaire/evenements');
    return response.data;
};

export const createEvenement = async (data) => {
    const response = await api.post('/secretaire/evenements', data);
    return response.data;
};

export const deleteEvenement = async (id) => {
    const response = await api.delete(`/secretaire/evenements/${id}`);
    return response.data;
};

