import { Moon, Sun } from "lucide-react";
import { useTheme } from "../store/ThemeContext";

export default function ThemeToggle() {
  const { theme, toggleTheme } = useTheme();

  return (
    <button
      onClick={toggleTheme}
      className="p-2 bg-white/5 dark:bg-white/5 bg-stone-200 rounded-full backdrop-blur-md border border-stone-300 dark:border-white/10 hover:bg-stone-300 dark:hover:bg-white/10 transition-colors"
      aria-label="Toggle theme"
    >
      {theme === 'dark' ? (
        <Sun size={20} className="text-white" />
      ) : (
        <Moon size={20} className="text-stone-900" />
      )}
    </button>
  );
}
