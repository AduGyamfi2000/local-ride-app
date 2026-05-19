// lib/core/services/voice_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../constants/app_constants.dart';

class VoiceService {
  final FlutterTts _tts = FlutterTts();
  String _currentLanguage = AppConstants.langEnglish;

  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal() {
    _init();
  }

  Future<void> _init() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.4); // Slow for accessibility
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  void setLanguage(String langCode) {
    _currentLanguage = langCode;
  }

  /// Speak text using TTS (English) or pre-recorded audio (Twi)
  Future<void> speak(String text, {String? langCode}) async {
    final lang = langCode ?? _currentLanguage;
    if (lang == AppConstants.langTwi) {
      // For Twi: play pre-recorded audio file
      await _playPreRecordedAudio(text);
    } else {
      await _tts.speak(text);
    }
  }

  /// Play pre-recorded Twi audio based on message key
  Future<void> _playPreRecordedAudio(String messageKey) async {
    // Maps message keys to pre-recorded audio files in assets/audio/twi/
    final Map<String, String> twiAudioMap = {
      'ride_searching': 'assets/audio/twi/ride_searching.mp3',
      'ride_accepted': 'assets/audio/twi/ride_accepted.mp3',
      'driver_arriving': 'assets/audio/twi/driver_arriving.mp3',
      'ride_started': 'assets/audio/twi/ride_started.mp3',
      'ride_completed': 'assets/audio/twi/ride_completed.mp3',
      'no_internet': 'assets/audio/twi/no_internet.mp3',
      'request_saved': 'assets/audio/twi/request_saved.mp3',
      'login_success': 'assets/audio/twi/login_success.mp3',
      'welcome': 'assets/audio/twi/welcome.mp3',
    };

    if (twiAudioMap.containsKey(messageKey)) {
      // Use audioplayers package in real impl
      // await audioPlayer.play(AssetSource(twiAudioMap[messageKey]!));
      debugPrint('Playing Twi audio: ${twiAudioMap[messageKey]}');
    } else {
      // Fallback to TTS English
      await _tts.speak(messageKey);
    }
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  Future<void> announceRideStatus(String status) async {
    final messages = {
      AppConstants.rideStatusSearching: 'Searching for a driver near you. Please wait.',
      AppConstants.rideStatusAccepted: 'Good news! A driver has accepted your ride.',
      AppConstants.rideStatusOnTheWay: 'Your driver is on the way to pick you up.',
      AppConstants.rideStatusArrived: 'Your driver has arrived. Please come out.',
      AppConstants.rideStatusInProgress: 'Your ride has started. Enjoy your trip.',
      AppConstants.rideStatusCompleted: 'You have reached your destination. Thank you for riding with us.',
      AppConstants.rideStatusCancelled: 'Your ride has been cancelled.',
    };

    final message = messages[status] ?? status;
    await speak(message);
  }

  void dispose() {
    _tts.stop();
  }
}

// Message keys for Twi audio
class VoiceMessages {
  VoiceMessages._();

  static const String rideSearching = 'ride_searching';
  static const String rideAccepted = 'ride_accepted';
  static const String driverArriving = 'driver_arriving';
  static const String rideStarted = 'ride_started';
  static const String rideCompleted = 'ride_completed';
  static const String noInternet = 'no_internet';
  static const String requestSaved = 'request_saved';
  static const String loginSuccess = 'login_success';
  static const String welcome = 'welcome';
}
