import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Navbar from './components/Navbar';
import LandingPage from './pages/LandingPage';
import LoginPage from './pages/LoginPage';
import RegisterPage from './pages/RegisterPage';
import ForoPage from './pages/ForoPage'; // Este es el que ahora llamaremos "Ayuda"

function App() {
  return (
    <Router>
      <Navbar />
      <Routes>
        <Route path="/" element={<LandingPage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/registro" element={<RegisterPage />} />
        {/* Cambiamos la ruta de la página de sugerencias/info a /ayuda */}
        <Route path="/ayuda" element={<ForoPage />} />
        {/* Dejamos /foro libre para la futura sección de comunidad propia */}
        <Route path="/foro" element={<div className="p-20 text-center font-bold">Próximamente: Panel de tu Comunidad</div>} />
      </Routes>
    </Router>
  );
}

export default App;