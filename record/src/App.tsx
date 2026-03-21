/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import { useEffect, useState } from "react";
import { BrowserRouter as Router, Routes, Route, Navigate } from "react-router-dom";
import Navigation from "./components/Navigation";
import Onboarding from "./pages/Onboarding";
import Home from "./pages/Home";
import TripDetail from "./pages/TripDetail";
import Archive from "./pages/Archive";
import Planner from "./pages/Planner";
import CreateTrip from "./pages/CreateTrip";
import Profile from "./pages/Profile";
import { TripProvider } from "./store/TripContext";
import { ThemeProvider } from "./store/ThemeContext";
import { LanguageProvider } from "./store/LanguageContext";
import { AuthProvider, useAuth } from "./store/AuthContext";
import SplashScreen from "./components/SplashScreen";

function AppContent() {
  const [showSplash, setShowSplash] = useState(true);
  const { user, loading } = useAuth();

  useEffect(() => {
    const timer = setTimeout(() => {
      setShowSplash(false);
    }, 2500); 
    return () => clearTimeout(timer);
  }, []);

  if (loading) return null;

  return (
    <Router>
      <div className="bg-stone-50 dark:bg-[#0a0a0a] min-h-screen text-stone-900 dark:text-stone-50 font-sans selection:bg-amber-400/30 transition-colors duration-300">
        <SplashScreen isVisible={showSplash} />
        <Routes>
          <Route path="/" element={user ? <Navigate to="/home" /> : <Onboarding />} />
          <Route path="/home" element={user ? <Home /> : <Navigate to="/" />} />
          <Route path="/trip/:id" element={user ? <TripDetail /> : <Navigate to="/" />} />
          <Route path="/archive" element={user ? <Archive /> : <Navigate to="/" />} />
          <Route path="/planner" element={user ? <Planner /> : <Navigate to="/" />} />
          <Route path="/create" element={user ? <CreateTrip /> : <Navigate to="/" />} />
          <Route path="/profile" element={user ? <Profile /> : <Navigate to="/" />} />
        </Routes>
        {user && <Navigation />}
      </div>
    </Router>
  );
}

export default function App() {
  return (
    <LanguageProvider>
      <AuthProvider>
        <ThemeProvider>
          <TripProvider>
            <AppContent />
          </TripProvider>
        </ThemeProvider>
      </AuthProvider>
    </LanguageProvider>
  );
}
