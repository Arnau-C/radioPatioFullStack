import axios from 'axios';

const API_URL = 'https://radiopatiofullstackbackend.onrender.com/api/auth/documentos';

// Función auxiliar para no repetir código en cada petición (¡Buenas prácticas!)
const getHeaders = (isMultipart = false) => {
    const user = JSON.parse(localStorage.getItem('user'));
    return {
        'Authorization': `Bearer ${user?.token}`,
        ...(isMultipart && { 'Content-Type': 'multipart/form-data' })
    };
};

const documentoService = {
    // 1. Ya no hace falta pasar la comunidad, el backend lo saca del Token JWT
    getCarpetas: async () => {
        const res = await axios.get(`${API_URL}/carpetas`, {
            headers: getHeaders()
        });
        return res.data;
    },

    getDocumentosByCarpeta: async (carpetaId) => {
        const res = await axios.get(`${API_URL}/carpeta/${carpetaId}`, {
            headers: getHeaders()
        });
        return res.data;
    },

    // 2. Solo enviamos el nombre, la comunidad la asocia el backend por seguridad
    crearCarpeta: async (nombre) => {
        const res = await axios.post(`${API_URL}/carpetas`, { nombre }, {
            headers: getHeaders()
        });
        return res.data;
    },

    // 3. Eliminamos el envío del 'username', el backend lo saca del JWT
    subirDocumento: async (file, carpetaId) => {
        const formData = new FormData();
        formData.append('file', file);
        formData.append('carpetaId', carpetaId);

        const res = await axios.post(`${API_URL}/subir`, formData, {
            headers: getHeaders(true)
        });
        return res.data;
    },

    borrarCarpeta: async (carpetaId) => {
        const res = await axios.delete(`${API_URL}/carpetas/${carpetaId}`, {
            headers: getHeaders()
        });
        return res.data;
    },

    verDocumento: async (documentoId) => {
        const res = await axios.get(`${API_URL}/descargar/${documentoId}`, {
            headers: getHeaders(),
            responseType: 'blob' 
        });
        return res.data;
    },

    borrarDocumento: async (documentoId) => {
        const res = await axios.delete(`${API_URL}/${documentoId}`, {
            headers: getHeaders()
        });
        return res.data;
    },

    moverDocumento: async (documentoId, nuevaCarpetaId) => {
        const res = await axios.put(`${API_URL}/mover/${documentoId}`, {
            nuevaCarpetaId: parseInt(nuevaCarpetaId) 
        }, {
            headers: getHeaders()
        });
        return res.data;
    }
};

export default documentoService;