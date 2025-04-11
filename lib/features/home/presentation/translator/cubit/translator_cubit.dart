import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/translator_service.dart';

part 'translator_state.dart';

class TranslatorCubit extends Cubit<TranslatorState> {
  final TranslatorService _translatorService;

  TranslatorCubit({required TranslatorService translatorService})
    : _translatorService = translatorService,
      super(const TranslatorInitial());

  Future<void> startTranslation(String videoData) async {
    try {
      emit(const TranslatorLoading());
      final response = await _translatorService.predictGestures(videoData);
      emit(
        TranslatorSuccess(
          formedText: response.formedText,
          predictions: response.predictions,
          rawPredictions: response.rawPredictions,
        ),
      );
    } catch (e) {
      emit(TranslatorError(error: e.toString()));
    }
  }

  void resetTranslation() {
    emit(const TranslatorInitial());
  }
}
