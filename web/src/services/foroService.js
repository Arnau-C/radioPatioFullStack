import axios from 'axios';

const API_URL = 'http://localhost:8080/api/foros';

// Función auxiliar para obtener el token del usuario logueado
const getAuthHeaders = () => {
  const userData = JSON.parse(localStorage.getItem('user'));
  if (userData && userData.token) {
    return { Authorization: `Bearer ${userData.token}` }; // Formato que espera el JwtAuthenticationFilter
  }
  return {};
};

const foroService = {
  getMensajes: async (foroId) => {
    try {
      const response = await axios.get(`${API_URL}/${foroId}/mensajes`, {
        headers: getAuthHeaders() // Añadimos el token aquí
      });
      return response.data;
    } catch (error) {
      console.error("Error al obtener mensajes:", error);
      throw error;
    }
  },

  

  enviarMensaje: async (foroId, username, contenido, respuestaAId = null) => {
    await axios.post(`${API_URL}/${foroId}/mensajes`, {
      username,
      contenido,
      respuestaAId
    }, { headers: getAuthHeaders() });
  },
  
  eliminarMensaje: async (id) => {
    await axios.delete(`${API_URL}/mensajes/${id}`, { headers: getAuthHeaders() });
  },

  toggleDestacado: async (id) => {
    await axios.patch(`${API_URL}/mensajes/${id}/destacar`, {}, { headers: getAuthHeaders() });
  }
};

export default foroService;