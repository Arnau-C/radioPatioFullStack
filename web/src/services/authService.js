// web/src/services/authService.js
import axios from 'axios';

//const API_URL = 'https://radiopatiofullstackbackend.onrender.com/api/auth';

const API_URL = 'http://localhost:8080/api/auth';

const authService = {
  login: async (username, password) => {
    try {
      const response = await axios.post(`${API_URL}/login`, {
        username,
        password,
        sistema: 'WEB'
      });
      if (response.data.token) {
        localStorage.setItem('user', JSON.stringify(response.data));
      }
      return response.data;
    } catch (error) {
      throw error.response ? error.response.data : new Error('Error de conexión');
    }
  },

  register: async (userData) => {
    try {
      const response = await axios.post(`${API_URL}/registro`, {
        nombre: userData.nombre,
        apellidos: userData.apellidos,
        email: userData.email,
        username: userData.username,
        password: userData.password
      });
      return response.data;
    } catch (error) {
      throw error.response ? error.response.data : new Error('Error al registrar');
    }
  },
  updateProfile: async (username, userData) => {
    const response = await axios.put(`${API_URL}/api/auth/update/${username}`, userData);
    
    const currentLocal = JSON.parse(localStorage.getItem('user'));
    const updatedLocal = { ...currentLocal, ...response.data };
    localStorage.setItem('user', JSON.stringify(updatedLocal));
    
    return response.data;
},

  logout: () => {
    localStorage.removeItem('user');
  }

  
};

export default authService;