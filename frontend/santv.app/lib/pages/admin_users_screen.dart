import 'dart:async';

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/admin_service.dart';
import '../models/admin_user.dart';
import '../widgets/admin/admin_app_bar.dart';
import '../widgets/admin_dashboard/dashboard_style.dart';
import '../widgets/admin_dashboard/error_retry_view.dart';
import '../widgets/admin_users/admin_users_widgets.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  late final AdminService _adminService;

  bool _cargando = true;
  bool _actualizando = false; // evita pedir dos veces a la vez
  String? _error;
  List<AdminUser> _usuarios = [];
  Timer? _refreshTimer;

  /// Cada cuánto se refresca la lista sola (para ver quién está activo).
  static const Duration _refreshInterval = Duration(seconds: 15);

  @override
  void initState() {
    super.initState();
    _adminService = AdminService(authService: widget.authService);
    _cargarUsuarios();
    _refreshTimer = Timer.periodic(
      _refreshInterval,
      (_) => _cargarUsuarios(silent: true),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  /// [silent] = true: refresco automático, sin spinner y sin borrar la
  /// lista si falla la petición.
  Future<void> _cargarUsuarios({bool silent = false}) async {
    if (_actualizando) return;
    _actualizando = true;

    if (!silent) {
      setState(() {
        _cargando = true;
        _error = null;
      });
    }

    final result = await _adminService.getAllUsers();
    _actualizando = false;

    if (!mounted) return;

    if (silent && !result.success) return; // conserva lo que ya se ve

    setState(() {
      _cargando = false;
      if (result.success) {
        _usuarios = result.users;
        _error = null;
      } else {
        _error = result.errorMessage;
      }
    });
  }

  Widget _buildBody() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator(color: kNeonGreen));
    }
    if (_error != null) {
      return ErrorRetryView(message: _error!, onRetry: _cargarUsuarios);
    }
    return UsersBody(users: _usuarios, onRefresh: () => _cargarUsuarios());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScreenBg,
      appBar: AdminAppBar(
        title: 'Usuarios',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _cargando ? null : () => _cargarUsuarios(),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}