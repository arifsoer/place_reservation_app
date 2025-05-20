import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends ChangeNotifier {
  User? _user;

  bool isLoading = false;
  bool isFething = false;

  AuthController() {
    dataInitialization();
  }

  User? get user => _user;

  Future<void> dataInitialization() async {
    FirebaseAuth.instance.authStateChanges().listen(authHandler);
  }

  void authHandler(User? user) {
    _user = user;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading = true;
      notifyListeners();
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Google: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      isLoading = true;
      notifyListeners();
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('Error signing out: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
