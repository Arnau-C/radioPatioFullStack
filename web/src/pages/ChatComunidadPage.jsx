import { useState, useEffect, useRef } from 'react';
import foroService from '../services/foroService';

const ChatComunidadPage = () => {
  const user = JSON.parse(localStorage.getItem('user'));
  const [mensajes, setMensajes] = useState([]);
  const [nuevoMensaje, setNuevoMensaje] = useState('');
  const scrollRef = useRef(null);
  
  // PARA PRUEBAS LOCALES: Usa el ID del foro de la comunidad (no el de ayuda que era el 1)
  const FORO_ID = 2; 

  const cargarMensajes = async () => {
    try {
      const data = await foroService.getMensajes(FORO_ID);
      setMensajes(data);
    } catch (e) { console.error("Error"); }
  };

  useEffect(() => {
    cargarMensajes();
    const interval = setInterval(cargarMensajes, 10000);
    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    if (scrollRef.current) scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
  }, [mensajes]);

  const handleEnviar = async (e) => {
    e.preventDefault();
    if (!nuevoMensaje.trim()) return;
    try {
      await foroService.enviarMensaje(FORO_ID, user.username, nuevoMensaje);
      setNuevoMensaje('');
      cargarMensajes();
    } catch (e) { alert("Error al enviar"); }
  };

  return (
    <div className="min-h-screen bg-slate-50 py-10 px-6">
      <div className="max-w-4xl mx-auto">
        <button 
          onClick={() => window.history.back()}
          className="mb-6 flex items-center text-slate-400 hover:text-orange-600 font-bold text-xs uppercase tracking-widest transition-colors"
        >
          ← Volver al Panel
        </button>

        <div className="bg-white rounded-[2rem] shadow-2xl overflow-hidden border border-slate-100 flex flex-col h-[700px]">
          <div className="bg-slate-800 p-6 text-white flex justify-between items-center">
            <div>
              <h2 className="text-xl font-black">Foro de Vecinos</h2>
              <p className="text-[10px] text-slate-400 uppercase font-bold tracking-tighter">Comunicación interna de la comunidad</p>
            </div>
            <div className="bg-orange-500 p-2 rounded-xl text-white shadow-lg">
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" /></svg>
            </div>
          </div>

          <div ref={scrollRef} className="flex-1 overflow-y-auto p-6 space-y-4 bg-slate-50/50">
            {mensajes.map((msg) => (
              <div key={msg.id} className={`flex flex-col ${msg.autorUsername === user.username ? 'items-end' : 'items-start'}`}>
                <div className={`max-w-[80%] p-4 rounded-2xl shadow-sm ${msg.autorUsername === user.username ? 'bg-orange-600 text-white' : 'bg-white text-slate-800 border border-slate-100'}`}>
                  <p className="text-[10px] font-black uppercase opacity-60 mb-1">{msg.autorNombre}</p>
                  <p className="text-sm font-medium">{msg.contenido}</p>
                </div>
                <span className="text-[9px] text-slate-400 mt-1 px-2 font-bold">{new Date(msg.fechaEnvio).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})}</span>
              </div>
            ))}
          </div>

          <form onSubmit={handleEnviar} className="p-6 bg-white border-t border-slate-100 flex gap-4">
            <input 
              type="text" 
              value={nuevoMensaje}
              onChange={(e) => setNuevoMensaje(e.target.value)}
              placeholder="Escribe un mensaje a la comunidad..."
              className="flex-1 p-4 bg-slate-50 border border-slate-100 rounded-2xl outline-none focus:ring-2 focus:ring-orange-500/20 text-sm transition-all"
            />
            <button type="submit" className="bg-orange-600 text-white px-8 rounded-2xl font-black text-xs uppercase hover:bg-orange-700 transition shadow-lg active:scale-95">Enviar</button>
          </form>
        </div>
      </div>
    </div>
  );
};

export default ChatComunidadPage;