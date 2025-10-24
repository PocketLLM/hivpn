import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'secure_store.dart';

final secureStoreProvider = Provider<SecureStore>((ref) {
  return SecureStore();
});
