import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import avisoService from '../services/avisoService';
import comunidadService from '../services/comunidadService';

const CalendarioPage = () => {
    const navigate = useNavigate();
    const user = JSON.parse(localStorage.getItem('user'));

    const [currentDate, setCurrentDate] = useState(new Date());
    const [avisos, setAvisos] = useState([]);
    const [loading, setLoading] = useState(true);
    
    // Panel lateral
    const [selectedDate, setSelectedDate] = useState(null);
    const [selectedEvents, setSelectedEvents] = useState([]);

    useEffect(() => {
        cargarAvisos();
    }, []);

    const cargarAvisos = async () => {
        try {
            const detalle = await comunidadService.getDetalle(user.username);
            const datosAvisos = await avisoService.getAvisosByComunidad(detalle.id);
            setAvisos(datosAvisos || []);
        } catch (error) {
            console.error("Error cargando avisos", error);
        } finally {
            setLoading(false);
        }
    };

    // --- LÓGICA DEL CALENDARIO ---
    const daysInMonth = (month, year) => new Date(year, month + 1, 0).getDate();
    // Para que el Lunes sea el primer día de la semana (0 = Lunes, 6 = Domingo)
    const firstDayOfMonth = (month, year) => {
        let day = new Date(year, month, 1).getDay();
        return day === 0 ? 6 : day - 1; 
    };

    const monthNames = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"];
    const weekDays = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"];

    const currentMonth = currentDate.getMonth();
    const currentYear = currentDate.getFullYear();
    const totalDays = daysInMonth(currentMonth, currentYear);
    const startDay = firstDayOfMonth(currentMonth, currentYear);

    // Días vacíos antes del día 1
    const blanks = Array(startDay).fill(null);
    // Días del mes (1, 2, 3...)
    const days = Array.from({ length: totalDays }, (_, i) => i + 1);

    // --- FUNCIONES ---
    const prevMonth = () => setCurrentDate(new Date(currentYear, currentMonth - 1, 1));
    const nextMonth = () => setCurrentDate(new Date(currentYear, currentMonth + 1, 1));

    // Comprueba si un día específico tiene avisos
    const getAvisosForDay = (day) => {
        if (!day) return [];
        return avisos.filter(aviso => {
            // Spring Boot puede enviar la fecha como array o string, nos aseguramos con new Date()
            const fechaAviso = new Date(aviso.fechaCreacion);
            return fechaAviso.getDate() === day &&
                   fechaAviso.getMonth() === currentMonth &&
                   fechaAviso.getFullYear() === currentYear;
        });
    };

    const handleDayClick = (day) => {
        if (!day) return;
        const events = getAvisosForDay(day);
        setSelectedDate(new Date(currentYear, currentMonth, day));
        setSelectedEvents(events);
    };

    if (loading) return <div className="p-10 text-center font-black text-orange-600">Cargando calendario...</div>;

    return (
        <div className="min-h-screen bg-slate-50 p-8 animate-in fade-in duration-500 flex flex-col">
            <header className="max-w-6xl mx-auto mb-8 w-full">
                <button onClick={() => navigate('/comunidad')} className="text-orange-600 font-bold text-xs uppercase mb-2 block hover:underline">← Volver</button>
                <h1 className="text-4xl font-black text-slate-800">Calendario de Comunidad</h1>
                <p className="text-sm text-slate-400 font-medium mt-1">Revisa los avisos y eventos próximos.</p>
            </header>

            <main className="max-w-6xl mx-auto w-full flex flex-col lg:flex-row gap-8 flex-1">
                
                {/* ZONA IZQUIERDA: EL CALENDARIO */}
                <div className="flex-1 bg-white p-8 rounded-[2.5rem] border border-slate-200 shadow-sm relative">
                    
                    {/* Controles del mes */}
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

                    {/* Días de la semana */}
                    <div className="grid grid-cols-7 gap-4 mb-4">
                        {weekDays.map(day => (
                            <div key={day} className="text-center text-[10px] font-black uppercase tracking-widest text-slate-400">{day}</div>
                        ))}
                    </div>

                    {/* Cuadrícula de días */}
                    <div className="grid grid-cols-7 gap-2 md:gap-4">
                        {[...blanks, ...days].map((day, index) => {
                            const dayEvents = getAvisosForDay(day);
                            const hasAvisos = dayEvents.length > 0;
                            const isSelected = selectedDate?.getDate() === day && selectedDate?.getMonth() === currentMonth;

                            // Comprobar si es "Hoy"
                            const isToday = day === new Date().getDate() && currentMonth === new Date().getMonth() && currentYear === new Date().getFullYear();

                            return (
                                <div 
                                    key={index}
                                    onClick={() => handleDayClick(day)}
                                    className={`
                                        aspect-square flex flex-col items-center justify-center rounded-2xl relative cursor-pointer transition-all
                                        ${!day ? 'bg-transparent cursor-default' : 'bg-slate-50 hover:bg-orange-50 border hover:border-orange-200'}
                                        ${isSelected ? 'ring-2 ring-orange-500 bg-orange-50 border-orange-200' : 'border-transparent'}
                                        ${isToday && day ? 'bg-orange-100 text-orange-700 font-black' : 'text-slate-600 font-bold'}
                                    `}
                                >
                                    {day && <span className="text-sm md:text-lg">{day}</span>}
                                    
                                    {/* Indicadores de Eventos */}
                                    {day && hasAvisos && (
                                        <div className="absolute bottom-2 flex gap-1">
                                            <div className="w-1.5 h-1.5 md:w-2 md:h-2 rounded-full bg-orange-500"></div>
                                            {/* Futuro: Si tiene reserva poner div azul, si tiene junta poner div rojo */}
                                        </div>
                                    )}
                                </div>
                            );
                        })}
                    </div>
                </div>

                {/* ZONA DERECHA: PANEL DE DETALLES DEL DÍA */}
                <div className="lg:w-96 bg-white p-8 rounded-[2.5rem] border border-slate-200 shadow-sm flex flex-col h-full min-h-[400px]">
                    {selectedDate ? (
                        <>
                            <h3 className="text-xl font-black text-slate-800 mb-6 border-b border-slate-100 pb-4">
                                {selectedDate.getDate()} de {monthNames[selectedDate.getMonth()]}
                            </h3>
                            
                            <div className="flex-1 overflow-y-auto space-y-4">
                                {selectedEvents.length === 0 ? (
                                    <p className="text-sm text-slate-400 italic text-center mt-10">No hay eventos para este día.</p>
                                ) : (
                                    selectedEvents.map(ev => (
                                        <div key={ev.id} className="p-4 bg-orange-50 rounded-2xl border border-orange-100">
                                            <div className="flex items-center gap-2 mb-2">
                                                <span className="text-lg">📢</span>
                                                <span className="text-[10px] font-black text-orange-600 uppercase tracking-widest bg-orange-200 px-2 py-0.5 rounded-full">Aviso</span>
                                            </div>
                                            <h4 className="font-bold text-slate-800 text-sm mb-1">{ev.titulo}</h4>
                                            <p className="text-xs text-slate-600 leading-relaxed">{ev.descripcion}</p>
                                        </div>
                                    ))
                                )}
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
        </div>
    );
};

export default CalendarioPage;