import 'package:get_it/get_it.dart';

import 'package:tc_flutter_web/features/guides/data/repositories/guides_repository_impl.dart';
import 'package:tc_flutter_web/features/guides/data/repositories/hero_detail_repository_impl.dart';
import 'package:tc_flutter_web/features/guides/domain/repositories/guides_repository.dart';
import 'package:tc_flutter_web/features/guides/domain/repositories/hero_detail_repository.dart';
import 'package:tc_flutter_web/features/home/data/repositories/home_repository_impl.dart';
import 'package:tc_flutter_web/features/home/domain/repositories/home_repository.dart';

/// Global service locator.
final GetIt sl = GetIt.instance;

/// Registers all app dependencies. Call once before `runApp`.
void setUpDependencies() {
  sl
    ..registerLazySingleton<HomeRepository>(HomeRepositoryImpl.new)
    ..registerLazySingleton<GuidesRepository>(GuidesRepositoryImpl.new)
    ..registerLazySingleton<HeroDetailRepository>(HeroDetailRepositoryImpl.new);
}
