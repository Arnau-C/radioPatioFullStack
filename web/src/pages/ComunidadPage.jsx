import { useNavigate } from 'react-router-dom';

const ComunidadPage = () => {
  const navigate = useNavigate();
  // Recuperamos el usuario del localStorage para verificar su rol
  const user = JSON.parse(localStorage.getItem('user'));

  // Lógica de control: Verificamos si el Rol es VECINO o PRESIDENTE
  // Si es "USER", significa que aún no tiene comunidad vinculada
  const esMiembroComunidad = user && (user.rol === 'VECINO' || user.rol === 'PRESIDENTE');

  // CASO A: El usuario NO es miembro de una comunidad todavía
  if (!esMiembroComunidad) {
    return (
      <div className="min-h-screen bg-slate-50 flex items-center justify-center p-6">
        <div className="max-w-md w-full bg-white p-10 rounded-[3rem] shadow-xl border border-orange-100 text-center animate-in fade-in zoom-in duration-500">
          <div className="bg-orange-100 w-20 h-20 rounded-3xl flex items-center justify-center text-orange-600 mx-auto mb-6">
            <svg className="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
            </svg>
          </div>
          <h2 className="text-2xl font-black text-slate-800 mb-4">No tienes comunidad</h2>
          <p className="text-slate-500 mb-8 leading-relaxed italic text-sm">
            Lo siento no estas dentro de ninguna comunidad.
          </p>
          <button 
            onClick={() => navigate('/')}
            className="w-full bg-orange-600 text-white py-4 rounded-2xl font-black uppercase tracking-widest text-xs hover:bg-orange-700 transition shadow-lg shadow-orange-200 active:scale-95"
          >
            Volver al inicio
          </button>
        </div>
      </div>
    );
  }

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
  ];

  return (
    <div className="min-h-screen bg-slate-50 p-8 animate-in fade-in duration-700">
      <header className="max-w-6xl mx-auto mb-12">
        <h1 className="text-4xl font-black text-slate-800">Mi Comunidad</h1>
        <div className="flex items-center gap-2 mt-2">
            <span className="bg-orange-100 text-orange-600 text-[10px] px-2 py-0.5 rounded-full font-black uppercase tracking-widest">
                {user.rol}
            </span>
            <p className="text-slate-500 font-medium uppercase tracking-widest text-xs">
                Gestión y comunicación vecinal
            </p>
        </div>
      </header>

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

        <div className="bg-slate-100/50 p-8 rounded-[2.5rem] border border-dashed border-slate-300 flex flex-col items-center justify-center text-center opacity-60">
          <p className="text-xs font-bold text-slate-400 uppercase tracking-widest">Próximas funciones</p>
        </div>
      </main>
    </div>
  );
};

export default ComunidadPage;