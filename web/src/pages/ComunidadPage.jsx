import { useState } from 'react'; 
import { useNavigate } from 'react-router-dom';
import comunidadService from '../services/comunidadService'; // IMPORTAMOS EL SERVICIO

const ComunidadPage = () => {
  const navigate = useNavigate();
  const [menuOpen, setMenuOpen] = useState(false); 
  
  // Estados para el Modal de Gestión (Presidente)
  const [showCodeModal, setShowCodeModal] = useState(false);
  const [inviteCode, setInviteCode] = useState('');
  
  const user = JSON.parse(localStorage.getItem('user'));

  const esPresidente = user?.rol === 'PRESIDENTE';
  const esMiembroComunidad = user && (user.rol === 'VECINO' || user.rol === 'PRESIDENTE');

  // Función para ver el código de invitación
  const handleVerCodigo = async () => {
    try {
      const data = await comunidadService.getDetalle(user.username);
      setInviteCode(data.codigoInvitacion);
      setShowCodeModal(true); // Abrimos el modal
      setMenuOpen(false); // Cerramos el menú hamburguesa
    } catch (error) {
      alert("Error al obtener el código de la comunidad");
    }
  };

  // --- CASO A: NO TIENE COMUNIDAD ---
  if (!esMiembroComunidad) {
    return (
      <div className="min-h-screen bg-slate-50 flex items-center justify-center p-6">
        <div className="max-w-md w-full bg-white p-10 rounded-[3rem] shadow-xl border border-orange-100 text-center animate-in fade-in zoom-in duration-500">
          <div className="bg-orange-100 w-20 h-20 rounded-3xl flex items-center justify-center text-orange-600 mx-auto mb-6">
            <svg className="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
            </svg>
          </div>
          <h2 className="text-2xl font-black text-slate-800 mb-4">Aún no tienes comunidad</h2>
          <p className="text-slate-500 mb-8 leading-relaxed italic text-sm">
            Para empezar a usar Radio Patio, necesitas crear una comunidad nueva o unirte a una existente con un código.
          </p>
          
          {/* NUEVOS BOTONES */}
          <div className="space-y-3">
            <button 
              onClick={() => navigate('/crear-comunidad')}
              className="w-full bg-orange-600 text-white py-4 rounded-2xl font-black uppercase tracking-widest text-xs hover:bg-orange-700 transition shadow-lg shadow-orange-200 active:scale-95"
            >
              Crear Comunidad
            </button>
            <button 
              onClick={() => navigate('/unirse-comunidad')}
              className="w-full bg-white text-orange-600 border-2 border-orange-100 py-4 rounded-2xl font-black uppercase tracking-widest text-xs hover:bg-orange-50 transition active:scale-95"
            >
              Unirse a Comunidad
            </button>
            <button 
              onClick={() => navigate(-1)}
              className="w-full py-4 text-slate-400 font-bold uppercase tracking-widest text-[10px] hover:text-slate-600 transition-colors mt-2"
            >
              ← Volver atrás
            </button>
          </div>
        </div>
      </div>
    );
  }

  // --- CASO B: SÍ TIENE COMUNIDAD (Mismo código que ya tenías) ---
  const opciones = [
    {
      id: 'foro',
      titulo: 'Foro Vecinal',
      descripcion: 'Habla con tus vecinos en este foro.',
      icono: (
        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M17 8h2a2 2 0 012 2v6a2 2 0 01-2 2h-2v4l-4-4H9a1.994-.586m0 0L11 14h4a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2v4l.586-.586z" />
        </svg>
      ),
      color: 'bg-orange-500',
      ruta: '/comunidad/foro'
    },
    {
      id: 'documentos',
      titulo: 'Documentos',
      descripcion: 'Accede a actas, estatutos y presupuestos.',
      icono: (
        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 7v8a2 2 0 002 2h6M8 7V5a2 2 0 012-2h4.586a1 1 0 01.707.293l4.414 4.414a1 1 0 01.293.707V15a2 2 0 01-2 2h-2M8 7H6a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2v-2" />
        </svg>
      ),
      color: 'bg-orange-500', // Mismo color para mantener coherencia
      ruta: '/comunidad/documentos'
    },
  ];

  return (
    <div className="min-h-screen bg-slate-50 p-8 animate-in fade-in duration-700 relative">
      
      {/* --- MODAL PARA EL CÓDIGO DE INVITACIÓN (Solo aparece si showCodeModal es true) --- */}
      {showCodeModal && (
        <div className="fixed inset-0 bg-slate-900/40 backdrop-blur-sm z-50 flex items-center justify-center p-4 animate-in fade-in">
          <div className="bg-white p-8 rounded-[2.5rem] shadow-2xl max-w-sm w-full text-center border border-orange-100 animate-in zoom-in-95">
            <div className="w-16 h-16 bg-orange-100 text-orange-600 rounded-2xl flex items-center justify-center mx-auto mb-4">
              <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 5v2m0 4v2m0 4v2M5 5a2 2 0 00-2 2v3a2 2 0 110 4v3a2 2 0 002 2h14a2 2 0 002-2v-3a2 2 0 110-4V7a2 2 0 00-2-2H5z" /></svg>
            </div>
            <h3 className="text-xl font-black text-slate-800 mb-2">Código de Invitación</h3>
            <p className="text-sm text-slate-500 mb-6">Comparte este código con tus vecinos para que puedan unirse a la comunidad.</p>
            
            <div className="bg-slate-50 border-2 border-dashed border-slate-200 rounded-2xl p-4 mb-6">
              <span className="text-3xl font-black tracking-[0.2em] text-orange-600">{inviteCode}</span>
            </div>

            <button 
              onClick={() => setShowCodeModal(false)}
              className="w-full bg-slate-800 text-white py-4 rounded-2xl font-black uppercase text-xs tracking-widest hover:bg-slate-700 transition-colors"
            >
              Cerrar
            </button>
          </div>
        </div>
      )}

      {/* --- CABECERA Y MENÚ HAMBURGUESA --- */}
      <header className="max-w-6xl mx-auto mb-12 flex justify-between items-start relative">
        <div>
          <h1 className="text-4xl font-black text-slate-800">Mi Comunidad</h1>
          <div className="flex items-center gap-2 mt-2">
            <span className="bg-orange-100 text-orange-600 text-[10px] px-2 py-0.5 rounded-full font-black uppercase tracking-widest">
                {user.rol}
            </span>
            <p className="text-slate-500 font-medium uppercase tracking-widest text-xs">
                {user.nombre} {user.apellidos}
            </p>
          </div>
        </div>

        <div className="relative">
          <button 
            onClick={() => setMenuOpen(!menuOpen)}
            className="p-4 bg-white rounded-2xl shadow-sm border border-slate-200 hover:shadow-md hover:border-orange-200 transition-all text-slate-600 focus:outline-none"
          >
            <svg className={`w-6 h-6 transition-transform ${menuOpen ? 'rotate-90' : ''}`} fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          </button>

          {menuOpen && (
            <div className="absolute right-0 mt-4 w-64 bg-white rounded-[2.5rem] shadow-2xl border border-slate-100 p-4 z-40 animate-in fade-in slide-in-from-top-4 duration-200">
              <div className="px-4 py-3 border-b border-slate-50 mb-2">
                <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Configuración</p>
              </div>
              
              <button 
                onClick={() => navigate('/perfil')}
                className="w-full text-left p-4 hover:bg-orange-50 rounded-2xl transition-colors flex items-center gap-3 group"
              >
                <div className="w-10 h-10 bg-orange-100 rounded-xl flex items-center justify-center text-orange-600 group-hover:scale-110 transition-transform">
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                  </svg>
                </div>
                <span className="text-sm font-bold text-slate-700">Ajustes de Perfil</span>
              </button>

              {esPresidente && (
                <button 
                  onClick={handleVerCodigo} // <-- LLAMAMOS A LA FUNCIÓN AQUÍ
                  className="w-full text-left p-4 hover:bg-blue-50 rounded-2xl transition-colors flex items-center gap-3 group mt-1"
                >
                  <div className="w-10 h-10 bg-blue-100 rounded-xl flex items-center justify-center text-blue-600 group-hover:scale-110 transition-transform">
                    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                    </svg>
                  </div>
                  <span className="text-sm font-bold text-slate-700">Gestión Comunidad</span>
                </button>
              )}
            </div>
          )}
        </div>
      </header>

      {/* --- GRID DE OPCIONES --- */}
      <main className="max-w-6xl mx-auto grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        {opciones.map((opc) => (
          <div 
            key={opc.id}
            onClick={() => navigate(opc.ruta)}
            className="bg-white p-8 rounded-[2.5rem] border border-slate-200 shadow-sm hover:shadow-xl hover:-translate-y-1 transition-all cursor-pointer group"
          >
            <div className={`${opc.color} w-16 h-16 rounded-2xl flex items-center justify-center text-white mb-6 shadow-lg shadow-orange-200 group-hover:scale-110 transition-transform`}>
              {opc.icono}
            </div>
            <h3 className="text-xl font-bold text-slate-800 mb-2">{opc.titulo}</h3>
            <p className="text-slate-400 text-sm leading-relaxed italic">
              {opc.descripcion}
            </p>
            <div className="mt-6 flex items-center text-orange-600 text-xs font-black uppercase tracking-tighter">
              Entrar ahora 
              <svg className="w-4 h-4 ml-1 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="3" d="M13 7l5 5m0 0l-5 5m5-5H6" />
              </svg>
            </div>
          </div>
        ))}
      </main>
    </div>
  );
};

export default ComunidadPage;