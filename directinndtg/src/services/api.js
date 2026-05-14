import axios from 'axios';

const baseURL = import.meta.env.PROD 
    ? 'https://schoolndtg.onrender.com/api' 
    : '/api';

const api = axios.create({
    baseURL: baseURL, // Uses real backend in production, and local proxy in development
    headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
    },
    withCredentials: true, // Important for Sanctum cookie
});

// Interceptor to add token if we decide to use Bearer token alongside/instead of cookies
api.interceptors.request.use((config) => {
    const token = localStorage.getItem('token');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
});

api.interceptors.response.use(
    (response) => response,
    (error) => {
        if (error.response && (error.response.status === 401 || error.response.status === 403)) {
            // Auto logout on 401 (Unauthenticated) or 403 (Unauthorized Role)
            localStorage.removeItem('token');
            localStorage.removeItem('user');
            window.location.href = '/login';
        }
        return Promise.reject(error);
    }
);

export default api;
