import { motion } from "framer-motion";
import { useAuth } from "../store/AuthContext";
import { useLanguage } from "../store/LanguageContext";
import { useTheme } from "../store/ThemeContext";
import { LogOut, Globe, Moon, Sun, ChevronRight, User } from "lucide-react";

export default function Profile() {
  const { t, language, setLanguage } = useLanguage();
  const { theme, toggleTheme } = useTheme();
  const { user, logout } = useAuth();

  return (
    <div className="min-h-screen bg-stone-50 dark:bg-[#0a0a0a] text-stone-900 dark:text-white p-6 pb-24 transition-colors duration-300">
      <header className="mb-12 pt-8">
        <h1 className="text-3xl font-black tracking-tighter">{t("profile.title")}</h1>
      </header>

      <div className="space-y-8 max-w-md mx-auto">
        {/* User Info */}
        <div className="flex items-center gap-4 p-4 bg-white dark:bg-white/5 rounded-2xl border border-stone-200 dark:border-white/10 shadow-sm">
          <div className="w-16 h-16 rounded-full bg-amber-500 flex items-center justify-center overflow-hidden border-2 border-white dark:border-stone-800 shadow-md">
            {user?.photoURL ? (
              <img src={user.photoURL} alt="Profile" className="w-full h-full object-cover" referrerPolicy="no-referrer" />
            ) : (
              <User size={32} className="text-white" />
            )}
          </div>
          <div>
            <h2 className="font-bold text-lg">{user?.nickname || "Traveler"}</h2>
            <p className="text-stone-500 dark:text-white/50 text-sm">@{user?.username}</p>
          </div>
        </div>

        {/* Settings Groups */}
        <div className="space-y-4">
          <h3 className="text-xs font-bold uppercase tracking-widest text-stone-400 dark:text-white/30 px-2">
            General
          </h3>
          
          <div className="bg-white dark:bg-white/5 rounded-2xl border border-stone-200 dark:border-white/10 overflow-hidden shadow-sm">
            {/* Language Toggle */}
            <div className="flex items-center justify-between p-4 border-b border-stone-100 dark:border-white/5">
              <div className="flex items-center gap-3">
                <div className="p-2 bg-blue-500/10 text-blue-500 rounded-lg">
                  <Globe size={18} />
                </div>
                <span className="font-medium">{t("profile.language")}</span>
              </div>
              <div className="flex bg-stone-100 dark:bg-white/10 p-1 rounded-full">
                <button
                  onClick={() => setLanguage("ko")}
                  className={`px-3 py-1 rounded-full text-xs font-bold transition-all ${
                    language === "ko" 
                      ? "bg-white dark:bg-stone-800 shadow-sm text-stone-900 dark:text-white" 
                      : "text-stone-400 dark:text-white/40"
                  }`}
                >
                  KO
                </button>
                <button
                  onClick={() => setLanguage("en")}
                  className={`px-3 py-1 rounded-full text-xs font-bold transition-all ${
                    language === "en" 
                      ? "bg-white dark:bg-stone-800 shadow-sm text-stone-900 dark:text-white" 
                      : "text-stone-400 dark:text-white/40"
                  }`}
                >
                  EN
                </button>
              </div>
            </div>

            {/* Theme Toggle */}
            <button
              onClick={toggleTheme}
              className="w-full flex items-center justify-between p-4 hover:bg-stone-50 dark:hover:bg-white/5 transition-colors"
            >
              <div className="flex items-center gap-3">
                <div className="p-2 bg-amber-500/10 text-amber-500 rounded-lg">
                  {theme === "dark" ? <Sun size={18} /> : <Moon size={18} />}
                </div>
                <span className="font-medium">{theme === "dark" ? "Light Mode" : "Dark Mode"}</span>
              </div>
              <ChevronRight size={18} className="text-stone-300 dark:text-white/20" />
            </button>
          </div>
        </div>

        {/* Account Group */}
        <div className="space-y-4">
          <h3 className="text-xs font-bold uppercase tracking-widest text-stone-400 dark:text-white/30 px-2">
            Account
          </h3>
          <button
            onClick={logout}
            className="w-full flex items-center gap-3 p-4 bg-red-500/10 text-red-500 rounded-2xl border border-red-500/20 hover:bg-red-500/20 transition-all font-bold"
          >
            <LogOut size={18} />
            {t("profile.logout")}
          </button>
        </div>
      </div>
    </div>
  );
}
