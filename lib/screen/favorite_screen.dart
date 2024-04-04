import 'package:flutter/material.dart';
import 'package:food_pick/model/favorite.dart';
import 'package:food_pick/model/food_store.dart';
import 'package:food_pick/widget/appbars.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: '찜해둔 맛집',
        isLeading: false,
      ),
      body: FutureBuilder(
        future: _getMyFavoriteFoodStore(),
        builder: (context, snapshot) {
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

          return ListView.builder(
            itemCount: snapshot.data?.length,
            itemBuilder: (context, index) {
              FoodStoreModel foodStoreModel = snapshot.data![index];
              return GestureDetector(
                child: _buildListItemFoodStore(foodStoreModel),
                onTap: () async {
                  var result = await Navigator.pushNamed(context, '/detail', arguments: foodStoreModel);
                  if (result != null) {
                    if (result == 'back_from_detail') {
                      setState(() {});
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<List<FoodStoreModel>> _getMyFavoriteFoodStore() async {
    List<FoodStoreModel> lstFavoriteFoodStore = [];
    // inner join 을 통해 각각의 table 을 연결
    final favoriteStoreMap = await supabase
        .from('food_store')
        .select('*, favorite!inner(*)')
        .eq('favorite.favorite_uid', supabase.auth.currentUser!.id);
    lstFavoriteFoodStore =
        favoriteStoreMap.map((elem) => FoodStoreModel.fromJson(elem)).toList();

    return lstFavoriteFoodStore;
  }

  Widget _buildListItemFoodStore(FoodStoreModel foodStoreModel) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(8),
      decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(width: 2, color: Colors.black),
      )),
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
              const Icon(
                Icons.star,
                size: 32,
              )
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
              style: const TextStyle(
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
}
