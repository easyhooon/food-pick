import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_pick/widget/appbars.dart';
import 'package:food_pick/widget/texts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/user.dart';

class MyInfoScreen extends StatefulWidget {
  const MyInfoScreen({super.key});

  @override
  State<MyInfoScreen> createState() => _MyInfoScreenState();
}

class _MyInfoScreenState extends State<MyInfoScreen> {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: '내 정보',
        isLeading: false,
        actions: [
          GestureDetector(
            child: SectionText(
              text: '로그아웃',
              textColor: const Color(0xff858585),
            ),
            onTap: () async {
              await supabase.auth.signOut();
              if (!mounted) return;
              Navigator.popAndPushNamed(context, '/login');
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: FutureBuilder(
        future: _getMyProfile(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
          UserModel userModel = snapshot.data!;
          return _buildMyProfile(userModel);
        },
      ),
    );
  }

  Future<UserModel> _getMyProfile() async {
    final userMap = await supabase
        .from('user')
        .select()
        .eq('uid', supabase.auth.currentUser!.id);
    return userMap.map((e) => UserModel.fromJson(e)).single;
  }

  Widget _buildMyProfile(UserModel userModel) {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: const BorderSide(width: 2),
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(360),
                child: userModel.profileUrl != null
                    ? Image.network(
                        userModel.profileUrl.toString(),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : const Icon(
                        Icons.person,
                        size: 50,
                      ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionText(
                    text: userModel.name,
                    textColor: Colors.black,
                  ),
                  Text(userModel.email,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xff858585),
                      ))
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 30),
        SectionText(text: '자기소개', textColor: Colors.black),
        const SizedBox(height: 28),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: const BorderSide(width: 2),
              ),
            ),
            child: Text(
              userModel.introduce,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )
      ]),
    );
  }
}
