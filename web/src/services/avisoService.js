import axios from 'axios';

const API_URL = 'http://localhost:8080/api/avisos';

const getToken = () => {
    const user = JSON.parse(localStorage.getItem('user'));
    return user?.token;
};

const avisoService = {
    // Obtener todos los avisos de una comunidad
    getAvisosByComunidad: async (comunidadId) => {
        const res = await axios.get(`${API_URL}/comunidad/${comunidadId}`, {
            headers: { 'Authorization': `Bearer ${getToken()}` }
        });
        return res.data;
    }
};

export default avisoService;