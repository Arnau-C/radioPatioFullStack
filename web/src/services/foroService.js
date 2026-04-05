import axios from 'axios';

const API_URL = 'http://localhost:8080/api/foros';

const foroService = {
  // Trae la lista de mensajes de un foro específico
  getMensajes: async (foroId) => {
    try {
      const response = await axios.get(`${API_URL}/${foroId}/mensajes`);
      return response.data;
    } catch (error) {
      console.error("Error al obtener mensajes:", error);
      throw error;
    }
  },

  // Envía un nuevo mensaje al backend
  enviarMensaje: async (foroId, username, contenido) => {
    try {
      await axios.post(`${API_URL}/${foroId}/mensajes`, {
        username: username,
        contenido: contenido
      });
    } catch (error) {
      console.error("Error al enviar mensaje:", error);
      throw error;
    }
  }
};

export default foroService;