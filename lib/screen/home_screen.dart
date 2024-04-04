import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:food_pick/widget/buttons.dart';
import 'package:food_pick/widget/text_fields.dart';
import 'package:food_pick/widget/texts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/food_store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late NaverMapController _mapController;
  Completer<NaverMapController> mapControllerCompleter = Completer();
  final supabase = Supabase.instance.client;

  Future<List<FoodStoreModel>>? _dataFuture;
  List<FoodStoreModel>? _lstFootStore;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _dataFuture = fetchStoreInfo();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _dataFuture,
        // _dataFuture 의 결과값이 snapshot 에 담김(NaverMap과 initState에서 호출한 함수의 동시성 문제를 해결하기 위함
        builder: (BuildContext context,
            AsyncSnapshot<List<FoodStoreModel>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(fontSize: 16),
              ),
            );
          }
          // 맛집 정보 리스트를 제공 받은 시점
          _lstFootStore = snapshot.data;

          return Stack(
            children: [
              NaverMap(
                options: const NaverMapViewOptions(
                  // 실내 맵 사용 여부
                  indoorEnable: true,
                  // 내 위치로 이동 버튼
                  locationButtonEnable: true,
                  // 심볼 탭 소비 여부
                  consumeSymbolTapEvents: false,
                ),
                onMapReady: (controller) async {
                  _mapController = controller;
                  NCameraPosition myPosition = await getMyLocation();

                  _buildMarkers();

                  _mapController.updateCamera(
                      NCameraUpdate.fromCameraPosition(myPosition));
                  mapControllerCompleter
                      .complete(_mapController); // 지도 컨트룰러 완료 신호 전송
                },
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 64,
                ),
                child: TextFormFieldCustom(
                  isPasswordField: false,
                  isReadOnly: false,
                  hintText: '맛집을 검색해주세요',
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.search,
                  validator: (value) => inputSearchValidator(value),
                  controller: _searchController,
                  onFieldSubmitted: (value) async {
                    final foodListMap = await supabase
                        .from('food_store')
                        .select()
                        .like('store_name', '%$value%');

                    List<FoodStoreModel> lstFoodStoreSearch = foodListMap
                        .map((elem) => FoodStoreModel.fromJson(elem))
                        .toList();
                    // context 를 얻지 못하는 경우에 대한 예외 처리
                    if (!mounted) return;
                    Navigator.pushNamed(context, '/search_result',
                        arguments: lstFoodStoreSearch);
                  },
                ),
              )
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Colors.black,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 32,
        ),
        onPressed: () async {
          var result = await Navigator.pushNamed(context, '/edit');
          if (result != null) {
            if (result == 'completed_edit') {
              // 맛집 등록 성공
              _lstFootStore = await fetchStoreInfo();
              // 마커 UI 갱신
              _buildMarkers();
              setState(() {});
            }
          }
        },
      ),
    );
  }

  Future<NCameraPosition> getMyLocation() async {
    // 위치 권한 체크, 권한 허용 여부 확인
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are denied forever');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    return NCameraPosition(
        target: NLatLng(position.latitude, position.longitude), zoom: 12);
  }

  Future<List<FoodStoreModel>>? fetchStoreInfo() async {
    final foodListMap = await supabase.from('food_store').select();
    List<FoodStoreModel> lstFoodStore =
        foodListMap.map((elem) => FoodStoreModel.fromJson(elem)).toList();
    return lstFoodStore;
  }

  void _buildMarkers() {
    _mapController.clearOverlays();
    for (FoodStoreModel foodStoreModel in _lstFootStore!) {
      final marker = NMarker(
        id: foodStoreModel.id.toString(),
        position: NLatLng(foodStoreModel.latitude, foodStoreModel.longitude),
        caption: NOverlayCaption(text: foodStoreModel.storeName),
      );
      marker.setOnTapListener(
        (overlay) => {
          _showBottomSummaryDialog(foodStoreModel),
        },
      );
      _mapController.addOverlay(marker);
    }
  }

  inputSearchValidator(value) {
    if (value.isEmpty) {
      return '검색어를 입력해주세요';
    }
    return null;
  }

  _showBottomSummaryDialog(FoodStoreModel foodStoreModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      builder: (context) {
        return Wrap(
          children: [
            Container(
              margin: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SectionText(
                        text: foodStoreModel.storeName,
                        textColor: Colors.black,
                      ),
                      const Spacer(),
                      GestureDetector(
                        child: Icon(
                          Icons.close,
                          size: 24,
                          color: Colors.black,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  foodStoreModel.storeImgUrl?.isNotEmpty == true
                      ? CircleAvatar(
                          radius: 32,
                          backgroundImage: NetworkImage(
                            foodStoreModel.storeImgUrl!,
                          ),
                        )
                      : const Icon(
                          Icons.image_not_supported,
                          size: 32,
                        ),
                  const SizedBox(height: 8),
                  Text(
                    foodStoreModel.storeComment,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButtonCustom(
                      text: '상세보기',
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, '/detail',
                            arguments: foodStoreModel);
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
