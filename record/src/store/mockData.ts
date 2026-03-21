export interface Country {
  name: string;
  code: string;
  continent: string;
}

export interface Trip {
  id: string;
  title: string;
  countries: Country[];
  startDate: string;
  endDate: string;
  description: string;
  coverImage: string;
  isUpcoming: boolean;
  locations: Location[];
  color: string;
  companions: string[];
}

export interface Location {
  id: string;
  name: string;
  lat: number;
  lng: number;
  date: string;
  photos: string[];
}

export const USER_DATA = {
  name: "한솔",
  title: "호기심 많은 세계 기록가",
  totalCities: 8,
  totalCountries: 5,
};

export const TRIPS: Trip[] = [
  {
    id: "trip-1",
    title: "Busan",
    countries: [{ name: "South Korea", code: "KR", continent: "Asia" }],
    startDate: "2025-08-10",
    endDate: "2025-08-15",
    description: "Busan was so rainy on the first day. We took a taxi from the train station to the W...",
    coverImage: "https://picsum.photos/seed/busan/800/600",
    isUpcoming: false,
    color: "#0047A0", // Blue from KR flag
    companions: ["Chris", "Alex"],
    locations: [
      {
        id: "loc-1",
        name: "Haeundae Beach",
        lat: 35.1587,
        lng: 129.1604,
        date: "2025-08-11",
        photos: ["https://picsum.photos/seed/haeundae1/400/400", "https://picsum.photos/seed/haeundae2/400/400"],
      },
      {
        id: "loc-2",
        name: "Gamcheon Culture Village",
        lat: 35.0975,
        lng: 129.0106,
        date: "2025-08-12",
        photos: ["https://picsum.photos/seed/gamcheon/400/400"],
      },
    ],
  },
  {
    id: "trip-2",
    title: "Yukon",
    countries: [{ name: "Canada", code: "CA", continent: "North America" }],
    startDate: "2025-12-20",
    endDate: "2025-12-28",
    description: "I've always wanted to visit Yukon so it was really nice that Chris offers to plan and book a tri...",
    coverImage: "https://picsum.photos/seed/yukon/800/600",
    isUpcoming: false,
    color: "#FF0000", // Red from CA flag
    companions: ["Chris"],
    locations: [
      {
        id: "loc-3",
        name: "Whitehorse",
        lat: 60.7212,
        lng: -135.0568,
        date: "2025-12-21",
        photos: ["https://picsum.photos/seed/whitehorse/400/400"],
      },
    ],
  },
  {
    id: "trip-3",
    title: "Grad Trip",
    countries: [{ name: "Japan", code: "JP", continent: "Asia" }],
    startDate: "2026-05-01",
    endDate: "2026-05-27",
    description: "Tokyo, Osaka",
    coverImage: "https://picsum.photos/seed/japan/800/600",
    isUpcoming: true,
    color: "#BC002D", // Crimson Red from JP flag
    companions: ["Sam"],
    locations: [
      {
        id: "loc-4",
        name: "Tokyo",
        lat: 35.6762,
        lng: 139.6503,
        date: "2026-05-02",
        photos: [],
      },
      {
        id: "loc-5",
        name: "Osaka",
        lat: 34.6937,
        lng: 135.5023,
        date: "2026-05-10",
        photos: [],
      },
    ],
  },
  {
    id: "trip-4",
    title: "Euro Trip",
    countries: [
      { name: "Italy", code: "IT", continent: "Europe" },
      { name: "France", code: "FR", continent: "Europe" }
    ],
    startDate: "2024-06-01",
    endDate: "2024-06-15",
    description: "Rome, Florence, Venice, Paris",
    coverImage: "https://picsum.photos/seed/italy/800/600",
    isUpcoming: false,
    color: "#009246", // Green from IT flag
    companions: ["Alex", "Sam"],
    locations: [
      {
        id: "loc-6",
        name: "Rome",
        lat: 41.9028,
        lng: 12.4964,
        date: "2024-06-02",
        photos: ["https://picsum.photos/seed/rome/400/400"],
      },
      {
        id: "loc-7",
        name: "Paris",
        lat: 48.8566,
        lng: 2.3522,
        date: "2024-06-10",
        photos: ["https://picsum.photos/seed/paris/400/400"],
      }
    ],
  }
];
