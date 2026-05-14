import api from './api';

const settingsService = {
    // Fetch all global settings (available to all authenticated users)
    getGlobalSettings: () => api.get('/settings'),

    // Helper function to extract common values directly
    getCurrentTerm: async () => {
        try {
            const response = await api.get('/settings');
            if (response.data) {
                return response.data.current_trimestre;
            }
            return null;
        } catch (error) {
            console.error("Error fetching global settings:", error);
            return null;
        }
    },

    getCurrentYear: async () => {
        try {
            const response = await api.get('/settings');
            if (response.data) {
                return response.data.current_annee_scolaire;
            }
            return null;
        } catch (error) {
            console.error("Error fetching global settings:", error);
            return null;
        }
    }
};

export default settingsService;
