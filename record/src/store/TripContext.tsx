import { createContext, useContext, useState, ReactNode, Dispatch, SetStateAction } from 'react';
import { TRIPS as initialTrips, Trip } from './mockData';

interface TripContextType {
  trips: Trip[];
  setTrips: Dispatch<SetStateAction<Trip[]>>;
  updateTrip: (updatedTrip: Trip) => void;
  addTrip: (newTrip: Trip) => void;
}

const TripContext = createContext<TripContextType | undefined>(undefined);

export function TripProvider({ children }: { children: ReactNode }) {
  const [trips, setTrips] = useState<Trip[]>(initialTrips);

  const updateTrip = (updatedTrip: Trip) => {
    setTrips((prevTrips) =>
      prevTrips.map((trip) => (trip.id === updatedTrip.id ? updatedTrip : trip))
    );
  };

  const addTrip = (newTrip: Trip) => {
    setTrips((prevTrips) => [newTrip, ...prevTrips]);
  };

  return (
    <TripContext.Provider value={{ trips, setTrips, updateTrip, addTrip }}>
      {children}
    </TripContext.Provider>
  );
}

export function useTrips() {
  const context = useContext(TripContext);
  if (context === undefined) {
    throw new Error('useTrips must be used within a TripProvider');
  }
  return context;
}
