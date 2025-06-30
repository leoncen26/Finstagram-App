import 'package:finstagram/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  double? _deviceHeight, _deviceWidth;
  FirebaseService? _firebaseService;

  final GlobalKey<FormState> _loginFromKey = GlobalKey<FormState>();

  String? _email;
  String? _password;
  bool visiblePass = false;

  @override
  void initState() {
    super.initState();
    _firebaseService = GetIt.instance.get<FirebaseService>();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
                _loginForm(),
                _loginButton(),
                _registerPageLink(),
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
        color: Colors.black,
        fontSize: 25,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _loginForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      height: _deviceHeight! * 0.40,
      child: Form(
        key: _loginFromKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _emailTextField(),
            _passwordTextField(),
          ],
        ),
      ),
    );
  }

  Widget _emailTextField() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        decoration: const InputDecoration(
          hintText: 'Email...',
          border: InputBorder.none,
        ),
        validator: (value) {
          bool result = value!.contains(
            RegExp(
                r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"),
          );
          if (result) {
            return null;
          } else {
            return 'Please enter a valid email';
          }
        },
        onSaved: (value) {
          setState(() {
            _email = value;
          });
        },
      ),
    );
  }

  Widget _passwordTextField() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              obscureText: !visiblePass,
              cursorColor: Colors.black,
              decoration: const InputDecoration(
                hintText: 'Password...',
                border: InputBorder.none
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
            ),
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  visiblePass = !visiblePass;
                });
              },
              icon: Icon(visiblePass ? Icons.visibility : Icons.visibility_off))
        ],
      ),
    );
  }

  Widget _loginButton() {
    return ElevatedButton(
      onPressed: _loginUser,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        minimumSize: Size(
          _deviceWidth! * 0.80,
          _deviceHeight! * 0.08,
        ),
      ),
      child: const Text(
        'Login',
        style: TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _registerPageLink() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, 'register');
      },
      child: const Text(
        "Don't have an account? Register Here",
        style: TextStyle(
          color: Colors.blue,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _loginUser() async {
    if (_loginFromKey.currentState!.validate()) {
      _loginFromKey.currentState!.save();
      bool _result = await _firebaseService!.loginUser(
        email: _email!,
        password: _password!,
      );
      if (_result) {
        Navigator.popAndPushNamed(context, 'home');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Welcome $_email'),
          backgroundColor: Colors.green,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Email atau Password tidak sesuai, harap coba lagi',
          ),
          backgroundColor: Colors.red,
        ));
      }
    }
  }
}
