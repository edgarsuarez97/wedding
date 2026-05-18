import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/wedding_content_repository.dart';
import '../../../../domain/models/wedding_content.dart';

enum WeddingContentStatus { initial, loading, success, failure }

class WeddingContentState extends Equatable {
  const WeddingContentState({
    this.status = WeddingContentStatus.initial,
    this.content,
    this.message,
  });

  final WeddingContentStatus status;
  final WeddingContent? content;
  final String? message;

  WeddingContentState copyWith({
    WeddingContentStatus? status,
    WeddingContent? content,
    String? message,
    bool clearMessage = false,
  }) {
    return WeddingContentState(
      status: status ?? this.status,
      content: content ?? this.content,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, content, message];
}

class WeddingContentCubit extends Cubit<WeddingContentState> {
  WeddingContentCubit(this._repository) : super(const WeddingContentState());

  final WeddingContentRepository _repository;

  Future<void> load() async {
    if (state.status == WeddingContentStatus.loading ||
        state.status == WeddingContentStatus.success) {
      return;
    }

    emit(
      state.copyWith(status: WeddingContentStatus.loading, clearMessage: true),
    );

    try {
      final content = await _repository.fetchContent();
      emit(
        state.copyWith(
          status: WeddingContentStatus.success,
          content: content,
          clearMessage: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: WeddingContentStatus.failure,
          message: 'Unable to load wedding details. Please refresh.',
        ),
      );
    }
  }
}
