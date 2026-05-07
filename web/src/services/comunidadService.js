// web/src/services/comunidadService.js
import axios from 'axios';

// Asegúrate de que esta URL coincida con la que usas en tu entorno
const API_URL = 'http://localhost:8080/api/comunidades'; 

const getToken = () => {
  const user = JSON.parse(localStorage.getItem('user'));
  return user?.token;
};

const comunidadService = {
  crearComunidad: async (nombre, direccion, presidenteUsername) => {
    const response = await axios.post(`${API_URL}/crear`, {
      nombre,
      direccion,
      presidenteUsername
    }, {
      headers: { 'Authorization': `Bearer ${getToken()}` }
    });
    return response.data;
  },

  unirseComunidad: async (codigo, username) => {
    const response = await axios.post(`${API_URL}/unirse`, {
      codigo,
      username
    }, {
      headers: { 'Authorization': `Bearer ${getToken()}` }
    });
    return response.data;
  },

  getDetalle: async (username) => {
    const response = await axios.get(`${API_URL}/detalle/${username}`, {
      headers: { 'Authorization': `Bearer ${getToken()}` }
    });
    return response.data;
  }
};

export default comunidadService;