// web/src/pages/LandingPage.jsx
import { Link } from 'react-router-dom';
import logo from '../assets/logo.png'; //

const LandingPage = () => {
  return (
    /* bg-orange-50: El fondo anaranjado suave para que resalte vuestra marca */
    <div className="bg-orange-50 min-h-screen">
      
      <section className="relative overflow-hidden pt-16 pb-32">
        <div className="max-w-7xl mx-auto px-8 flex flex-col lg:flex-row items-center gap-12">
          
          {/* PARTE IZQUIERDA: CONTENIDO Y PRESENTACIÓN */}
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
              {/* Botón de Iniciar Sesión */}
              <Link to="/login" className="inline-block bg-orange-600 text-white px-10 py-4 rounded-2xl text-xl font-bold hover:bg-orange-700 transition shadow-lg mb-10">
                Inicia sesión
              </Link>

              {/* TEXTO EXPLICATIVO EXPANDIDO: 
                  He cambiado 'max-w-sm' por 'max-w-2xl' para que el texto se estire.
                  He usado 'text-gray-600' para que sea más legible sobre el fondo naranja.
              */}
              <div className="max-w-2xl space-y-4">
                <p className="text-base text-gray-700 leading-relaxed">
                  <span className="font-bold text-orange-700">Este es un proyecto de software en fase de desarrollo.</span>
                </p>
                
                <p className="text-base text-gray-600 leading-relaxed">
                  Hola. Somos <span className="font-semibold text-gray-800">Arnau Calvo, Eric Sanchez y Óscar Nuñez</span>, estudiantes de Desarrollo de Aplicaciones Multiplataforma en el <span className="italic">IES el Calamot</span>. 
                  Nuestro proyecto de final de curso es <span className="font-bold text-orange-600">Radio Patio</span>, una plataforma diseñada para digitalizar la gestión de comunidades vecinales.
                </p>

                <p className="text-base text-gray-600 leading-relaxed">
                  Nuestro objetivo es ofrecer una solución integral que reúna todas las utilidades necesarias para el día a día de un bloque de vecinos, haciendo que la experiencia sea dinámica y, sobre todo, <span className="text-orange-700 font-medium">totalmente personalizable</span> según las necesidades de cada comunidad.
                </p>

                <p className="text-sm text-gray-400 italic mt-4 border-t border-orange-200 pt-4">
                  * Nota: Al encontrarse en fase de desarrollo, algunas funciones podrían no estar disponibles o presentar errores temporales.
                </p>
              </div>
            </div>
          </div>
          
          {/* PARTE DERECHA: LOGO GRANDE */}
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
          <div className="text-center p-6 bg-white/50 rounded-2xl border border-orange-50">
            <div className="text-3xl mb-2">💬</div>
            <h3 className="font-bold text-gray-800">Foro Vecinal</h3>
            <p className="text-sm text-gray-500">Comunicación directa con tu bloque.</p>
          </div>
          <div className="text-center p-6 bg-white/50 rounded-2xl border border-orange-50">
            <div className="text-3xl mb-2">🛠️</div>
            <h3 className="font-bold text-gray-800">Incidencias</h3>
            <p className="text-sm text-gray-500">Avisa de averías en tiempo real.</p>
          </div>
          <div className="text-center p-6 bg-white/50 rounded-2xl border border-orange-50">
            <div className="text-3xl mb-2">📅</div>
            <h3 className="font-bold text-gray-800">Reservas</h3>
            <p className="text-sm text-gray-500">Gestiona espacios comunes fácilmente.</p>
          </div>
        </div>
      </section>
    </div>
  );
};

export default LandingPage;