import React, { createContext, useContext, useState, useEffect } from "react";

interface User {
  username: string;
  nickname: string;
  photoURL?: string;
}

interface AuthContextType {
  user: User | null;
  login: (username: string, password: string) => boolean;
  signup: (username: string, password: string, nickname: string) => boolean;
  logout: () => void;
  loading: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const savedUser = localStorage.getItem("current_user");
    if (savedUser) {
      setUser(JSON.parse(savedUser));
    }
    setLoading(false);
  }, []);

  const signup = (username: string, password: string, nickname: string) => {
    const users = JSON.parse(localStorage.getItem("app_users") || "[]");
    if (users.find((u: any) => u.username === username)) {
      return false;
    }
    const newUser = { username, password, nickname };
    users.push(newUser);
    localStorage.setItem("app_users", JSON.stringify(users));
    
    // Auto login after signup
    const sessionUser = { username, nickname };
    setUser(sessionUser);
    localStorage.setItem("current_user", JSON.stringify(sessionUser));
    return true;
  };

  const login = (username: string, password: string) => {
    const users = JSON.parse(localStorage.getItem("app_users") || "[]");
    const foundUser = users.find((u: any) => u.username === username && u.password === password);
    if (foundUser) {
      const sessionUser = { username: foundUser.username, nickname: foundUser.nickname };
      setUser(sessionUser);
      localStorage.setItem("current_user", JSON.stringify(sessionUser));
      return true;
    }
    return false;
  };

  const logout = () => {
    setUser(null);
    localStorage.removeItem("current_user");
  };

  return (
    <AuthContext.Provider value={{ user, login, signup, logout, loading }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
};
