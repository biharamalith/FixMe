import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/user_model.dart';


abstract class AuthRepository {
  Future<UserModel> signIn(UserModel user);
  Future<UserModel> signUp(UserModel user);
  Future<void> signOut();
}




class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<UserModel> signIn(UserModel user) async {
    UserCredential credential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: user.email, password: user.password);
    return UserModel(email: credential.user!.email ?? '', password: '');
  }

  @override
  Future<UserModel> signUp(UserModel user) async {
    UserCredential credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: user.email, password: user.password);
    return UserModel(email: credential.user!.email ?? '', password: '');
  }

  @override
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}