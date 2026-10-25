import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

abstract class AuthService {
  UserProfile? get currentUser;
  bool get isAuthenticated;
  bool get isGuest;

  Future<UserProfile> loginWithEmailPassword(String email, String password);
  Future<UserProfile> signUpWithEmailPassword(
    String email,
    String password,
    String displayName,
  );
  Future<UserProfile> continueAsGuest();
  Future<void> sendPasswordResetEmail(String email);
  Future<UserProfile> updateProfile({
    required String displayName,
    String? bio,
    List<String>? preferredCategories,
    String? travelStyle,
  });
  Future<void> logout();
}

class LocalAuthService implements AuthService {
  static const String _keyAccounts = 'auth_local_accounts';
  static const String _keyActiveUserId = 'auth_active_user_id';
  static const String _keyIsGuest = 'auth_is_guest';

  final SharedPreferences _prefs;
  UserProfile? _currentUser;
  bool _isGuest = true;

  LocalAuthService(this._prefs) {
    _loadState();
  }

  void _loadState() {
    _isGuest = _prefs.getBool(_keyIsGuest) ?? true;
    final activeId = _prefs.getString(_keyActiveUserId);
    if (!_isGuest && activeId != null) {
      final accounts = _getStoredAccounts();
      final userAccount = accounts[activeId];
      if (userAccount != null) {
        _currentUser = UserProfile.fromJson(
          Map<String, dynamic>.from(userAccount['profile']),
        );
        return;
      }
    }
    // Default to Guest profile
    _currentUser = UserProfile.guest();
  }

  Map<String, dynamic> _getStoredAccounts() {
    final raw = _prefs.getString(_keyAccounts);
    if (raw == null) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(raw));
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveAccounts(Map<String, dynamic> accounts) async {
    await _prefs.setString(_keyAccounts, jsonEncode(accounts));
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode('salt_travel_explorer_$password');
    return sha256.convert(bytes).toString();
  }

  @override
  UserProfile? get currentUser => _currentUser;

  @override
  bool get isAuthenticated => _currentUser != null && !_isGuest;

  @override
  bool get isGuest => _isGuest;

  @override
  Future<UserProfile> loginWithEmailPassword(
    String email,
    String password,
  ) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      throw Exception('Please provide a valid email address.');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters.');
    }

    final accounts = _getStoredAccounts();
    final userEntry = accounts[cleanEmail];

    if (userEntry == null) {
      throw Exception(
        'No account found with this email. Please sign up first.',
      );
    }

    final storedHash = userEntry['passwordHash'] as String;
    if (_hashPassword(password) != storedHash) {
      throw Exception('Incorrect password. Please try again.');
    }

    final profile = UserProfile.fromJson(
      Map<String, dynamic>.from(userEntry['profile']),
    );
    _currentUser = profile.copyWith(isGuest: false);
    _isGuest = false;

    await _prefs.setString(_keyActiveUserId, cleanEmail);
    await _prefs.setBool(_keyIsGuest, false);
    return _currentUser!;
  }

  @override
  Future<UserProfile> signUpWithEmailPassword(
    String email,
    String password,
    String displayName,
  ) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = displayName.trim();

    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      throw Exception('Please provide a valid email address.');
    }
    if (cleanName.isEmpty) {
      throw Exception('Please enter your full name.');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters.');
    }

    final accounts = _getStoredAccounts();
    if (accounts.containsKey(cleanEmail)) {
      throw Exception(
        'An account with this email already exists. Please log in.',
      );
    }

    final newProfile = UserProfile(
      id: cleanEmail,
      email: cleanEmail,
      displayName: cleanName,
      bio: 'Travel enthusiast exploring the beauty of India.',
      isGuest: false,
    );

    accounts[cleanEmail] = {
      'passwordHash': _hashPassword(password),
      'profile': newProfile.toJson(),
    };

    await _saveAccounts(accounts);
    await _prefs.setString(_keyActiveUserId, cleanEmail);
    await _prefs.setBool(_keyIsGuest, false);

    _currentUser = newProfile;
    _isGuest = false;
    return newProfile;
  }

  @override
  Future<UserProfile> continueAsGuest() async {
    _isGuest = true;
    _currentUser = UserProfile.guest();
    await _prefs.setBool(_keyIsGuest, true);
    await _prefs.remove(_keyActiveUserId);
    return _currentUser!;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      throw Exception('Please enter a valid email address.');
    }
    final accounts = _getStoredAccounts();
    if (!accounts.containsKey(cleanEmail)) {
      throw Exception('No account found for $cleanEmail.');
    }
    // Simulation for password reset confirmation email
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<UserProfile> updateProfile({
    required String displayName,
    String? bio,
    List<String>? preferredCategories,
    String? travelStyle,
  }) async {
    if (_currentUser == null) throw Exception('No user logged in');

    final updated = _currentUser!.copyWith(
      displayName: displayName.trim(),
      bio: bio?.trim(),
      preferredCategories: preferredCategories,
      travelStyle: travelStyle,
    );

    _currentUser = updated;

    if (!_isGuest) {
      final accounts = _getStoredAccounts();
      final emailKey = updated.email;
      if (accounts.containsKey(emailKey)) {
        accounts[emailKey]['profile'] = updated.toJson();
        await _saveAccounts(accounts);
      }
    }

    return updated;
  }

  @override
  Future<void> logout() async {
    await continueAsGuest();
  }
}
