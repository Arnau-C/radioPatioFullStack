import { Link } from 'react-router-dom';

const LandingPage = () => {
  return (
    <div className="bg-white">
      {/* Hero Section */}
      <section className="px-8 py-20 max-w-7xl mx-auto flex flex-col md:flex-row items-center gap-12">
        <div className="flex-1 text-left">
          <h1 className="text-6xl font-black text-gray-900 leading-tight">
            La comunidad de vecinos <br />
            <span className="text-blue-600">en tu bolsillo.</span>
          </h1>
          <p className="mt-6 text-xl text-gray-600 leading-relaxed">
            Gestiona incidencias, vota en juntas y entérate de todo lo que pasa en tu patio sin moverte del sofá. 
            La herramienta definitiva para una convivencia moderna.
          </p>
          <div className="mt-10 flex gap-4">
            <Link to="/login" className="bg-blue-600 text-white px-8 py-4 rounded-xl text-lg font-bold hover:bg-blue-700 transition shadow-lg">
              Entrar en mi Comunidad
            </Link>
          </div>
        </div>
        
        <div className="flex-1 bg-blue-50 rounded-3xl p-12 hidden md:block">
           {/* Aquí podrías poner una captura de la app móvil o un gráfico dinámico */}
           <div className="aspect-video bg-white rounded-xl shadow-2xl flex items-center justify-center text-blue-200">
             <span className="text-8xl">🏠</span>
           </div>
        </div>
      </section>
    </div>
  );
};

export default LandingPage;