import 'package:flutter/widgets.dart';

class RecordStrings {
  RecordStrings._(this._languageCode);

  final String _languageCode;

  static RecordStrings of(BuildContext context) {
    return RecordStrings._(Localizations.localeOf(context).languageCode);
  }

  bool get isKorean => _languageCode == 'ko';

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
      'home.countryOpen': '나라 보기',
      'home.countryDraft': '아직 세부 기록이 없어 홈에서는 분위기만 먼저 보여줍니다.',
      'home.metricMemories': '기록',
      'home.metricCities': '도시',
      'home.metricLatest': '최근',
      'planner.title': '플래너',
      'planner.noUpcoming': '예정된 여행이 없습니다.',
      'planner.planNew': '새 여행 계획하기',
      'planner.openMap': '지도 보기',
      'planner.schedule': '일정 보기',
      'planner.view': '열기',
      'archive.title': '아카이브',
      'archive.allCompanions': '전체',
      'archive.empty': '완료된 여행 기록이 아직 없습니다.',
      'profile.title': '마이페이지',
      'profile.preferences': '환경 설정',
      'profile.account': '계정',
      'profile.language': '언어 설정',
      'profile.systemTheme': '시스템 테마',
      'profile.systemThemeSubtitle': '아이폰의 밝기 설정을 그대로 따릅니다.',
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
      'home.countryOpen': 'Open Country',
      'home.countryDraft':
          'This country is only connected to a trip shell for now, so the home globe shows mood first.',
      'home.metricMemories': 'Memories',
      'home.metricCities': 'Cities',
      'home.metricLatest': 'Latest',
      'planner.title': 'Planner',
      'planner.noUpcoming': 'No upcoming trips yet.',
      'planner.planNew': 'Plan a new trip',
      'planner.openMap': 'Open Map',
      'planner.schedule': 'Schedule',
      'planner.view': 'Open',
      'archive.title': 'Archive',
      'archive.allCompanions': 'All',
      'archive.empty': 'No completed trips yet.',
      'profile.title': 'Profile',
      'profile.preferences': 'Preferences',
      'profile.account': 'Account',
      'profile.language': 'Language',
      'profile.systemTheme': 'System Theme',
      'profile.systemThemeSubtitle':
          'Follows your iPhone appearance automatically.',
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
}
