import api from './api';

const CAISSE_API = '/direction/caisse';

// Dashboard
export const getCaisseDashboard = async (date) => {
    const params = new URLSearchParams();
    if (date) params.append('date', date);

    const response = await api.get(`${CAISSE_API}/dashboard?${params.toString()}`);
    return response.data;
};

// Paiements (Scolarité)
export const getPaiements = async () => {
    const response = await api.get(`${CAISSE_API}/paiements`);
    return response.data;
};

export const createPaiement = async (data) => {
    const response = await api.post(`${CAISSE_API}/paiements`, data);
    return response.data;
};

export const getPaiementQrCode = async (paiementId) => {
    const response = await api.get(`${CAISSE_API}/paiements/${paiementId}/qrcode`);
    return response.data;
};

export const downloadReceiptPDF = async (paiementId) => {
    const response = await api.get(`${CAISSE_API}/paiements/${paiementId}/receipt`, {
        responseType: 'blob'
    });

    // Create a Blob from the PDF Stream
    const file = new Blob([response.data], { type: 'application/pdf' });
    const fileURL = URL.createObjectURL(file);
    return fileURL;
};

// Ventes
export const storeVente = async (data) => {
    const response = await api.post(`${CAISSE_API}/ventes`, data);
    return response.data;
};

export const downloadVenteReceiptPDF = async (venteId) => {
    const response = await api.get(`${CAISSE_API}/ventes/${venteId}/receipt`, {
        responseType: 'blob'
    });

    const file = new Blob([response.data], { type: 'application/pdf' });
    const fileURL = URL.createObjectURL(file);
    return fileURL;
};

export const getVenteQrCode = async (venteId) => {
    const response = await api.get(`${CAISSE_API}/ventes/${venteId}/qrcode`);
    return response.data;
};
