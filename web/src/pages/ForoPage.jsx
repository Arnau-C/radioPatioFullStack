import { useState, useEffect, useRef } from 'react';
import foroService from '../services/foroService';

const ForoPage = () => {
  const user = JSON.parse(localStorage.getItem('user'));
  const [mensajes, setMensajes] = useState([]);
  const [nuevoMensaje, setNuevoMensaje] = useState('');
  const [respondiendoA, setRespondiendoA] = useState(null); 
  const scrollRef = useRef(null);
  const FORO_ID = 1;

  // Permisos de administrador
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
    if (window.confirm("¿Estás seguro de que quieres eliminar este mensaje?")) {
      try {
        await foroService.eliminarMensaje(id);
        cargarMensajes(); // Recargar lista
      } catch (e) { alert("Error al eliminar"); }
    }
  };

  const handleDestacar = async (id) => {
    try {
      await foroService.toggleDestacado(id);
      cargarMensajes(); // Recargar lista para ver el cambio
    } catch (e) { alert("Error al destacar"); }
  };

  // 4. NAVEGACIÓN ENTRE MENSAJES
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

  // 5. ENVÍO DE MENSAJE
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

  // Filtramos los mensajes que el admin ha marcado como "Destacados"
  const destacados = mensajes.filter(m => m.destacado);

  return (
    <div className="min-h-screen bg-orange-50 pb-20">
      
      {/* SECCIÓN 1: NUESTRO PROYECTO */}
      <section className="max-w-6xl mx-auto pt-16 px-6 mb-16 text-center">
        <h1 className="text-5xl font-black text-orange-700 mb-6">Nuestro proyecto</h1>
        <div className="bg-white p-10 rounded-3xl shadow-xl border border-orange-100 text-left">
          <p className="text-gray-600 text-lg leading-relaxed italic">
            Radio Patio es un proyecto el cual nace de la necesidad de tener comunidades de vecinos mucho mas comunicadas y de forma mucho mas senzilla.
            Con esta aplicacion no solo queremos que los vecinos puedan ver los anuncios y avisos de forma mas senzilla, sino que queremos
            que la gestion economica sea senzilla para el presidente, que las reservas de espacios comunes sean mas faciles y que la comunicacion entre vecinos sea mas fluida y directa.
          </p>
        </div>
      </section>

      {/* SECCIÓN 2: FORO DE SUGERENCIAS */}
      <section className="max-w-4xl mx-auto px-6 mb-24">
        <div className="bg-white rounded-3xl shadow-2xl border border-orange-100 overflow-hidden flex flex-col h-[600px] relative">
          
          <div className="bg-orange-600 p-6 text-white flex justify-between items-center shadow-lg z-10">
            <div>
              <h3 className="text-xl font-black">Buzón de Sugerencias</h3>
              <p className="text-xs text-orange-100 italic">Haz clic en un mensaje para responder (Admin)</p>
            </div>
            <span className="text-2xl animate-bounce">💬</span>
          </div>

          {/* LISTA DE MENSAJES */}
          <div ref={scrollRef} className="flex-1 overflow-y-auto p-6 space-y-6 bg-orange-50/20">
            {mensajes.map((msg) => {
              const msgIsAdmin = msg.autorUsername === 'superadmin';
              const esMio = msg.autorUsername === user.username;
              
              return (
                <div 
                  key={msg.id} 
                  id={`msg-${msg.id}`} 
                  onClick={() => isAdmin && setRespondiendoA(msg)}
                  className={`flex flex-col group transition-all duration-500 ${msgIsAdmin ? 'items-center px-10' : (esMio ? 'items-end' : 'items-start')}`}
                >
                  <div className={`p-4 rounded-2xl shadow-sm relative transition-all active:scale-95 cursor-pointer ${
                    msgIsAdmin 
                      ? 'bg-blue-50 border-2 border-blue-200 text-blue-900 w-full text-center' 
                      : (esMio ? 'bg-orange-600 text-white' : 'bg-white text-gray-800 border border-orange-100')
                  }`}>
                    
                    {/* BOTONES DE GESTIÓN (Solo Admin) */}
                    {isAdmin && (
                      <div className="absolute -right-2 -top-2 flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity z-20">
                        <button 
                          onClick={(e) => { e.stopPropagation(); handleDestacar(msg.id); }}
                          className={`p-2 rounded-full shadow-md transition ${msg.destacado ? 'bg-yellow-400 text-white' : 'bg-white text-yellow-500 hover:bg-yellow-50'}`}
                          title="Destacar pregunta"
                        >
                          ★
                        </button>
                        <button 
                          onClick={(e) => { e.stopPropagation(); handleEliminar(msg.id); }}
                          className="p-2 bg-white text-red-500 rounded-full shadow-md hover:bg-red-50 transition"
                          title="Eliminar mensaje"
                        >
                          🗑️
                        </button>
                      </div>
                    )}

                    {/* CITA */}
                    {msg.respuestaAId && (
                      <div 
                        onClick={(e) => { e.stopPropagation(); irAlMensajeOriginal(msg.respuestaAId); }}
                        className={`text-[10px] p-2 rounded-lg mb-2 border-l-4 italic flex flex-col text-left hover:brightness-95 transition-all ${
                          msgIsAdmin ? 'bg-blue-100/50 border-blue-400' : 'bg-black/5 border-orange-400'
                        }`}
                      >
                        <span className="font-black opacity-60 flex justify-between">
                          Respuesta a {msg.respuestaAAutor}
                          <span className="text-[9px] uppercase font-bold text-orange-600">↑ ir al mensaje</span>
                        </span>
                        <span className="truncate">"{msg.respuestaAContenido}"</span>
                      </div>
                    )}

                    {msgIsAdmin && (
                      <span className="absolute -top-3 left-1/2 -translate-x-1/2 bg-blue-600 text-white text-[9px] px-3 py-1 rounded-full font-black uppercase shadow-sm">
                        Respuesta Oficial
                      </span>
                    )}
                    
                    <p className={`text-[10px] font-bold uppercase mb-1 opacity-70`}>
                      {msgIsAdmin ? '🛡️ Equipo de Desarrollo' : msg.autorNombre}
                    </p>
                    <p className="text-sm leading-relaxed">{msg.contenido}</p>
                  </div>
                  <span className="text-[9px] text-gray-400 mt-1 px-2 font-medium">
                    {new Date(msg.fechaEnvio).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                  </span>
                </div>
              );
            })}
          </div>

          {/* BARRA DE ESTADO: RESPONDIENDO A... */}
          {respondiendoA && (
            <div className="bg-blue-50 border-t border-blue-200 p-3 px-6 flex justify-between items-center animate-in fade-in slide-in-from-bottom-2">
              <div className="text-xs text-blue-800">
                Respondiendo a <span className="font-bold">{respondiendoA.autorNombre}</span>: 
                <span className="italic opacity-70 ml-1">"{respondiendoA.contenido.substring(0, 30)}..."</span>
              </div>
              <button onClick={() => setRespondiendoA(null)} className="bg-blue-200 text-blue-800 h-6 w-6 rounded-full font-bold flex items-center justify-center hover:bg-blue-300">✕</button>
            </div>
          )}

          {/* INPUT DE ENVÍO */}
          <form onSubmit={handleEnviar} className="p-4 bg-white border-t border-orange-100 flex gap-2">
            <input 
              type="text" 
              value={nuevoMensaje}
              onChange={(e) => setNuevoMensaje(e.target.value)}
              placeholder={isAdmin ? "Escribe una respuesta oficial..." : "¿Qué mejorarías?"} 
              className="flex-1 p-4 bg-gray-50 border border-orange-100 rounded-2xl outline-none focus:ring-2 focus:ring-orange-500 text-sm transition-all"
            />
            <button type="submit" className="bg-orange-600 text-white px-8 rounded-2xl font-bold text-sm hover:bg-orange-700 transition shadow-lg active:scale-95">
              Enviar
            </button>
          </form>

        </div>
      </section>

      {/* SECCIÓN 3: DUDAS RESUELTAS (DESTACADOS) */}
      <section className="max-w-6xl mx-auto px-6 mt-10">
        <div className="text-center mb-12">
          <h2 className="text-4xl font-black text-gray-800">Dudas Resueltas</h2>
          <p className="text-orange-600 font-bold uppercase tracking-widest text-xs mt-2">Seleccionadas por el equipo de desarrollo</p>
        </div>

        {destacados.length === 0 ? (
          <div className="text-center p-12 bg-white rounded-3xl border border-dashed border-orange-200 text-gray-400 italic">
            Aún no hay dudas destacadas. ¡Las respuestas del equipo aparecerán aquí!
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {destacados.map(d => (
              <div key={d.id} className="bg-white p-8 rounded-[2.5rem] border border-orange-100 shadow-xl hover:shadow-2xl transition-all relative overflow-hidden flex flex-col justify-between">
                <div className="absolute top-0 right-0 bg-yellow-400 text-white px-4 py-1 rounded-bl-2xl font-black text-[10px] uppercase">
                  ⭐ Destacado
                </div>
                
                <div>
                  <div className="mb-4">
                    <span className="text-[10px] font-black text-orange-500 uppercase tracking-tighter">Consulta:</span>
                    <p className="text-gray-800 font-bold mt-1 text-lg leading-tight italic">
                      {d.respuestaAContenido ? `"${d.respuestaAContenido}"` : "Consulta general sobre el sistema"}
                    </p>
                    <p className="text-[10px] text-gray-400 mt-2">— Preguntado por {d.respuestaAAutor || d.autorNombre}</p>
                  </div>

                  <div className="bg-blue-50/50 p-5 rounded-2xl border-l-4 border-blue-400">
                    <span className="text-[9px] font-black text-blue-600 uppercase">Respuesta del Equipo:</span>
                    <p className="text-blue-900 text-sm mt-2 leading-relaxed">"{d.contenido}"</p>
                  </div>
                </div>

                <div className="mt-6 pt-4 border-t border-orange-50 flex justify-between items-center">
                   <span className="text-[10px] text-gray-300 font-bold uppercase">{new Date(d.fechaEnvio).toLocaleDateString()}</span>
                   <button 
                    onClick={() => irAlMensajeOriginal(d.id)}
                    className="text-orange-600 text-[10px] font-black hover:underline uppercase"
                   >
                     Ver en el chat →
                   </button>
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