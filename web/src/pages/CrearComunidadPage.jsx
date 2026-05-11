import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import comunidadService from '../services/comunidadService';

const CrearComunidadPage = () => {
  const navigate = useNavigate();
  const user = JSON.parse(localStorage.getItem('user'));
  
  const [formData, setFormData] = useState({
    nombre: '',
    direccion: ''
  });
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      const res = await comunidadService.crearComunidad(formData.nombre, formData.direccion, user.username);
      
      const updatedUser = { 
          ...user, 
          rol: 'PRESIDENTE',
          foroId: res.foroId 
      };
      localStorage.setItem('user', JSON.stringify(updatedUser));

      alert("¡Comunidad creada con éxito! Ahora eres el Presidente.");
      navigate('/comunidad');
    } catch (error) {
      alert(error.response?.data || "Error al crear la comunidad");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-orange-50 flex items-center justify-center p-6">
      <div className="max-w-md w-full bg-white p-10 rounded-[3rem] shadow-2xl border border-orange-100 animate-in fade-in zoom-in duration-300">
        <header className="mb-8 text-center">
          <div className="bg-orange-600 w-16 h-16 rounded-2xl flex items-center justify-center text-white mx-auto mb-4 shadow-lg shadow-orange-200">
             <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" /></svg>
          </div>
          <h2 className="text-3xl font-black text-slate-800">Nueva Comunidad</h2>
          <p className="text-slate-400 text-xs font-bold uppercase tracking-widest mt-1">Registra tu edificio en Radio Patio</p>
        </header>

        <form onSubmit={handleSubmit} className="space-y-5">
          <div>
            <label className="block text-[10px] font-black uppercase text-slate-400 mb-2 ml-1">Nombre del Edificio / Comunidad</label>
            <input 
              type="text" 
              placeholder="Ej: Residencial Las Flores"
              className="w-full p-4 bg-slate-50 border border-slate-100 rounded-2xl outline-none focus:ring-2 focus:ring-orange-500/20 text-sm font-medium transition-all"
              value={formData.nombre} 
              onChange={(e) => setFormData({...formData, nombre: e.target.value})} 
              required
            />
          </div>

          <div>
            <label className="block text-[10px] font-black uppercase text-slate-400 mb-2 ml-1">Dirección Completa</label>
            <input 
              type="text" 
              placeholder="Ej: Calle Mayor 12, Gavà"
              className="w-full p-4 bg-slate-50 border border-slate-100 rounded-2xl outline-none focus:ring-2 focus:ring-orange-500/20 text-sm font-medium transition-all"
              value={formData.direccion} 
              onChange={(e) => setFormData({...formData, direccion: e.target.value})} 
              required
            />
          </div>

          <div className="pt-4 space-y-3">
            <button 
              type="submit" 
              disabled={loading}
              className="w-full bg-orange-600 text-white py-4 rounded-2xl font-black uppercase tracking-widest text-xs hover:bg-orange-700 transition shadow-lg shadow-orange-200 active:scale-95 disabled:opacity-50"
            >
              {loading ? "Creando..." : "Confirmar y Crear"}
            </button>
            <button 
              type="button" 
              onClick={() => navigate('/comunidad')}
              className="w-full py-4 text-slate-400 font-bold uppercase tracking-widest text-[10px] hover:text-slate-600 transition-colors"
            >
              Cancelar
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default CrearComunidadPage;