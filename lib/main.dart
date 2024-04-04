import 'package:flutter/material.dart';
import 'package:food_pick/model/food_store.dart';
import 'package:food_pick/screen/detail_screen.dart';
import 'package:food_pick/screen/edit_screen.dart';
import 'package:food_pick/screen/login_screen.dart';
import 'package:food_pick/screen/main_screen.dart';
import 'package:food_pick/screen/register_screen.dart';
import 'package:food_pick/screen/search_address_screen.dart';
import 'package:food_pick/screen/search_result_screen.dart';
import 'package:food_pick/screen/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

// TODO: 로그인 화면 에러 스낵바로 출력되지 않는 문제 해결해야 함
// TODO: dart 파일마다 반복되는 함수들 따로 빼내기
// TODO: 에러 상황 발생시 에러를 좀 더 자세히 파악할 수 있도록 -> 현재는 성공 실패 여부만 알 수 있음
// TODO: 민감 정보 감추기(API 키, ApiUrl)
// TODO: riverpod 으로 리팩토링
// TODO: 하드 코딩된 문자열 리소스로 추출
// TODO: 자동 로그인 구현
// TODO: lint 추가
// TODO: supabase 에 데이터를 저장 실패시, 실패관련 로그가 출력되도록(이유 파악을 위함)
// TODO: 사진 촬영시에도 권한 요청 플로우 추가
// TODO: iOS 에뮬레이터에서도 잘 동작하는지 확인
// TODO: supabase 객체 싱글톤으로 관리(강의 참고)
Future<void> main() async {
  // main 메소드에서 비동기로 데이터를 다루는 상황이 있을 때 반드시 최초에 호출을 해줘야 함
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ujazkiruzhepdqbirumw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVqYXpraXJ1emhlcGRxYmlydW13Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTE1NjcxMDEsImV4cCI6MjAyNzE0MzEwMX0.c5rFC3MjQP7Tqo4J7LWYR8r3c74_4yIADSSf-G9pO8g',
  );

  await NaverMapSdk.instance.initialize(
    clientId: '8eq3utwfe5',
    onAuthFailed: (exception) => print('네이버 맵 인증오류 : $exception'),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/main': (context) => MainScreen(),
        '/edit': (context) => EditScreen(),
        '/search_address': (context) => SearchAddressScreen(),
        // onGenerateRoute 에서 선언했으므로 여기엔 필요 없음
        // '/detail': (context) => DetailScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {
          FoodStoreModel foodStoreModel = settings.arguments as FoodStoreModel;
          return MaterialPageRoute(
            builder: (context) {
              return DetailScreen(foodStoreModel: foodStoreModel);
            },
          );
        } else if (settings.name == '/search_result') {
          List<FoodStoreModel> lstFoodStore =
              settings.arguments as List<FoodStoreModel>;
          return MaterialPageRoute(
            builder: (context) {
              return SearchResultScreen(
                lstFoodStore: lstFoodStore,
              );
            },
          );
        }
      },
    );
  }
}
