import React, { createContext, useContext, useState, useEffect } from "react";

type Language = "ko" | "en";

interface LanguageContextType {
  language: Language;
  setLanguage: (lang: Language) => void;
  t: (key: string) => string;
}

const translations: Record<Language, Record<string, string>> = {
  ko: {
    "app.name": "record",
    "onboarding.title": "당신의 여정을 기록하세요",
    "onboarding.subtitle": "개인용 3D 지구본에 모든 순간과 목적지를 담아보세요.",
    "onboarding.signup": "회원가입",
    "onboarding.login": "로그인",
    "onboarding.guest": "둘러보기",
    "home.title": "님의 지구본",
    "home.stats": "개 도시, 개국 여행자",
    "home.helper": "+ 버튼을 눌러 새로운 여행을 기록해보세요.",
    "nav.home": "홈",
    "nav.archive": "보관함",
    "nav.planner": "플래너",
    "nav.profile": "마이페이지",
    "nav.create": "기록하기",
    "profile.title": "마이페이지",
    "profile.language": "언어 설정",
    "profile.logout": "로그아웃",
    "archive.title": "아카이브",
    "archive.tripsThisYear": "올해 완료한 여행",
    "archive.allCompanions": "모든 동행자",
    "archive.with": "동행:",
    "archive.countries": "국가",
    "archive.trips": "여행",
    "planner.title": "플래너",
    "planner.upcomingTrips": "개의 예정된 여행이 있습니다",
    "planner.openMap": "지도 보기",
    "planner.schedule": "일정 보기",
    "planner.view": "보기",
    "planner.noUpcoming": "예정된 여행이 없습니다.",
    "planner.planNew": "새 여행 계획하기",
    "create.title": "새로운 여정",
    "create.step": "단계",
    "create.of": "/",
    "create.where": "어디로 다녀오셨나요?",
    "create.tripTitle": "여행 제목",
    "create.country": "국가",
    "create.when": "언제였나요?",
    "create.startDate": "시작일",
    "create.endDate": "종료일",
    "create.upload": "추억 업로드",
    "create.uploadDesc": "사진에서 위치와 날짜를 자동으로 추출하여 타임라인을 구성합니다.",
    "create.selectPhotos": "사진 선택",
    "create.dragDrop": "또는 여기에 드래그 앤 드롭",
    "create.invite": "동행자 초대",
    "create.continue": "계속하기",
    "create.createJourney": "여정 생성",
    "create.analyzing": "사진 분석 중...",
    "create.analyzingDesc": "시간과 장소별로 사진을 정리하고 있습니다.",
    "create.organized": "개의 사진이 정리되었습니다.",
    "create.description": "설명",
    "create.descriptionPlaceholder": "이 여행에 대해 들려주세요...",
    "auth.email": "이메일",
    "auth.username": "아이디",
    "auth.nickname": "닉네임",
    "auth.password": "비밀번호",
    "auth.login": "로그인",
    "auth.signup": "회원가입",
    "auth.noAccount": "계정이 없으신가요?",
    "auth.hasAccount": "이미 계정이 있으신가요?",
    "auth.google": "Google로 계속하기",
    "auth.error": "정보를 다시 확인해주세요.",
    "auth.welcome": "환영합니다!",
    "common.save": "저장",
    "common.cancel": "취소",
    "common.delete": "삭제"
  },
  en: {
    "app.name": "record",
    "onboarding.title": "Record Your Journey",
    "onboarding.subtitle": "Capture every moment and destination on your personal 3D globe.",
    "onboarding.signup": "Sign up",
    "onboarding.login": "Login",
    "onboarding.guest": "Continue as Guest",
    "home.title": "'s Globe",
    "home.stats": "cities, countries traveled",
    "home.helper": "Tap + to record a new journey.",
    "nav.home": "Home",
    "nav.archive": "Archive",
    "nav.planner": "Planner",
    "nav.profile": "Profile",
    "nav.create": "Create",
    "profile.title": "My Profile",
    "profile.language": "Language Settings",
    "profile.logout": "Logout",
    "archive.title": "Archive",
    "archive.tripsThisYear": "Trips completed this year",
    "archive.allCompanions": "All Companions",
    "archive.with": "With",
    "archive.countries": "Countries",
    "archive.trips": "Trips",
    "planner.title": "Planner",
    "planner.upcomingTrips": "upcoming trips",
    "planner.openMap": "Open Map",
    "planner.schedule": "Schedule",
    "planner.view": "View",
    "planner.noUpcoming": "No upcoming trips planned.",
    "planner.planNew": "Plan a new trip",
    "create.title": "New Journey",
    "create.step": "Step",
    "create.of": "of",
    "create.where": "Where did you go?",
    "create.tripTitle": "Trip Title",
    "create.country": "Country",
    "create.when": "When was it?",
    "create.startDate": "Start Date",
    "create.endDate": "End Date",
    "create.upload": "Upload Memories",
    "create.uploadDesc": "We'll automatically extract locations and dates from your photos to build your timeline.",
    "create.selectPhotos": "Select Photos",
    "create.dragDrop": "or drag and drop here",
    "create.invite": "Invite Companions",
    "create.continue": "Continue",
    "create.createJourney": "Create Journey",
    "create.analyzing": "Analyzing Photos...",
    "create.analyzingDesc": "Organizing photos by time and place.",
    "create.organized": "photos organized.",
    "create.description": "Description",
    "create.descriptionPlaceholder": "Tell us about this journey...",
    "auth.email": "Email",
    "auth.username": "ID",
    "auth.nickname": "Nickname",
    "auth.password": "Password",
    "auth.login": "Login",
    "auth.signup": "Sign up",
    "auth.noAccount": "Don't have an account?",
    "auth.hasAccount": "Already have an account?",
    "auth.google": "Continue with Google",
    "auth.error": "Please check your information.",
    "auth.welcome": "Welcome!",
    "common.save": "Save",
    "common.cancel": "Cancel",
    "common.delete": "Delete"
  }
};

const LanguageContext = createContext<LanguageContextType | undefined>(undefined);

export const LanguageProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [language, setLanguageState] = useState<Language>(() => {
    const saved = localStorage.getItem("app_language");
    return (saved as Language) || "ko";
  });

  const setLanguage = (lang: Language) => {
    setLanguageState(lang);
    localStorage.setItem("app_language", lang);
  };

  const t = (key: string) => {
    return translations[language][key] || key;
  };

  return (
    <LanguageContext.Provider value={{ language, setLanguage, t }}>
      {children}
    </LanguageContext.Provider>
  );
};

export const useLanguage = () => {
  const context = useContext(LanguageContext);
  if (!context) {
    throw new Error("useLanguage must be used within a LanguageProvider");
  }
  return context;
};
