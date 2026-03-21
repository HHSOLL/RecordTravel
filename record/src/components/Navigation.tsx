import { Globe, Map, PlusCircle, Calendar, User } from "lucide-react";
import { Link, useLocation } from "react-router-dom";
import { cn } from "../lib/utils";
import { useLanguage } from "../store/LanguageContext";

export default function Navigation() {
  const location = useLocation();
  const { t } = useLanguage();

  const navItems = [
    { icon: Globe, path: "/home", label: t("nav.home") },
    { icon: Map, path: "/archive", label: t("nav.archive") },
    { icon: PlusCircle, path: "/create", label: t("nav.create"), isPrimary: true },
    { icon: Calendar, path: "/planner", label: t("nav.planner") },
    { icon: User, path: "/profile", label: t("nav.profile") },
  ];

  // Don't show nav on onboarding
  if (location.pathname === "/") return null;

  return (
    <div className="fixed bottom-0 left-0 right-0 z-50 px-6 pb-8 pt-4 bg-gradient-to-t from-stone-50 dark:from-[#0a0a0a] to-transparent pointer-events-none transition-colors duration-300">
      <div className="max-w-md mx-auto bg-white/90 dark:bg-stone-800/90 backdrop-blur-md border border-stone-200 dark:border-white/10 rounded-full px-6 py-3 flex items-center justify-between pointer-events-auto shadow-2xl transition-colors duration-300">
        {navItems.map((item) => {
          const isActive = location.pathname === item.path;
          const Icon = item.icon;

          if (item.isPrimary) {
            return (
              <Link
                key={item.path}
                to={item.path}
                className="w-12 h-12 bg-amber-500 dark:bg-amber-400 rounded-full flex items-center justify-center shadow-[0_0_20px_rgba(245,158,11,0.4)] dark:shadow-[0_0_20px_rgba(251,191,36,0.4)] text-white dark:text-stone-900 hover:scale-105 transition-transform"
              >
                <Icon size={24} strokeWidth={2.5} />
              </Link>
            );
          }

          return (
            <Link
              key={item.path}
              to={item.path}
              className={cn(
                "p-2 rounded-full transition-colors",
                isActive ? "text-stone-900 bg-stone-100 dark:text-white dark:bg-white/10" : "text-stone-400 hover:text-stone-700 dark:text-white/50 dark:hover:text-white/80"
              )}
            >
              <Icon size={24} strokeWidth={2} />
            </Link>
          );
        })}
      </div>
    </div>
  );
}
