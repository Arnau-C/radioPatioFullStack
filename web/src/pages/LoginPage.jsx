import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import authService from '../services/authService';
import logo from '../assets/logo.png'; //

const LoginPage = () => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleLogin = async (e) => {
    e.preventDefault();
    setError(''); // Limpiamos errores anteriores
    try {
      /* Conectamos con el AuthController de Java. 
         El servicio ya incluye 'sistema: WEB' en la petición. 
      */
      await authService.login(username, password);
      navigate('/foro'); 
    } catch (err) {
      setError("Usuario o contraseña incorrectos");
    }
  };

  return (
    /* bg-orange-50: El mismo fondo que la Landing Page para dar continuidad visual */
    <div className="min-h-screen flex items-center justify-center bg-orange-50 px-4">
      
      {/* Tarjeta del formulario con bordes muy redondeados y sombra suave */}
      <div className="bg-white p-10 rounded-3xl shadow-2xl w-full max-w-md border border-orange-100">
        
        {/* ENCABEZADO: Logo y Título */}
        <div className="text-center mb-8">
          <img src={logo} alt="Logo" className="h-20 w-auto mx-auto mb-4" />
          <h2 className="text-3xl font-black text-orange-700">Acceder</h2>
          <p className="text-gray-500 text-sm mt-1">Tu comunidad te espera</p>
        </div>

        {/* Alerta de error (solo si falla el login) */}
        {error && (
          <div className="bg-red-50 text-red-600 p-3 rounded-xl text-sm mb-6 text-center font-medium border border-red-100">
            {error}
          </div>
        )}

        <form onSubmit={handleLogin} className="space-y-5">
          {/* Campo Usuario */}
          <div>
            <label className="block text-sm font-bold text-gray-700 mb-2 ml-1">Usuario</label>
            <input 
              type="text" 
              placeholder="Nombre de usuario" 
              className="w-full p-4 bg-orange-50/30 border border-orange-100 rounded-2xl outline-none focus:ring-2 focus:ring-orange-500 transition-all"
              onChange={(e) => setUsername(e.target.value)}
              required
            />
          </div>

          {/* Campo Contraseña */}
          <div>
            <label className="block text-sm font-bold text-gray-700 mb-2 ml-1">Contraseña</label>
            <input 
              type="password" 
              placeholder="••••••••" 
              className="w-full p-4 bg-orange-50/30 border border-orange-100 rounded-2xl outline-none focus:ring-2 focus:ring-orange-500 transition-all"
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>

          {/* BOTÓN: Naranja Radio Patio con efecto de click activo */}
          <button 
            type="submit" 
            className="w-full bg-orange-600 text-white p-4 rounded-2xl font-bold text-lg hover:bg-orange-700 transition-all shadow-lg active:scale-95"
          >
            Entrar
          </button>
        </form>

        {/* PIE DE PÁGINA: Enlaces de ayuda */}
        <div className="mt-8 text-center space-y-4">
          <p className="text-gray-500 text-sm">
            ¿Eres nuevo? {' '}
            <Link to="/registro" className="text-orange-600 font-bold hover:underline">
              Crea tu cuenta
            </Link>
          </p>
          <Link to="/" className="inline-block text-xs text-gray-400 hover:text-orange-500 transition-colors">
            ← Volver al inicio
          </Link>
        </div>
      </div>
    </div>
  );
};

export default LoginPage;