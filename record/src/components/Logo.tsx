import { Globe } from "lucide-react";

export default function Logo({ size = 24, className = "" }: { size?: number, className?: string }) {
  return (
    <div className={`relative flex items-center justify-center ${className}`} style={{ width: size, height: size }}>
      <Globe size={size} className="text-stone-900 dark:text-white" strokeWidth={1.5} />
      <div 
        className="absolute w-1/3 h-1/3 bg-red-500 rounded-full animate-pulse" 
        style={{ top: '50%', left: '50%', transform: 'translate(-50%, -50%)' }}
      />
    </div>
  );
}
