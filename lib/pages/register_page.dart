import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:finstagram/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RegisterPageState();
  }
}

class _RegisterPageState extends State<RegisterPage> {
  double? _deviceHeight, _deviceWidth;

  String? _name;
  String? _email;
  String? _password;
  File? _image;
  FirebaseService? firebaseService;


  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    firebaseService = GetIt.instance.get<FirebaseService>();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: _deviceWidth! * 0.05),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _titleWidget(),
                _profileImageWidget(),
                _registerationFrom(),
                _registerButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _titleWidget() {
    return const Text(
      'Finstagram',
      style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _registerationFrom() {
    return Container(
      height: _deviceHeight! * 0.30,
      child: Form(
        key: _registerFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _nameTextFiel(),
            _emailTextField(),
            _passwordTextField(),
          ],
        ),
      ),
    );
  }

  Widget _profileImageWidget() {
    var _imageProvider = _image != null
        ? FileImage(_image!)
        : const NetworkImage('https://i.pravatar.cc/150?img=58');
    return GestureDetector(
      onTap: () {
        FilePicker.platform.pickFiles(type: FileType.image).then((_result) {
          setState(() {
            _image = File(_result!.files.first.path!);
          });
        });
      },
      child: Container(
        height: _deviceHeight! * 0.15,
        width: _deviceHeight! * 0.15,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: _imageProvider as ImageProvider,
          ),
        ),
      ),
    );
  }

  Widget _nameTextFiel() {
    return TextFormField(
      decoration: const InputDecoration(
        hintText: 'Name...',
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
          ),
        ),
      ),
      validator: (_value) {
        if (_value!.length > 0) {
          return null;
        } else {
          return 'Please enter your name';
        }
      },
      onSaved: (_value) {
        setState(() {
          _name = _value;
        });
      },
    );
  }

  Widget _emailTextField() {
    return TextFormField(
      decoration: const InputDecoration(
        hintText: 'Email...',
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
          ),
        ),
      ),
      validator: (_value) {
        bool _result = _value!.contains(
          RegExp(
              r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"),
        );
        if (_result) {
          return null;
        } else {
          return 'Please enter a valid email';
        }
      },
      onSaved: (_value) {
        setState(() {
          _email = _value;
        });
      },
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      obscureText: true,
      cursorColor: Colors.black,
      decoration: const InputDecoration(
        hintText: 'Password...',
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
          ),
        ),
      ),
      validator: (_value) {
        if (_value!.length > 6) {
          return null;
        } else {
          return 'Please enter a password grater than 6 character';
        }
      },
      onSaved: (_value) {
        setState(() {
          _password = _value;
        });
      },
    );
  }

  Widget _registerButton() {
    return MaterialButton(
      onPressed: _submitRegisterForm,
      minWidth: _deviceWidth! * 0.50,
      height: _deviceHeight! * 0.05,
      color: Colors.red,
      child: const Text(
        'Register',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  void _submitRegisterForm() async {
    if (_registerFormKey.currentState!.validate() && _image != null) {
      _registerFormKey.currentState!.save();
      bool _result = await firebaseService!.registerUser(name: _name!, email: _email!, password: _password!, image: _image!);
      if(_result){
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration Success'),
        ),
      );
      }
    }
  }
}
