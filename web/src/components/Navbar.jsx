import { Link, useNavigate } from 'react-router-dom';
import logo from '../assets/logo.png';

const Navbar = () => {
  const navigate = useNavigate();
  const user = JSON.parse(localStorage.getItem('user'));

  const handleLogout = () => {
    localStorage.removeItem('user');
    navigate('/login');
  };

  return (
    <nav className="bg-white border-b border-orange-100 py-4 px-6 flex justify-between items-center sticky top-0 z-50 shadow-sm">
      <Link to="/" className="flex items-center gap-2">
        <img src={logo} alt="Logo" className="h-10 w-auto" />
        <span className="text-xl font-black text-orange-700 tracking-tighter">Radio Patio</span>
      </Link>

      <div className="flex items-center gap-4 md:gap-6">
        {user ? (
          <>
            {/* Estos enlaces SOLO se ven si el usuario ha iniciado sesión */}
            <Link to="/ayuda" className="text-gray-400 text-sm font-medium hover:text-orange-600 transition">
              Ayuda
            </Link>
            
            <Link to="/comunidad" className="text-gray-600 font-bold hover:text-orange-600 transition">
    Tu comunidad
    </Link>

            <button 
              onClick={handleLogout}
              className="bg-orange-100 text-orange-700 px-4 py-2 rounded-xl text-sm font-bold hover:bg-orange-200 transition"
            >
              Salir
            </button>
          </>
        ) : (
          <>
            {/* Si NO hay usuario, solo mostramos acceso y registro */}
            <Link to="/login" className="text-gray-600 font-bold hover:text-orange-600 transition">
              Entrar
            </Link>
            <Link 
              to="/registro" 
              className="bg-orange-600 text-white px-5 py-2 rounded-xl font-bold hover:bg-orange-700 transition shadow-md"
            >
              Registro
            </Link>
          </>
        )}
      </div>
    </nav>
  );
};

export default Navbar;