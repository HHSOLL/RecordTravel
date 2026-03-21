import { motion, AnimatePresence } from "framer-motion";
import Logo from "./Logo";

export default function SplashScreen({ isVisible }: { isVisible: boolean }) {
  return (
    <AnimatePresence>
      {isVisible && (
        <motion.div
          initial={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.8, ease: "easeInOut" }}
          className="fixed inset-0 z-[100] flex flex-col items-center justify-center bg-stone-50 dark:bg-stone-900"
        >
          <motion.div
            initial={{ scale: 0.8, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            transition={{ duration: 0.5, ease: "easeOut" }}
            className="flex flex-col items-center gap-6"
          >
            <Logo size={80} />
            <motion.h1
              initial={{ y: 20, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              transition={{ delay: 0.3, duration: 0.5 }}
              className="text-4xl font-black tracking-tighter text-stone-900 dark:text-white"
            >
              record
            </motion.h1>
            <motion.p
              initial={{ opacity: 0 }}
              animate={{ opacity: 0.5 }}
              transition={{ delay: 0.6, duration: 0.5 }}
              className="text-sm font-medium tracking-widest uppercase text-stone-500 dark:text-white/50"
            >
              Capture your journey
            </motion.p>
          </motion.div>
          
          <motion.div 
            initial={{ scaleX: 0 }}
            animate={{ scaleX: 1 }}
            transition={{ delay: 0.2, duration: 1.5, ease: "easeInOut" }}
            className="absolute bottom-20 w-32 h-0.5 bg-stone-200 dark:bg-white/10 origin-left"
          />
        </motion.div>
      )}
    </AnimatePresence>
  );
}
