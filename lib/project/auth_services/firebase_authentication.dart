import 'dart:async';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
// Replace this import with the actual path to your custom_toast file
import 'package:money_assistant_2608/project/classes/custom_toast.dart';

class FirebaseAuthentication {
  static bool _googleInitialized = false;

  static Future<FirebaseApp> initializeFireBase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
  }

  /// Ensures Google Sign-In is initialized with the correct Client IDs,
  /// especially for Web support.
  static Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;

    // --dart-define=GOOGLE_WEB_CLIENT_ID=xxxx
    const webIdFromEnv = String.fromEnvironment(
      'GOOGLE_WEB_CLIENT_ID',
      defaultValue: '',
    );
    const serverId = String.fromEnvironment(
      'GOOGLE_SERVER_CLIENT_ID',
      defaultValue: '',
    );

    // Fallback to specific ID if env is empty (adjust ID as needed)
    final webId = webIdFromEnv.isNotEmpty
        ? webIdFromEnv
        : (kIsWeb
            ? '1078897962612-gi25eummqh39an2radj6c6ilnuj3nf5o.apps.googleusercontent.com'
            : '');

    await GoogleSignIn.instance.initialize(
      clientId: webId.isEmpty ? null : webId,
      serverClientId: serverId.isEmpty ? null : serverId,
    );

    // Attempt silent authentication
    unawaited(GoogleSignIn.instance.attemptLightweightAuthentication());
    _googleInitialized = true;
  }

  static Future<User?> googleSignIn({required BuildContext context}) async {
    User? user;

    try {
      await _ensureGoogleInitialized();
      final GoogleSignIn gsi = GoogleSignIn.instance;
      final FirebaseAuth auth = FirebaseAuth.instance;

      // 1. Check if the new authenticate() flow is supported
      if (!gsi.supportsAuthenticate()) {
        customToast(
            context, 'Google Sign-In is not supported on this platform.');
        return null;
      }

      // 2. Start interactive authentication
      // Note: This does not await the result directly in v7, we listen to events
      unawaited(gsi.authenticate());

      // 3. Wait for the result via the event stream
      final event = await gsi.authenticationEvents
          .firstWhere(
            (e) =>
                e is GoogleSignInAuthenticationEventSignIn ||
                e is GoogleSignInAuthenticationEventSignOut,
          )
          .timeout(const Duration(seconds: 30));

      if (event is GoogleSignInAuthenticationEventSignIn) {
        final GoogleSignInAuthentication googleAuth =
            await event.user.authentication;

        // 4. Create Credential
        // IMPORTANT: In the new API, accessToken is null/removed.
        // We only use the idToken for Firebase.
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: null,
        );

        // 5. Sign in to Firebase
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);
        user = userCredential.user;
      } else {
        // User canceled or signed out during the process
        customToast(context, 'Sign in canceled');
      }
    } on TimeoutException {
      customToast(context, 'Sign in timed out. Please try again.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        customToast(
            context, 'The account already exists with a different credential.');
      } else if (e.code == 'invalid-credential') {
        customToast(
            context, 'Error occurred while accessing credentials. Try again.');
      } else {
        customToast(context, 'Authentication Error: ${e.message}');
      }
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        customToast(context, 'Sign in canceled');
      } else {
        customToast(context, 'Google Sign-In Error: ${e.description}');
      }
    } catch (e) {
      customToast(context, 'Error occurred using Google Sign-In. Try again.');
      debugPrint('General Error in googleSignIn: $e');
    }

    return user;
  }

  static Future<void> signOut({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;

    try {
      // It is good practice to sign out of both Firebase and Google
      await Future.wait([
        googleSignIn.signOut(),
        auth.signOut(),
      ]);
    } catch (e) {
      customToast(context, 'Error signing out. Try again.');
    }
  }
}
// final FirebaseAuth _auth = FirebaseAuth.instance;
//
// UserUid _userUid(User user) {
//   return user != null ? UserUid(uid: user.uid) : null;
// }
//
// // what is get?
// Stream<UserUid> get user {
//   return _auth.authStateChanges().map((User user) => _userUid(user));
//   // .map(_userUid);
// }
//
// // sign in anon
// Future signInAnon() async {
//   try {
//     UserCredential result = await _auth.signInAnonymously();
//     User user = result.user;
//     return _userUid(user);
//   } catch (e) {
//     print(e.toString());
//     return null;
//   }
// }
//
// // sign in with email and password
// Future signInWithEmailAndPassword(String email, String password) async {
//   try {
//     UserCredential result = await _auth.signInWithEmailAndPassword(
//         email: email, password: password);
//     User user = result.user;
//     return user;
//   } catch (error) {
//     print(error.toString());
//     return null;
//   }
// }
//
// // register with email and password
// Future registerWithEmailAndPassword(String email, String password) async {
//   try {
//     UserCredential result = await _auth.createUserWithEmailAndPassword(
//         email: email, password: password);
//     User user = result.user;
//     return _userUid(user);
//   } catch (error) {
//     print(error.toString());
//     return null;
//   }
// }
//
// // sign out
// Future signOut() async {
//   try {
//     return await _auth.signOut();
//   } catch (error) {
//     print(error.toString());
//     return null;
//   }
// }
// }

// class UserUid {
//   final String uid;
//
//   UserUid({this.uid});
// }
