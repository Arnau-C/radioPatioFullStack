import axios from 'axios';

const API_URL = 'https://radiopatiofullstackbackend.onrender.com/api/foros';
const getAuthHeaders = () => {
  const userData = JSON.parse(localStorage.getItem('user'));
  return userData?.token ? { Authorization: `Bearer ${userData.token}` } : {};
};

const foroService = {
  getMensajes: async (foroId) => {
    const response = await axios.get(`${API_URL}/${foroId}/mensajes`, { headers: getAuthHeaders() });
    return response.data;
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
  }
};

export default foroService;