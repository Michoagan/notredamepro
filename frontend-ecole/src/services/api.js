import axios from 'axios';

const baseURL = import.meta.env.PROD 
    ? 'https://schoolndtg.onrender.com/api' 
    : '/api';

const api = axios.create({
    baseURL: baseURL, // Uses real backend in production, and local proxy in development
    headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    }
});

api.interceptors.request.use(config => {
    const token = localStorage.getItem('eleve_token');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
});

export const authService = {
    register: (data) => api.post('/eleve/register', data),
    login: (credentials) => api.post('/eleve/login', credentials),
    logout: () => api.post('/eleve/logout'),
};

export const eleveService = {
    getNotes: () => api.get('/eleve/notes'),
    getEpreuves: () => api.get('/eleve/epreuves'),
    getExercices: () => api.get('/eleve/exercices'),
    getContacts: () => api.get('/eleve/contacts')
};

export default api;
