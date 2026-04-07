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

  const cargarMensajes = async () => {
    try {
      const data = await foroService.getMensajes(FORO_ID);
      setMensajes(data);
    } catch (e) { console.error("Error al cargar"); }
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
      await foroService.enviarMensaje(FORO_ID, user.username, nuevoMensaje, respondiendoA?.id);
      setNuevoMensaje('');
      setRespondiendoA(null); 
      cargarMensajes();
    } catch (e) { alert("No se pudo enviar el mensaje"); }
  };

  const handleEliminar = async (id) => {
    if (window.confirm("¿Eliminar este mensaje?")) {
      try {
        await foroService.eliminarMensaje(id);
        cargarMensajes();
      } catch (e) { alert("Error al eliminar"); }
    }
  };

  const irAlMensajeOriginal = (targetId) => {
    const elemento = document.getElementById(`msg-${targetId}`);
    if (elemento) {
      elemento.scrollIntoView({ behavior: 'smooth', block: 'center' });
      elemento.classList.add('resaltar-mensaje');
      setTimeout(() => elemento.classList.remove('resaltar-mensaje'), 2000);
    }
  };

  return (
    <div className="min-h-screen bg-orange-50 pb-20">
      
      <section className="max-w-6xl mx-auto pt-16 px-6 mb-16 text-center">
        <h1 className="text-5xl font-black text-orange-700 mb-6">Ayudanos a mejorar</h1>
        <div className="bg-white p-10 rounded-3xl shadow-xl border border-orange-100 text-left">
          <p className="text-gray-600 text-lg leading-relaxed italic">
            Nuestro objetivo con todo esto es poder hacer una aplicación que ayude realmente a los usuarios, por eso hemos creado este apartado,
            Aqui podreis escribir todos los errores, quejas y mejoras que vayan apareciendo o creeis que necesite la aplicación, nosotros, el euqipo de desarrollo
            de RadioPatio iremos respondiendo y haciendo caso a todo el feedback que nos deis. Tambien iremos poniendo aqui las actualizacioens que vayamos diciendo y 
            las proximas funciones que vendran.
            Como siempre recordar que este es un proyecto en desarrollo, por lo que es normal que haya errores y funciones sin terminar, pero con vuestra ayuda queremos hacer la mejor aplicación de gestión de comunidades posible.
          </p>
        </div>
      </section>
      <section className="max-w-6xl mx-auto px-6 mb-20">
  <div className="text-center mb-10">
    <h2 className="text-2xl font-black text-gray-800 uppercase tracking-tighter">Próximas funcionalidades</h2>
    <p className="text-orange-600 text-sm font-bold">En lo que estamos trabajando actualmente</p>
  </div>
  
  <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
    <div className="bg-white p-6 rounded-2xl border border-orange-100 shadow-sm hover:shadow-md transition-shadow">
      <div className="bg-orange-100 w-10 h-10 rounded-lg flex items-center justify-center mb-4 text-orange-600 font-bold">01</div>
      <h3 className="font-bold text-gray-800 mb-2 text-sm uppercase">Implementación de reservas personalizabls</h3>
      <p className="text-xs text-gray-500 leading-relaxed italic">Poder implementar reservas personalizadas para cada comunidad, y seguirlas a traves del calendario</p>
    </div>

    <div className="bg-white p-6 rounded-2xl border border-orange-100 shadow-sm hover:shadow-md transition-shadow">
      <div className="bg-orange-100 w-10 h-10 rounded-lg flex items-center justify-center mb-4 text-orange-600 font-bold">02</div>
      <h3 className="font-bold text-gray-800 mb-2 text-sm uppercase">Sistema de Roles</h3>
      <p className="text-xs text-gray-500 leading-relaxed italic">Poder dar permisos específicos a diferentes usuarios dentro de la comunidad.</p>
    </div>

    <div className="bg-white p-6 rounded-2xl border border-orange-100 shadow-sm hover:shadow-md transition-shadow">
      <div className="bg-orange-100 w-10 h-10 rounded-lg flex items-center justify-center mb-4 text-orange-600 font-bold">03</div>
      <h3 className="font-bold text-gray-800 mb-2 text-sm uppercase">Votaciónes</h3>
      <p className="text-xs text-gray-500 leading-relaxed italic">Sistema para realizar votaciones dentro de la comunidad.</p>
    </div>
  </div>
</section>

      <section className="max-w-4xl mx-auto px-6 mb-24">
        <div className="bg-white rounded-3xl shadow-2xl border border-orange-100 overflow-hidden flex flex-col h-[600px] relative">
          
          <div className="bg-orange-600 p-5 text-white flex justify-between items-center shadow-lg z-10">
            <div>
              <h3 className="text-lg font-black tracking-tight">Buzón de Sugerencias</h3>
              <p className="text-[10px] text-orange-100 font-medium uppercase tracking-widest italic">Feedback Directo</p>
            </div>
            <svg className="w-6 h-6 opacity-80" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M8 10h.01M12 10h.01M16 10h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
            </svg>
          </div>

          <div ref={scrollRef} className="flex-1 overflow-y-auto p-6 space-y-6 bg-slate-50/30">
            {mensajes.map((msg) => {
              const msgIsAdmin = msg.autorUsername === 'superadmin';
              const esMio = msg.autorUsername === user.username;
              
              return (
                <div key={msg.id} id={`msg-${msg.id}`} onClick={() => isAdmin && setRespondiendoA(msg)} className={`flex flex-col group transition-all duration-500 ${msgIsAdmin ? 'items-center px-10' : (esMio ? 'items-end' : 'items-start')}`}>
                  <div className={`p-4 rounded-2xl shadow-sm relative transition-all active:scale-[0.98] cursor-pointer ${
                    msgIsAdmin ? 'bg-blue-50 border border-blue-100 text-blue-900 w-full text-center' : (esMio ? 'bg-orange-600 text-white' : 'bg-white text-gray-800 border border-slate-100')
                  }`}>
                    
                    {isAdmin && (
                      <div className="absolute -right-1 -top-1 opacity-0 group-hover:opacity-100 transition-all z-20">
                        <button onClick={(e) => { e.stopPropagation(); handleEliminar(msg.id); }} className="p-1.5 bg-white border border-slate-200 rounded-lg shadow-sm text-slate-400 hover:text-red-500">
                          <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg>
                        </button>
                      </div>
                    )}

                    {msg.respuestaAId && (
                      <div onClick={(e) => { e.stopPropagation(); irAlMensajeOriginal(msg.respuestaAId); }} className={`text-[10px] p-2 rounded-xl mb-3 border-l-2 italic flex flex-col text-left hover:opacity-80 transition-all ${msgIsAdmin ? 'bg-blue-100/50 border-blue-400' : 'bg-black/5 border-orange-300'}`}>
                        <span className="font-bold opacity-60 flex justify-between">
                          Ref: {msg.respuestaAAutor}
                          <span className="text-[8px] uppercase font-black text-orange-600 underline">Volver ↑</span>
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

          <form onSubmit={handleEnviar} className="p-4 bg-white border-t border-slate-100 flex gap-3">
            <input type="text" value={nuevoMensaje} onChange={(e) => setNuevoMensaje(e.target.value)} placeholder={isAdmin ? "Responder como administrador..." : "¿Qué mejorarías?"} className="flex-1 p-3.5 bg-slate-50 border border-slate-100 rounded-2xl outline-none focus:ring-2 focus:ring-orange-500/20 text-sm transition-all" />
            <button type="submit" className="bg-orange-600 text-white px-7 rounded-2xl font-black text-xs uppercase tracking-widest hover:bg-orange-700 transition shadow-md active:scale-95">Enviar</button>
          </form>
        </div>
      </section>
    </div>
  );
};

export default ForoPage;