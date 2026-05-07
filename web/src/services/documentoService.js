import axios from 'axios';

const API_URL = 'http://localhost:8080/api/documentos';

const getToken = () => {
    const user = JSON.parse(localStorage.getItem('user'));
    return user?.token;
};

const documentoService = {
    getCarpetas: async (comunidadNombre) => {
        const res = await axios.get(`${API_URL}/carpetas/${comunidadNombre}`, {
            headers: { 'Authorization': `Bearer ${getToken()}` }
        });
        return res.data;
    },

    getDocumentosByCarpeta: async (carpetaId) => {
        const res = await axios.get(`${API_URL}/carpeta/${carpetaId}`, {
            headers: { 'Authorization': `Bearer ${getToken()}` }
        });
        return res.data;
    },

    crearCarpeta: async (nombre, comunidadNombre) => {
        const res = await axios.post(`${API_URL}/carpetas`, { nombre, comunidadNombre }, {
            headers: { 'Authorization': `Bearer ${getToken()}` }
        });
        return res.data;
    },

    subirDocumento: async (file, username, carpetaId) => {
        const formData = new FormData();
        formData.append('file', file);
        formData.append('carpetaId', carpetaId);
        formData.append('username', username);

        const res = await axios.post(`${API_URL}/subir`, formData, {
            headers: { 
                'Authorization': `Bearer ${getToken()}`,
                'Content-Type': 'multipart/form-data'
            }
        });
        return res.data;
    },

    borrarCarpeta: async (carpetaId) => {
        const res = await axios.delete(`${API_URL}/carpetas/${carpetaId}`, {
            headers: { 'Authorization': `Bearer ${getToken()}` }
        });
        return res.data;
    },

    verDocumento: async (documentoId) => {
        const res = await axios.get(`${API_URL}/descargar/${documentoId}`, {
            headers: { 'Authorization': `Bearer ${getToken()}` },
            responseType: 'blob' // Clave para los PDFs
        });
        return res.data;
    }
};

export default documentoService;