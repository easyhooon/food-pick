import 'package:flutter/material.dart';
import 'package:food_pick/model/favorite.dart';
import 'package:food_pick/model/food_store.dart';
import 'package:food_pick/widget/appbars.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchResultScreen extends StatefulWidget {
  List<FoodStoreModel> lstFoodStore;

  SearchResultScreen({super.key, required this.lstFoodStore});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  List<FavoriteModel> lstMyFavorite = [];
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    _getMyFavorite();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: '검색결과',
        isLeading: true,
      ),
      body: ListView.builder(
        // count 를 지정해줘야 함
        itemCount: widget.lstFoodStore.length,
        itemBuilder: (context, index) {
          FoodStoreModel foodStoreModel = widget.lstFoodStore[index];
          return GestureDetector(
            child: _buildListItemFoodStore(foodStoreModel),
            onTap: () async {
              var result = await Navigator.pushNamed(
                context,
                '/detail',
                arguments: foodStoreModel,
              );
              if (result != null) {
                if (result == 'back_from_detail') {
                  // 찜하기 이력 갱신
                  _getMyFavorite();
                }
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildListItemFoodStore(FoodStoreModel foodStoreModel) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(8),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(width: 2, color: Colors.black),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  foodStoreModel.storeName,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildFavoriteIcon(foodStoreModel),
            ],
          ),
          Text(
            foodStoreModel.storeComment,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              foodStoreModel.storeAddress,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFavoriteIcon(FoodStoreModel foodStoreModel) {
    bool isFavorite = false;
    for (FavoriteModel favoriteModel in lstMyFavorite) {
      if (favoriteModel.foodStoreId == foodStoreModel.id) {
        isFavorite = true;
        break;
      }
    }

    if (!isFavorite) {
      return const Icon(
        Icons.star_border_outlined,
        size: 32,
      );
    } else {
      return const Icon(
        Icons.star,
        size: 32,
      );
    }
  }

  Future _getMyFavorite() async {
    final myFavoriteMap = await supabase
        .from('favorite')
        .select()
        .eq('favorite_uid', supabase.auth.currentUser!.id);

    setState(() {
      lstMyFavorite =
          myFavoriteMap.map((elem) => FavoriteModel.fromJson(elem)).toList();
    });
  }
}
