import { Link } from 'react-router-dom';
import logo from '../assets/logoirem.png'; //

const Navbar = () => {
  return (
    /* bg-orange-50/90: Fondo naranja muy clarito con un toque de transparencia.
       backdrop-blur-md: Efecto cristal empañado al hacer scroll.
       border-orange-100: Borde sutil a juego.
    */
    <nav className="bg-orange-50/90 backdrop-blur-md border-b border-orange-100 px-8 py-2 flex justify-between items-center sticky top-0 z-50">
      
      {/* SECCIÓN DEL LOGO: He aumentado el tamaño considerablemente */}
      <Link to="/" className="flex items-center gap-4 group">
        <img 
          src={logo} 
          alt="Radio Patio Logo" 
          /* h-20: Lo hace el doble de grande que antes. 
             hover:scale-110: Un pequeño efecto al pasar el ratón.
          */
          className="h-20 w-auto transition-transform duration-300 group-hover:scale-110" 
        />
        {/* Nombre del proyecto en naranja fuerte para que resalte */}
        <span className="text-3xl font-black text-orange-700 tracking-tighter">
          Radio Patio
        </span>
      </Link>
      
      {/* BOTONES DE NAVEGACIÓN */}
      <div className="flex items-center gap-6">
        <Link 
          to="/login" 
          className="text-lg font-bold text-orange-800 hover:text-orange-600 transition-colors"
        >
          Iniciar Sesión
        </Link>
        
        <Link 
          to="/registro" 
          /* bg-orange-600: Botón llamativo que combina con el Hero.
             rounded-2xl: Bordes redondeados modernos.
          */
          className="px-6 py-3 bg-orange-600 text-white font-extrabold rounded-2xl hover:bg-orange-700 transition shadow-md hover:shadow-orange-200"
        >
          Registrarse
        </Link>
      </div>
    </nav>
  );
};

export default Navbar;