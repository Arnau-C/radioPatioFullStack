import { useState, useEffect, useRef } from 'react';
import foroService from '../services/foroService';

const ForoPage = () => {
  const user = JSON.parse(localStorage.getItem('user'));
  const [mensajes, setMensajes] = useState([]);
  const [nuevoMensaje, setNuevoMensaje] = useState('');
  const [respondiendoA, setRespondiendoA] = useState(null); 
  const scrollRef = useRef(null);
  const FORO_ID = 1;

  const isAdmin = user?.rol === 'SUPER_ADMIN';

  // 1. CARGA DE MENSAJES
  const cargarMensajes = async () => {
    try {
      const data = await foroService.getMensajes(FORO_ID);
      setMensajes(data);
    } catch (e) { 
      console.error("Error al cargar mensajes"); 
    }
  };

  useEffect(() => {
    cargarMensajes();
    const interval = setInterval(cargarMensajes, 15000);
    return () => clearInterval(interval);
  }, []);

  // 2. AUTO-SCROLL AL FINAL
  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [mensajes]);

  // 3. FUNCIONES DE ADMINISTRACIÓN
  const handleEliminar = async (id) => {
    if (window.confirm("¿Eliminar este mensaje?")) {
      try {
        await foroService.eliminarMensaje(id);
        cargarMensajes();
      } catch (e) { alert("Error al eliminar"); }
    }
  };

  const handleDestacar = async (id) => {
    try {
      await foroService.toggleDestacado(id);
      cargarMensajes();
    } catch (e) { alert("Error al destacar"); }
  };

  // 4. NAVEGACIÓN
  const irAlMensajeOriginal = (targetId) => {
    const elemento = document.getElementById(`msg-${targetId}`);
    if (elemento) {
      elemento.scrollIntoView({ behavior: 'smooth', block: 'center' });
      elemento.classList.add('resaltar-mensaje');
      setTimeout(() => {
        elemento.classList.remove('resaltar-mensaje');
      }, 2000);
    }
  };

  // 5. ENVÍO
  const handleEnviar = async (e) => {
    e.preventDefault();
    if (!nuevoMensaje.trim()) return;
    try {
      await foroService.enviarMensaje(FORO_ID, user.username, nuevoMensaje, respondiendoA?.id);
      setNuevoMensaje('');
      setRespondiendoA(null); 
      cargarMensajes();
    } catch (e) { 
      alert("Error al enviar"); 
    }
  };

  const destacados = mensajes.filter(m => m.destacado);

  return (
    <div className="min-h-screen bg-orange-50 pb-20">
      
      {/* SECCIÓN 1: PROYECTO */}
      <section className="max-w-6xl mx-auto pt-16 px-6 mb-16 text-center">
        <h1 className="text-5xl font-black text-orange-700 mb-6">Nuestro proyecto</h1>
        <div className="bg-white p-10 rounded-3xl shadow-xl border border-orange-100 text-left">
          <p className="text-gray-600 text-lg leading-relaxed italic">
            Radio Patio es un proyecto el cual nace de la necesidad de tener comunidades de vecinos mucho mas comunicadas...
            <br /><br />
            En definitiva, queremos que Radio Patio sea la herramienta definitiva para transformar la gestión de comunidades vecinales.
          </p>
        </div>
      </section>

      {/* SECCIÓN 2: FORO */}
      <section className="max-w-4xl mx-auto px-6 mb-24">
        <div className="bg-white rounded-3xl shadow-2xl border border-orange-100 overflow-hidden flex flex-col h-[600px] relative font-sans">
          
          <div className="bg-orange-600 p-5 text-white flex justify-between items-center shadow-lg z-10">
            <div>
              <h3 className="text-lg font-black tracking-tight">Buzón de Sugerencias</h3>
              <p className="text-[10px] text-orange-100 font-medium uppercase tracking-widest">Feedback Directo</p>
            </div>
            {/* Icono Minimalista de Chat */}
            <svg className="w-6 h-6 opacity-80" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M8 10h.01M12 10h.01M16 10h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
            </svg>
          </div>

          {/* LISTA DE MENSAJES */}
          <div ref={scrollRef} className="flex-1 overflow-y-auto p-6 space-y-6 bg-slate-50/30">
            {mensajes.map((msg) => {
              const msgIsAdmin = msg.autorUsername === 'superadmin';
              const esMio = msg.autorUsername === user.username;
              
              return (
                <div key={msg.id} id={`msg-${msg.id}`} onClick={() => isAdmin && setRespondiendoA(msg)} className={`flex flex-col group transition-all duration-500 ${msgIsAdmin ? 'items-center px-10' : (esMio ? 'items-end' : 'items-start')}`}>
                  <div className={`p-4 rounded-2xl shadow-sm relative transition-all active:scale-[0.98] cursor-pointer ${
                    msgIsAdmin ? 'bg-blue-50 border border-blue-100 text-blue-900 w-full text-center' : (esMio ? 'bg-orange-600 text-white' : 'bg-white text-gray-800 border border-slate-100')
                  }`}>
                    
                    {/* BOTONES ADMIN MINIMALISTAS Y PEQUEÑOS */}
                    {isAdmin && (
                      <div className="absolute -right-1 -top-1 flex gap-1 opacity-0 group-hover:opacity-100 transition-all z-20">
                        <button 
                          onClick={(e) => { e.stopPropagation(); handleDestacar(msg.id); }}
                          className={`p-1.5 rounded-lg shadow-sm border transition-colors ${msg.destacado ? 'bg-yellow-400 border-yellow-500 text-white' : 'bg-white border-slate-200 text-slate-400 hover:text-yellow-500'}`}
                        >
                          <svg className="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" /></svg>
                        </button>
                        <button 
                          onClick={(e) => { e.stopPropagation(); handleEliminar(msg.id); }}
                          className="p-1.5 bg-white border border-slate-200 rounded-lg shadow-sm text-slate-400 hover:text-red-500 transition-colors"
                        >
                          <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg>
                        </button>
                      </div>
                    )}

                    {/* CITA */}
                    {msg.respuestaAId && (
                      <div onClick={(e) => { e.stopPropagation(); irAlMensajeOriginal(msg.respuestaAId); }} className={`text-[10px] p-2 rounded-xl mb-3 border-l-2 italic flex flex-col text-left hover:opacity-80 transition-all ${msgIsAdmin ? 'bg-blue-100/50 border-blue-400' : 'bg-black/5 border-orange-300'}`}>
                        <span className="font-bold opacity-60 flex justify-between">
                          Ref: {msg.respuestaAAutor}
                          <span className="text-[8px] uppercase font-black text-orange-600">Volver ↑</span>
                        </span>
                        <span className="truncate opacity-80">"{msg.respuestaAContenido}"</span>
                      </div>
                    )}

                    {msgIsAdmin && (
                      <span className="absolute -top-2.5 left-1/2 -translate-x-1/2 bg-blue-600 text-white text-[8px] px-2 py-0.5 rounded-full font-black uppercase tracking-widest">Oficial</span>
                    )}
                    
                    <p className="text-[9px] font-bold uppercase mb-1 tracking-wider opacity-50">{msgIsAdmin ? 'Radio Patio Team' : msg.autorNombre}</p>
                    <p className="text-sm font-medium leading-relaxed">{msg.contenido}</p>
                  </div>
                  <span className="text-[8px] text-slate-400 mt-1.5 px-2 font-bold uppercase tracking-tighter">
                    {new Date(msg.fechaEnvio).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                  </span>
                </div>
              );
            })}
          </div>

          {/* BARRA DE RESPUESTA */}
          {respondiendoA && (
            <div className="bg-blue-50 border-t border-blue-100 p-2.5 px-6 flex justify-between items-center animate-in slide-in-from-bottom-1">
              <div className="text-[10px] text-blue-700 font-medium">
                Respondiendo a <span className="font-black underline">{respondiendoA.autorNombre}</span>
              </div>
              <button onClick={() => setRespondiendoA(null)} className="text-blue-400 hover:text-blue-600 p-1">
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" /></svg>
              </button>
            </div>
          )}

          {/* INPUT */}
          <form onSubmit={handleEnviar} className="p-4 bg-white border-t border-slate-100 flex gap-3">
            <input type="text" value={nuevoMensaje} onChange={(e) => setNuevoMensaje(e.target.value)} placeholder={isAdmin ? "Responder como administrador..." : "¿Qué mejorarías?"} className="flex-1 p-3.5 bg-slate-50 border border-slate-100 rounded-2xl outline-none focus:ring-2 focus:ring-orange-500/20 text-sm transition-all" />
            <button type="submit" className="bg-orange-600 text-white px-7 rounded-2xl font-black text-xs uppercase tracking-widest hover:bg-orange-700 transition shadow-md active:scale-95">Enviar</button>
          </form>
        </div>
      </section>

      {/* SECCIÓN 3: DESTACADOS (FAQ DINÁMICA) */}
      <section className="max-w-6xl mx-auto px-6 mt-10">
        <div className="text-center mb-14">
          <h2 className="text-3xl font-black text-slate-800">Dudas Resueltas</h2>
          <div className="h-1 w-12 bg-orange-500 mx-auto mt-3 rounded-full"></div>
        </div>

        {destacados.length === 0 ? (
          <div className="text-center p-16 bg-white rounded-[2rem] border border-dashed border-slate-200 text-slate-400 text-sm font-medium italic">
            Las dudas destacadas por el equipo aparecerán aquí.
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-10">
            {destacados.map(d => (
              <div key={d.id} className="bg-white p-8 rounded-[2.5rem] border border-slate-100 shadow-xl shadow-orange-900/5 hover:shadow-2xl hover:-translate-y-1 transition-all relative flex flex-col justify-between group">
                <div>
                  <div className="mb-6">
                    <span className="text-[9px] font-black text-orange-500 uppercase tracking-widest">Pregunta de {d.respuestaAAutor || d.autorNombre}</span>
                    <p className="text-slate-800 font-bold mt-2 text-base leading-tight italic">
                      {d.respuestaAContenido ? `"${d.respuestaAContenido}"` : "Consulta general"}
                    </p>
                  </div>
                  <div className="bg-blue-50/40 p-5 rounded-3xl border border-blue-50">
                    <span className="text-[8px] font-black text-blue-500 uppercase tracking-widest">Respuesta Radio Patio</span>
                    <p className="text-blue-900 text-sm mt-2 leading-relaxed font-medium">"{d.contenido}"</p>
                  </div>
                </div>
                <div className="mt-8 pt-5 border-t border-slate-50 flex justify-between items-center">
                   <span className="text-[9px] text-slate-300 font-bold uppercase">{new Date(d.fechaEnvio).toLocaleDateString()}</span>
                   <button onClick={() => irAlMensajeOriginal(d.id)} className="text-orange-600 text-[9px] font-black hover:underline uppercase tracking-widest">Ver en chat</button>
                </div>
              </div>
            ))}
          </div>
        )}
      </section>
    </div>
  );
};

export default ForoPage;