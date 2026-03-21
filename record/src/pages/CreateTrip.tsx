import React, { useState, useRef } from "react";
import { useNavigate } from "react-router-dom";
import { ArrowLeft, Upload, MapPin, Calendar, Users, Check, Loader2, Image as ImageIcon } from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";
import { useLanguage } from "../store/LanguageContext";
import { useTrips } from "../store/TripContext";
import { Trip, Location } from "../store/mockData";
import { format } from "date-fns";

export default function CreateTrip() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const { addTrip } = useTrips();
  const fileInputRef = useRef<HTMLInputElement>(null);

  const [step, setStep] = useState(1);
  const [title, setTitle] = useState("");
  const [countryName, setCountryName] = useState("");
  const [countryCode, setCountryCode] = useState("KR");
  const [startDate, setStartDate] = useState("");
  const [endDate, setEndDate] = useState("");
  const [description, setDescription] = useState("");
  const [color, setColor] = useState("#F59E0B");
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const [uploadedPhotos, setUploadedPhotos] = useState<{ url: string; date: string; name: string }[]>([]);
  const [groupedLocations, setGroupedLocations] = useState<Location[]>([]);

  const PRESET_COLORS = [
    "#F59E0B", // Amber
    "#EF4444", // Red
    "#3B82F6", // Blue
    "#10B981", // Emerald
    "#8B5CF6", // Violet
    "#EC4899", // Pink
    "#06B6D4", // Cyan
    "#0047A0", // KR Blue
    "#BC002D", // JP Red
  ];

  const handleNext = () => {
    if (step < 3) setStep(step + 1);
    else handleCreate();
  };

  const handlePhotoUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files;
    if (!files) return;

    setIsAnalyzing(true);
    
    // Simulate photo analysis (extracting dates and grouping)
    setTimeout(() => {
      const newPhotos = Array.from(files as FileList).map((file: File) => {
        // In a real app, we'd use EXIF data. Here we simulate it.
        const randomDayOffset = Math.floor(Math.random() * 5);
        const photoDate = new Date(startDate || Date.now());
        photoDate.setDate(photoDate.getDate() + randomDayOffset);
        
        return {
          url: URL.createObjectURL(file),
          date: photoDate.toISOString(),
          name: file.name
        };
      });

      setUploadedPhotos(newPhotos);

      // Group photos into locations automatically
      const groups: { [key: string]: Location } = {};
      newPhotos.forEach((photo) => {
        const dateKey = format(new Date(photo.date), "yyyy-MM-dd");
        if (!groups[dateKey]) {
          groups[dateKey] = {
            id: `new-loc-${dateKey}`,
            name: `${countryName} - Day ${Object.keys(groups).length + 1}`,
            lat: 37.5665 + (Math.random() - 0.5) * 0.1, // Near city center
            lng: 126.9780 + (Math.random() - 0.5) * 0.1,
            date: photo.date,
            photos: []
          };
        }
        groups[dateKey].photos.push(photo.url);
      });

      setGroupedLocations(Object.values(groups).sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime()));
      setIsAnalyzing(false);
    }, 2000);
  };

  const handleCreate = () => {
    const newTrip: Trip = {
      id: `trip-${Date.now()}`,
      title: title || "New Journey",
      countries: [{ name: countryName || "Unknown", code: countryCode, continent: "Asia" }],
      startDate: startDate || new Date().toISOString(),
      endDate: endDate || new Date().toISOString(),
      description: description || "A new adventure recorded.",
      coverImage: uploadedPhotos[0]?.url || "https://picsum.photos/seed/travel/800/600",
      isUpcoming: new Date(startDate) > new Date(),
      locations: groupedLocations,
      color: color,
      companions: []
    };

    addTrip(newTrip);
    navigate("/home");
  };

  return (
    <div className="min-h-screen bg-stone-50 dark:bg-[#0a0a0a] text-stone-900 dark:text-white flex flex-col transition-colors duration-300">
      {/* Header */}
      <header className="p-6 flex items-center justify-between z-10 bg-stone-50/80 dark:bg-[#0a0a0a]/80 backdrop-blur-md sticky top-0 transition-colors duration-300">
        <button onClick={() => navigate(-1)} className="p-2 bg-stone-200 dark:bg-white/5 rounded-full hover:bg-stone-300 dark:hover:bg-white/10 transition-colors text-stone-700 dark:text-white">
          <ArrowLeft size={20} />
        </button>
        <div className="text-center flex-1">
          <h1 className="text-xl font-bold">{t("create.title")}</h1>
          <p className="text-xs text-stone-500 dark:text-white/50">{t("create.step").replace("{{step}}", step.toString())}</p>
        </div>
        <div className="w-10" />
      </header>

      {/* Progress Bar */}
      <div className="h-1 bg-stone-200 dark:bg-white/10 w-full transition-colors duration-300">
        <motion.div
          className="h-full bg-amber-500 dark:bg-amber-400"
          initial={{ width: "33%" }}
          animate={{ width: `${(step / 3) * 100}%` }}
          transition={{ duration: 0.3 }}
        />
      </div>

      {/* Content */}
      <div className="flex-1 p-6 flex flex-col">
        <AnimatePresence mode="wait">
          {step === 1 && (
            <motion.div
              key="step1"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
              className="flex-1 flex flex-col"
            >
              <h2 className="text-2xl font-bold mb-6">{t("create.where")}</h2>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm text-stone-600 dark:text-white/60 mb-2">{t("create.tripTitle")}</label>
                  <input
                    type="text"
                    value={title}
                    onChange={(e) => setTitle(e.target.value)}
                    placeholder="e.g. Summer in Paris"
                    className="w-full bg-white dark:bg-white/5 border border-stone-200 dark:border-white/10 rounded-xl px-4 py-3 text-stone-900 dark:text-white placeholder-stone-400 dark:placeholder-white/30 focus:outline-none focus:border-amber-500 dark:focus:border-amber-400 focus:ring-1 focus:ring-amber-500 dark:focus:ring-amber-400 transition-all"
                  />
                </div>
                <div>
                  <label className="block text-sm text-stone-600 dark:text-white/60 mb-2">{t("create.country")}</label>
                  <div className="relative">
                    <MapPin size={18} className="absolute left-4 top-1/2 -transtone-y-1/2 text-stone-400 dark:text-white/40" />
                    <input
                      type="text"
                      value={countryName}
                      onChange={(e) => setCountryName(e.target.value)}
                      placeholder="e.g. France"
                      className="w-full bg-white dark:bg-white/5 border border-stone-200 dark:border-white/10 rounded-xl pl-12 pr-4 py-3 text-stone-900 dark:text-white placeholder-stone-400 dark:placeholder-white/30 focus:outline-none focus:border-amber-500 dark:focus:border-amber-400 focus:ring-1 focus:ring-amber-500 dark:focus:ring-amber-400 transition-all"
                    />
                  </div>
                </div>
                <div>
                  <label className="block text-sm text-stone-600 dark:text-white/60 mb-2">{t("create.description")}</label>
                  <textarea
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                    placeholder={t("create.descriptionPlaceholder")}
                    className="w-full bg-white dark:bg-white/5 border border-stone-200 dark:border-white/10 rounded-xl px-4 py-3 text-stone-900 dark:text-white placeholder-stone-400 dark:placeholder-white/30 focus:outline-none focus:border-amber-500 dark:focus:border-amber-400 focus:ring-1 focus:ring-amber-500 dark:focus:ring-amber-400 transition-all h-32 resize-none"
                  />
                </div>
                <div>
                  <label className="block text-sm text-stone-600 dark:text-white/60 mb-3">Trip Color on Globe</label>
                  <div className="flex flex-wrap gap-3">
                    {PRESET_COLORS.map((c) => (
                      <button
                        key={c}
                        onClick={() => setColor(c)}
                        className={`w-8 h-8 rounded-full border-2 transition-all ${
                          color === c ? "border-stone-900 dark:border-white scale-110" : "border-transparent"
                        }`}
                        style={{ backgroundColor: c }}
                      />
                    ))}
                    <input
                      type="color"
                      value={color}
                      onChange={(e) => setColor(e.target.value)}
                      className="w-8 h-8 rounded-full overflow-hidden bg-transparent border-none cursor-pointer p-0"
                    />
                  </div>
                </div>
              </div>
            </motion.div>
          )}

          {step === 2 && (
            <motion.div
              key="step2"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
              className="flex-1 flex flex-col"
            >
              <h2 className="text-2xl font-bold mb-6">{t("create.when")}</h2>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm text-stone-600 dark:text-white/60 mb-2">{t("create.startDate")}</label>
                  <div className="relative">
                    <Calendar size={18} className="absolute left-4 top-1/2 -transtone-y-1/2 text-stone-400 dark:text-white/40" />
                    <input
                      type="date"
                      value={startDate}
                      onChange={(e) => setStartDate(e.target.value)}
                      className="w-full bg-white dark:bg-white/5 border border-stone-200 dark:border-white/10 rounded-xl pl-12 pr-4 py-3 text-stone-900 dark:text-white focus:outline-none focus:border-amber-500 dark:focus:border-amber-400 focus:ring-1 focus:ring-amber-500 dark:focus:ring-amber-400 transition-all dark:[color-scheme:dark]"
                    />
                  </div>
                </div>
                <div>
                  <label className="block text-sm text-stone-600 dark:text-white/60 mb-2">{t("create.endDate")}</label>
                  <div className="relative">
                    <Calendar size={18} className="absolute left-4 top-1/2 -transtone-y-1/2 text-stone-400 dark:text-white/40" />
                    <input
                      type="date"
                      value={endDate}
                      onChange={(e) => setEndDate(e.target.value)}
                      className="w-full bg-white dark:bg-white/5 border border-stone-200 dark:border-white/10 rounded-xl pl-12 pr-4 py-3 text-stone-900 dark:text-white focus:outline-none focus:border-amber-500 dark:focus:border-amber-400 focus:ring-1 focus:ring-amber-500 dark:focus:ring-amber-400 transition-all dark:[color-scheme:dark]"
                    />
                  </div>
                </div>
              </div>
            </motion.div>
          )}

          {step === 3 && (
            <motion.div
              key="step3"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
              className="flex-1 flex flex-col"
            >
              <h2 className="text-2xl font-bold mb-2">{t("create.upload")}</h2>
              <p className="text-stone-500 dark:text-white/50 text-sm mb-6">{t("create.uploadDesc")}</p>
              
              <input 
                type="file" 
                multiple 
                accept="image/*" 
                className="hidden" 
                ref={fileInputRef} 
                onChange={handlePhotoUpload}
              />

              {uploadedPhotos.length === 0 ? (
                <div 
                  onClick={() => fileInputRef.current?.click()}
                  className="flex-1 border-2 border-dashed border-stone-300 dark:border-white/20 rounded-2xl flex flex-col items-center justify-center bg-stone-100 dark:bg-white/5 hover:bg-stone-200 dark:hover:bg-white/10 transition-colors cursor-pointer group"
                >
                  {isAnalyzing ? (
                    <div className="flex flex-col items-center">
                      <Loader2 size={48} className="text-amber-500 animate-spin mb-4" />
                      <p className="font-semibold text-lg text-stone-900 dark:text-white">{t("create.analyzing")}</p>
                      <p className="text-stone-500 dark:text-white/40 text-sm">{t("create.analyzingDesc")}</p>
                    </div>
                  ) : (
                    <>
                      <div className="w-16 h-16 rounded-full bg-amber-100 dark:bg-amber-400/20 flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                        <Upload size={24} className="text-amber-600 dark:text-amber-400" />
                      </div>
                      <p className="font-semibold text-lg mb-1 text-stone-900 dark:text-white">{t("create.selectPhotos")}</p>
                      <p className="text-stone-500 dark:text-white/40 text-sm">{t("create.dragDrop")}</p>
                    </>
                  )}
                </div>
              ) : (
                <div className="flex-1 space-y-6 overflow-y-auto pr-2">
                  <div className="flex items-center justify-between">
                    <p className="text-sm font-bold text-amber-600 dark:text-amber-400 flex items-center gap-2">
                      <Check size={16} />
                      {uploadedPhotos.length} {t("create.organized")}
                    </p>
                    <button 
                      onClick={() => setUploadedPhotos([])}
                      className="text-xs text-stone-400 hover:text-red-500 transition-colors"
                    >
                      Clear All
                    </button>
                  </div>

                  <div className="space-y-4">
                    {groupedLocations.map((loc, idx) => (
                      <div key={loc.id} className="bg-white dark:bg-white/5 border border-stone-200 dark:border-white/10 rounded-2xl p-4">
                        <div className="flex items-center justify-between mb-3">
                          <h4 className="font-bold text-sm">{loc.name}</h4>
                          <span className="text-[10px] font-mono text-stone-400">{format(new Date(loc.date), "MMM d")}</span>
                        </div>
                        <div className="grid grid-cols-4 gap-2">
                          {loc.photos.map((url, pIdx) => (
                            <div key={pIdx} className="aspect-square rounded-lg overflow-hidden bg-stone-100 dark:bg-white/10">
                              <img src={url} alt="Uploaded" className="w-full h-full object-cover" />
                            </div>
                          ))}
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              <div className="mt-6">
                <button className="w-full flex items-center justify-center gap-2 py-4 rounded-xl bg-stone-100 dark:bg-white/5 border border-stone-200 dark:border-white/10 hover:bg-stone-200 dark:hover:bg-white/10 transition-colors text-stone-700 dark:text-white/80">
                  <Users size={18} />
                  <span>{t("create.invite")}</span>
                </button>
              </div>
            </motion.div>
          )}
        </AnimatePresence>

        {/* Footer Actions */}
        <div className="mt-8 mb-4">
          <button
            onClick={handleNext}
            disabled={(step === 1 && (!title || !countryName)) || (step === 3 && isAnalyzing)}
            className="w-full py-4 rounded-full bg-amber-500 dark:bg-amber-400 text-white dark:text-black font-bold text-lg hover:bg-amber-600 dark:hover:bg-amber-300 transition-colors disabled:opacity-50 disabled:cursor-not-allowed shadow-[0_0_20px_rgba(245,158,11,0.3)] dark:shadow-[0_0_20px_rgba(251,191,36,0.3)]"
          >
            {step === 3 ? t("create.createJourney") : t("create.continue")}
          </button>
        </div>
      </div>
    </div>
  );
}
