import { useState, useMemo } from "react";
import { Country } from "../store/mockData";
import { useTrips } from "../store/TripContext";
import { Link } from "react-router-dom";
import { format } from "date-fns";
import { MapPin, CalendarDays, ArrowRight, Users, ChevronDown, Globe, ChevronRight } from "lucide-react";
import { cn } from "../lib/utils";
import ThemeToggle from "../components/ThemeToggle";
import { useLanguage } from "../store/LanguageContext";

function getFlagEmoji(countryCode: string) {
  const codePoints = countryCode
    .toUpperCase()
    .split('')
    .map(char => 127397 + char.charCodeAt(0));
  return String.fromCodePoint(...codePoints);
}

export default function Archive() {
  const { trips } = useTrips();
  const { t } = useLanguage();
  const pastTrips = trips.filter((t) => !t.isUpcoming);
  
  const allCompanions = useMemo(() => {
    return Array.from(new Set(pastTrips.flatMap(t => t.companions))).sort();
  }, [pastTrips]);

  const [selectedCompanion, setSelectedCompanion] = useState<string | null>(null);
  const [isCompanionPopupOpen, setIsCompanionPopupOpen] = useState(false);

  const [selectedContinent, setSelectedContinent] = useState<string | null>(null);
  const [selectedCountry, setSelectedCountry] = useState<string | null>(null);

  const filteredTrips = useMemo(() => {
    return selectedCompanion 
      ? pastTrips.filter(t => t.companions.includes(selectedCompanion))
      : pastTrips;
  }, [pastTrips, selectedCompanion]);

  const tripsThisYear = filteredTrips.filter(
    (t) => new Date(t.startDate).getFullYear() === new Date().getFullYear()
  ).length;

  // Compute Continents
  const continents = useMemo(() => {
    const continentNames = Array.from(new Set(filteredTrips.flatMap(t => t.countries.map(c => c.continent))));
    return continentNames.map(continent => {
      const tripsInContinent = filteredTrips.filter(t => t.countries.some(c => c.continent === continent));
      const countriesInContinent = new Set(tripsInContinent.flatMap(t => t.countries.filter(c => c.continent === continent).map(c => c.code)));
      return {
        name: continent,
        countryCount: countriesInContinent.size,
        tripCount: tripsInContinent.length
      };
    });
  }, [filteredTrips]);

  // Compute Countries for selected continent
  const countriesInSelectedContinent = useMemo(() => {
    if (!selectedContinent) return [];
    const uniqueCountries = new Map<string, Country>();
    filteredTrips.forEach(t => {
      t.countries.forEach(c => {
        if (c.continent === selectedContinent) {
          uniqueCountries.set(c.code, c);
        }
      });
    });
    
    return Array.from(uniqueCountries.values()).map(country => {
      const tripsInCountry = filteredTrips.filter(t => t.countries.some(c => c.code === country.code));
      return {
        ...country,
        tripCount: tripsInCountry.length
      };
    });
  }, [filteredTrips, selectedContinent]);

  // Trips to show
  const tripsToShow = useMemo(() => {
    if (!selectedCountry) return [];
    return filteredTrips.filter(t => t.countries.some(c => c.code === selectedCountry));
  }, [filteredTrips, selectedCountry]);

  return (
    <div className="min-h-screen bg-stone-50 dark:bg-[#0a0a0a] text-stone-900 dark:text-white p-6 pb-32 transition-colors duration-300">
      {/* Header */}
      <header className="mb-8 pt-4 flex flex-col gap-4">
        <div className="flex justify-between items-start">
          <div>
            <h1 className="text-3xl font-bold tracking-tight mb-2">{t("archive.title")}</h1>
            <div className="flex items-center gap-2 text-stone-500 dark:text-white/60">
              <CalendarDays size={16} />
              <span>{t("archive.tripsThisYear")}: <strong className="text-stone-900 dark:text-white">{tripsThisYear}</strong></span>
            </div>
          </div>
          <ThemeToggle />
        </div>
          
        {/* Companion Filter */}
        <div className="relative self-start">
          <button 
            onClick={() => setIsCompanionPopupOpen(!isCompanionPopupOpen)} 
            className="flex items-center gap-2 px-4 py-2 bg-white dark:bg-white/5 border border-stone-200 dark:border-white/10 rounded-full hover:bg-stone-100 dark:hover:bg-white/10 transition-colors shadow-sm"
          >
            <Users size={16} />
            <span className="text-sm font-medium">{selectedCompanion ? `${t("archive.with")} ${selectedCompanion}` : t("archive.allCompanions")}</span>
            <ChevronDown size={16} className="text-stone-400 dark:text-white/50" />
          </button>
          
          {isCompanionPopupOpen && (
            <div className="absolute top-full mt-2 left-0 w-48 bg-white dark:bg-stone-800 border border-stone-200 dark:border-white/10 rounded-xl shadow-2xl overflow-hidden z-50">
              <button 
                onClick={() => { setSelectedCompanion(null); setIsCompanionPopupOpen(false); }}
                className={cn("w-full text-left px-4 py-3 text-sm hover:bg-stone-50 dark:hover:bg-white/5 transition-colors", !selectedCompanion && "text-amber-600 dark:text-amber-400 bg-stone-50 dark:bg-white/5")}
              >
                {t("archive.allCompanions")}
              </button>
              {allCompanions.map(companion => (
                <button 
                  key={companion}
                  onClick={() => { setSelectedCompanion(companion); setIsCompanionPopupOpen(false); }}
                  className={cn("w-full text-left px-4 py-3 text-sm hover:bg-stone-50 dark:hover:bg-white/5 transition-colors", selectedCompanion === companion && "text-amber-600 dark:text-amber-400 bg-stone-50 dark:bg-white/5")}
                >
                  {companion}
                </button>
              ))}
            </div>
          )}
        </div>

        {/* Breadcrumbs */}
        {(selectedContinent || selectedCountry) && (
          <div className="flex items-center gap-2 text-sm text-stone-500 dark:text-white/50 mt-2">
            <button onClick={() => { setSelectedContinent(null); setSelectedCountry(null); }} className="hover:text-stone-900 dark:hover:text-white transition-colors">All</button>
            {selectedContinent && (
              <>
                <ChevronRight size={14} />
                <button onClick={() => setSelectedCountry(null)} className={cn("hover:text-stone-900 dark:hover:text-white transition-colors", !selectedCountry && "text-stone-900 dark:text-white font-medium")}>{selectedContinent}</button>
              </>
            )}
            {selectedCountry && (
              <>
                <ChevronRight size={14} />
                <span className="text-stone-900 dark:text-white font-medium">{countriesInSelectedContinent.find(c => c.code === selectedCountry)?.name}</span>
              </>
            )}
          </div>
        )}
      </header>

      {/* View 1: Continents */}
      {!selectedContinent && (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {continents.map(continent => (
            <div 
              key={continent.name}
              onClick={() => setSelectedContinent(continent.name)}
              className="bg-white dark:bg-stone-800 border border-stone-200 dark:border-white/10 rounded-3xl p-6 flex flex-col justify-between cursor-pointer hover:bg-stone-50 dark:hover:bg-white/5 hover:-transtone-y-1 transition-all shadow-lg hover:shadow-xl"
            >
              <div className="flex justify-between items-start mb-8">
                <div className="w-12 h-12 rounded-xl bg-stone-100 dark:bg-white/5 flex items-center justify-center">
                  <Globe size={24} className="text-stone-500 dark:text-white/70" />
                </div>
                <span className="px-3 py-1 rounded-full bg-stone-100 dark:bg-white/5 text-xs text-stone-600 dark:text-white/70 border border-stone-200 dark:border-white/10">
                  {continent.countryCount} {t("archive.countries")}
                </span>
              </div>
              <div>
                <h3 className="text-2xl font-bold mb-1">{continent.name}</h3>
                <p className="text-sm text-stone-500 dark:text-white/50">{continent.tripCount} {t("archive.trips")}</p>
              </div>
            </div>
          ))}
          {continents.length === 0 && (
            <div className="col-span-full text-center py-12 text-stone-400 dark:text-white/40">
              No trips found for the selected companion.
            </div>
          )}
        </div>
      )}

      {/* View 2: Countries */}
      {selectedContinent && !selectedCountry && (
        <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
          {countriesInSelectedContinent.map(country => (
            <div 
              key={country.code}
              onClick={() => setSelectedCountry(country.code)}
              className="bg-white dark:bg-stone-800 border border-stone-200 dark:border-white/10 rounded-3xl p-5 flex flex-col justify-between cursor-pointer hover:bg-stone-50 dark:hover:bg-white/5 hover:-transtone-y-1 transition-all shadow-lg hover:shadow-xl"
            >
              <div className="text-4xl mb-6">
                {getFlagEmoji(country.code)}
              </div>
              <div>
                <h3 className="text-lg font-bold mb-1">{country.name}</h3>
                <div className="flex justify-between items-end">
                  <p className="text-xs text-stone-500 dark:text-white/50 uppercase tracking-wider">{country.continent}</p>
                  <p className="text-sm font-medium text-amber-600 dark:text-amber-400">{country.tripCount} {t("archive.trips")}</p>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* View 3: Trips in Country */}
      {selectedCountry && (
        <div className="space-y-6">
          {tripsToShow.map((trip) => (
            <Link
              key={trip.id}
              to={`/trip/${trip.id}`}
              className="block group relative overflow-hidden rounded-3xl bg-white dark:bg-stone-800 border border-stone-200 dark:border-white/5 shadow-xl dark:shadow-2xl transition-all hover:-transtone-y-1 hover:shadow-2xl dark:hover:shadow-[0_10px_40px_rgba(0,0,0,0.5)]"
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
              </div>

              {/* Content */}
              <div className="p-6 relative">
                <div className="flex justify-between items-end mb-3">
                  <div>
                    <h2 className="text-2xl font-bold mb-1">{trip.title}</h2>
                    <p className="text-sm text-stone-500 dark:text-white/50 font-mono">
                      {format(new Date(trip.startDate), "MMM d")} - {format(new Date(trip.endDate), "MMM d, yyyy")}
                    </p>
                  </div>
                  <div className="w-10 h-10 rounded-full bg-stone-100 dark:bg-white/5 flex items-center justify-center group-hover:bg-stone-200 dark:group-hover:bg-white/10 transition-colors">
                    <ArrowRight size={18} className="text-stone-400 dark:text-white/70 group-hover:text-stone-900 dark:group-hover:text-white group-hover:transtone-x-0.5 transition-all" />
                  </div>
                </div>
                
                <p className="text-stone-600 dark:text-white/70 text-sm line-clamp-2 leading-relaxed">
                  {trip.description}
                </p>

                {/* Companions */}
                {trip.companions.length > 0 && (
                  <div className="mt-4 flex items-center gap-2 text-xs text-stone-500 dark:text-white/50">
                    <Users size={12} />
                    <span>With {trip.companions.join(", ")}</span>
                  </div>
                )}

                {/* Locations preview */}
                <div className="mt-3 flex flex-wrap gap-2">
                  {trip.locations.slice(0, 3).map((loc) => (
                    <span key={loc.id} className="inline-flex items-center gap-1 text-xs px-2.5 py-1 rounded-md bg-stone-100 dark:bg-white/5 text-stone-600 dark:text-white/60 border border-stone-200 dark:border-white/5">
                      <MapPin size={10} />
                      {loc.name}
                    </span>
                  ))}
                  {trip.locations.length > 3 && (
                    <span className="inline-flex items-center text-xs px-2.5 py-1 rounded-md bg-stone-100 dark:bg-white/5 text-stone-500 dark:text-white/40">
                      +{trip.locations.length - 3} more
                    </span>
                  )}
                </div>
              </div>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
