import axios from 'axios';

const api = axios.create({
    baseURL: '/api', // Adapte selon l'URL de ton backend Laravel
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
    getExercices: () => api.get('/eleve/exercices')
};

export default api;
