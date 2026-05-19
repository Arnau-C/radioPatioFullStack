import axios from 'axios';

const API_URL = 'https://radiopatiofullstackbackend.onrender.com/api/avisos';
const getToken = () => {
    const user = JSON.parse(localStorage.getItem('user'));
    return user?.token;
};

const avisoService = {
    /**
     * GET /api/avisos?fecha=YYYY-MM-DD
     * Devuelve los avisos de un día concreto para la comunidad del usuario autenticado.
     * La comunidad se determina desde el JWT en el servidor.
     */
    getAvisosByFecha: async (fecha) => {
        const res = await axios.get(API_URL, {
            params: { fecha },
            headers: { 'Authorization': `Bearer ${getToken()}` }
        });
        return res.data;
    },

    /**
     * POST /api/avisos
     * Crea un aviso (solo PRESIDENTE). El creador se extrae del JWT en el servidor.
     * @param {string} titulo
     * @param {string} descripcion
     * @param {string} fecha - formato "YYYY-MM-DD"
     */
    crearAviso: async (titulo, descripcion, fecha) => {
        const res = await axios.post(API_URL, { titulo, descripcion, fecha }, {
            headers: { 'Authorization': `Bearer ${getToken()}` }
        });
        return res.data;
    }
};

export default avisoService;