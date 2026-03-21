import React, { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import Logo from "../components/Logo";
import { useLanguage } from "../store/LanguageContext";
import { useAuth } from "../store/AuthContext";
import { User, Lock, UserCircle, ArrowRight } from "lucide-react";

const TRAVEL_PHOTOS = [
  { id: 1, seed: "tokyo", label: "TOKYO", delay: 0.2, rotate: -5, x: -60, y: 20 },
  { id: 2, seed: "paris", label: "PARIS", delay: 0.4, rotate: 10, x: 40, y: -40 },
  { id: 3, seed: "nyc", label: "NEW YORK", delay: 0.6, rotate: -12, x: -20, y: -80 },
  { id: 4, seed: "seoul", label: "SEOUL", delay: 0.8, rotate: 8, x: 70, y: 30 },
];

export default function Onboarding() {
  const { t } = useLanguage();
  const { login, signup } = useAuth();
  const [mode, setMode] = useState<"welcome" | "login" | "signup">("welcome");
  const [formData, setFormData] = useState({ username: "", password: "", nickname: "" });
  const [error, setError] = useState("");

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    
    if (mode === "login") {
      const success = login(formData.username, formData.password);
      if (!success) setError(t("auth.error"));
    } else {
      if (!formData.username || !formData.password || !formData.nickname) {
        setError(t("auth.error"));
        return;
      }
      const success = signup(formData.username, formData.password, formData.nickname);
      if (!success) setError("ID already exists");
    }
  };

  return (
    <div className="min-h-screen bg-stone-50 dark:bg-[#0a0a0a] text-stone-900 dark:text-white flex flex-col items-center justify-center p-6 relative overflow-hidden transition-colors duration-300">
      {/* Background decoration */}
      <div className="absolute inset-0 z-0 opacity-20 pointer-events-none">
        <div className="absolute top-1/4 left-1/4 w-64 h-64 bg-amber-500 rounded-full mix-blend-multiply dark:mix-blend-screen filter blur-[100px]" />
        <div className="absolute bottom-1/4 right-1/4 w-64 h-64 bg-purple-500 rounded-full mix-blend-multiply dark:mix-blend-screen filter blur-[100px]" />
      </div>

      <div className="z-10 w-full max-w-sm flex flex-col items-center space-y-8">
        <AnimatePresence mode="wait">
          {mode === "welcome" ? (
            <motion.div
              key="welcome"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              className="w-full flex flex-col items-center space-y-12"
            >
              <div className="flex flex-col items-center gap-4">
                <Logo size={64} />
                <h1 className="text-4xl font-black tracking-tighter">{t("app.name")}</h1>
              </div>

              <div className="relative w-full h-64 flex items-center justify-center">
                {TRAVEL_PHOTOS.map((photo) => (
                  <motion.div
                    key={photo.id}
                    initial={{ opacity: 0, y: 100, rotate: photo.rotate * 2, scale: 0.5 }}
                    animate={{ opacity: 1, y: photo.y, rotate: photo.rotate, scale: 1 }}
                    className="absolute bg-white p-2 pb-6 shadow-2xl rounded-sm border border-stone-200"
                    style={{ 
                      width: '100px', 
                      height: '130px',
                      left: `calc(50% + ${photo.x}px)`,
                      top: `calc(50% + ${photo.y}px)`,
                      zIndex: photo.id
                    }}
                  >
                    <img 
                      src={`https://picsum.photos/seed/${photo.seed}/200/200`} 
                      alt={photo.label} 
                      className="w-full h-full object-cover grayscale-[0.2] contrast-[1.1]" 
                      referrerPolicy="no-referrer" 
                    />
                    <div className="absolute bottom-1 left-0 w-full text-center text-black/40 text-[8px] font-mono uppercase tracking-widest">
                      {photo.label}
                    </div>
                  </motion.div>
                ))}
              </div>

              <div className="text-center space-y-4">
                <h2 className="text-2xl font-bold tracking-tight">{t("onboarding.title")}</h2>
                <p className="text-stone-600 dark:text-white/60 text-sm max-w-[280px] mx-auto leading-relaxed">
                  {t("onboarding.subtitle")}
                </p>
              </div>

              <div className="w-full flex flex-col space-y-3">
                <button
                  onClick={() => setMode("signup")}
                  className="w-full py-4 rounded-2xl bg-stone-900 dark:bg-white text-white dark:text-stone-900 font-bold text-center hover:opacity-90 transition-all shadow-xl"
                >
                  {t("onboarding.signup")}
                </button>
                <button
                  onClick={() => setMode("login")}
                  className="w-full py-4 rounded-2xl bg-stone-200 dark:bg-white/10 text-stone-900 dark:text-white font-medium text-center hover:bg-stone-300 dark:hover:bg-white/20 transition-colors backdrop-blur-md border border-stone-300 dark:border-white/10"
                >
                  {t("onboarding.login")}
                </button>
              </div>
            </motion.div>
          ) : (
            <motion.div
              key="auth-form"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
              className="w-full space-y-8"
            >
              <div className="flex items-center gap-4">
                <button onClick={() => setMode("welcome")} className="p-2 bg-stone-100 dark:bg-white/5 rounded-full">
                  <Logo size={24} />
                </button>
                <h2 className="text-2xl font-black tracking-tighter">
                  {mode === "login" ? t("auth.login") : t("auth.signup")}
                </h2>
              </div>

              <form onSubmit={handleSubmit} className="space-y-4">
                <div className="space-y-2">
                  <div className="relative">
                    <User className="absolute left-4 top-1/2 -translate-y-1/2 text-stone-400" size={18} />
                    <input
                      type="text"
                      placeholder={t("auth.username")}
                      value={formData.username}
                      onChange={(e) => setFormData({ ...formData, username: e.target.value })}
                      className="w-full pl-12 pr-4 py-4 bg-white dark:bg-white/5 border border-stone-200 dark:border-white/10 rounded-2xl focus:outline-none focus:ring-2 focus:ring-amber-500 transition-all"
                    />
                  </div>
                  {mode === "signup" && (
                    <div className="relative">
                      <UserCircle className="absolute left-4 top-1/2 -translate-y-1/2 text-stone-400" size={18} />
                      <input
                        type="text"
                        placeholder={t("auth.nickname")}
                        value={formData.nickname}
                        onChange={(e) => setFormData({ ...formData, nickname: e.target.value })}
                        className="w-full pl-12 pr-4 py-4 bg-white dark:bg-white/5 border border-stone-200 dark:border-white/10 rounded-2xl focus:outline-none focus:ring-2 focus:ring-amber-500 transition-all"
                      />
                    </div>
                  )}
                  <div className="relative">
                    <Lock className="absolute left-4 top-1/2 -translate-y-1/2 text-stone-400" size={18} />
                    <input
                      type="password"
                      placeholder={t("auth.password")}
                      value={formData.password}
                      onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                      className="w-full pl-12 pr-4 py-4 bg-white dark:bg-white/5 border border-stone-200 dark:border-white/10 rounded-2xl focus:outline-none focus:ring-2 focus:ring-amber-500 transition-all"
                    />
                  </div>
                </div>

                {error && <p className="text-red-500 text-xs px-2">{error}</p>}

                <button
                  type="submit"
                  className="w-full py-4 bg-amber-500 hover:bg-amber-600 text-white rounded-2xl font-bold shadow-lg shadow-amber-500/20 flex items-center justify-center gap-2 transition-all"
                >
                  {mode === "login" ? t("auth.login") : t("auth.signup")}
                  <ArrowRight size={18} />
                </button>
              </form>

              <div className="text-center">
                <button
                  onClick={() => setMode(mode === "login" ? "signup" : "login")}
                  className="text-sm text-stone-500 dark:text-white/40 hover:text-stone-900 dark:hover:text-white transition-colors"
                >
                  {mode === "login" ? t("auth.noAccount") : t("auth.hasAccount")}
                </button>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </div>
  );
}
