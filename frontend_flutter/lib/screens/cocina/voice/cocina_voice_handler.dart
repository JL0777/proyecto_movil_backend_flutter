import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class CocinaVoiceHandler {
  final SpeechToText _speech = SpeechToText();

  bool escuchando = false;
  bool modoContinuo = false;
  bool speechDisponible = false;

  final Function(String, Color) onFeedback;
  final Function(String) onComando;
  final VoidCallback onEstadoChanged;

  CocinaVoiceHandler({
    required this.onFeedback,
    required this.onComando,
    required this.onEstadoChanged,
  });

  Future<void> inicializar() async {
    speechDisponible = await _speech.initialize(
      onError: (error) {
        escuchando = false;
        onEstadoChanged();
        if (modoContinuo) {
          Future.delayed(const Duration(seconds: 1), escucharContinuo);
        }
      },
      onStatus: (status) {
        debugPrint('🎙 Estado: $status');
        if (status == 'done' || status == 'notListening') {
          if (modoContinuo) {
            Future.delayed(
              const Duration(milliseconds: 500),
              escucharContinuo,
            );
          }
        }
      },
    );
    onEstadoChanged();
  }

  void toggle() {
    if (!speechDisponible) {
      onFeedback('Micrófono no disponible', Colors.red);
      return;
    }
    if (modoContinuo) {
      modoContinuo = false;
      _speech.stop();
      escuchando = false;
      onEstadoChanged();
    } else {
      modoContinuo = true;
      escucharContinuo();
    }
  }

  void escucharContinuo() {
    if (!modoContinuo) return;

    escuchando = true;
    onEstadoChanged();

    _speech.listen(
      localeId: 'es_CO',
      listenOptions: SpeechListenOptions(partialResults: false),
      onResult: (result) {
        if (result.finalResult) {
          if (result.recognizedWords.isNotEmpty) {
            onComando(result.recognizedWords);
          }
          if (modoContinuo) {
            Future.delayed(
              const Duration(milliseconds: 1000),
              escucharContinuo,
            );
          }
        }
      },
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 60),
    );
  }

  void dispose() {
    modoContinuo = false;
    _speech.stop();
  }
}