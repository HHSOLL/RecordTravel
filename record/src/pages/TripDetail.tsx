import { useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { useTrips } from "../store/TripContext";
import { ArrowLeft, Share2, Edit3, MoreVertical, Map as MapIcon, List } from "lucide-react";
import { format } from "date-fns";
import { useJsApiLoader, GoogleMap, Marker, Polyline, OverlayViewF } from "@react-google-maps/api";
import { cn } from "../lib/utils";
import { useTheme } from "../store/ThemeContext";
import { useLanguage } from "../store/LanguageContext";

const libraries: ("places")[] = ["places"];

export default function TripDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { trips } = useTrips();
  const { theme } = useTheme();
  const { t } = useLanguage();
  const trip = trips.find((t) => t.id === id);
  const [viewMode, setViewMode] = useState<'timeline' | 'map'>('timeline');

  const { isLoaded } = useJsApiLoader({
    id: 'google-map-script',
    googleMapsApiKey: import.meta.env.VITE_GOOGLE_MAPS_API_KEY || "",
    libraries,
  });

  if (!trip) return <div className="p-8 text-stone-900 dark:text-white">Trip not found</div>;

  const center = trip.locations.length > 0 
    ? { lat: trip.locations[0].lat, lng: trip.locations[0].lng } 
    : { lat: 0, lng: 0 };

  const mapStyles = theme === 'dark' ? [
    { elementType: "geometry", stylers: [{ color: "#242f3e" }] },
    { elementType: "labels.text.stroke", stylers: [{ color: "#242f3e" }] },
    { elementType: "labels.text.fill", stylers: [{ color: "#746855" }] },
    { featureType: "administrative.locality", elementType: "labels.text.fill", stylers: [{ color: "#d59563" }] },
    { featureType: "poi", elementType: "labels.text.fill", stylers: [{ color: "#d59563" }] },
    { featureType: "poi.park", elementType: "geometry", stylers: [{ color: "#263c3f" }] },
    { featureType: "poi.park", elementType: "labels.text.fill", stylers: [{ color: "#6b9a76" }] },
    { featureType: "road", elementType: "geometry", stylers: [{ color: "#38414e" }] },
    { featureType: "road", elementType: "geometry.stroke", stylers: [{ color: "#212a37" }] },
    { featureType: "road", elementType: "labels.text.fill", stylers: [{ color: "#9ca5b3" }] },
    { featureType: "road.highway", elementType: "geometry", stylers: [{ color: "#746855" }] },
    { featureType: "road.highway", elementType: "geometry.stroke", stylers: [{ color: "#1f2835" }] },
    { featureType: "road.highway", elementType: "labels.text.fill", stylers: [{ color: "#f3d19c" }] },
    { featureType: "transit", elementType: "geometry", stylers: [{ color: "#2f3948" }] },
    { featureType: "transit.station", elementType: "labels.text.fill", stylers: [{ color: "#d59563" }] },
    { featureType: "water", elementType: "geometry", stylers: [{ color: "#17263c" }] },
    { featureType: "water", elementType: "labels.text.fill", stylers: [{ color: "#515c6d" }] },
    { featureType: "water", elementType: "labels.text.stroke", stylers: [{ color: "#17263c" }] },
  ] : [];

  return (
    <div className="min-h-screen bg-stone-50 dark:bg-[#0a0a0a] text-stone-900 dark:text-white flex flex-col transition-colors duration-300">
      {/* Header */}
      <header className="p-6 flex items-center justify-between z-10 bg-stone-50/80 dark:bg-[#0a0a0a]/80 backdrop-blur-md sticky top-0 transition-colors duration-300">
        <button onClick={() => navigate(-1)} className="p-2 bg-stone-200 dark:bg-white/5 rounded-full hover:bg-stone-300 dark:hover:bg-white/10 transition-colors">
          <ArrowLeft size={20} />
        </button>
        <div className="text-center flex-1">
          <h1 className="text-xl font-bold">{trip.title}</h1>
          <p className="text-xs text-stone-500 dark:text-white/50">{format(new Date(trip.startDate), "MMM d")} - {format(new Date(trip.endDate), "MMM d, yyyy")}</p>
        </div>
        <div className="flex gap-2">
          <button className="p-2 bg-stone-200 dark:bg-white/5 rounded-full hover:bg-stone-300 dark:hover:bg-white/10 transition-colors">
            <Share2 size={20} />
          </button>
          <button className="p-2 bg-stone-200 dark:bg-white/5 rounded-full hover:bg-stone-300 dark:hover:bg-white/10 transition-colors">
            <MoreVertical size={20} />
          </button>
        </div>
      </header>

      {/* View Toggle */}
      <div className="px-6 pb-4 z-10 bg-stone-50/80 dark:bg-[#0a0a0a]/80 backdrop-blur-md sticky top-[88px] flex justify-center transition-colors duration-300">
        <div className="bg-stone-200 dark:bg-white/5 p-1 rounded-full flex gap-1 border border-stone-300 dark:border-white/10">
          <button
            onClick={() => setViewMode('timeline')}
            className={cn(
              "flex items-center gap-2 px-4 py-2 rounded-full text-sm font-medium transition-colors",
              viewMode === 'timeline' ? "bg-white dark:bg-white/10 text-stone-900 dark:text-white shadow-sm" : "text-stone-500 dark:text-white/50 hover:text-stone-700 dark:hover:text-white/80"
            )}
          >
            <List size={16} />
            {t("trip.timeline")}
          </button>
          <button
            onClick={() => setViewMode('map')}
            className={cn(
              "flex items-center gap-2 px-4 py-2 rounded-full text-sm font-medium transition-colors",
              viewMode === 'map' ? "bg-white dark:bg-white/10 text-stone-900 dark:text-white shadow-sm" : "text-stone-500 dark:text-white/50 hover:text-stone-700 dark:hover:text-white/80"
            )}
          >
            <MapIcon size={16} />
            {t("trip.map")}
          </button>
        </div>
      </div>

      {viewMode === 'timeline' ? (
        <>
          {/* Map Area */}
          <div className="h-64 w-full relative z-0">
            {!isLoaded ? (
              <div className="flex items-center justify-center h-full text-stone-500 dark:text-white/40">Loading Google Maps...</div>
            ) : (
              <GoogleMap
                mapContainerStyle={{ width: '100%', height: '100%' }}
                center={center}
                zoom={5}
                options={{
                  styles: mapStyles,
                  disableDefaultUI: true,
                  zoomControl: false,
                }}
              >
                {trip.locations.map((loc) => (
                  <Marker 
                    key={loc.id} 
                    position={{ lat: loc.lat, lng: loc.lng }}
                    title={loc.name}
                  />
                ))}
                {trip.locations.length > 1 && (
                  <Polyline 
                    path={trip.locations.map(loc => ({ lat: loc.lat, lng: loc.lng }))}
                    options={{
                      strokeColor: trip.color,
                      strokeOpacity: 1.0,
                      strokeWeight: 3,
                    }}
                  />
                )}
              </GoogleMap>
            )}
            
            {/* Gradient Overlay */}
            <div className="absolute bottom-0 left-0 right-0 h-24 bg-gradient-to-t from-stone-50 dark:from-[#0a0a0a] to-transparent z-[400] pointer-events-none transition-colors duration-300" />
          </div>

          {/* Timeline Area */}
          <div className="flex-1 p-6 relative z-10 -mt-6 pb-32">
            <div className="flex justify-between items-center mb-8">
              <h2 className="text-lg font-semibold flex items-center gap-2 text-stone-900 dark:text-white">
                <span className="w-2 h-2 rounded-full" style={{ backgroundColor: trip.color }} />
                {t("trip.timeline")}
              </h2>
              <button className="text-xs flex items-center gap-1 bg-stone-200 dark:bg-white/10 px-3 py-1.5 rounded-full hover:bg-stone-300 dark:hover:bg-white/20 transition-colors text-stone-700 dark:text-white">
                <Edit3 size={14} /> {t("trip.edit")}
              </button>
            </div>

            <div className="space-y-8 relative before:absolute before:inset-0 before:ml-5 before:-transtone-x-px md:before:mx-auto md:before:transtone-x-0 before:h-full before:w-0.5 before:bg-gradient-to-b before:from-transparent before:via-stone-300 dark:before:via-white/10 before:to-transparent">
              {trip.locations.map((loc, idx) => (
                <div key={loc.id} className="relative flex items-center justify-between md:justify-normal md:odd:flex-row-reverse group is-active">
                  {/* Timeline Dot */}
                  <div
                    className="flex items-center justify-center w-10 h-10 rounded-full border-4 border-stone-50 dark:border-[#0a0a0a] shrink-0 md:order-1 md:group-odd:-transtone-x-1/2 md:group-even:transtone-x-1/2 shadow-xl z-10 transition-colors duration-300"
                    style={{ backgroundColor: trip.color }}
                  >
                    <span className="text-xs font-bold text-white">{idx + 1}</span>
                  </div>

                  {/* Content Card */}
                  <div className="w-[calc(100%-4rem)] md:w-[calc(50%-2.5rem)] p-4 rounded-2xl bg-white dark:bg-stone-800/80 backdrop-blur-sm border border-stone-200 dark:border-white/5 shadow-lg">
                    <div className="flex items-center justify-between mb-2">
                      <h3 className="font-bold text-stone-900 dark:text-white">{loc.name}</h3>
                      <time className="text-xs text-stone-500 dark:text-white/40 font-mono">{format(new Date(loc.date), "MMM d")}</time>
                    </div>
                    
                    {loc.photos.length > 0 ? (
                      <div className="grid grid-cols-2 gap-3 mt-4">
                        {loc.photos.map((photo, pIdx) => (
                          <div key={pIdx} className="relative bg-white p-2 pb-6 rounded-sm shadow-md transform transition-transform hover:scale-105 hover:z-10 hover:-rotate-2 border border-stone-100 dark:border-none">
                            <div className="aspect-square overflow-hidden bg-gray-100">
                              <img src={photo} alt={`Photo ${pIdx}`} className="w-full h-full object-cover" referrerPolicy="no-referrer" />
                            </div>
                          </div>
                        ))}
                      </div>
                    ) : (
                      <div className="mt-3 h-24 rounded-lg border border-dashed border-stone-300 dark:border-white/20 flex items-center justify-center text-stone-400 dark:text-white/30 text-sm">
                        {t("trip.noPhotos")}
                      </div>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </>
      ) : (
        <div className="flex-1 relative z-0">
          {!isLoaded ? (
            <div className="flex items-center justify-center h-full text-stone-500 dark:text-white/40">Loading Google Maps...</div>
          ) : (
            <GoogleMap
              mapContainerStyle={{ width: '100%', height: '100%' }}
              center={center}
              zoom={5}
              options={{
                styles: mapStyles,
                disableDefaultUI: true,
                zoomControl: true,
              }}
            >
              {trip.locations.map((loc, idx) => (
                <OverlayViewF
                  key={loc.id}
                  position={{ lat: loc.lat, lng: loc.lng }}
                  mapPaneName={"overlayMouseTarget"}
                  getPixelPositionOffset={(width, height) => ({
                    x: -(width / 2),
                    y: -(height),
                  })}
                >
                  <div className="relative group cursor-pointer">
                    {loc.photos.length > 0 ? (
                      <div className="relative bg-white p-1 pb-4 rounded-sm shadow-xl transform transition-transform group-hover:scale-110 group-hover:z-50 w-16 h-16">
                        <div className="w-full h-full overflow-hidden bg-gray-100">
                          <img src={loc.photos[0]} alt={loc.name} className="w-full h-full object-cover" referrerPolicy="no-referrer" />
                        </div>
                        <div className="absolute bottom-0 left-0 right-0 text-center text-[8px] text-black font-bold truncate px-1">
                          {idx + 1}
                        </div>
                      </div>
                    ) : (
                      <div 
                        className="w-8 h-8 rounded-full border-2 border-white flex items-center justify-center shadow-lg transform transition-transform group-hover:scale-110"
                        style={{ backgroundColor: trip.color }}
                      >
                        <span className="text-xs font-bold text-white">{idx + 1}</span>
                      </div>
                    )}
                    
                    {/* Tooltip */}
                    <div className="absolute bottom-full left-1/2 -transtone-x-1/2 mb-2 w-max max-w-[150px] bg-stone-900/90 dark:bg-black/80 text-white text-xs px-2 py-1 rounded opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none z-50 shadow-lg">
                      <p className="font-bold truncate">{loc.name}</p>
                      <p className="text-white/70">{format(new Date(loc.date), "MMM d")}</p>
                    </div>
                  </div>
                </OverlayViewF>
              ))}
              {trip.locations.length > 1 && (
                <Polyline 
                  path={trip.locations.map(loc => ({ lat: loc.lat, lng: loc.lng }))}
                  options={{
                    strokeColor: trip.color,
                    strokeOpacity: 0.8,
                    strokeWeight: 4,
                  }}
                />
              )}
            </GoogleMap>
          )}
        </div>
      )}
    </div>
  );
}
