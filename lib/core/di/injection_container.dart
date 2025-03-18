// core/di/injection_container.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../features/auth/data/datasources/auth_firebase_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_state_changes_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_with_email_usecase.dart';
import '../../features/auth/domain/usecases/login_with_google_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/obra/data/datasources/obra_datasource.dart';
import '../../features/obra/data/datasources/obra_firebase_datasource.dart';
import '../../features/obra/data/repositories/obra_repository_impl.dart';
import '../../features/obra/domain/repositories/obra_repository.dart';
import '../../features/obra/domain/usecases/delete_obra_usecase.dart';
import '../../features/obra/domain/usecases/get_obra_by_id_usecase.dart';
import '../../features/obra/domain/usecases/get_obras_usecase.dart';
import '../../features/obra/domain/usecases/save_obra_usecase.dart';
import '../../features/obra/domain/usecases/update_obra_usecase.dart';
import '../../features/obra/presentation/controllers/obra_controller.dart';
import '../../features/relatorio/data/datasources/relatorio_datasource.dart';
import '../../features/relatorio/data/datasources/relatorio_firebase_datasource.dart';
import '../../features/relatorio/data/repositories/relatorio_repository_impl.dart';
import '../../features/relatorio/domain/repositories/relatorio_repository.dart';
import '../../features/relatorio/domain/usecases/delete_relatorio_usecase.dart';
import '../../features/relatorio/domain/usecases/get_relatorio_by_id_usecase.dart';
import '../../features/relatorio/domain/usecases/get_relatorios_by_obra_id_usecase.dart';
import '../../features/relatorio/domain/usecases/update_relatorio_usecase.dart';
import '../../features/relatorio/presentation/controllers/relatorio_controller.dart';
import '../../features/relatorio/presentation/controllers/relatorio_editor_controller.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
// Firebase instances
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn());

  // Controllers
  sl.registerFactory(() => ObraController(
        getObrasUseCase: sl(),
        saveObraUseCase: sl(),
        updateObraUseCase: sl(),
        deleteObraUseCase: sl(),
      ));

  sl.registerFactory(() => RelatorioController(
        getObraByIdUseCase: sl(),
        getRelatoriosByObraIdUseCase: sl(),
        deleteRelatorioUseCase: sl(),
      ));

  sl.registerFactory(() => AuthController(
        loginWithEmailUseCase: sl(),
        loginWithGoogleUseCase: sl(),
        logoutUseCase: sl(),
        registerUseCase: sl(), // Novo parâmetro
        getCurrentUserUseCase: sl(),
        authStateChangesUseCase: sl(),
      ));
  sl.registerFactory(() => EditRelatorioController(
        getRelatorioByIdUseCase: sl(),
        updateRelatorioUseCase: sl(),
        getObraByIdUseCase: sl(),
      ));

  // Use Cases
  sl.registerLazySingleton(() => GetObrasUseCase(sl()));
  sl.registerLazySingleton(() => GetObraByIdUseCase(sl()));
  sl.registerLazySingleton(() => SaveObraUseCase(sl()));
  sl.registerLazySingleton(() => UpdateObraUseCase(sl()));
  sl.registerLazySingleton(() => DeleteObraUseCase(sl()));
  sl.registerLazySingleton(() => GetRelatoriosByObraIdUseCase(sl()));
  sl.registerLazySingleton(() => DeleteRelatorioUseCase(sl()));
  sl.registerLazySingleton(() => LoginWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => LoginWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => AuthStateChangesUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl())); // Novo caso de uso
  sl.registerLazySingleton(() => GetRelatorioByIdUseCase(sl()));
  sl.registerLazySingleton(() => UpdateRelatorioUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<ObraRepository>(() => ObraRepositoryImpl(
        dataSource: sl(),
      ));
  sl.registerLazySingleton<RelatorioRepository>(() => RelatorioRepositoryImpl(
        dataSource: sl(),
      ));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(dataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<ObraDataSource>(() => ObraFirebaseDataSource(
        firestore: sl(),
      ));
  sl.registerLazySingleton<RelatorioDataSource>(
      () => RelatorioFirebaseDataSource(
            firestore: sl(),
          ));
  sl.registerLazySingleton<AuthDataSource>(
    () => AuthFirebaseDataSource(
      firebaseAuth: sl<FirebaseAuth>(),
      googleSignIn: sl<GoogleSignIn>(),
    ),
  );

  // External Services
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
}
