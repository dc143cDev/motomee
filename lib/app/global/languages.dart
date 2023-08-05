import 'package:get/get.dart';

class Languages extends Translations {
  @override
  //locale
  Map<String, Map<String, String>> get keys => {
        //en_us는 원래 텍스트와 동일하도록 함.
        'en_US': {
          'Insert here': ' Insert here',
          'Tags': 'Tags',
          'Customizing': 'Customizing',
          'Searching': 'Searching',
          'Search here': ' Search here',
          'Device': 'Device',
          'Light': 'Light',
          'Dark': 'Dark',
          //태그는 중복 패스
          //control view.
          'Deleted Memo': 'Deleted Memo',
          'Fonts & Locale': 'Fonts & Locale',
          'Application info': 'Application Info',
          'Tags Customize': 'Tags Customize',
          //trash view.
          'Recover Memo': 'Recover Memo',
          'Hard Delete': 'Hard Delete',
          'Delete All Items': 'Delete All Items',
          'Are you sure you want to \npermanently delete all items?':
              'Are you sure you want to \npermanently delete all items?',
          'Cancel': 'Cancel',
          'Confirm': 'Confirm',
          //empty.
          'Deleted Memo\nis Empty': 'Deleted Memo\nis Empty',
          'Memo is Empty': 'Memo is Empty',
          'Can not found Memo': 'Can not find Memo',
          'Tagged in ': 'Tagged in ',
          'Searched in ': 'Searched in ',
          'Please get send button\nTo add Memo':
              'Please get send button\nTo add Memo',
        },
        'en_UK': {
          'Insert here': ' Insert here',
        },
        'ko_KR': {
          'Insert here': ' 메모 입력',
          'Tags': '태그',
          'Customizing': '태그 설정',
          'Searching': '검색하기',
          'Search here': ' 검색어 입력',
          'Device': '설정에 맞게',
          'Light': '라이트',
          'Dark': '다크',
          'Deleted Memo': '삭제한 메모',
          'Fonts & Locale': '폰트 및 언어',
          'Application info': '애플리케이션 정보',
          'Tags Customize': '태그 설정',
          'Recover Memo': '메모 복구하기',
          'Hard Delete': '메모 엉구 삭제',
          'Delete All Items': '모든 메모 영구 삭제',
          'Are you sure you want to \npermanently delete all items?':
              '삭제한 모든 메모를\n영구적으로 삭제하시겠습니까?',
          'Cancel': '취소',
          'Confirm': '확인',
          'Deleted Memo\nis Empty': '삭제한 메모가\n없어요',
          'Memo is Empty': '메모가 비었어요',
          'Can not found Memo': '메모를 찾을수 없어요',
          'Tagged in ': '현재 설정된 태그: ',
          'Searched in ': '현재 설정된 검색어: ',
          'Please get send button\nTo add Memo': '전송 버튼을 눌러\n메모를 추가해주세요',
        },
        'ja_JP': {
          'Insert here': ' Insert here',
        },
      };
}
