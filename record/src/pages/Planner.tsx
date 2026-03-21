import { useState, useRef } from "react";
import { Trip } from "../store/mockData";
import { useTrips } from "../store/TripContext";
import { Link } from "react-router-dom";
import { format, differenceInDays } from "date-fns";
import { Map, Plane, Calendar, MapPin, X, Plus, Clock, Search, Trash2 } from "lucide-react";
import { useJsApiLoader, GoogleMap, Marker, Polyline, Autocomplete } from "@react-google-maps/api";
import ThemeToggle from "../components/ThemeToggle";
import { useTheme } from "../store/ThemeContext";
import { useLanguage } from "../store/LanguageContext";

const libraries: ("places")[] = ["places"];

export default function Planner() {
  const { trips, updateTrip } = useTrips();
  const { theme } = useTheme();
  const { t } = useLanguage();
  const upcomingTrips = trips.filter((t) => t.isUpcoming);
  
  const [activeMapTripId, setActiveMapTripId] = useState<string | null>(null);
  const [activeScheduleTripId, setActiveScheduleTripId] = useState<string | null>(null);
  
  const mapTrip = trips.find(t => t.id === activeMapTripId) || null;
  const scheduleTrip = trips.find(t => t.id === activeScheduleTripId) || null;

  const [isAddingLocation, setIsAddingLocation] = useState(false);
  const [pendingPlace, setPendingPlace] = useState<{name: string, lat: number, lng: number} | null>(null);
  const [selectedDate, setSelectedDate] = useState("");
  const [selectedTime, setSelectedTime] = useState("12:00");
  
  const autocompleteRef = useRef<google.maps.places.Autocomplete | null>(null);

  const { isLoaded } = useJsApiLoader({
    id: 'google-map-script',
    googleMapsApiKey: import.meta.env.VITE_GOOGLE_MAPS_API_KEY || "",
    libraries,
  });

  const today = new Date();

  const onPlaceChanged = () => {
    if (autocompleteRef.current !== null) {
      const place = autocompleteRef.current.getPlace();
      if (place.geometry && place.geometry.location && scheduleTrip) {
        setPendingPlace({
          name: place.name || place.formatted_address || "New Location",
          lat: place.geometry.location.lat(),
          lng: place.geometry.location.lng(),
        });
      }
    }
  };

  const handleSaveLocation = () => {
    if (!pendingPlace || !scheduleTrip || !selectedDate || !selectedTime) return;
    
    const newLoc = {
      id: Date.now().toString(),
      name: pendingPlace.name,
      lat: pendingPlace.lat,
      lng: pendingPlace.lng,
      date: new Date(`${selectedDate}T${selectedTime}`).toISOString(),
      photos: []
    };
    
    const updatedTrip = {
      ...scheduleTrip,
      locations: [...scheduleTrip.locations, newLoc].sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime())
    };
    
    updateTrip(updatedTrip);
    
    setPendingPlace(null);
    setSelectedDate("");
    setSelectedTime("12:00");
    setIsAddingLocation(false);
  };

  const handleDeleteLocation = (locId: string) => {
    if (!scheduleTrip) return;
    const updatedTrip = {
      ...scheduleTrip,
      locations: scheduleTrip.locations.filter(l => l.id !== locId)
    };
    updateTrip(updatedTrip);
  };

  const mapStyles = theme === 'dark' ? [
    { elementType: "geometry", stylers: [{ color: "#242f3e" }] },
    { elementType: "labels.text.stroke", stylers: [{ color: "#242f3e" }] },
    { elementType: "labels.text.fill", stylers: [{ color: "#746855" }] },
    {
      featureType: "administrative.locality",
      elementType: "labels.text.fill",
      stylers: [{ color: "#d59563" }],
    },
    {
      featureType: "poi",
      elementType: "labels.text.fill",
      stylers: [{ color: "#d59563" }],
    },
    {
      featureType: "poi.park",
      elementType: "geometry",
      stylers: [{ color: "#263c3f" }],
    },
    {
      featureType: "poi.park",
      elementType: "labels.text.fill",
      stylers: [{ color: "#6b9a76" }],
    },
    {
      featureType: "road",
      elementType: "geometry",
      stylers: [{ color: "#38414e" }],
    },
    {
      featureType: "road",
      elementType: "geometry.stroke",
      stylers: [{ color: "#212a37" }],
    },
    {
      featureType: "road",
      elementType: "labels.text.fill",
      stylers: [{ color: "#9ca5b3" }],
    },
    {
      featureType: "road.highway",
      elementType: "geometry",
      stylers: [{ color: "#746855" }],
    },
    {
      featureType: "road.highway",
      elementType: "geometry.stroke",
      stylers: [{ color: "#1f2835" }],
    },
    {
      featureType: "road.highway",
      elementType: "labels.text.fill",
      stylers: [{ color: "#f3d19c" }],
    },
    {
      featureType: "transit",
      elementType: "geometry",
      stylers: [{ color: "#2f3948" }],
    },
    {
      featureType: "transit.station",
      elementType: "labels.text.fill",
      stylers: [{ color: "#d59563" }],
    },
    {
      featureType: "water",
      elementType: "geometry",
      stylers: [{ color: "#17263c" }],
    },
    {
      featureType: "water",
      elementType: "labels.text.fill",
      stylers: [{ color: "#515c6d" }],
    },
    {
      featureType: "water",
      elementType: "labels.text.stroke",
      stylers: [{ color: "#17263c" }],
    },
  ] : [];

  return (
    <div className="min-h-screen bg-stone-50 dark:bg-[#0a0a0a] text-stone-900 dark:text-white p-6 pb-32 relative transition-colors duration-300">
      {/* Header */}
      <header className="mb-8 pt-4 flex justify-between items-start">
        <div>
          <h1 className="text-3xl font-bold tracking-tight mb-2">{t("planner.title")}</h1>
          <div className="flex items-center gap-2 text-stone-500 dark:text-white/60">
            <Plane size={16} />
            <span>{t("planner.upcomingTrips").replace("{{count}}", upcomingTrips.length.toString()).replace("{{s}}", upcomingTrips.length !== 1 ? 's' : '')}</span>
          </div>
        </div>
        <ThemeToggle />
      </header>

      {/* Trip List */}
      <div className="space-y-8">
        {upcomingTrips.map((trip) => {
          const daysLeft = differenceInDays(new Date(trip.startDate), today);
          
          return (
            <div
              key={trip.id}
              className="block group relative overflow-hidden rounded-3xl bg-white dark:bg-stone-800 border border-stone-200 dark:border-white/5 shadow-xl dark:shadow-2xl transition-colors duration-300"
            >
              {/* Cover Image */}
              <div className="h-48 w-full relative overflow-hidden">
                <img
                  src={trip.coverImage}
                  alt={trip.title}
                  className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-105"
                  referrerPolicy="no-referrer"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/40 to-transparent" />
                
                {/* Country Badge */}
                <div className="absolute top-4 right-4 px-3 py-1 rounded-full bg-black/40 backdrop-blur-md border border-white/20 flex items-center gap-2">
                  <span className="w-2 h-2 rounded-full" style={{ backgroundColor: trip.color }} />
                  <span className="text-xs font-bold tracking-wider uppercase text-white">
                    {trip.countries.map(c => c.name).join(", ")}
                  </span>
                </div>

                {/* Countdown Badge */}
                <div className="absolute top-4 left-4 px-3 py-1.5 rounded-xl bg-white/10 backdrop-blur-md border border-white/20 flex items-center gap-2 shadow-lg">
                  <Clock size={14} className="text-amber-400" />
                  <span className="text-sm font-bold text-white">
                    {daysLeft > 0 ? `D-${daysLeft}` : daysLeft === 0 ? "D-Day" : "Started"}
                  </span>
                </div>
              </div>

              {/* Content */}
              <div className="p-6 relative">
                <div className="flex justify-between items-end mb-4">
                  <div>
                    <h2 className="text-2xl font-bold mb-1">{trip.title}</h2>
                    <p className="text-sm text-stone-500 dark:text-white/50 font-mono">
                      {format(new Date(trip.startDate), "MMM d")} - {format(new Date(trip.endDate), "MMM d, yyyy")}
                    </p>
                  </div>
                  <Link
                    to={`/trip/${trip.id}`}
                    className="px-4 py-2 rounded-full text-sm font-bold shadow-lg hover:opacity-90 transition-opacity"
                    style={{ backgroundColor: trip.color, color: "#fff" }}
                  >
                    {t("planner.view")}
                  </Link>
                </div>
                
                <p className="text-stone-600 dark:text-white/70 text-sm line-clamp-2 leading-relaxed mb-6">
                  {trip.description}
                </p>

                {/* Action Buttons */}
                <div className="flex gap-3">
                  <button 
                    onClick={() => setActiveMapTripId(trip.id)}
                    className="flex-1 flex items-center justify-center gap-2 py-3 rounded-xl bg-stone-100 dark:bg-white/5 hover:bg-stone-200 dark:hover:bg-white/10 transition-colors border border-stone-200 dark:border-white/5 text-stone-700 dark:text-white"
                  >
                    <Map size={16} />
                    <span className="text-sm font-medium">{t("planner.openMap")}</span>
                  </button>
                  <button 
                    onClick={() => setActiveScheduleTripId(trip.id)}
                    className="flex-1 flex items-center justify-center gap-2 py-3 rounded-xl bg-stone-100 dark:bg-white/5 hover:bg-stone-200 dark:hover:bg-white/10 transition-colors border border-stone-200 dark:border-white/5 text-stone-700 dark:text-white"
                  >
                    <Calendar size={16} />
                    <span className="text-sm font-medium">{t("planner.schedule")}</span>
                  </button>
                </div>
              </div>
            </div>
          );
        })}

        {upcomingTrips.length === 0 && (
          <div className="text-center py-20 text-stone-400 dark:text-white/40">
            <Plane size={48} className="mx-auto mb-4 opacity-20" />
            <p>{t("planner.noUpcoming")}</p>
            <Link to="/create" className="text-amber-600 dark:text-amber-400 hover:underline mt-2 inline-block">{t("planner.planNew")}</Link>
          </div>
        )}
      </div>

      {/* Map Modal */}
      {mapTrip && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm">
          <div className="bg-white dark:bg-stone-800 border border-stone-200 dark:border-white/10 rounded-3xl w-full max-w-2xl overflow-hidden shadow-2xl flex flex-col h-[70vh] transition-colors duration-300">
            <div className="p-4 flex justify-between items-center border-b border-stone-200 dark:border-white/10">
              <div>
                <h3 className="font-bold text-lg text-stone-900 dark:text-white">{mapTrip.title} Map</h3>
                <p className="text-xs text-stone-500 dark:text-white/50">{mapTrip.locations.length} locations planned</p>
              </div>
              <button 
                onClick={() => setActiveMapTripId(null)}
                className="p-2 bg-stone-100 dark:bg-white/5 rounded-full hover:bg-stone-200 dark:hover:bg-white/10 transition-colors text-stone-500 dark:text-white"
              >
                <X size={20} />
              </button>
            </div>
            <div className="flex-1 relative">
              {!isLoaded ? (
                <div className="flex items-center justify-center h-full text-stone-500 dark:text-white/40">Loading Google Maps...</div>
              ) : mapTrip.locations.length > 0 ? (
                <GoogleMap
                  mapContainerStyle={{ width: '100%', height: '100%' }}
                  center={{ lat: mapTrip.locations[0].lat, lng: mapTrip.locations[0].lng }}
                  zoom={5}
                  options={{
                    styles: mapStyles,
                    disableDefaultUI: true,
                    zoomControl: true,
                  }}
                >
                  {mapTrip.locations.map((loc) => (
                    <Marker 
                      key={loc.id} 
                      position={{ lat: loc.lat, lng: loc.lng }}
                      title={loc.name}
                    />
                  ))}
                  {mapTrip.locations.length > 1 && (
                    <Polyline 
                      path={mapTrip.locations.map(loc => ({ lat: loc.lat, lng: loc.lng }))}
                      options={{
                        strokeColor: mapTrip.color,
                        strokeOpacity: 1.0,
                        strokeWeight: 3,
                      }}
                    />
                  )}
                </GoogleMap>
              ) : (
                <div className="flex items-center justify-center h-full text-stone-500 dark:text-white/40">
                  No locations added yet.
                </div>
              )}
            </div>
          </div>
        </div>
      )}

      {/* Schedule Modal */}
      {scheduleTrip && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm">
          <div className="bg-white dark:bg-stone-800 border border-stone-200 dark:border-white/10 rounded-3xl w-full max-w-md overflow-hidden shadow-2xl flex flex-col max-h-[80vh] transition-colors duration-300">
            <div className="p-4 flex justify-between items-center border-b border-stone-200 dark:border-white/10 bg-white dark:bg-stone-800 sticky top-0 z-10 transition-colors duration-300">
              <div>
                <h3 className="font-bold text-lg text-stone-900 dark:text-white">{scheduleTrip.title} Itinerary</h3>
                <p className="text-xs text-stone-500 dark:text-white/50">
                  {format(new Date(scheduleTrip.startDate), "MMM d")} - {format(new Date(scheduleTrip.endDate), "MMM d")}
                </p>
              </div>
              <button 
                onClick={() => {
                  setActiveScheduleTripId(null);
                  setIsAddingLocation(false);
                  setPendingPlace(null);
                }}
                className="p-2 bg-stone-100 dark:bg-white/5 rounded-full hover:bg-stone-200 dark:hover:bg-white/10 transition-colors text-stone-500 dark:text-white"
              >
                <X size={20} />
              </button>
            </div>
            
            <div className="p-6 overflow-y-auto flex-1">
              {scheduleTrip.locations.length > 0 ? (
                <div className="space-y-6 relative before:absolute before:inset-0 before:ml-[11px] before:-transtone-x-px before:h-full before:w-0.5 before:bg-stone-200 dark:before:bg-white/10">
                  {scheduleTrip.locations.map((loc, idx) => (
                    <div key={loc.id} className="relative flex items-start gap-4">
                      <div 
                        className="w-6 h-6 rounded-full border-4 border-white dark:border-stone-800 shrink-0 z-10 mt-1 transition-colors duration-300"
                        style={{ backgroundColor: scheduleTrip.color }}
                      />
                      <div className="flex-1 bg-stone-50 dark:bg-white/5 border border-stone-200 dark:border-white/5 rounded-2xl p-4 group/item">
                        <div className="flex justify-between items-start mb-1">
                          <h4 className="font-bold text-stone-900 dark:text-white pr-6">{loc.name}</h4>
                          <div className="flex flex-col items-end gap-2">
                            <span className="text-xs text-stone-500 dark:text-white/40 font-mono">
                              {format(new Date(loc.date), "MMM d, HH:mm")}
                            </span>
                            <button 
                              onClick={() => handleDeleteLocation(loc.id)}
                              className="text-red-500/50 hover:text-red-500 transition-colors opacity-0 group-hover/item:opacity-100"
                            >
                              <Trash2 size={14} />
                            </button>
                          </div>
                        </div>
                        <div className="flex items-center gap-1 text-xs text-stone-500 dark:text-white/50 mt-1">
                          <MapPin size={12} />
                          <span>Lat: {loc.lat.toFixed(2)}, Lng: {loc.lng.toFixed(2)}</span>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="text-center py-10 text-stone-400 dark:text-white/40">
                  <Calendar size={32} className="mx-auto mb-3 opacity-20" />
                  <p>Your itinerary is empty.</p>
                </div>
              )}

              {isAddingLocation ? (
                <div className="mt-8 p-4 bg-stone-50 dark:bg-white/5 rounded-2xl border border-stone-200 dark:border-white/10">
                  <div className="flex justify-between items-center mb-3">
                    <h4 className="font-medium text-sm text-stone-900 dark:text-white">Add New Location</h4>
                    <button onClick={() => { setIsAddingLocation(false); setPendingPlace(null); }} className="text-stone-400 dark:text-white/50 hover:text-stone-600 dark:hover:text-white">
                      <X size={16} />
                    </button>
                  </div>
                  
                  {!pendingPlace ? (
                    isLoaded ? (
                      <Autocomplete
                        onLoad={(autocomplete) => {
                          autocompleteRef.current = autocomplete;
                        }}
                        onPlaceChanged={onPlaceChanged}
                      >
                        <div className="relative">
                          <Search size={16} className="absolute left-3 top-1/2 -transtone-y-1/2 text-stone-400 dark:text-white/50" />
                          <input
                            type="text"
                            placeholder="Search on Google Maps..."
                            className="w-full bg-white dark:bg-stone-900 border border-stone-200 dark:border-white/10 rounded-xl py-2 pl-9 pr-4 text-sm text-stone-900 dark:text-white placeholder:text-stone-400 dark:placeholder:text-white/30 focus:outline-none focus:border-amber-500 dark:focus:border-amber-400 transition-colors"
                          />
                        </div>
                      </Autocomplete>
                    ) : (
                      <div className="text-sm text-stone-500 dark:text-white/50">Loading Google Maps...</div>
                    )
                  ) : (
                    <div className="space-y-4">
                      <div className="p-3 bg-white dark:bg-stone-900 rounded-xl border border-stone-200 dark:border-white/10 flex items-center gap-2">
                        <MapPin size={16} className="text-amber-600 dark:text-amber-400 shrink-0" />
                        <span className="text-sm font-medium truncate text-stone-900 dark:text-white">{pendingPlace.name}</span>
                      </div>
                      <div className="grid grid-cols-2 gap-3">
                        <div>
                          <label className="block text-xs text-stone-500 dark:text-white/50 mb-1">Date</label>
                          <input 
                            type="date" 
                            value={selectedDate} 
                            onChange={e => setSelectedDate(e.target.value)} 
                            className="w-full bg-white dark:bg-stone-900 border border-stone-200 dark:border-white/10 rounded-xl py-2 px-3 text-sm text-stone-900 dark:text-white focus:outline-none focus:border-amber-500 dark:focus:border-amber-400 dark:[color-scheme:dark]" 
                          />
                        </div>
                        <div>
                          <label className="block text-xs text-stone-500 dark:text-white/50 mb-1">Time</label>
                          <input 
                            type="time" 
                            value={selectedTime} 
                            onChange={e => setSelectedTime(e.target.value)} 
                            className="w-full bg-white dark:bg-stone-900 border border-stone-200 dark:border-white/10 rounded-xl py-2 px-3 text-sm text-stone-900 dark:text-white focus:outline-none focus:border-amber-500 dark:focus:border-amber-400 dark:[color-scheme:dark]" 
                          />
                        </div>
                      </div>
                      <div className="flex gap-2 pt-2">
                        <button 
                          onClick={() => setPendingPlace(null)} 
                          className="flex-1 py-2 rounded-xl border border-stone-200 dark:border-white/10 text-sm font-medium text-stone-700 dark:text-white hover:bg-stone-100 dark:hover:bg-white/5 transition-colors"
                        >
                          Back
                        </button>
                        <button 
                          onClick={handleSaveLocation} 
                          disabled={!selectedDate || !selectedTime} 
                          className="flex-1 py-2 rounded-xl bg-amber-600 dark:bg-amber-500 text-white dark:text-black text-sm font-bold hover:bg-amber-700 dark:hover:bg-amber-400 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                          Save
                        </button>
                      </div>
                    </div>
                  )}
                </div>
              ) : (
                <button 
                  onClick={() => setIsAddingLocation(true)}
                  className="w-full mt-8 py-4 rounded-2xl border border-dashed border-stone-300 dark:border-white/20 text-stone-500 dark:text-white/60 hover:text-stone-700 dark:hover:text-white hover:bg-stone-50 dark:hover:bg-white/5 hover:border-stone-400 dark:hover:border-white/40 transition-all flex items-center justify-center gap-2"
                >
                  <Plus size={18} />
                  <span className="font-medium">Add Location</span>
                </button>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
