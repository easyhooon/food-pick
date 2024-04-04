import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_pick/common/snackbar_util.dart';
import 'package:food_pick/model/user.dart';
import 'package:food_pick/widget/appbars.dart';
import 'package:food_pick/widget/buttons.dart';
import 'package:food_pick/widget/text_fields.dart';
import 'package:food_pick/widget/texts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// TODO 카메라 권한 허용 요청, 권한 확인 플로우 추가
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 입력필드 유효성 검사를 위한
  // 각각의 위젯은 key 가 존재하며 key 를 통해 해당 위젯이 상위 위젯인지, 하위 위젯인지 알 수 있음
  final formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;
  File? profileImg;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordReController = TextEditingController();
  final TextEditingController _introduceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordReController.dispose();
    _introduceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Food Pick 가입하기',
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
                GestureDetector(
                  child: _buildProfile(),
                  onTap: () {
                    showBottomSheetAboutProfile();
                  },
                ),
                SectionText(text: '닉네임', textColor: Color(0xff979797)),
                const SizedBox(height: 8),
                TextFormFieldCustom(
                  hintText: '닉네임을 입력해주세요',
                  isPasswordField: false,
                  isReadOnly: false,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  validator: (value) => inputNameValidator(value),
                  controller: _nameController,
                ),
                const SizedBox(height: 16),
                SectionText(text: '이메일', textColor: Color(0xff979797)),
                const SizedBox(height: 8),
                TextFormFieldCustom(
                  hintText: '이메일을 입력해주세요',
                  isPasswordField: false,
                  isReadOnly: false,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) => inputEmailValidator(value),
                  controller: _emailController,
                ),
                const SizedBox(height: 16),
                SectionText(text: '비밀번호', textColor: Color(0xff979797)),
                const SizedBox(height: 8),
                TextFormFieldCustom(
                  hintText: '비밀번호를 입력해주세요',
                  isPasswordField: true,
                  maxLines: 1,
                  // obscure 가 활성화된 경우엔 반드시 maxLine 1
                  isReadOnly: false,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  validator: (value) => inputPasswordValidator(value),
                  controller: _passwordController,
                ),
                const SizedBox(height: 16),
                SectionText(text: '비밀번호 확인', textColor: Color(0xff979797)),
                const SizedBox(height: 8),
                TextFormFieldCustom(
                  hintText: '비밀번호를 한번 더 입력해주세요',
                  isPasswordField: true,
                  maxLines: 1,
                  isReadOnly: false,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  validator: (value) => inputPasswordReValidator(value),
                  controller: _passwordReController,
                ),
                const SizedBox(height: 16),
                SectionText(text: '자기소개', textColor: Color(0xff979797)),
                const SizedBox(height: 8),
                TextFormFieldCustom(
                  hintText: '자기소개를 입력해주세요',
                  isPasswordField: false,
                  isReadOnly: false,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  validator: (value) => inputIntroduceValidator(value),
                  controller: _introduceController,
                ),
                const SizedBox(height: 16),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 16),
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButtonCustom(
                    text: '가입완료',
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    onPressed: () async {
                      String emailValue = _emailController.text;
                      String passwordValue = _passwordController.text;

                      if (!formKey.currentState!.validate()) {
                        return;
                      }

                      bool isRegisteredSuccess = await registerAccount(emailValue, passwordValue);
                      // context 관련 warning 해결
                      if (!context.mounted) return;
                      if (!isRegisteredSuccess) {
                        showSnackBar(context, '회원가입을 실패하였습니다.');
                        return;
                      }
                      showSnackBar(context, '회원가입을 성공하였습니다.');
                      Navigator.pop(context);
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

  Widget _buildProfile() {
    if (profileImg == null) {
      return Center(
        child: CircleAvatar(
          backgroundColor: Colors.grey,
          radius: 48,
          child: Icon(
            Icons.add_a_photo,
            color: Colors.white,
            size: 48,
          ),
        ),
      );
    } else {
      return Center(
        child: CircleAvatar(
          backgroundColor: Colors.grey,
          radius: 48,
          backgroundImage: FileImage(profileImg!),
        ),
      );
    }
  }

  void showBottomSheetAboutProfile() {
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
                  deleteProfileImg();
                },
                child: Text(
                  '프로필 사진 삭제',
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
        profileImg = File(image.path);
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
        profileImg = File(image.path);
      });
    }
  }

  void deleteProfileImg() {
    setState(() {
      profileImg = null;
    });
  }

  inputNameValidator(value) {
    if (value.isEmpty) {
      return '닉네임을 입력해주세요';
    }
    return null;
  }

  inputEmailValidator(value) {
    if (value.isEmpty) {
      return '이메일을 입력해주세요';
    }
    return null;
  }

  inputPasswordValidator(value) {
    if (value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    return null;
  }

  inputPasswordReValidator(value) {
    if (value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    return null;
  }

  inputIntroduceValidator(value) {
    if (value.isEmpty) {
      return '자기소개를 입력해주세요';
    }
    return null;
  }

  Future<bool> registerAccount(String emailValue, String passwordValue) async {
    bool isRegisterSuccess = false;
    final AuthResponse response =
        await supabase.auth.signUp(email: emailValue, password: passwordValue);
    if (response.user != null) {
      isRegisterSuccess = true;

      DateTime nowTime = DateTime.now();
      String? imageUrl;
      if (profileImg != null) {
        final imgFile = profileImg;
        final imgPath = 'profiles/${response.user!.id}_$nowTime.jpg';
        await supabase.storage.from('food_pick').upload(
              imgPath,
              imgFile!,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true,
              ),
            );

        imageUrl = supabase.storage.from('food_pick').getPublicUrl(imgPath);
        // response.user.id -> 회원가입 성공시 각각의 유저에게 발급되는 고유 값
      }
      await supabase.from('user').insert(
            UserModel(
              profileUrl: imageUrl,
              name: _nameController.text,
              email: emailValue,
              introduce: _introduceController.text,
              uid: response.user!.id,
            ).toMap(),
          );
    } else {
      isRegisterSuccess = false;
    }

    return isRegisterSuccess;
  }
}
