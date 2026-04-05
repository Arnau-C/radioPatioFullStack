import { useState, useEffect, useRef } from 'react';
import foroService from '../services/foroService';

const ForoPage = () => {
  // Obtenemos los datos del usuario logueado
  const user = JSON.parse(localStorage.getItem('user'));
  const [mensajes, setMensajes] = useState([]);
  const [nuevoMensaje, setNuevoMensaje] = useState('');
  const [vistaActiva, setVistaActiva] = useState('sugerencias');
  const scrollRef = useRef(null);

  // Usamos el ID 1 para el foro global que creaste en el DataInitializer
  const FORO_ID = 1;

  // Cargar mensajes del backend
  const cargarMensajes = async () => {
    try {
      const data = await foroService.getMensajes(FORO_ID);
      setMensajes(data);
    } catch (e) {
      console.error("Error cargando el foro");
    }
  };

  useEffect(() => {
    cargarMensajes();
    // Refresco automático cada 10 segundos
    const interval = setInterval(cargarMensajes, 10000);
    return () => clearInterval(interval);
  }, []);

  // Hacer scroll automático al final cuando llegan mensajes nuevos
  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [mensajes]);

  const handleEnviar = async (e) => {
    e.preventDefault();
    if (!nuevoMensaje.trim()) return;

    try {
      await foroService.enviarMensaje(FORO_ID, user.username, nuevoMensaje);
      setNuevoMensaje('');
      cargarMensajes(); // Recargamos para ver nuestro mensaje
    } catch (e) {
      alert("No se pudo enviar el mensaje");
    }
  };

  return (
    <div className="min-h-screen bg-orange-50 p-4 md:p-8">
      <div className="max-w-4xl mx-auto flex flex-col h-[85vh]">
        
        {/* Cabecera del Foro */}
        <div className="bg-white p-6 rounded-t-3xl border-x border-t border-orange-100 shadow-sm flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-black text-orange-700">Foro de Sugerencias</h1>
            <p className="text-sm text-gray-500 italic">Conectado como: {user.nombre} ({user.username})</p>
          </div>
          <button onClick={cargarMensajes} className="p-2 hover:bg-orange-50 rounded-full transition">🔄</button>
        </div>

        {/* Contenedor de Mensajes */}
        <div 
          ref={scrollRef}
          className="flex-1 bg-white/50 backdrop-blur-sm border-x border-orange-100 overflow-y-auto p-6 space-y-4"
        >
          {mensajes.length === 0 ? (
            <div className="text-center py-20 text-gray-400">Aún no hay mensajes. ¡Sé el primero en escribir!</div>
          ) : (
            mensajes.map((msg) => (
              <div 
                key={msg.id} 
                className={`flex flex-col ${msg.autorUsername === user.username ? 'items-end' : 'items-start'}`}
              >
                {/* Burbuja de mensaje */}
                <div className={`max-w-[75%] p-4 rounded-2xl shadow-sm ${
                  msg.autorUsername === user.username 
                    ? 'bg-orange-600 text-white rounded-tr-none' 
                    : 'bg-white text-gray-800 border border-orange-50 rounded-tl-none'
                }`}>
                  <p className="text-[10px] font-bold uppercase tracking-wider mb-1 opacity-70">
                    {msg.autorNombre}
                  </p>
                  <p className="text-sm leading-relaxed">{msg.contenido}</p>
                </div>
                {/* Fecha y hora */}
                <span className="text-[10px] text-gray-400 mt-1 px-2">
                  {new Date(msg.fechaEnvio).toLocaleString('es-ES', { 
                    hour: '2-digit', minute: '2-digit', day: '2-digit', month: 'short' 
                  })}
                </span>
              </div>
            ))
          )}
        </div>

        {/* Formulario de Envío */}
        <form 
          onSubmit={handleEnviar}
          className="bg-white p-4 rounded-b-3xl border-x border-b border-orange-100 shadow-lg flex gap-3"
        >
          <input 
            type="text" 
            value={nuevoMensaje}
            onChange={(e) => setNuevoMensaje(e.target.value)}
            placeholder="Escribe tu sugerencia aquí..." 
            className="flex-1 p-4 bg-orange-50/50 border border-orange-100 rounded-2xl outline-none focus:ring-2 focus:ring-orange-500 transition-all"
          />
          <button 
            type="submit"
            className="bg-orange-600 text-white px-8 rounded-2xl font-bold hover:bg-orange-700 transition-all active:scale-95 shadow-md shadow-orange-100"
          >
            Enviar
          </button>
        </form>

      </div>
    </div>
  );
};

export default ForoPage;