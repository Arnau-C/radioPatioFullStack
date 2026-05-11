// web/src/pages/RegisterPage.jsx
import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import authService from '../services/authService';
import logo from '../assets/logo.png';

const RegisterPage = () => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    nombre: '', apellidos: '', email: '', username: '', password: '', confirmPassword: ''
  });
  const [error, setError] = useState('');

  // Misma validación que vuestro archivo validators.dart
  const validatePassword = (pass) => {
    const regex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
    return regex.test(pass);
  };

  const handleRegister = async (e) => {
    e.preventDefault();
    setError('');

    if (formData.password !== formData.confirmPassword) {
      return setError('Las contraseñas no coinciden');
    }
    if (!validatePassword(formData.password)) {
      return setError('La contraseña debe tener min. 8 caracteres, una mayúscula, un número y un símbolo');
    }

    try {
      await authService.register(formData);
      alert('¡Registro completado! Ahora puedes iniciar sesión.');
      navigate('/login');
    } catch (err) {
      setError(typeof err === 'string' ? err : 'Error al crear la cuenta');
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-orange-50 py-12 px-4">
      <div className="bg-white p-10 rounded-3xl shadow-2xl w-full max-w-2xl border border-orange-100">
        
        <div className="text-center mb-10">
          <img src={logo} alt="Radio Patio" className="h-20 w-auto mx-auto mb-4" />
          <h2 className="text-3xl font-black text-orange-700">Crear Cuenta</h2>
        </div>

        {error && <div className="bg-red-50 text-red-600 p-4 rounded-2xl text-sm mb-6 text-center font-bold border border-red-100">{error}</div>}

        <form onSubmit={handleRegister} className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <input 
            type="text" placeholder="Nombre" 
            className="p-4 bg-orange-50/20 border border-orange-100 rounded-2xl outline-none focus:ring-2 focus:ring-orange-500 transition-all"
            onChange={(e) => setFormData({...formData, nombre: e.target.value})} required
          />
          <input 
            type="text" placeholder="Apellidos" 
            className="p-4 bg-orange-50/20 border border-orange-100 rounded-2xl outline-none focus:ring-2 focus:ring-orange-500 transition-all"
            onChange={(e) => setFormData({...formData, apellidos: e.target.value})} required
          />
          <input 
            type="email" placeholder="Correo electrónico" 
            className="md:col-span-2 p-4 bg-orange-50/20 border border-orange-100 rounded-2xl outline-none focus:ring-2 focus:ring-orange-500 transition-all"
            onChange={(e) => setFormData({...formData, email: e.target.value})} required
          />
          <input 
            type="text" placeholder="Usuario para la app" 
            className="md:col-span-2 p-4 bg-orange-50/20 border border-orange-100 rounded-2xl outline-none focus:ring-2 focus:ring-orange-500 transition-all"
            onChange={(e) => setFormData({...formData, username: e.target.value})} required
          />
          <input 
            type="password" placeholder="Contraseña" 
            className="p-4 bg-orange-50/20 border border-orange-100 rounded-2xl outline-none focus:ring-2 focus:ring-orange-500 transition-all"
            onChange={(e) => setFormData({...formData, password: e.target.value})} required
          />
          <input 
            type="password" placeholder="Confirmar contraseña" 
            className="p-4 bg-orange-50/20 border border-orange-100 rounded-2xl outline-none focus:ring-2 focus:ring-orange-500 transition-all"
            onChange={(e) => setFormData({...formData, confirmPassword: e.target.value})} required
          />

          <button className="md:col-span-2 bg-orange-600 text-white p-4 rounded-2xl font-bold text-lg hover:bg-orange-700 transition-all shadow-lg active:scale-95 mt-4">
            Registrarme ahora
          </button>
        </form>

        <div className="mt-8 text-center">
          <p className="text-gray-500">¿Ya eres de Radio Patio? <Link to="/login" className="text-orange-600 font-bold hover:underline">Entra aquí</Link></p>
        </div>
      </div>
    </div>
  );
};

export default RegisterPage;