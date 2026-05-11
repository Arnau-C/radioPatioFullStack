import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import comunidadService from '../services/comunidadService';

const UnirseComunidadPage = () => {
  const navigate = useNavigate();
  const [codigo, setCodigo] = useState('');
  const [loading, setLoading] = useState(false);
  const user = JSON.parse(localStorage.getItem('user'));

  const handleJoin = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      const res = await comunidadService.unirseComunidad(codigo.toUpperCase(), user.username);
      
      const updatedUser = { 
          ...user, 
          rol: 'VECINO',
          foroId: res.foroId 
      };
      localStorage.setItem('user', JSON.stringify(updatedUser));

      alert(`¡Bienvenido! Te has unido a: ${res.comunidadNombre}`);
      navigate('/comunidad');
    } catch (error) {
      alert(error.response?.data?.error || "Código de invitación no válido");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-orange-50 flex items-center justify-center p-6">
      <div className="max-w-md w-full bg-white p-10 rounded-[3rem] shadow-2xl border border-orange-100 animate-in fade-in zoom-in duration-300">
        <header className="mb-8 text-center">
          <div className="bg-slate-800 w-16 h-16 rounded-2xl flex items-center justify-center text-white mx-auto mb-4 shadow-lg">
             <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" /></svg>
          </div>
          <h2 className="text-3xl font-black text-slate-800">Unirse</h2>
          <p className="text-slate-400 text-xs font-bold uppercase tracking-widest mt-1">Introduce el código de tu comunidad</p>
        </header>

        <form onSubmit={handleJoin} className="space-y-6">
          <div>
            <input 
              type="text" 
              placeholder="Ej: GAVA001"
              className="w-full p-5 bg-slate-50 border-2 border-slate-100 rounded-2xl outline-none focus:border-orange-500 text-center text-2xl font-black tracking-widest uppercase transition-all placeholder:text-slate-200"
              value={codigo} 
              onChange={(e) => setCodigo(e.target.value)} 
              required
            />
          </div>

          <div className="space-y-3">
            <button 
              type="submit" 
              disabled={loading}
              className="w-full bg-orange-600 text-white py-4 rounded-2xl font-black uppercase tracking-widest text-xs hover:bg-orange-700 transition shadow-lg active:scale-95 disabled:opacity-50"
            >
              {loading ? "Validando..." : "Unirse ahora"}
            </button>
            <button 
              type="button" 
              onClick={() => navigate('/comunidad')}
              className="w-full py-4 text-slate-400 font-bold uppercase tracking-widest text-[10px] hover:text-slate-600 transition-colors"
            >
              Volver atrás
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default UnirseComunidadPage;