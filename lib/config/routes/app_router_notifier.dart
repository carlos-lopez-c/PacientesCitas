import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paciente_citas_1/auth/presentation/providers/auth_provider.dart';


final goRouterNotifierProvider = Provider((ref) {
  final authState = ref.watch(authProvider);
  return GoRouterNotifier(ref, authState.authStatus);
});

class GoRouterNotifier extends ChangeNotifier {
  final Ref _ref;
  AuthStatus _authStatus;

  GoRouterNotifier(this._ref, this._authStatus) {
    _ref.listen(authProvider, (previous, next) {
      if (previous?.authStatus != next.authStatus) {
        authStatus = next.authStatus;
      }
    });
  }

  AuthStatus get authStatus => _authStatus;

  set authStatus(AuthStatus value) {
    if (_authStatus != value) {
      _authStatus = value;
      notifyListeners();
    }
  }
}
