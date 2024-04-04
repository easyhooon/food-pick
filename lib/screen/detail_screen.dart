import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_pick/model/favorite.dart';
import 'package:food_pick/model/food_store.dart';
import 'package:food_pick/model/user.dart';
import 'package:food_pick/widget/appbars.dart';
import 'package:food_pick/widget/buttons.dart';
import 'package:food_pick/widget/texts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailScreen extends StatefulWidget {
  FoodStoreModel foodStoreModel;

  DetailScreen({super.key, required this.foodStoreModel});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final supabase = Supabase.instance.client;
  String? _uploaderName;
  bool isFavorite = false;

  @override
  void initState() {
    _getUploaderName();
    _getFavorite();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 시스템 백 버튼을 감지하기 위한 컴포넌트
    return WillPopScope(
      onWillPop: () {
        // 시스템 백버튼을 감지
        Navigator.pop(context, 'back_from_detail');
        return Future.value(true);
      },
      child: Scaffold(
        appBar: CommonAppBar(
          title: widget.foodStoreModel.storeName,
          isLeading: true,
          // AppBar 내에 백버튼에 대한 클릭 처리
          onTapBackButton: () {
            Navigator.pop(context, 'back_from_detail');
            // 왜 여기는 return Future.value(true) 가 없지
          },
        ),
        body: Container(
          margin: EdgeInsets.all(16),
          child: Column(
            children: [
              _buildStoreImg(),
              const SizedBox(height: 16),
              SectionText(text: '맛집 위치 [도로면 주소]', textColor: Colors.black),
              const SizedBox(height: 8),
              ReadOnlyText(title: widget.foodStoreModel.storeAddress),
              const SizedBox(height: 16),
              SectionText(text: '맛집 공유자', textColor: Colors.black),
              const SizedBox(height: 8),
              ReadOnlyText(title: _uploaderName ?? ''),
              const SizedBox(height: 16),
              SectionText(text: '메모', textColor: Colors.black),
              const SizedBox(height: 8),
              // 남은 공간을 모두 차지
              Expanded(
                child: ReadOnlyText(title: widget.foodStoreModel.storeComment),
              ),
              const SizedBox(height: 16),

              isFavorite
                  ? Container(
                      width: double.infinity,
                      height: 69,
                      child: ElevatedButtonCustom(
                        text: '찜하기 취소',
                        backgroundColor: Color(0xff979797),
                        textColor: Colors.white,
                        onPressed: () async {
                          await supabase
                              .from('favorite')
                              .delete()
                              .eq('food_store_id', widget.foodStoreModel.id!)
                              .eq('favorite_uid',
                                  supabase.auth.currentUser!.id);

                          // refresh
                          _getFavorite();
                        },
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      height: 69,
                      child: ElevatedButtonCustom(
                        text: '찜하기',
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        onPressed: () async {
                          await supabase.from('favorite').upsert(
                                FavoriteModel(
                                  foodStoreId: widget.foodStoreModel.id!,
                                  favoriteUid: supabase.auth.currentUser!.id,
                                ).toMap(),
                              );
                          // refresh
                          _getFavorite();
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreImg() {
    if (widget.foodStoreModel.storeImgUrl == null) {
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
        child: Image.network(
          widget.foodStoreModel.storeImgUrl!,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  Future<void> _getUploaderName() async {
    final userMap = await supabase
        .from('user')
        .select()
        .eq('uid', widget.foodStoreModel.uid);
    UserModel userModel =
        userMap.map((elem) => UserModel.fromJson(elem)).single;
    setState(() {
      _uploaderName = userModel.name;
    });
  }

  Future _getFavorite() async {
    final favoriteMap = await supabase
        .from('favorite')
        .select()
        .eq('food_store_id', widget.foodStoreModel.id!)
        .eq('favorite_uid', supabase.auth.currentUser!.id);

    setState(() {
      isFavorite = favoriteMap.isNotEmpty;
    });
  }
}
