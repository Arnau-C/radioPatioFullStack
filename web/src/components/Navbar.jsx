import { Link } from 'react-router-dom';
import logo from '../assets/logo.png';

const Navbar = () => {
  return (
    <nav className="bg-white border-b border-gray-100 px-8 py-4 flex justify-between items-center sticky top-0 z-50">
      <Link to="/" className="flex items-center gap-3">
        <img src={logo} alt="Radio Patio Logo" className="h-10 w-auto" />
        <span className="text-2xl font-extrabold text-blue-700 tracking-tight">Radio Patio</span>
      </Link>
      
      <div className="flex gap-4">
        <Link to="/login" className="px-5 py-2 font-semibold text-gray-700 hover:text-blue-600 transition">
          Iniciar Sesión
        </Link>
        <Link to="/registro" className="px-5 py-2 bg-blue-600 text-white font-semibold rounded-full hover:bg-blue-700 transition shadow-md">
          Registrarse
        </Link>
      </div>
    </nav>
  );
};

export default Navbar;