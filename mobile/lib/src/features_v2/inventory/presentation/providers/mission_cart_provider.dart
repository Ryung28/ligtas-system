import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/inventory_item.dart';

part 'mission_cart_provider.g.dart';

@riverpod
class MissionCartNotifier extends _$MissionCartNotifier {
  @override
  Map<String, CartItem> build() {
    return {};
  }

  void addItem(InventoryItem item) {
    if (item.availableStock <= 0) return; // 🛡️ STOCK GUARD: Prevents adding out-of-stock items

    final itemId = item.id.toString();
    if (state.containsKey(itemId)) {
      // Item already in cart, increment quantity
      final currentItem = state[itemId]!;
      if (currentItem.quantity < item.availableStock) {
        state = {
          ...state,
          itemId: currentItem.copyWith(quantity: currentItem.quantity + 1),
        };
      }
    } else {
      // Add new item to cart
      state = {
        ...state,
        itemId: CartItem(item: item, quantity: 1),
      };
    }
  }

  void removeItem(InventoryItem item) {
    final itemId = item.id.toString();
    final newState = Map<String, CartItem>.from(state);
    newState.remove(itemId);
    state = newState;
  }

  void decrementItem(InventoryItem item) {
    final itemId = item.id.toString();
    if (state.containsKey(itemId)) {
      final currentItem = state[itemId]!;
      if (currentItem.quantity > 1) {
        state = {
          ...state,
          itemId: currentItem.copyWith(quantity: currentItem.quantity - 1),
        };
      } else {
        removeItem(item);
      }
    }
  }

  void updateQuantity(InventoryItem item, int quantity) {
    final itemId = item.id.toString();
    if (state.containsKey(itemId) && quantity > 0 && quantity <= item.availableStock) {
      state = {
        ...state,
        itemId: state[itemId]!.copyWith(quantity: quantity),
      };
    }
  }

  void clearCart() {
    state = {};
  }

  bool isInCart(InventoryItem item) {
    return state.containsKey(item.id.toString());
  }

  int getQuantity(InventoryItem item) {
    final itemId = item.id.toString();
    return state[itemId]?.quantity ?? 0;
  }

  int get totalItems => state.length;

  int get totalQuantity => state.values.fold(0, (sum, item) => sum + item.quantity);
}

// Cart item model
class CartItem {
  final InventoryItem item;
  final int quantity;

  const CartItem({
    required this.item,
    required this.quantity,
  });

  CartItem copyWith({
    InventoryItem? item,
    int? quantity,
  }) {
    return CartItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
    );
  }
}
