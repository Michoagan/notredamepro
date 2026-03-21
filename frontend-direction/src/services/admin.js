import api from './api';

const ADMIN_API = '/admin';

export const getDashboardStats = async () => {
    const response = await api.get(`${ADMIN_API}/dashboard`);
    return response.data;
};

export const getPendingAccounts = async () => {
    const response = await api.get(`${ADMIN_API}/pending-accounts`);
    return response.data;
};

export const getSettings = async () => {
    const response = await api.get('/settings');
    return response.data;
};

export const updateSetting = async (data) => {
    const response = await api.post('/direction/settings', data);
    return response.data;
};

export const getAllAccounts = async (filters = {}) => {
    const params = new URLSearchParams(filters).toString();
    const response = await api.get(`${ADMIN_API}/all-accounts?${params}`);
    return response.data;
};

export const approveAccount = async (id, notes = '') => {
    const response = await api.post(`${ADMIN_API}/account/${id}/approve`, { notes });
    return response.data;
};

export const rejectAccount = async (id, reason) => {
    const response = await api.post(`${ADMIN_API}/account/${id}/reject`, { rejection_reason: reason });
    return response.data;
};

export const toggleAccountStatus = async (id) => {
    const response = await api.post(`${ADMIN_API}/account/${id}/toggle-status`);
    return response.data;
};

export const createUser = async (data) => {
    const response = await api.post(`${ADMIN_API}/users`, data);
    return response.data;
};

export const getMatieres = async () => {
    const response = await api.get('/classes/matieres');
    return response.data;
};
