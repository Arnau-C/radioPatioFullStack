// web/src/pages/LandingPage.jsx
import { Link } from 'react-router-dom';
import logo from '../assets/logo.png';

const LandingPage = () => {
  return (
    <div className="bg-orange-50 min-h-screen">
      
      {/* SECCIÓN HERO: PRESENTACIÓN */}
      <section className="relative overflow-hidden pt-16 pb-32">
        <div className="max-w-7xl mx-auto px-8 flex flex-col lg:flex-row items-center gap-12">
          
          {/* PARTE IZQUIERDA: CONTENIDO */}
          <div className="lg:w-1/2 text-left z-10">
            <span className="inline-block py-1 px-3 rounded-full bg-orange-100 text-orange-700 text-sm font-bold mb-4">
              Gestión de comunidades moderna
            </span>
            
            <h1 className="text-6xl font-black text-gray-900 leading-tight">
              Tu comunidad, <br />
              <span className="text-orange-600 italic">mejor conectada.</span>
            </h1>
            
            <p className="mt-6 text-xl text-gray-700 max-w-lg font-semibold">
             Radio Patio: la aplicación multiplataforma de gestión vecinal. Conecta con tu bloque a otro nivel.
            </p>

            <div className="mt-10">
              <Link to="/login" className="inline-block bg-orange-600 text-white px-10 py-4 rounded-2xl text-xl font-bold hover:bg-orange-700 transition shadow-lg mb-10">
                Inicia sesión
              </Link>

              {/* SOBRE EL PROYECTO */}
              <div className="max-w-2xl space-y-4">
                <p className="text-base text-gray-700 leading-relaxed">
                  <span className="font-bold text-orange-700">Este es un proyecto de software en fase de desarrollo.</span>
                </p>
                
                <p className="text-base text-gray-600 leading-relaxed">
                  Hola. Somos <span className="font-semibold text-gray-800">Arnau Calvo, Eric Sanchez y Óscar Nuñez</span>, estudiantes de Desarrollo de Aplicaciones Multiplataforma en el <span className="italic">IES el Calamot</span>. 
                  Nuestro proyecto de final de curso es <span className="font-bold text-orange-600">Radio Patio</span>.
                </p>

                <p className="text-base text-gray-600 leading-relaxed">
                  Nuestro objetivo es ofrecer una solución integral que reúna todas las utilidades necesarias para el día a día de un bloque de vecinos, haciendo que la experiencia sea dinámica y <span className="text-orange-700 font-medium">totalmente personalizable</span>.
                </p>

                <p className="text-sm text-gray-400 italic mt-4 border-t border-orange-200 pt-4">
                  * Nota: Al encontrarse en fase de desarrollo, algunas funciones podrían no estar disponibles.
                </p>
              </div>
            </div>
          </div>
          
          {/* PARTE DERECHA: LOGO */}
          <div className="lg:w-1/2 flex justify-center">
            <img 
              src={logo} 
              alt="Radio Patio App" 
              className="w-full max-w-lg h-auto drop-shadow-2xl animate-pulse-slow" 
              style={{ animationDuration: '5s' }}
            />
          </div>
        </div>
      </section>

      {/* SECCIÓN DE CARACTERÍSTICAS */}
      <section className="bg-white/40 py-20 border-t border-orange-100">
        <div className="max-w-7xl mx-auto px-8 grid md:grid-cols-3 gap-8">
          <div className="text-center p-8 bg-white/50 rounded-3xl border border-orange-50 shadow-sm">
            <div className="text-4xl mb-4">💬</div>
            <h3 className="font-bold text-gray-800 text-lg">Foro Vecinal</h3>
            <p className="text-sm text-gray-500 mt-2">Comunicación directa y fluida con todos los vecinos de tu bloque.</p>
          </div>
          <div className="text-center p-8 bg-white/50 rounded-3xl border border-orange-50 shadow-sm">
            <div className="text-4xl mb-4">🛠️</div>
            <h3 className="font-bold text-gray-800 text-lg">Gestión de Avisos</h3>
            <p className="text-sm text-gray-500 mt-2">Mantente al tanto de derramas, reuniones y noticias importantes.</p>
          </div>
          <div className="text-center p-8 bg-white/50 rounded-3xl border border-orange-50 shadow-sm">
            <div className="text-4xl mb-4">📁</div>
            <h3 className="font-bold text-gray-800 text-lg">Documentación</h3>
            <p className="text-sm text-gray-500 mt-2">Accede a actas y contratos de la comunidad de forma digital.</p>
          </div>
        </div>
      </section>

      {/* NUEVA SECCIÓN: CALL TO ACTION AL BUZÓN */}
      <section className="py-24 bg-orange-100/30 border-t border-orange-200">
        <div className="max-w-4xl mx-auto px-6 text-center">
          <h2 className="text-4xl font-black text-orange-900 mb-4">¿Tienes alguna idea para mejorar?</h2>
          <p className="text-lg text-gray-600 mb-10 leading-relaxed">
            Estamos construyendo Radio Patio para vosotros. Si crees que falta alguna funcionalidad 
            o has encontrado un error, cuéntanoslo en nuestro foro global.
          </p>
          <Link 
            to="/ayuda" 
            className="inline-flex items-center gap-3 bg-white text-orange-600 border-2 border-orange-600 px-10 py-5 rounded-2xl font-black text-xl hover:bg-orange-600 hover:text-white transition-all shadow-xl active:scale-95"
          >
            <span>📩 Ir al Buzón de Sugerencias</span>
          </Link>
        </div>
      </section>

      {/* FOOTER */}
      <footer className="py-12 text-center border-t border-orange-100">
        <img src={logo} alt="Radio Patio" className="h-8 mx-auto mb-4 opacity-50" />
        <p className="text-gray-400 text-sm">© 2026 Radio Patio Team</p>
        <p className="text-gray-300 text-xs mt-1 font-medium uppercase tracking-widest">Gavà, Barcelona</p>
      </footer>

    </div>
  );
};

export default LandingPage;