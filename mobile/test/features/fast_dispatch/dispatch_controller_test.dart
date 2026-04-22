import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/src/features/fast_dispatch/providers/dispatch_controller.dart';

void main() {
  group('FastDispatchController', () {
    test('quantity is clamped and cannot go below 1', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(fastDispatchControllerProvider.notifier);
      notifier.selectItem(42, 'Helmet');
      notifier.updateItemQuantity(0);

      final state = container.read(fastDispatchControllerProvider).value!;
      expect(state.selectedItem, isNotNull);
      expect(state.selectedItem!.quantity, 1);
    });

    test('submit fails when borrower data is incomplete', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(fastDispatchControllerProvider.notifier);
      notifier.selectItem(99, 'Rescue Rope');
      notifier.updateBorrowerDraft(name: 'Responder One', contact: '', office: 'Ops');

      await notifier.submit();

      final state = container.read(fastDispatchControllerProvider).value!;
      expect(state.error, 'Complete borrower name, contact, and office');
    });
  });
}
