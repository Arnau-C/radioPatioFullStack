// web/src/pages/PerfilPage.jsx
import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import authService from '../services/authService';

const PerfilPage = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [user, setUser] = useState(null);
  
  const [formData, setFormData] = useState({
    nombre: '',
    apellidos: '',
    email: ''
  });

  useEffect(() => {
    const storedUser = localStorage.getItem('user');
    if (!storedUser) {
      navigate('/login');
      return;
    }
    
    const parsedUser = JSON.parse(storedUser);
    setUser(parsedUser);
    setFormData({
      nombre: parsedUser.nombre || '',
      apellidos: parsedUser.apellidos || '',
      email: parsedUser.email || ''
    });
    setLoading(false);
  }, [navigate]);

  const handleUpdate = async (e) => {
    e.preventDefault();
    try {
      await authService.updateProfile(user.username, formData);
      alert("¡Perfil actualizado con éxito!");
      navigate('/comunidad');
    } catch (err) {
      console.error(err);
      alert("Error al actualizar los datos");
    }
  };

  // Mientras carga los datos del localStorage, no renderizamos nada para evitar errores
  if (loading) return null;

  return (
    <div className="min-h-screen bg-orange-50 flex items-center justify-center p-6">
      <div className="max-w-md w-full bg-white p-10 rounded-[3rem] shadow-2xl border border-orange-100 animate-in fade-in zoom-in duration-300">
        <header className="mb-8">
          <h2 className="text-3xl font-black text-slate-800">Tu Perfil</h2>
          <p className="text-slate-400 text-xs font-bold uppercase tracking-widest mt-1">Gestiona tus datos personales</p>
        </header>

        <form onSubmit={handleUpdate} className="space-y-5">
          <div>
            <label className="block text-[10px] font-black uppercase text-slate-400 mb-2 ml-1">Nombre</label>
            <input 
              type="text" 
              className="w-full p-4 bg-slate-50 border border-slate-100 rounded-2xl outline-none focus:ring-2 focus:ring-orange-500/20 text-sm font-medium transition-all"
              value={formData.nombre} 
              onChange={(e) => setFormData({...formData, nombre: e.target.value})} 
              required
            />
          </div>

          <div>
            <label className="block text-[10px] font-black uppercase text-slate-400 mb-2 ml-1">Apellidos</label>
            <input 
              type="text" 
              className="w-full p-4 bg-slate-50 border border-slate-100 rounded-2xl outline-none focus:ring-2 focus:ring-orange-500/20 text-sm font-medium transition-all"
              value={formData.apellidos} 
              onChange={(e) => setFormData({...formData, apellidos: e.target.value})} 
              required
            />
          </div>

          <div>
            <label className="block text-[10px] font-black uppercase text-slate-400 mb-2 ml-1">Correo Electrónico</label>
            <input 
              type="email" 
              className="w-full p-4 bg-slate-50 border border-slate-100 rounded-2xl outline-none focus:ring-2 focus:ring-orange-500/20 text-sm font-medium transition-all"
              value={formData.email} 
              onChange={(e) => setFormData({...formData, email: e.target.value})} 
              required
            />
          </div>

          <div className="flex gap-4 pt-4">
            <button 
              type="button" 
              onClick={() => navigate('/comunidad')}
              className="flex-1 py-4 text-slate-400 font-black uppercase text-[10px] tracking-widest hover:text-slate-600 transition-colors"
            >
              Cancelar
            </button>
            <button 
              type="submit" 
              className="flex-[2] bg-orange-600 text-white py-4 rounded-2xl font-black uppercase tracking-widest text-[10px] hover:bg-orange-700 transition shadow-lg shadow-orange-200 active:scale-95"
            >
              Guardar Cambios
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default PerfilPage;