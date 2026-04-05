import { useNavigate } from 'react-router-dom';

const ForoPage = () => {
  const navigate = useNavigate();
  // Recuperamos los datos del usuario guardados por el servicio
  const user = JSON.parse(localStorage.getItem('user'));

  const handleLogout = () => {
    localStorage.removeItem('user');
    navigate('/');
  };

  return (
    <div className="min-h-screen bg-orange-50 flex flex-col items-center justify-center p-4">
      <div className="bg-white p-12 rounded-3xl shadow-2xl text-center max-w-lg border border-orange-100">
        <div className="text-6xl mb-6">🎉</div>
        <h1 className="text-4xl font-black text-orange-700 mb-4">¡Has entrado!</h1>
        
        <p className="text-xl text-gray-600 mb-8">
          Bienvenido/a de nuevo, <span className="font-bold text-gray-800">{user?.nombre || 'Vecino/a'}</span>. 
          La conexión con el backend ha funcionado correctamente.
        </p>

        <div className="space-y-4">
          <div className="p-4 bg-green-50 text-green-700 rounded-2xl font-medium border border-green-100">
            ✅ Token JWT verificado y sesión iniciada.
          </div>
          
          <button 
            onClick={handleLogout}
            className="mt-6 text-orange-600 font-bold hover:underline"
          >
            Cerrar sesión y volver
          </button>
        </div>
      </div>
    </div>
  );
};

export default ForoPage;