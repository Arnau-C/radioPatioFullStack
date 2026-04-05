import axios from 'axios';

const API_URL = 'http://localhost:8080/api/auth';

const authService = {
  login: async (username, password) => {
    try {
      const response = await axios.post(`${API_URL}/login`, {
        username,
        password,
        sistema: 'WEB' // identificacion entrada web
      });
      
      if (response.data.token) {
        localStorage.setItem('user', JSON.stringify(response.data));
      }
      return response.data;
    } catch (error) {
      throw error.response ? error.response.data : new Error('Error de conexión');
    }
  },

  logout: () => {
    localStorage.removeItem('user');
  }
};

export default authService;