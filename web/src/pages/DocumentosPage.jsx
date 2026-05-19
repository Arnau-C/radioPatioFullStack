import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import documentoService from '../services/documentoService';
import comunidadService from '../services/comunidadService';

const DocumentosPage = () => {
    const navigate = useNavigate();
    const user = JSON.parse(localStorage.getItem('user'));
    const esPresidente = user?.rol === 'PRESIDENTE';

    const [comunidadNombre, setComunidadNombre] = useState('');
    const [carpetas, setCarpetas] = useState([]);
    const [carpetaSeleccionada, setCarpetaSeleccionada] = useState(null);
    const [documentos, setDocumentos] = useState([]);
    const [loading, setLoading] = useState(true);

    const [showModalCarpeta, setShowModalCarpeta] = useState(false);
    const [showModalSubir, setShowModalSubir] = useState(false);
    const [nuevoNombreCarpeta, setNuevoNombreCarpeta] = useState('');
    const [archivoASubir, setArchivoASubir] = useState(null);

    // ESTADOS PARA MOVER ARCHIVOS
    const [showModalMover, setShowModalMover] = useState(false);
    const [documentoAMover, setDocumentoAMover] = useState(null);
    const [carpetaDestinoId, setCarpetaDestinoId] = useState('');

    useEffect(() => {
        cargarDatosIniciales();
    }, []);

    const cargarDatosIniciales = async () => {
        try {
            // Aún pedimos el detalle para poder mostrar el nombre de tu bloque en el título (UI)
            const detalle = await comunidadService.getDetalle(user.username);
            setComunidadNombre(detalle.nombre); 
            
            // ¡MAGIA! Ya no le pasamos el detalle.nombre, el backend lo sabe por el JWT
            const docsCarpetas = await documentoService.getCarpetas();
            setCarpetas(docsCarpetas || []);
            if (docsCarpetas && docsCarpetas.length > 0) {
                seleccionarCarpeta(docsCarpetas[0]);
            }
        } catch (error) {
            console.error("Error cargando documentos", error);
        } finally {
            setLoading(false);
        }
    };

    const seleccionarCarpeta = async (carpeta) => {
        setCarpetaSeleccionada(carpeta);
        try {
            const docs = await documentoService.getDocumentosByCarpeta(carpeta.id);
            setDocumentos(docs || []);
        } catch (err) {
            setDocumentos([]);
        }
    };

    const handleCrearCarpeta = async (e) => {
        e.preventDefault();
        try {
            // Ya no pasamos la comunidadNombre
            await documentoService.crearCarpeta(nuevoNombreCarpeta);
            setNuevoNombreCarpeta('');
            setShowModalCarpeta(false);
            cargarDatosIniciales();
        } catch (error) { 
            alert("Error al crear carpeta: " + (error.response?.data?.error || "")); 
        }
    };

    const handleSubirArchivo = async (e) => {
        e.preventDefault();
        if (!archivoASubir || !carpetaSeleccionada) return;
        try {
            // Ya no pasamos user.username, el Backend es seguro y lo extrae solo
            await documentoService.subirDocumento(archivoASubir, carpetaSeleccionada.id);
            setShowModalSubir(false);
            setArchivoASubir(null);
            seleccionarCarpeta(carpetaSeleccionada); 
        } catch (error) { 
            alert("Error al subir archivo"); 
        }
    };

    const handleBorrarCarpeta = async (carpetaId) => {
        if (!window.confirm("¿Seguro que quieres borrar esta carpeta?")) return;
        try {
            await documentoService.borrarCarpeta(carpetaId);
            cargarDatosIniciales(); 
        } catch (error) { 
            alert("Error al borrar la carpeta: " + (error.response?.data?.error || "")); 
        }
    };

    const handleVerDocumento = async (documentoId) => {
        try {
            const blob = await documentoService.verDocumento(documentoId);
            const fileUrl = window.URL.createObjectURL(new Blob([blob], { type: 'application/pdf' }));
            window.open(fileUrl, '_blank');
        } catch (error) {
            alert("Error al intentar abrir el documento");
        }
    };

    const handleBorrarDocumento = async (documentoId) => {
        if (!window.confirm("¿Estás seguro de que deseas eliminar este documento permanentemente?")) return;
        try {
            await documentoService.borrarDocumento(documentoId);
            seleccionarCarpeta(carpetaSeleccionada);
        } catch (error) {
            alert("Error al borrar el documento");
        }
    };

    const abrirModalMover = (doc) => {
        setDocumentoAMover(doc);
        const carpetasDisponibles = carpetas.filter(c => c.id !== carpetaSeleccionada?.id);
        if (carpetasDisponibles.length > 0) {
            setCarpetaDestinoId(carpetasDisponibles[0].id);
        } else {
            setCarpetaDestinoId('');
        }
        setShowModalMover(true);
    };

    const handleMoverDocumento = async (e) => {
        e.preventDefault();
        if (!documentoAMover || !carpetaDestinoId) return;
        try {
            await documentoService.moverDocumento(documentoAMover.id, carpetaDestinoId);
            setShowModalMover(false);
            setDocumentoAMover(null);
            seleccionarCarpeta(carpetaSeleccionada);
        } catch (error) {
            alert("Error al mover el documento");
        }
    };

    if (loading) return <div className="p-10 text-center font-black text-orange-600">Cargando archivador...</div>;

    return (
        <div className="min-h-screen bg-slate-50 p-8 animate-in fade-in duration-500">
            <header className="max-w-6xl mx-auto mb-8 flex justify-between items-center">
                <div>
                    <button onClick={() => navigate('/comunidad')} className="text-orange-600 font-bold text-xs uppercase mb-2 block">← Volver</button>
                    <h1 className="text-4xl font-black text-slate-800">Documentos</h1>
                </div>
                {esPresidente && (
                    <div className="flex gap-3">
                        <button onClick={() => setShowModalCarpeta(true)} className="bg-white border-2 border-orange-100 text-orange-600 px-6 py-3 rounded-2xl font-black text-xs uppercase hover:bg-orange-50 transition">Nueva Carpeta</button>
                        <button onClick={() => setShowModalSubir(true)} className="bg-orange-600 text-white px-6 py-3 rounded-2xl font-black text-xs uppercase hover:bg-orange-700 shadow-lg shadow-orange-200 transition">Subir Archivo</button>
                    </div>
                )}
            </header>

            <main className="max-w-6xl mx-auto grid grid-cols-1 lg:grid-cols-4 gap-8">
                {/* Lateral: Carpetas */}
                <div className="lg:col-span-1 space-y-2">
                    <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest ml-4 mb-4">Carpetas</p>
                    {carpetas?.length === 0 && <p className="text-sm text-slate-400 ml-4 italic">No hay carpetas</p>}
                    {carpetas?.map(c => (
                        <button 
                            key={c.id} 
                            onClick={() => seleccionarCarpeta(c)}
                            className={`w-full text-left p-4 rounded-2xl font-bold transition-all flex items-center gap-3 ${carpetaSeleccionada?.id === c.id ? 'bg-orange-600 text-white shadow-lg' : 'bg-white text-slate-600 hover:bg-orange-50'}`}
                        >
                            <svg className="w-5 h-5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z" /></svg>
                            <span className="truncate">{c.nombre}</span>
                        </button>
                    ))}
                </div>

                {/* Principal: Archivos */}
                <div className="lg:col-span-3 bg-white rounded-[2.5rem] p-8 border border-slate-200 shadow-sm min-h-[500px]">
                    <div className="flex flex-col sm:flex-row sm:items-center justify-between mb-6 gap-4 border-b border-slate-50 pb-4">
                        <h2 className="text-xl font-black text-slate-800 flex items-center gap-2">
                            {carpetaSeleccionada?.nombre || "Selecciona una carpeta"}
                            {carpetaSeleccionada && <span className="text-slate-300 text-sm font-medium">({documentos?.length || 0} archivos)</span>}
                        </h2>

                        {esPresidente && carpetaSeleccionada && carpetas?.length > 0 && carpetaSeleccionada.id !== carpetas[0].id && documentos?.length === 0 && (
                            <button 
                                onClick={() => handleBorrarCarpeta(carpetaSeleccionada.id)}
                                className="text-red-500 bg-red-50 hover:bg-red-100 hover:text-red-700 px-4 py-2 rounded-xl font-black uppercase text-[10px] tracking-widest transition-all"
                            >
                                Eliminar Carpeta
                            </button>
                        )}
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        {documentos?.length === 0 && carpetaSeleccionada && (
                            <p className="text-slate-400 italic">Carpeta vacía.</p>
                        )}
                        {documentos?.map(d => (
                            <div key={d.id} className="group p-5 rounded-2xl border border-slate-100 hover:border-orange-200 hover:bg-orange-50/50 transition-all flex items-center justify-between">
                                <div className="flex items-center gap-4 overflow-hidden pr-2">
                                    <div className="bg-orange-100 p-3 rounded-xl text-orange-600 font-bold text-xs uppercase flex-shrink-0">PDF</div>
                                    <div className="overflow-hidden">
                                        <p className="font-bold text-slate-700 text-sm truncate" title={d.nombreOriginal}>{d.nombreOriginal}</p>
                                        <p className="text-[10px] text-slate-400 font-medium">Subido el {new Date(d.fechaSubida).toLocaleDateString()}</p>
                                    </div>
                                </div>
                                
                                {/* BOTONERA DE ARCHIVOS */}
                                <div className="flex items-center gap-2">
                                    <button 
                                        onClick={() => handleVerDocumento(d.id)}
                                        title="Ver PDF"
                                        className="flex-shrink-0 opacity-0 group-hover:opacity-100 bg-white p-2 rounded-lg text-blue-500 shadow-sm hover:scale-110 transition-all cursor-pointer"
                                    >
                                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>
                                    </button>

                                    {esPresidente && (
                                        <>
                                            <button 
                                                onClick={() => abrirModalMover(d)}
                                                title="Mover a otra carpeta"
                                                className="flex-shrink-0 opacity-0 group-hover:opacity-100 bg-white p-2 rounded-lg text-amber-500 shadow-sm hover:scale-110 transition-all cursor-pointer"
                                            >
                                                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" /></svg>
                                            </button>

                                            <button 
                                                onClick={() => handleBorrarDocumento(d.id)}
                                                title="Eliminar PDF"
                                                className="flex-shrink-0 opacity-0 group-hover:opacity-100 bg-white p-2 rounded-lg text-red-500 shadow-sm hover:scale-110 transition-all cursor-pointer"
                                            >
                                                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg>
                                            </button>
                                        </>
                                    )}
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            </main>

            {/* Modal Nueva Carpeta */}
            {showModalCarpeta && (
                <div className="fixed inset-0 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center p-4 z-50">
                    <form onSubmit={handleCrearCarpeta} className="bg-white p-8 rounded-[2.5rem] w-full max-w-sm shadow-2xl">
                        <h3 className="text-xl font-black mb-4">Nueva Carpeta</h3>
                        <input 
                            type="text" 
                            className="w-full p-4 bg-slate-50 border border-slate-100 rounded-2xl mb-4 outline-none focus:ring-2 focus:ring-orange-500/20"
                            placeholder="Nombre (Ej: Actas 2024)"
                            value={nuevoNombreCarpeta}
                            onChange={(e) => setNuevoNombreCarpeta(e.target.value)}
                            required
                        />
                        <div className="flex gap-3">
                            <button type="button" onClick={() => setShowModalCarpeta(false)} className="flex-1 py-3 font-bold text-slate-400">Cancelar</button>
                            <button type="submit" className="flex-1 bg-orange-600 text-white py-3 rounded-xl font-black uppercase text-xs">Crear</button>
                        </div>
                    </form>
                </div>
            )}

            {/* Modal Subir Archivo */}
            {showModalSubir && (
                <div className="fixed inset-0 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center p-4 z-50">
                    <form onSubmit={handleSubirArchivo} className="bg-white p-8 rounded-[2.5rem] w-full max-w-sm shadow-2xl">
                        <h3 className="text-xl font-black mb-2">Subir Archivo</h3>
                        <p className="text-xs text-slate-400 mb-6 font-bold uppercase tracking-widest">En: {carpetaSeleccionada?.nombre}</p>
                        <input 
                            type="file" 
                            className="w-full mb-6 text-sm text-slate-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-xs file:font-black file:bg-orange-100 file:text-orange-600"
                            onChange={(e) => setArchivoASubir(e.target.files[0])}
                            required
                        />
                        <div className="flex gap-3">
                            <button type="button" onClick={() => setShowModalSubir(false)} className="flex-1 py-3 font-bold text-slate-400">Cancelar</button>
                            <button type="submit" className="flex-1 bg-orange-600 text-white py-3 rounded-xl font-black uppercase text-xs">Subir</button>
                        </div>
                    </form>
                </div>
            )}

            {/* Modal Mover Archivo */}
            {showModalMover && (
                <div className="fixed inset-0 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center p-4 z-50">
                    <form onSubmit={handleMoverDocumento} className="bg-white p-8 rounded-[2.5rem] w-full max-w-sm shadow-2xl">
                        <h3 className="text-xl font-black mb-2">Mover Archivo</h3>
                        <p className="text-xs text-slate-500 mb-6 truncate">Archivo: <strong>{documentoAMover?.nombreOriginal}</strong></p>
                        
                        <label className="block text-[10px] font-black uppercase text-slate-400 mb-2 ml-1">Selecciona la carpeta destino</label>
                        <select 
                            className="w-full p-4 bg-slate-50 border border-slate-100 rounded-2xl mb-6 outline-none focus:ring-2 focus:ring-orange-500/20 font-medium text-slate-700 cursor-pointer"
                            value={carpetaDestinoId}
                            onChange={(e) => setCarpetaDestinoId(e.target.value)}
                            required
                        >
                            <option value="" disabled>Elige una carpeta...</option>
                            {carpetas.filter(c => c.id !== carpetaSeleccionada?.id).map(c => (
                                <option key={c.id} value={c.id}>{c.nombre}</option>
                            ))}
                        </select>

                        <div className="flex gap-3">
                            <button type="button" onClick={() => setShowModalMover(false)} className="flex-1 py-3 font-bold text-slate-400">Cancelar</button>
                            <button type="submit" disabled={!carpetaDestinoId} className="flex-1 bg-orange-600 text-white py-3 rounded-xl font-black uppercase text-xs disabled:opacity-50">Mover</button>
                        </div>
                    </form>
                </div>
            )}
        </div>
    );
};

export default DocumentosPage;