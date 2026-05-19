import axios from 'axios';

const API_URL = 'https://radiopatiofullstackbackend.onrender.com/api/reservas';

const getToken = () => {
    const user = JSON.parse(localStorage.getItem('user'));
    return user?.token;
};

const reservaService = {
    /**
     * GET /api/reservas/comunidad/{comunidadId}
     * Devuelve todas las reservas ACTIVAS de la comunidad.
     * El servidor valida que el comunidadId coincide con la comunidad del JWT.
     */
    getReservasByComunidad: async (comunidadId) => {
        const res = await axios.get(`${API_URL}/comunidad/${comunidadId}`, {
            headers: { 'Authorization': `Bearer ${getToken()}` }
        });
        return res.data;
    }
};

export default reservaService;
