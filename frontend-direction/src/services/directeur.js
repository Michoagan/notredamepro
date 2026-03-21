import api from './api';

const DIRECTEUR_API = '/direction';

// Dashboard
export const getDirecteurDashboard = async () => {
    // Note: The route in api.php is '/direction/directeur' pointing to 'directeurDashboard'
    const response = await api.get(`${DIRECTEUR_API}/directeur`);
    return response.data;
};

// Settings (Academic Year)
export const getSettings = async () => {
    const response = await api.get(`${DIRECTEUR_API}/settings`);
    return response.data;
};

export const updateSettings = async (data) => {
    const response = await api.post(`${DIRECTEUR_API}/settings`, data);
    return response.data;
};

// Personnel (Professeurs)
export const getProfesseurs = async (filters = {}) => {
    // Assuming we use the existing route '/professeurs' but maybe we want the export/list one from DirecteurController
    // Actually DirecteurController::exportProfesseurs is for PDF. 
    // ProfesseurController::index returns list. Let's use that or add a specific one if needed.
    // For now, let's use the one that returns detailed list.
    const response = await api.get(`/professeurs`);
    return response.data;
};

// Parents
export const getParents = async (search = '') => {
    const response = await api.get(`${DIRECTEUR_API}/parents?search=${search}`);
    return response.data;
};

// Cahiers de Texte (Global View)
// DirecteurController has `detailProfesseur` which includes cahiers.
// Maybe we need a global "Cahiers de Texte" view?
// For now, we will probably access it via the Professors list -> Detail -> Cahiers.
export const getProfesseurDetails = async (id) => {
    const response = await api.get(`/professeurs/${id}`); // Check routing for details
    return response.data;
};

// Analyse des performances du professeur (Assiduité, Programme, Impact)
export const getTeacherPerformance = async (id) => {
    const response = await api.get(`/professeurs/${id}/performance`);
    return response.data;
};
