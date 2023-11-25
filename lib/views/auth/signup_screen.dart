import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_8/models/user_model.dart';
import 'package:flutter_application_8/services/user_service.dart';
import 'package:flutter_application_8/views/auth/login_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserService userService = UserService();
  String? _email;
  String? _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: <Widget>[
            Center(child: Image.asset("images/logo.png", width: 200)),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Crie a sua conta. É grátis!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira um e-mail.';
                      }
                      if (!value.contains('@')) {
                        return 'E-mail inválido.';
                      }
                      return null;
                    },
                    onSaved: (value) => _email = value,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira uma senha.';
                      }
                      if (value.length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres.';
                      }
                      return null;
                    },
                    onSaved: (value) => _password = value,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        final newUserModel = UserModel.withoutId(
                          email: _email!,
                          password: _password!,
                        );

                        try {
                          final registeredUser =
                              await userService.signUp(newUserModel);
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => LoginScreen()));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: <Widget>[
                                  Icon(Icons.check, color: Colors.green),
                                  SizedBox(width: 8.0),
                                  Text('Registro bem-sucedido!'),
                                ],
                              ),
                            ),
                          );
                        } on FirebaseAuthException catch (authError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(authError.message ??
                                    'Ocorreu um erro desconhecido')),
                          );
                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error.toString())),
                          );
                        }
                      }
                    },
                    child: Text('Cadastre-se'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
