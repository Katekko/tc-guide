import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection_container.dart';
import 'core/router/configure_url_strategy.dart';

void main() {
  configureUrlStrategy();
  setUpDependencies();
  runApp(App());
}
