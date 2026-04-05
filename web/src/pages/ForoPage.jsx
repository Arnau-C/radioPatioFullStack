import { useState, useEffect, useRef } from 'react';
import foroService from '../services/foroService';

const ForoPage = () => {
  const user = JSON.parse(localStorage.getItem('user'));
  const [mensajes, setMensajes] = useState([]);
  const [nuevoMensaje, setNuevoMensaje] = useState('');
  const [respondiendoA, setRespondiendoA] = useState(null); 
  const scrollRef = useRef(null);
  const FORO_ID = 1;

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

  // 3. FUNCIÓN PARA SALTAR AL MENSAJE ORIGINAL (SCROLL TO REFERENCE)
  const irAlMensajeOriginal = (targetId) => {
    const elemento = document.getElementById(`msg-${targetId}`);
    if (elemento) {
      elemento.scrollIntoView({ behavior: 'smooth', block: 'center' });
      
      // Añade efecto visual temporal (requiere CSS en index.css)
      elemento.classList.add('resaltar-mensaje');
      setTimeout(() => {
        elemento.classList.remove('resaltar-mensaje');
      }, 2000);
    }
  };

  // 4. ENVÍO DE MENSAJE
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

  return (
    <div className="min-h-screen bg-orange-50 pb-20">
      
      {/* SECCIÓN 1: BIENVENIDA E IDEA */}
      <section className="max-w-6xl mx-auto pt-16 px-6 mb-20 text-center">
        <h1 className="text-5xl font-black text-orange-700 mb-6">Nuestro proyecto</h1>
        <div className="bg-white p-10 rounded-3xl shadow-xl border border-orange-100 text-left">
          <p className="text-gray-600 text-lg leading-relaxed mb-6 italic">
            Radio Patio es un proyecto el cual nace de la necesidad de tener comunidades de vecinos mucho mas comunicadas y de forma mucho mas senzilla.
            El poder llevar de manera senzilla y en todos los aspectos le gestion de la comunidad fue lo que nos llevo a crear esta aplicacion.
            Con esta aplicacion no solo queremos que los vecinos puedan ver los anuncios y avisos de forma mas senzilla, sino que queremos
            que la gestion economica sea senzilla para el presidente, que las reservas de espacios comunes sean mas faciles y que la comunicacion entre vecinos sea mas fluida y directa."
            En definitiva, queremos que Radio Patio sea la herramienta definitiva para transformar la gestión de comunidades vecinales, haciendo que cada bloque de vecinos esté más conectado, informado y organizado que nunca.
          </p>
        </div>
      </section>

      {/* SECCIÓN 2: PREGUNTAS FRECUENTES (FAQ) */}
      <section className="max-w-4xl mx-auto px-6 mb-32">
        <h2 className="text-3xl font-black text-orange-800 mb-8 text-center">Preguntas Frecuentes</h2>
        <div className="grid grid-cols-1 gap-4">
          <div className="bg-white p-6 rounded-2xl border border-orange-100 shadow-sm">
            <p className="font-bold text-orange-700 mb-1 italic">¿Cual es el futuro de RadioPatio</p>
            <p className="text-gray-600 text-sm">El futuro de la aplicacion es poder expandir las utilidades y prestaciones de esta al maximo, haciendo una
                experiencia lo mas completa y personalizada para cada comunidad. Siempre teniendo en cuenta las opiniones y sugerencias de los usuarios para mejorar cada dia. Nuestro objetivo es que cada bloque de vecinos pueda configurar su Radio Patio a su gusto, eligiendo las funciones que mas se adapten a sus necesidades y haciendo que la gestion de la comunidad sea lo mas senzilla y eficiente posible.</p>
          </div>
          <div className="bg-white p-6 rounded-2xl border border-orange-100 shadow-sm">
            <p className="font-bold text-orange-700 mb-1 italic">¿RadioPatio sera de pago?</p>
            <p className="text-gray-600 text-sm">No, RadioPatio sera una aplicacion gratuita para todos los usuarios.</p>
          </div>
          <div className="bg-white p-6 rounded-2xl border border-orange-100 shadow-sm">
            <p className="font-bold text-orange-700 mb-1 italic">¿Que pasa si tengo un error en la aplicacion?</p>
            <p className="text-gray-600 text-sm">Escribenos en el foro de abajo de sugerencias y intentaremos arreglarlo lo antes posible.</p>
          </div>
        </div>
      </section>

      {/* SECCIÓN 3: FORO DE SUGERENCIAS */}
      <section className="max-w-4xl mx-auto px-6">
        <div className="bg-white rounded-3xl shadow-2xl border border-orange-100 overflow-hidden flex flex-col h-[600px] relative">
          
          <div className="bg-orange-600 p-6 text-white flex justify-between items-center shadow-lg z-10">
            <div>
              <h3 className="text-xl font-black">Buzón de Sugerencias</h3>
              <p className="text-xs text-orange-100 italic">Escribenos tus ideas y comentarios</p>
            </div>
            <span className="text-2xl animate-bounce">💬</span>
          </div>

          {/* LISTA DE MENSAJES */}
          <div ref={scrollRef} className="flex-1 overflow-y-auto p-6 space-y-6 bg-orange-50/20">
            {mensajes.map((msg) => {
              const isAdmin = msg.autorUsername === 'superadmin';
              const esMio = msg.autorUsername === user.username;
              
              return (
                <div 
                  key={msg.id} 
                  id={`msg-${msg.id}`} 
                  onClick={() => user.rol === 'SUPER_ADMIN' && setRespondiendoA(msg)}
                  className={`flex flex-col group transition-all duration-500 ${isAdmin ? 'items-center px-10' : (esMio ? 'items-end' : 'items-start')}`}
                >
                  <div className={`p-4 rounded-2xl shadow-sm relative transition-all active:scale-95 cursor-pointer ${
                    isAdmin 
                      ? 'bg-blue-50 border-2 border-blue-200 text-blue-900 w-full text-center' 
                      : (esMio ? 'bg-orange-600 text-white' : 'bg-white text-gray-800 border border-orange-100')
                  }`}>
                    
                    {/* VISUALIZACIÓN DE LA CITA CON SALTO AL ORIGINAL */}
                    {msg.respuestaAId && (
                      <div 
                        onClick={(e) => {
                          e.stopPropagation(); 
                          irAlMensajeOriginal(msg.respuestaAId);
                        }}
                        className={`text-[10px] p-2 rounded-lg mb-2 border-l-4 italic flex flex-col text-left hover:brightness-95 transition-all cursor-alias ${
                          isAdmin ? 'bg-blue-100/50 border-blue-400' : 'bg-black/5 border-orange-400'
                        }`}
                      >
                        <span className="font-black opacity-60 flex justify-between">
                          Respuesta a {msg.respuestaAAutor}
                          <span className="text-[9px] uppercase tracking-tighter not-italic font-bold text-orange-600">↑ ir al mensaje</span>
                        </span>
                        <span className="truncate">"{msg.respuestaAContenido}"</span>
                      </div>
                    )}

                    {isAdmin && (
                      <span className="absolute -top-3 left-1/2 -translate-x-1/2 bg-blue-600 text-white text-[9px] px-3 py-1 rounded-full font-black uppercase tracking-tighter shadow-sm">
                        Respuesta Oficial
                      </span>
                    )}
                    
                    <p className={`text-[10px] font-bold uppercase mb-1 ${isAdmin ? 'opacity-60' : 'opacity-70'}`}>
                      {isAdmin ? '🛡️ Equipo de Desarrollo' : msg.autorNombre}
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
              <button 
                onClick={() => setRespondiendoA(null)}
                className="bg-blue-200 text-blue-800 h-6 w-6 rounded-full font-bold flex items-center justify-center hover:bg-blue-300 transition"
              >
                ✕
              </button>
            </div>
          )}

          {/* INPUT DE ENVÍO */}
          <form onSubmit={handleEnviar} className="p-4 bg-white border-t border-orange-100 flex gap-2">
            <input 
              type="text" 
              value={nuevoMensaje}
              onChange={(e) => setNuevoMensaje(e.target.value)}
              placeholder={user.rol === 'SUPER_ADMIN' ? "Escribe una respuesta oficial..." : "¿Qué mejorarías?"} 
              className="flex-1 p-4 bg-gray-50 border border-orange-100 rounded-2xl outline-none focus:ring-2 focus:ring-orange-500 text-sm transition-all"
            />
            <button type="submit" className="bg-orange-600 text-white px-8 rounded-2xl font-bold text-sm hover:bg-orange-700 transition shadow-lg active:scale-95 disabled:opacity-50">
              Enviar
            </button>
          </form>

        </div>
      </section>

    </div>
  );
};

export default ForoPage;