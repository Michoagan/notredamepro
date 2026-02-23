import api from './api';

export const login = async (identifier, password) => {
    // CSRF Cookie for Sanctum
    await api.get('/sanctum/csrf-cookie', { baseURL: '/' });

    const isEmail = identifier.includes('@');
    const endpoint = isEmail ? '/direction/login' : '/admin/login';
    const payload = isEmail ? { email: identifier, password } : { username: identifier, password };

    // Force base URL to /api to avoid /api/direction prefix from default instance
    const response = await api.post(endpoint, payload, { baseURL: '/api' });

    if (response.data.success || response.data.token) {
        localStorage.setItem('token', response.data.access_token || response.data.token);
        localStorage.setItem('user', JSON.stringify(response.data.user));
    }
    return response.data;
};

export const logout = async () => {
    try {
        await api.post('/logout');
    } finally {
        localStorage.removeItem('token');
        localStorage.removeItem('user');
        window.location.href = '/login';
    }
};

export const getUser = () => {
    const userStr = localStorage.getItem('user');
    return userStr ? JSON.parse(userStr) : null;
};

export const register = async (userData) => {
    // CSRF Cookie for Sanctum
    await api.get('/sanctum/csrf-cookie', { baseURL: '/' }); // Ensure base URL is root for cookie set

    // Assuming registration is for Direction staff. Admin registration should be separate if needed.
    const response = await api.post('/direction/register', userData);
    return response.data;
};
