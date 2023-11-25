import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_8/models/user_model.dart';

class UserService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<UserModel> signUp(UserModel user) async {
    UserCredential userCredential =
        await _firebaseAuth.createUserWithEmailAndPassword(
      email: user.email!,
      password: user.password!,
    );

    UserModel registeredUser = UserModel.withoutPassword(
      id: userCredential.user!.uid,
      email: userCredential.user!.email,
    );
    return registeredUser;
  }

  Future<UserModel> signIn(String email, String password) async {
    UserCredential userCredential =
        await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    UserModel signedInUser = UserModel.withoutPassword(
      id: userCredential.user!.uid,
      email: userCredential.user!.email!,
    );
    return signedInUser;
  }
}
