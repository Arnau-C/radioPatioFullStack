import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Navbar from './components/Navbar';

// src/App.jsx
function App() {
  return (
    <div style={{ 
      display: 'flex', 
      flexDirection: 'column', 
      alignItems: 'center', 
      justifyContent: 'center', 
      height: '100vh',
      fontFamily: 'sans-serif' 
    }}>
      <h1 style={{ color: '#2563eb' }}>📡 ¡Radio Patio Web está viva!</h1>
      <p>Si ves esto, tu configuración de Node y React es correcta.</p>
      <div style={{ marginTop: '20px', padding: '10px', border: '1px solid #ddd', borderRadius: '8px' }}>
        <p>Próximo paso: Conectar con el backend en <b>localhost:8080</b></p>
      </div>
    </div>
  );
}

export default App;