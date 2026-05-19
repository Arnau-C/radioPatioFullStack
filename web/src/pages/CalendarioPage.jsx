import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import avisoService from '../services/avisoService';
import reservaService from '../services/reservaService';
import comunidadService from '../services/comunidadService';

const toYMD = (year, month, day) => {
    const mm = String(month + 1).padStart(2, '0');
    const dd = String(day).padStart(2, '0');
    return `${year}-${mm}-${dd}`;
};

const CalendarioPage = () => {
    const navigate = useNavigate();
    const user = JSON.parse(localStorage.getItem('user'));
    const esPresidente = user?.rol === 'PRESIDENTE';

    const [currentDate, setCurrentDate] = useState(new Date());
    const [loading, setLoading] = useState(true);
    const [avisosDias, setAvisosDias] = useState({});
    const [reservas, setReservas] = useState([]);
    const [comunidadId, setComunidadId] = useState(null);

    const [selectedDate, setSelectedDate] = useState(null);
    const [selectedAvisos, setSelectedAvisos] = useState([]);
    const [selectedReservas, setSelectedReservas] = useState([]);

    const [showModal, setShowModal] = useState(false);
    const [formTitulo, setFormTitulo] = useState('');
    const [formDescripcion, setFormDescripcion] = useState('');
    const [formFecha, setFormFecha] = useState('');
    const [saving, setSaving] = useState(false);
    const [saveError, setSaveError] = useState('');

    const currentMonth = currentDate.getMonth();
    const currentYear = currentDate.getFullYear();

    const monthNames = ["Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"];
    const weekDays = ["Lun","Mar","Mié","Jue","Vie","Sáb","Dom"];

    const daysInMonth = (m, y) => new Date(y, m + 1, 0).getDate();
    const firstDayOfMonth = (m, y) => { const d = new Date(y, m, 1).getDay(); return d === 0 ? 6 : d - 1; };

    const totalDays = daysInMonth(currentMonth, currentYear);
    const startDay = firstDayOfMonth(currentMonth, currentYear);
    const blanks = Array(startDay).fill(null);
    const days = Array.from({ length: totalDays }, (_, i) => i + 1);

    const cargarDatos = useCallback(async () => {
        setLoading(true);
        setAvisosDias({});
        setReservas([]);
        setSelectedDate(null);
        setSelectedAvisos([]);
        setSelectedReservas([]);
        try {
            let cid = comunidadId;
            if (!cid) {
                const detalle = await comunidadService.getDetalle(user.username);
                cid = detalle.id;
                setComunidadId(cid);
            }
            const numDias = daysInMonth(currentMonth, currentYear);
            const fechas = Array.from({ length: numDias }, (_, i) => toYMD(currentYear, currentMonth, i + 1));
            const resultados = await Promise.all(fechas.map(f => avisoService.getAvisosByFecha(f).catch(() => [])));
            const mapa = {};
            fechas.forEach((f, i) => { if (resultados[i]?.length > 0) mapa[f] = resultados[i]; });
            setAvisosDias(mapa);
            const todasReservas = await reservaService.getReservasByComunidad(cid);
            const reservasMes = (todasReservas || []).filter(r => {
                const fi = new Date(r.fechaInicio);
                return fi.getFullYear() === currentYear && fi.getMonth() === currentMonth && r.estado === 'ACTIVA';
            });
            setReservas(reservasMes);
        } catch (err) {
            console.error("Error cargando datos del calendario:", err);
        } finally {
            setLoading(false);
        }
    }, [currentMonth, currentYear]); // eslint-disable-line

    useEffect(() => { cargarDatos(); }, [cargarDatos]);

    const getAvisosForDay = (day) => {
        if (!day) return [];
        return avisosDias[toYMD(currentYear, currentMonth, day)] || [];
    };

    const getReservasForDay = (day) => {
        if (!day) return [];
        return reservas.filter(r => {
            const fi = new Date(r.fechaInicio);
            return fi.getFullYear() === currentYear && fi.getMonth() === currentMonth && fi.getDate() === day;
        });
    };

    const handleDayClick = (day) => {
        if (!day) return;
        setSelectedDate(new Date(currentYear, currentMonth, day));
        setSelectedAvisos(getAvisosForDay(day));
        setSelectedReservas(getReservasForDay(day));
    };

    const prevMonth = () => setCurrentDate(new Date(currentYear, currentMonth - 1, 1));
    const nextMonth = () => setCurrentDate(new Date(currentYear, currentMonth + 1, 1));

    const abrirModal = () => {
        const fechaDefault = selectedDate
            ? toYMD(selectedDate.getFullYear(), selectedDate.getMonth(), selectedDate.getDate())
            : toYMD(currentYear, currentMonth, new Date().getDate());
        setFormFecha(fechaDefault);
        setFormTitulo('');
        setFormDescripcion('');
        setSaveError('');
        setShowModal(true);
    };

    const handleCrearAviso = async (e) => {
        e.preventDefault();
        if (!formTitulo.trim() || !formDescripcion.trim() || !formFecha) { setSaveError('Rellena todos los campos.'); return; }
        setSaving(true);
        setSaveError('');
        try {
            await avisoService.crearAviso(formTitulo.trim(), formDescripcion.trim(), formFecha);
            setShowModal(false);
            await cargarDatos();
        } catch (err) {
            setSaveError(err?.response?.data?.error || 'Error al crear el aviso.');
        } finally {
            setSaving(false);
        }
    };

    if (loading) {
        return (
            <div className="min-h-screen bg-slate-50 flex items-center justify-center">
                <p className="text-orange-600 font-black text-lg animate-pulse">Cargando calendario...</p>
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-slate-50 p-8 animate-in fade-in duration-500 flex flex-col">
            <header className="max-w-6xl mx-auto mb-8 w-full flex items-start justify-between">
                <div>
                    <button onClick={() => navigate('/comunidad')} className="text-orange-600 font-bold text-xs uppercase mb-2 block hover:underline">← Volver</button>
                    <h1 className="text-4xl font-black text-slate-800">Calendario de Comunidad</h1>
                    <p className="text-sm text-slate-400 font-medium mt-1">Revisa los avisos y reservas próximas.</p>
                </div>
                {esPresidente && (
                    <button onClick={abrirModal} className="mt-6 flex items-center gap-2 bg-orange-500 hover:bg-orange-600 text-white font-black text-sm px-5 py-3 rounded-2xl shadow-md transition-all">
                        <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M12 4v16m8-8H4" /></svg>
                        Nuevo aviso
                    </button>
                )}
            </header>

            <main className="max-w-6xl mx-auto w-full flex flex-col lg:flex-row gap-8 flex-1">
                <div className="flex-1 bg-white p-8 rounded-[2.5rem] border border-slate-200 shadow-sm">
                    <div className="flex items-center justify-between mb-8">
                        <button onClick={prevMonth} className="p-3 rounded-xl hover:bg-slate-100 text-slate-500 transition-colors">
                            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 19l-7-7 7-7" /></svg>
                        </button>
                        <h2 className="text-2xl font-black text-slate-800 uppercase tracking-wide">
                            {monthNames[currentMonth]} <span className="text-orange-600">{currentYear}</span>
                        </h2>
                        <button onClick={nextMonth} className="p-3 rounded-xl hover:bg-slate-100 text-slate-500 transition-colors">
                            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 5l7 7-7 7" /></svg>
                        </button>
                    </div>
                    <div className="grid grid-cols-7 gap-4 mb-4">
                        {weekDays.map(day => (
                            <div key={day} className="text-center text-[10px] font-black uppercase tracking-widest text-slate-400">{day}</div>
                        ))}
                    </div>
                    <div className="grid grid-cols-7 gap-2 md:gap-4">
                        {[...blanks, ...days].map((day, index) => {
                            const hasAvisos = getAvisosForDay(day).length > 0;
                            const hasReservas = getReservasForDay(day).length > 0;
                            const isSelected = selectedDate?.getDate() === day && selectedDate?.getMonth() === currentMonth && selectedDate?.getFullYear() === currentYear;
                            const isToday = day === new Date().getDate() && currentMonth === new Date().getMonth() && currentYear === new Date().getFullYear();
                            return (
                                <div key={index} onClick={() => handleDayClick(day)}
                                    className={`aspect-square flex flex-col items-center justify-center rounded-2xl relative transition-all
                                        ${!day ? 'bg-transparent cursor-default' : 'bg-slate-50 hover:bg-orange-50 border hover:border-orange-200 cursor-pointer'}
                                        ${isSelected ? 'ring-2 ring-orange-500 bg-orange-50 border-orange-200' : 'border-transparent'}
                                        ${isToday && day ? 'bg-orange-100 text-orange-700 font-black' : 'text-slate-600 font-bold'}`}>
                                    {day && <span className="text-sm md:text-lg leading-none">{day}</span>}
                                    {day && (hasAvisos || hasReservas) && (
                                        <div className="absolute bottom-1.5 flex gap-1 items-center">
                                            {hasAvisos && <span className="w-1.5 h-1.5 md:w-2 md:h-2 rounded-full bg-red-500 block" />}
                                            {hasReservas && <span className="w-1.5 h-1.5 md:w-2 md:h-2 rounded-full bg-blue-500 block" />}
                                        </div>
                                    )}
                                </div>
                            );
                        })}
                    </div>
                    <div className="flex items-center gap-6 mt-6 pt-4 border-t border-slate-100">
                        <div className="flex items-center gap-2">
                            <span className="w-2.5 h-2.5 rounded-full bg-red-500 block" />
                            <span className="text-xs text-slate-500 font-semibold">Aviso</span>
                        </div>
                        <div className="flex items-center gap-2">
                            <span className="w-2.5 h-2.5 rounded-full bg-blue-500 block" />
                            <span className="text-xs text-slate-500 font-semibold">Reserva</span>
                        </div>
                    </div>
                </div>

                <div className="lg:w-96 bg-white p-8 rounded-[2.5rem] border border-slate-200 shadow-sm flex flex-col h-full min-h-[400px]">
                    {selectedDate ? (
                        <>
                            <div className="flex items-center justify-between mb-6 border-b border-slate-100 pb-4">
                                <h3 className="text-xl font-black text-slate-800">
                                    {selectedDate.getDate()} de {monthNames[selectedDate.getMonth()]}
                                </h3>
                                {esPresidente && (
                                    <button onClick={abrirModal} title="Crear aviso para este día"
                                        className="p-2 rounded-xl bg-orange-100 hover:bg-orange-200 text-orange-600 transition-colors">
                                        <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M12 4v16m8-8H4" /></svg>
                                    </button>
                                )}
                            </div>
                            <div className="flex-1 overflow-y-auto space-y-4">
                                {selectedAvisos.length === 0 && selectedReservas.length === 0 && (
                                    <p className="text-sm text-slate-400 italic text-center mt-10">No hay eventos para este día.</p>
                                )}
                                {selectedAvisos.map(av => (
                                    <div key={`aviso-${av.id}`} className="p-4 bg-red-50 rounded-2xl border border-red-100">
                                        <div className="flex items-center gap-2 mb-2">
                                            <span className="w-2 h-2 rounded-full bg-red-500 block flex-shrink-0" />
                                            <span className="text-[10px] font-black text-red-600 uppercase tracking-widest bg-red-100 px-2 py-0.5 rounded-full">Aviso</span>
                                        </div>
                                        <h4 className="font-bold text-slate-800 text-sm mb-1">{av.titulo}</h4>
                                        <p className="text-xs text-slate-600 leading-relaxed">{av.descripcion}</p>
                                        <p className="text-[10px] text-slate-400 mt-2">Por: {av.creadorUsername}</p>
                                    </div>
                                ))}
                                {selectedReservas.map(res => {
                                    const inicio = new Date(res.fechaInicio);
                                    const fin = new Date(res.fechaFin);
                                    const hhmm = d => `${String(d.getHours()).padStart(2,'0')}:${String(d.getMinutes()).padStart(2,'0')}`;
                                    return (
                                        <div key={`reserva-${res.id}`} className="p-4 bg-blue-50 rounded-2xl border border-blue-100">
                                            <div className="flex items-center gap-2 mb-2">
                                                <span className="w-2 h-2 rounded-full bg-blue-500 block flex-shrink-0" />
                                                <span className="text-[10px] font-black text-blue-600 uppercase tracking-widest bg-blue-100 px-2 py-0.5 rounded-full">Reserva</span>
                                            </div>
                                            <h4 className="font-bold text-slate-800 text-sm mb-1">{res.recurso?.nombre || 'Recurso'}</h4>
                                            <p className="text-xs text-slate-600">{hhmm(inicio)} – {hhmm(fin)}</p>
                                            <p className="text-[10px] text-slate-400 mt-1">Por: {res.usuario?.username || '—'}</p>
                                        </div>
                                    );
                                })}
                            </div>
                        </>
                    ) : (
                        <div className="flex-1 flex flex-col items-center justify-center text-slate-400 space-y-4 opacity-50">
                            <svg className="w-16 h-16" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" /></svg>
                            <p className="text-sm font-bold uppercase tracking-widest text-center">Selecciona un día para ver los detalles</p>
                        </div>
                    )}
                </div>
            </main>

            {showModal && (
                <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4">
                    <div className="bg-white rounded-[2.5rem] shadow-2xl w-full max-w-md p-8">
                        <div className="flex items-center justify-between mb-6">
                            <h2 className="text-2xl font-black text-slate-800">Nuevo aviso</h2>
                            <button onClick={() => setShowModal(false)} className="p-2 rounded-xl hover:bg-slate-100 text-slate-400 transition-colors">
                                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" /></svg>
                            </button>
                        </div>
                        <form onSubmit={handleCrearAviso} className="space-y-4">
                            <div>
                                <label className="block text-xs font-black text-slate-500 uppercase tracking-widest mb-1">Fecha del aviso</label>
                                <input type="date" value={formFecha} onChange={e => setFormFecha(e.target.value)} required
                                    className="w-full border border-slate-200 rounded-2xl px-4 py-3 text-sm font-semibold text-slate-700 focus:outline-none focus:ring-2 focus:ring-orange-400 bg-slate-50" />
                            </div>
                            <div>
                                <label className="block text-xs font-black text-slate-500 uppercase tracking-widest mb-1">Título</label>
                                <input type="text" value={formTitulo} onChange={e => setFormTitulo(e.target.value)} placeholder="Ej: Reunión de vecinos" required maxLength={100}
                                    className="w-full border border-slate-200 rounded-2xl px-4 py-3 text-sm font-semibold text-slate-700 focus:outline-none focus:ring-2 focus:ring-orange-400 bg-slate-50" />
                            </div>
                            <div>
                                <label className="block text-xs font-black text-slate-500 uppercase tracking-widest mb-1">Descripción</label>
                                <textarea value={formDescripcion} onChange={e => setFormDescripcion(e.target.value)} placeholder="Detalla el aviso..." required rows={4} maxLength={500}
                                    className="w-full border border-slate-200 rounded-2xl px-4 py-3 text-sm font-semibold text-slate-700 focus:outline-none focus:ring-2 focus:ring-orange-400 bg-slate-50 resize-none" />
                            </div>
                            {saveError && <p className="text-xs text-red-500 font-semibold bg-red-50 px-4 py-2 rounded-xl">{saveError}</p>}
                            <div className="flex gap-3 pt-2">
                                <button type="button" onClick={() => setShowModal(false)}
                                    className="flex-1 py-3 rounded-2xl border border-slate-200 text-slate-500 font-black text-sm hover:bg-slate-50 transition-colors">Cancelar</button>
                                <button type="submit" disabled={saving}
                                    className="flex-1 py-3 rounded-2xl bg-orange-500 hover:bg-orange-600 text-white font-black text-sm transition-colors disabled:opacity-50">
                                    {saving ? 'Guardando...' : 'Crear aviso'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
};

export default CalendarioPage;