import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class RecordStrings {
  RecordStrings._(this._languageCode);

  final String _languageCode;

  static RecordStrings of(BuildContext context) {
    return RecordStrings._(Localizations.localeOf(context).languageCode);
  }

  bool get isKorean => _languageCode == 'ko';

  DateFormat dateFormat(String pattern) {
    try {
      return DateFormat(pattern, _languageCode);
    } catch (_) {
      return DateFormat(pattern);
    }
  }

  String text(String key) {
    return _translations[_languageCode]?[key] ??
        _translations['en']?[key] ??
        key;
  }

  String homeTitle(String name) => isKorean ? '$name님의 지구본' : '$name\'s Globe';

  String cityCountryProgress(int cities, int countries) => isKorean
      ? '$cities 도시, $countries 나라를 기록했어요'
      : '$cities cities, $countries countries recorded';

  String upcomingTrips(int count) =>
      isKorean ? '예정된 여행 $count개' : '$count upcoming trips';

  String pastTrips(int total, int visible) => isKorean
      ? '지난 여행 $total개 • 표시 중 $visible개'
      : '$total past trips • $visible visible';

  String profileTrips(int total) => isKorean ? '$total 여행' : '$total trips';

  String timelineEntries(int count) =>
      isKorean ? '기록 $count개' : '$count entries';

  String stopCount(int count) =>
      isKorean ? '$count 경유지' : '$count stop${count == 1 ? '' : 's'}';

  String plannerCountdownLabel(int daysLeft) {
    if (daysLeft > 0) {
      return 'D-$daysLeft';
    }
    if (daysLeft == 0) {
      return 'D-Day';
    }
    return isKorean ? '여행 중' : 'Started';
  }

  String continentLabel(String continent) {
    if (!isKorean) {
      return continent;
    }

    return switch (continent.toLowerCase()) {
      'asia' => '아시아',
      'europe' => '유럽',
      'north america' => '북아메리카',
      'south america' => '남아메리카',
      'oceania' => '오세아니아',
      'africa' => '아프리카',
      'antarctica' => '남극',
      _ => continent,
    };
  }

  String countryName(String countryCode, String fallback) {
    return _countryNames[_languageCode]?[countryCode] ??
        _countryNames['en']?[countryCode] ??
        fallback;
  }

  String tripTitle(String tripId, String fallback) {
    return _tripTitles[_languageCode]?[tripId] ??
        _tripTitles['en']?[tripId] ??
        fallback;
  }

  String tripDescription(String tripId, String fallback) {
    return _tripDescriptions[_languageCode]?[tripId] ??
        _tripDescriptions['en']?[tripId] ??
        fallback;
  }

  static const _translations = <String, Map<String, String>>{
    'ko': {
      'app.name': 'record',
      'nav.home': '홈',
      'nav.archive': '보관함',
      'nav.planner': '플래너',
      'nav.profile': '마이페이지',
      'nav.create': '여행 추가하기',
      'home.helper': '지구본을 드래그해서 지난 여정을 다시 훑어보세요.',
      'home.empty': '아직 여행 기록이 없습니다. 첫 여행을 추가해 보세요.',
      'home.actionsTitle': '다음 액션',
      'home.actionsSubtitle': '새 여행을 만들거나 갤러리에서 추억을 불러와 지구본을 채워보세요.',
      'home.importGallery': '갤러리 전체 가져오기',
      'home.importGallerySubtitle': '사진 메타데이터를 스캔해 여행 기록 초안을 만듭니다.',
      'home.createTrip': '새 여행 만들기',
      'home.createTripSubtitle': '다음 목적지를 추가하고 플래너를 채웁니다.',
      'home.countryOpen': '나라 보기',
      'home.countryDraft': '아직 세부 기록이 없어 홈에서는 분위기만 먼저 보여줍니다.',
      'home.metricMemories': '기록',
      'home.metricCities': '도시',
      'home.metricLatest': '최근',
      'home.globeUnavailableTitle': '3D 지구본을 불러오지 못했습니다.',
      'home.globeUnavailableSubtitle':
          '이 기기에서는 안정적인 미리보기 경로로 전환했습니다. 아래 국가 버튼으로 2D 상세를 바로 열 수 있습니다.',
      'home.globeAvailabilityCheckingTitle': '3D 보기 가능 여부를 확인하는 중입니다.',
      'home.globeAvailabilityCheckingSubtitle': '기기를 확인하는 동안 홈 화면을 준비하고 있습니다.',
      'home.retry3d': '3D 다시 시도',
      'home.quickCountries': '빠른 국가 열기',
      'map.unavailableTitle': '지도를 불러올 수 없습니다.',
      'map.unavailableSubtitle':
          '이 빌드에는 사용할 수 있는 지도 인증 정보가 없어 경로와 정차를 카드 정보로만 표시합니다.',
      'planner.title': '플래너',
      'planner.noUpcoming': '예정된 여행이 없습니다.',
      'planner.planNew': '새 여행 계획하기',
      'planner.heroTitle': '다음 여정을 준비하세요',
      'planner.heroSubtitle': '예정된 여행과 갤러리 메타데이터를 한곳에서 관리합니다.',
      'planner.importLibrary': '갤러리 전체 가져오기',
      'planner.importLibrarySubtitle': '사진 정보를 먼저 읽어 여행과 연결할 수 있습니다.',
      'planner.nextDeparture': '가장 가까운 출발',
      'planner.mapped': '기록 위치',
      'planner.nextShort': '다음',
      'planner.openMap': '지도 보기',
      'planner.schedule': '일정 보기',
      'planner.view': '열기',
      'archive.title': '아카이브',
      'archive.allCompanions': '전체',
      'archive.trips': '여행',
      'archive.countries': '국가',
      'archive.continents': '대륙',
      'archive.searchHint': '여행 제목 검색',
      'archive.periodFilter': '기간 선택',
      'archive.clearFilters': '필터 해제',
      'archive.empty': '완료된 여행 기록이 아직 없습니다.',
      'archive.noMatches': '현재 필터에 맞는 여행이 없습니다.',
      'profile.title': '마이페이지',
      'profile.preferences': '환경 설정',
      'profile.account': '계정',
      'profile.workspaceTitle': '기록 워크스페이스',
      'profile.workspaceSubtitle': '가져오기와 동기화 상태를 먼저 확인하고 설정을 조정하세요.',
      'profile.importLibrary': '갤러리 전체 가져오기',
      'profile.importLibrarySubtitle': '사진 메타데이터를 읽어 로컬 기록 큐로 보냅니다.',
      'profile.syncNow': '지금 동기화',
      'profile.syncNowSubtitle': '로컬 변경사항과 업로드 대기열 상태를 새로고칩니다.',
      'profile.photos': '사진',
      'profile.pendingUploads': '대기 업로드',
      'profile.language': '언어 설정',
      'profile.systemTheme': '시스템 테마',
      'profile.systemThemeSubtitle': '현재는 다크 모드만 지원합니다.',
      'profile.systemShort': '시스템',
      'profile.lightShort': '라이트',
      'profile.darkShort': '다크',
      'profile.darkMode': '다크 모드',
      'profile.lightMode': '라이트 모드',
      'profile.logout': '로그아웃',
      'profile.previewAuth': '임시 로그인 모드',
      'profile.previewAuthSubtitle': '완성 전까지는 아무 아이디로 들어올 수 있습니다.',
      'create.title': '새 여행 만들기',
      'create.step': '단계',
      'create.of': '/',
      'create.where': '어디로 떠나시나요?',
      'create.destination': '도시',
      'create.country': '국가',
      'create.when': '언제인가요?',
      'create.startDate': '시작일',
      'create.endDate': '종료일',
      'create.description': '설명',
      'create.descriptionPlaceholder': '이번 여행에서 기대하는 순간이나 테마를 적어보세요.',
      'create.tripTitle': '여행 제목',
      'create.continue': '다음',
      'create.back': '이전',
      'create.createJourney': '여행 만들기',
      'create.review': '마지막으로 여행의 분위기를 정리합니다.',
      'create.previewNote':
          '사진 업로드 자동화는 다음 단계에서 연결할 예정입니다. 지금은 여행 자체를 먼저 저장합니다.',
      'trip.timeline': '타임라인',
      'trip.map': '지도',
      'trip.noEntries': '아직 연결된 기록이 없습니다.',
      'trip.noMap': '표시할 위치 정보가 아직 없습니다.',
      'common.save': '저장',
      'common.cancel': '취소',
      'common.close': '닫기',
      'common.photo': '사진',
      'common.note': '메모',
      'common.none': '없음',
    },
    'en': {
      'app.name': 'record',
      'nav.home': 'Home',
      'nav.archive': 'Archive',
      'nav.planner': 'Planner',
      'nav.profile': 'Profile',
      'nav.create': 'Add Trip',
      'home.helper':
          'Drag the globe to revisit the places you already recorded.',
      'home.empty': 'No trips yet. Start by adding your first journey.',
      'home.actionsTitle': 'Next actions',
      'home.actionsSubtitle':
          'Add a new trip or bring in memories from your gallery to keep the globe moving.',
      'home.importGallery': 'Import full gallery',
      'home.importGallerySubtitle':
          'Scan photo metadata and stage travel drafts automatically.',
      'home.createTrip': 'Create a trip',
      'home.createTripSubtitle':
          'Add your next destination and keep the planner ready.',
      'home.countryOpen': 'Open Country',
      'home.countryDraft':
          'This country is only connected to a trip shell for now, so the home globe shows mood first.',
      'home.metricMemories': 'Memories',
      'home.metricCities': 'Cities',
      'home.metricLatest': 'Latest',
      'home.globeUnavailableTitle': '3D globe is unavailable right now.',
      'home.globeUnavailableSubtitle':
          'The app switched to a stable fallback preview. Use the quick country buttons below to open the 2D detail view.',
      'home.globeAvailabilityCheckingTitle': 'Checking 3D globe support.',
      'home.globeAvailabilityCheckingSubtitle':
          'The home view is preparing while the device capability is verified.',
      'home.retry3d': 'Retry 3D view',
      'home.quickCountries': 'Quick countries',
      'map.unavailableTitle': 'Map preview is unavailable.',
      'map.unavailableSubtitle':
          'This build does not have usable native map credentials, so routes and stops are shown as cards only.',
      'planner.title': 'Planner',
      'planner.noUpcoming': 'No upcoming trips yet.',
      'planner.planNew': 'Plan a new trip',
      'planner.heroTitle': 'Prepare the next journey',
      'planner.heroSubtitle':
          'Manage upcoming trips and gallery metadata in one place.',
      'planner.importLibrary': 'Import full gallery',
      'planner.importLibrarySubtitle':
          'Read photo metadata first, then connect it to trips.',
      'planner.nextDeparture': 'Next departure',
      'planner.mapped': 'Mapped',
      'planner.nextShort': 'Next',
      'planner.openMap': 'Open Map',
      'planner.schedule': 'Schedule',
      'planner.view': 'Open',
      'archive.title': 'Archive',
      'archive.allCompanions': 'All',
      'archive.trips': 'Trips',
      'archive.countries': 'Countries',
      'archive.continents': 'Continents',
      'archive.searchHint': 'Search trip titles',
      'archive.periodFilter': 'Pick dates',
      'archive.clearFilters': 'Clear filters',
      'archive.empty': 'No completed trips yet.',
      'archive.noMatches': 'No trips match the current filters.',
      'profile.title': 'Profile',
      'profile.preferences': 'Preferences',
      'profile.account': 'Account',
      'profile.workspaceTitle': 'record workspace',
      'profile.workspaceSubtitle':
          'Check import and sync status first, then adjust your settings.',
      'profile.importLibrary': 'Import full gallery',
      'profile.importLibrarySubtitle':
          'Read photo metadata and send it into the local record queue.',
      'profile.syncNow': 'Sync now',
      'profile.syncNowSubtitle':
          'Refresh the local change queue and upload status.',
      'profile.photos': 'Photos',
      'profile.pendingUploads': 'Pending uploads',
      'profile.language': 'Language',
      'profile.systemTheme': 'System Theme',
      'profile.systemThemeSubtitle':
          'Dark mode is the only supported appearance right now.',
      'profile.systemShort': 'System',
      'profile.lightShort': 'Light',
      'profile.darkShort': 'Dark',
      'profile.darkMode': 'Dark Mode',
      'profile.lightMode': 'Light Mode',
      'profile.logout': 'Log Out',
      'profile.previewAuth': 'Preview sign-in mode',
      'profile.previewAuthSubtitle':
          'Any ID works until the full auth flow is ready.',
      'create.title': 'Create a Trip',
      'create.step': 'Step',
      'create.of': 'of',
      'create.where': 'Where are you headed?',
      'create.destination': 'City',
      'create.country': 'Country',
      'create.when': 'When is it?',
      'create.startDate': 'Start Date',
      'create.endDate': 'End Date',
      'create.description': 'Description',
      'create.descriptionPlaceholder':
          'Describe the feeling, pace, or purpose of this trip.',
      'create.tripTitle': 'Trip Title',
      'create.continue': 'Next',
      'create.back': 'Back',
      'create.createJourney': 'Create Trip',
      'create.review': 'Finish the mood and save the trip shell first.',
      'create.previewNote':
          'Automatic photo import will be connected next. For now the trip itself is saved locally.',
      'trip.timeline': 'Timeline',
      'trip.map': 'Map',
      'trip.noEntries': 'No entries linked to this trip yet.',
      'trip.noMap': 'No mapped places yet.',
      'common.save': 'Save',
      'common.cancel': 'Cancel',
      'common.close': 'Close',
      'common.photo': 'Photo',
      'common.note': 'Note',
      'common.none': 'None',
    },
  };

  static const _countryNames = <String, Map<String, String>>{
    'ko': {
      'KR': '대한민국',
      'JP': '일본',
      'PT': '포르투갈',
      'FR': '프랑스',
      'TH': '태국',
      'US': '미국',
      'CA': '캐나다',
      'ES': '스페인',
      'IT': '이탈리아',
    },
    'en': {
      'KR': 'South Korea',
      'JP': 'Japan',
      'PT': 'Portugal',
      'FR': 'France',
      'TH': 'Thailand',
      'US': 'United States',
      'CA': 'Canada',
      'ES': 'Spain',
      'IT': 'Italy',
    },
  };

  static const _tripTitles = <String, Map<String, String>>{
    'ko': {
      'trip-seoul-kyoto': '서울과 교토 사이의 봄',
      'trip-paris-lisbon': '리스본의 대서양 빛',
      'trip-busan-jeju': '해안선을 따라 쉬어가기',
      'trip-sapporo-osaka': '북쪽의 눈빛, 도시의 밤',
      'trip-bangkok-chiangmai': '사원 열기와 야간열차',
      'trip-sf-vancouver': '태평양 편집 스프린트',
      'trip-barcelona-rome': '지중해 환승 여정',
    },
  };

  static const _tripDescriptions = <String, Map<String, String>>{
    'ko': {
      'trip-seoul-kyoto': '박물관, 비 내리는 골목, 그리고 늦은 밤의 메모들',
      'trip-paris-lisbon': '파리 일정 뒤에 이어진 조용한 한 주',
      'trip-busan-jeju': '카메라를 먼저 꺼낸 짧은 국내 리셋 여행',
      'trip-sapporo-osaka': '삿포로의 눈 내린 아침과 오사카의 골목 저녁',
      'trip-bangkok-chiangmai': '방콕 시장, 치앙마이 카페, 그리고 긴 야간열차 한 번',
      'trip-sf-vancouver': '업무 이동이 사진 일지가 된 태평양 연안 여정',
      'trip-barcelona-rome': '두 도시와 하나의 캐리온, 그리고 늦은 저녁이 많은 일정',
    },
  };
}
