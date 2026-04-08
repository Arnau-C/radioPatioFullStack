import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Navbar from './components/Navbar';
import LandingPage from './pages/LandingPage';
import LoginPage from './pages/LoginPage';
import RegisterPage from './pages/RegisterPage';
import ForoPage from './pages/ForoPage'; // Este es el que ahora llamaremos "Ayuda"
import ComunidadPage from './pages/ComunidadPage';
import PerfilPage from './pages/PerfilPage';
import ChatComunidadPage from './pages/ChatComunidadPage';

function App() {
  return (
    <Router>
      <Navbar />
      <Routes>
        <Route path="/" element={<LandingPage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/registro" element={<RegisterPage />} />
        <Route path="/comunidad" element={<ComunidadPage />} />
        <Route path="/perfil" element={<PerfilPage />} />
<Route path="/comunidad/foro" element={<ChatComunidadPage />} />
        {/* Cambiamos la ruta de la página de sugerencias/info a /ayuda */}
        <Route path="/ayuda" element={<ForoPage />} />
        {/* Dejamos /foro libre para la futura sección de comunidad propia */}
        <Route path="/foro" element={<div className="p-20 text-center font-bold">Próximamente: Panel de tu Comunidad</div>} />
      </Routes>
    </Router>
  );
}

export default App;