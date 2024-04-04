import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_pick/common/snackbar_util.dart';
import 'package:food_pick/model/food_store.dart';
import 'package:food_pick/widget/appbars.dart';
import 'package:food_pick/widget/buttons.dart';
import 'package:food_pick/widget/text_fields.dart';
import 'package:food_pick/widget/texts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:daum_postcode_search/data_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class EditScreen extends StatefulWidget {
  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  File? storeImg;

  final formKey = GlobalKey<FormState>();
  final TextEditingController _storeAddressController = TextEditingController();
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _storeCommentController = TextEditingController();

  // 주소 검색 결과 값을 받는 변수
  DataModel? dataModel;
  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    _storeAddressController.dispose();
    _storeNameController.dispose();
    _storeCommentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: '맛집 등록하기',
        isLeading: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 맛집 사진
                GestureDetector(
                  child: _buildStoreImg(),
                  onTap: () {
                    showBottomSheetAboutStoreImg();
                  },
                ),
                const SizedBox(height: 24),
                // 맛집 위치(도로명 주소)
                SectionText(
                  text: '맛집 위치 (도로명 주소)',
                  textColor: Colors.black,
                ),
                const SizedBox(height: 8),
                TextFormFieldCustom(
                    isPasswordField: false,
                    isReadOnly: true,
                    keyboardType: TextInputType.streetAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) => inputAddressValidator(value),
                    controller: _storeAddressController,
                    onTap: () async {
                      var result =
                          await Navigator.pushNamed(context, '/search_address');
                      if (result != null) {
                        setState(() {
                          dataModel = result as DataModel?;
                          _storeAddressController.text =
                              dataModel?.roadAddress ?? '맛집 주소를 선택해주세요';
                        });
                      }
                    }),
                const SizedBox(height: 24),
                SectionText(text: '맛집 별명', textColor: Colors.black),
                const SizedBox(height: 8),
                TextFormFieldCustom(
                  isPasswordField: false,
                  isReadOnly: false,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  validator: (value) => inputAddressValidator(value),
                  controller: _storeNameController,
                ),
                const SizedBox(height: 24),
                SectionText(text: '메모', textColor: Colors.black),
                const SizedBox(height: 8),
                // 맛집 메모
                TextFormFieldCustom(
                  isPasswordField: false,
                  isReadOnly: false,
                  maxLines: 5,
                  hintText: '메모를 입력해주세요',
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: (value) => inputMemoValidator(value),
                  controller: _storeCommentController,
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  height: 69,
                  child: ElevatedButtonCustom(
                    text: '맛집 등록 완료',
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }
                      bool isEditSuccess = await editFoodStore();
                      if (!mounted) return;
                      if (!isEditSuccess) {
                        showSnackBar(context, '맛집 등록 중 문제가 발생했습니다');
                        Navigator.pop(context);
                        return;
                      }
                      showSnackBar(context, '맛집 등록을 성공 하였습니다');
                      Navigator.pop(context, 'completed_edit');
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  inputNameValidator(value) {
    if (value.isEmpty) {
      return '맛집 별명을 입력해주세요.';
    }
    return null;
  }

  inputAddressValidator(value) {
    if (value.isEmpty) {
      return '맛집 위치를 입력해주세요.';
    }
    return null;
  }

  inputMemoValidator(value) {
    if (value.isEmpty) {
      return '맛집 메모를 입력해주세요.';
    }
    return null;
  }

  // default
  Widget _buildStoreImg() {
    if (storeImg == null) {
      return Container(
        width: double.infinity,
        height: 140,
        decoration: ShapeDecoration(
          color: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: const Icon(
          Icons.image_search,
          size: 96,
          color: Colors.white,
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        height: 140,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Image.file(
          storeImg!,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  void showBottomSheetAboutStoreImg() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  getCameraImage();
                },
                child: Text(
                  '사진 촬영',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  getGalleryImage();
                },
                child: Text(
                  '앨범에서 사진 선택',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  deleteStoreImg();
                },
                child: Text(
                  '맛집 사진 삭제',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> getCameraImage() async {
    var image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 10,
    );
    if (image != null) {
      setState(() {
        storeImg = File(image.path);
      });
    }
  }

  Future<void> getGalleryImage() async {
    var image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 10,
    );
    if (image != null) {
      setState(() {
        storeImg = File(image.path);
      });
    }
  }

  void deleteStoreImg() {
    setState(() {
      storeImg = null;
    });
  }

  Future<bool> editFoodStore() async {
    DateTime nowTime = DateTime.now();
    String? imageUrl;

    if (storeImg != null) {
      final imgFile = storeImg;
      String imgPath = 'stores/$nowTime.jpg';
      await supabase.storage.from('food_pick').upload(
            imgPath,
            imgFile!,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      imageUrl = supabase.storage.from('food_pick').getPublicUrl(imgPath);
    }
    // geocoding api 를 활용하여 주소 -> 위경도 값으로 반환 !
    final String apiUrl =
        'https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=${_storeAddressController.text}';
    final apiResponse = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'X-NCP-APIGW-API-KEY-ID': '8eq3utwfe5',
        'X-NCP-APIGW-API-KEY': 'OLv2wopF11FYxS0YpZeBptrSCEWbJMSJv6CpTjHL',
        'Accept': 'application/json',
      },
    );

    if (apiResponse.statusCode == 200) {
      Map<String, dynamic> parsedJson = jsonDecode(apiResponse.body);

      if (parsedJson["meta"]['totalCount'] == 0) {
        if (!mounted) return false;
        showSnackBar(context, '위치 계산에 오류가 있어서 다른 주소 값으로 검색 바랍니다.');
        return false;
      }

      double latitude = double.parse(parsedJson['addresses'][0]['y']);
      double longitude = double.parse(parsedJson['addresses'][0]['x']);

      await supabase.from('food_store').insert(
            FoodStoreModel(
              storeName: _storeNameController.text,
              storeAddress: _storeAddressController.text,
              storeComment: _storeCommentController.text,
              storeImgUrl: imageUrl,
              uid: supabase.auth.currentUser!.id,
              latitude: latitude,
              longitude: longitude,
            ).toMap(),
          );
      return true;
    } else {
      return false;
    }
  }
}
