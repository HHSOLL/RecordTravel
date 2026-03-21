import { useEffect, useRef, useState, useMemo } from "react";
import Globe from "react-globe.gl";
import { motion } from "framer-motion";
import { USER_DATA } from "../store/mockData";
import { useTrips } from "../store/TripContext";
import { useNavigate } from "react-router-dom";
import { User } from "lucide-react";
import ThemeToggle from "../components/ThemeToggle";
import { useTheme } from "../store/ThemeContext";
import Logo from "../components/Logo";
import { useLanguage } from "../store/LanguageContext";
import { useAuth } from "../store/AuthContext";

export default function Home() {
  const globeEl = useRef<any>();
  const [countries, setCountries] = useState({ features: [] });
  const [hoverD, setHoverD] = useState<any>();
  const navigate = useNavigate();
  const { trips } = useTrips();
  const { theme } = useTheme();
  const { t, language } = useLanguage();
  const { user } = useAuth();

  const [dimensions, setDimensions] = useState({
    width: typeof window !== "undefined" ? window.innerWidth : 800,
    height: typeof window !== "undefined" ? window.innerHeight : 800,
  });

  const globeImageUrl = theme === 'dark' 
    ? "//unpkg.com/three-globe/example/img/earth-night.jpg"
    : "//unpkg.com/three-globe/example/img/earth-blue-marble.jpg";
  const bumpImageUrl = "//unpkg.com/three-globe/example/img/earth-topology.png";

  useEffect(() => {
    const handleResize = () => {
      setDimensions({
        width: window.innerWidth,
        height: window.innerHeight,
      });
    };
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  useEffect(() => {
    // Load country data
    fetch("https://raw.githubusercontent.com/vasturiano/react-globe.gl/master/example/datasets/ne_110m_admin_0_countries.geojson")
      .then((res) => res.json())
      .then(setCountries);
  }, []);

  useEffect(() => {
    // Auto-rotate
    const controls = globeEl.current?.controls();
    if (controls) {
      controls.autoRotate = true;
      controls.autoRotateSpeed = 0.5;
      controls.enableZoom = false;
    }

    // Zoom out to make the globe smaller and prevent overlapping with text
    if (globeEl.current) {
      setTimeout(() => {
        globeEl.current?.pointOfView({ altitude: 2.8 });
      }, 100);
    }
  }, []);

  // Map trips to country codes
  const visitedCountries = useMemo(() => {
    const map = new Map();
    trips.forEach((trip) => {
      trip.countries.forEach((country) => {
        const count = map.get(country.code)?.count || 0;
        map.set(country.code, { count: count + 1, color: trip.color, id: trip.id });
      });
    });
    return map;
  }, [trips]);

  const getPolygonColor = (feat: any) => {
    const isoCode = feat.properties.ISO_A2;
    const visited = visitedCountries.get(isoCode);
    
    if (visited) {
      // Visited countries: Use flag-based color
      if (feat === hoverD) {
        return theme === 'dark' ? "#ffffff" : "#000000";
      }
      return visited.color;
    }

    // Unvisited countries: Transparent to show the realistic earth texture
    if (theme === 'dark') {
      return feat === hoverD 
        ? "rgba(255, 255, 255, 0.1)" // Subtle highlight on hover
        : "rgba(0, 0, 0, 0)"; // Transparent base
    } else {
      return feat === hoverD 
        ? "rgba(255, 255, 255, 0.3)" // Highlight on hover
        : "rgba(0, 0, 0, 0)"; // Transparent base
    }
  };

  const getPolygonAltitude = (feat: any) => {
    return 0.01;
  };

  const handlePolygonClick = (polygon: any) => {
    const isoCode = polygon.properties.ISO_A2;
    const visited = visitedCountries.get(isoCode);
    if (visited) {
      navigate(`/trip/${visited.id}`);
    }
  };

  return (
    <div className="min-h-screen bg-stone-50 dark:bg-[#020617] text-stone-900 dark:text-white overflow-hidden relative transition-colors duration-700">
      {/* Paper Texture Overlay (Light Mode) */}
      {theme === 'light' && (
        <div 
          className="absolute inset-0 z-30 pointer-events-none opacity-[0.03] mix-blend-multiply"
          style={{ backgroundImage: 'url("https://www.transparenttextures.com/patterns/paper-fibers.png")' }}
        />
      )}

      {/* Dark Mode Cosmic Background */}
      {theme === 'dark' && (
        <div className="absolute inset-0 z-0 pointer-events-none overflow-hidden">
          <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_center,_var(--tw-gradient-stops))] from-slate-900 via-[#020617] to-black" />
          
          {/* Stars */}
          {[...Array(80)].map((_, i) => (
            <motion.div
              key={`star-${i}`}
              initial={{ opacity: Math.random() }}
              animate={{ opacity: [0.2, 0.8, 0.2] }}
              transition={{ duration: 2 + Math.random() * 3, repeat: Infinity }}
              className="absolute bg-white rounded-full"
              style={{
                width: Math.random() * 2 + 'px',
                height: Math.random() * 2 + 'px',
                top: Math.random() * 100 + '%',
                left: Math.random() * 100 + '%',
              }}
            />
          ))}

          {/* Floating Planets/Satellites */}
          <motion.div
            animate={{ 
              y: [0, -20, 0],
              rotate: 360 
            }}
            transition={{ duration: 20, repeat: Infinity, ease: "linear" }}
            className="absolute top-[20%] right-[15%] w-12 h-12 rounded-full bg-gradient-to-br from-purple-500/20 to-blue-500/20 blur-sm border border-white/10"
          />
          <motion.div
            animate={{ 
              y: [0, 30, 0],
              x: [0, -20, 0]
            }}
            transition={{ duration: 15, repeat: Infinity, ease: "easeInOut" }}
            className="absolute bottom-[25%] left-[10%] w-8 h-8 rounded-full bg-gradient-to-tr from-orange-500/10 to-red-500/10 blur-[2px] border border-white/5"
          />
          
          {/* Subtle Nebula Glow */}
          <div className="absolute top-0 left-0 w-full h-full bg-[radial-gradient(circle_at_20%_30%,_rgba(56,189,248,0.05)_0%,_transparent_50%)]" />
          <div className="absolute bottom-0 right-0 w-full h-full bg-[radial-gradient(circle_at_80%_70%,_rgba(139,92,246,0.05)_0%,_transparent_50%)]" />
        </div>
      )}

      {/* Light Mode Sky Background */}
      {theme === 'light' && (
        <div className="absolute inset-0 z-0 pointer-events-none overflow-hidden bg-[#e0f2fe]">
          <div className="absolute inset-0 bg-gradient-to-b from-sky-200/50 via-sky-100/30 to-stone-50" />
          
          {/* Floating Illustrated Elements */}
          <motion.div
            animate={{ x: [0, 10, 0], y: [0, -10, 0] }}
            transition={{ duration: 8, repeat: Infinity, ease: "easeInOut" }}
            className="absolute top-[15%] left-[10%] opacity-40"
          >
            <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1" className="text-sky-900">
              <path d="M12 3L20 7.5V16.5L12 21L4 16.5V7.5L12 3Z" />
              <path d="M12 3V21" />
              <path d="M4 7.5L20 16.5" />
              <path d="M20 7.5L4 16.5" />
            </svg>
          </motion.div>

          <motion.div
            animate={{ x: [0, -15, 0], y: [0, 15, 0] }}
            transition={{ duration: 12, repeat: Infinity, ease: "easeInOut" }}
            className="absolute bottom-[20%] right-[12%] opacity-30"
          >
            <svg width="60" height="30" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1" className="text-sky-900">
              <path d="M2 12h20M12 2v20M4.93 4.93l14.14 14.14M4.93 19.07L19.07 4.93" />
            </svg>
          </motion.div>
          
          {/* Floating Clouds */}
          {[...Array(6)].map((_, i) => (
            <motion.div
              key={`cloud-${i}`}
              initial={{ x: -300, y: 50 + i * 120 }}
              animate={{ x: dimensions.width + 300 }}
              transition={{ 
                duration: 50 + Math.random() * 50, 
                repeat: Infinity, 
                ease: "linear",
                delay: i * 8
              }}
              className="absolute opacity-60"
            >
              <div className="w-64 h-20 bg-white/80 rounded-full blur-3xl" />
            </motion.div>
          ))}
        </div>
      )}

      {/* Header */}
      <header className="absolute top-0 left-0 right-0 z-40 p-6 flex justify-between items-center bg-gradient-to-b from-stone-50/50 dark:from-[#020617]/50 to-transparent backdrop-blur-[2px]">
        <ThemeToggle />
        <div className="flex items-center gap-2">
          <Logo size={24} />
          <h1 className="text-xl font-black tracking-tighter">{t("app.name")}</h1>
        </div>
        <button 
          onClick={() => navigate('/profile')}
          className="p-2 bg-stone-200/50 dark:bg-white/5 rounded-full backdrop-blur-md border border-stone-300/50 dark:border-white/10 hover:bg-stone-300 dark:hover:bg-white/10 transition-colors overflow-hidden"
        >
          {user?.photoURL ? (
            <img src={user.photoURL} alt="User" className="w-5 h-5 rounded-full object-cover" referrerPolicy="no-referrer" />
          ) : (
            <User size={20} className="text-stone-900 dark:text-white" />
          )}
        </button>
      </header>

      {/* Stats Overlay */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.5 }}
        className="absolute top-24 left-0 right-0 z-40 flex flex-col items-center pointer-events-none"
      >
        <div className="bg-amber-500/20 dark:bg-amber-400/20 text-amber-700 dark:text-amber-300 px-4 py-1 rounded-full text-xs font-semibold tracking-wide border border-amber-500/30 dark:border-amber-400/30 mb-3 backdrop-blur-sm">
          {USER_DATA.title}
        </div>
        <h2 className="text-2xl font-bold text-stone-900 dark:text-white drop-shadow-sm">
          {language === 'ko' ? (
            `${user?.displayName || "Traveler"}님의 지구본`
          ) : (
            `${user?.displayName || "Traveler"}${t("home.title")}`
          )}
        </h2>
        <p className="text-stone-500 dark:text-white/60 font-medium">
          {USER_DATA.totalCities}{t("home.stats")}
        </p>
      </motion.div>

      {/* Globe Container */}
      <div className="absolute inset-0 flex items-center justify-center cursor-grab active:cursor-grabbing z-10">
        <Globe
          ref={globeEl}
          width={dimensions.width}
          height={Math.max(400, dimensions.height - 240)}
          backgroundColor="rgba(0,0,0,0)"
          showGlobe={true}
          globeImageUrl={globeImageUrl}
          bumpImageUrl={bumpImageUrl}
          showAtmosphere={true}
          atmosphereColor={theme === 'dark' ? "#38bdf8" : "#2563eb"}
          atmosphereAltitude={theme === 'dark' ? 0.25 : 0.15}
          polygonsData={countries.features}
          polygonAltitude={getPolygonAltitude}
          polygonCapColor={getPolygonColor}
          polygonSideColor={getPolygonColor}
          polygonStrokeColor={() => theme === 'dark' ? "#ffffff1a" : "#ffffff33"}
          polygonLabel={({ properties: d }: any) => {
            const visited = visitedCountries.get(d.ISO_A2);
            if (visited) {
              return `
                <div class="bg-white/90 dark:bg-stone-800/90 backdrop-blur-md border border-stone-200 dark:border-white/20 px-3 py-2 rounded-xl shadow-xl flex items-center gap-2">
                  <span class="font-bold text-stone-900 dark:text-white">${d.ADMIN}</span>
                  <span class="bg-stone-200 dark:bg-white/20 text-stone-700 dark:text-white text-xs px-2 py-0.5 rounded-full">${visited.count}</span>
                </div>
              `;
            }
            return `
              <div class="bg-white/80 dark:bg-black/80 px-2 py-1 rounded text-xs text-stone-700 dark:text-white/70 shadow-md">
                ${d.ADMIN}
              </div>
            `;
          }}
          onPolygonHover={setHoverD}
          onPolygonClick={handlePolygonClick}
          polygonsTransitionDuration={300}
        />
      </div>

      {/* Helper Text */}
      <div className="absolute bottom-32 left-0 right-0 z-40 text-center pointer-events-none">
        <p className="text-stone-500 dark:text-white/50 text-sm">{t("home.helper")}</p>
      </div>
    </div>
  );
}
