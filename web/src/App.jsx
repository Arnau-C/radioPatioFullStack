import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Navbar from './components/Navbar';
import LandingPage from './pages/LandingPage';
import LoginPage from './pages/LoginPage';
import ForoPage from './pages/ForoPage'; // <--- AÑADE ESTO
import RegisterPage from './pages/RegisterPage';

const RegisterPlaceholder = () => <div className="p-20 text-center text-2xl font-bold">Página de Registro en construcción...</div>;

function App() {
  return (
    <Router>
      <Navbar />
      <Routes>
        <Route path="/" element={<LandingPage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/foro" element={<ForoPage />} /> {/* <--- AÑADE ESTO */}
        <Route path="/registro" element={<RegisterPage />} />
      </Routes>
    </Router>
  );
}

export default App;