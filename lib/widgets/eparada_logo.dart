import 'package:flutter/material.dart';

import '../models/auth_user.dart';

class EParadaLogo extends StatelessWidget {
  const EParadaLogo({
    super.key,
    this.role = EParadaLogoRole.general,
    this.size = 64,
    this.semanticLabel,
  });

  factory EParadaLogo.forUser(AuthUser user, {Key? key, double size = 64}) {
    final role = user.isDriver
        ? EParadaLogoRole.driver
        : user.isParkingOwner
        ? EParadaLogoRole.provider
        : EParadaLogoRole.general;

    return EParadaLogo(
      key: key,
      role: role,
      size: size,
      semanticLabel: '${user.roleLabel} E-Parada logo',
    );
  }

  final EParadaLogoRole role;
  final double size;
  final String? semanticLabel;

  String get _asset => switch (role) {
    EParadaLogoRole.driver => 'assets/branding/eparada_driver.png',
    EParadaLogoRole.provider => 'assets/branding/eparada_provider.png',
    EParadaLogoRole.general => 'assets/branding/eparada_general.png',
  };

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: semanticLabel ?? 'E-Parada logo',
    );
  }
}

enum EParadaLogoRole { general, driver, provider }
