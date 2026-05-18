import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_g_and_e/data/repositories/wedding_content_repository.dart';
import 'package:wedding_g_and_e/ui/features/home/cubit/wedding_content_cubit.dart';

void main() {
  group('WeddingContentCubit', () {
    late WeddingContentCubit cubit;

    setUp(() {
      cubit = WeddingContentCubit(WeddingContentRepository());
    });

    tearDown(() async {
      await cubit.close();
    });

    blocTest<WeddingContentCubit, WeddingContentState>(
      'loads wedding content successfully',
      build: () => cubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const WeddingContentState(status: WeddingContentStatus.loading),
        isA<WeddingContentState>().having(
          (state) => state.status,
          'status',
          WeddingContentStatus.success,
        ),
      ],
    );
  });
}
