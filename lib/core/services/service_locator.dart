import 'package:get_it/get_it.dart';
import 'package:merema/core/layers/data/sources/register_api_service.dart';
import 'package:merema/core/network/dio_client.dart';
import 'package:merema/features/auth/data/sources/auth_local_service.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/auth/domain/usecases/get_acc_id.dart';
import 'package:merema/features/auth/domain/usecases/get_token.dart';
import 'package:merema/features/auth/domain/usecases/get_user_role.dart';
import 'package:merema/features/auth/domain/usecases/is_logged_in.dart';
import 'package:merema/features/auth/domain/usecases/login.dart';
import 'package:merema/features/auth/domain/usecases/logout.dart';
import 'package:merema/features/auth/domain/usecases/recovery.dart';
import 'package:merema/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:merema/features/auth/data/sources/auth_api_service.dart';
import 'package:merema/features/comms/data/repositories/comms_repository_impl.dart';
import 'package:merema/features/comms/data/sources/comms_local_service.dart';
import 'package:merema/features/comms/data/sources/comms_websocket_service.dart';
import 'package:merema/features/comms/domain/repositories/comms_repository.dart';
import 'package:merema/features/comms/domain/usecases/close_ws_connection.dart';
import 'package:merema/features/comms/domain/usecases/get_contacts.dart';
import 'package:merema/features/comms/domain/usecases/get_messages.dart';
import 'package:merema/features/comms/domain/usecases/mark_seen_message.dart';
import 'package:merema/features/comms/domain/usecases/open_ws_connection.dart';
import 'package:merema/features/comms/domain/usecases/send_message.dart';
import 'package:merema/features/comms/presentation/notifiers/comms_notifier.dart';
import 'package:merema/features/patients/data/repositories/patient_repository_impl.dart';
import 'package:merema/features/patients/data/sources/patient_api_service.dart';
import 'package:merema/features/patients/domain/repositories/patient_repository.dart';
import 'package:merema/features/patients/domain/usecases/get_patient_infos.dart';
import 'package:merema/features/patients/domain/usecases/get_patients_list.dart';
import 'package:merema/features/patients/domain/usecases/register_patient.dart';
import 'package:merema/features/patients/domain/usecases/update_patient.dart';
import 'package:merema/features/prescriptions/data/repositories/prescription_repository_impl.dart';
import 'package:merema/features/prescriptions/data/sources/prescription_api_service.dart';
import 'package:merema/features/prescriptions/data/sources/prescription_local_service.dart';
import 'package:merema/features/prescriptions/domain/repositories/prescription_repository.dart';
import 'package:merema/features/prescriptions/domain/usecases/add_prescription_medication.dart';
import 'package:merema/features/prescriptions/domain/usecases/confirm_received.dart';
import 'package:merema/features/prescriptions/domain/usecases/create_prescription.dart';
import 'package:merema/features/prescriptions/domain/usecases/delete_prescription_medication.dart';
import 'package:merema/features/prescriptions/domain/usecases/get_medication_by_id.dart';
import 'package:merema/features/prescriptions/domain/usecases/get_medications.dart';
import 'package:merema/features/prescriptions/domain/usecases/get_prescription_details.dart';
import 'package:merema/features/prescriptions/domain/usecases/get_prescriptions_by_patient.dart';
import 'package:merema/features/prescriptions/domain/usecases/get_prescriptions_by_record.dart';
import 'package:merema/features/prescriptions/domain/usecases/update_prescription.dart';
import 'package:merema/features/prescriptions/domain/usecases/update_prescription_medication.dart';
import 'package:merema/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:merema/features/profile/data/sources/profile_api_service.dart';
import 'package:merema/features/profile/data/sources/profile_local_service.dart';
import 'package:merema/features/profile/domain/repositories/profile_repository.dart';
import 'package:merema/features/profile/domain/usecases/get_user_profile.dart';
import 'package:merema/features/profile/domain/usecases/update_profile.dart';
import 'package:merema/features/schedules/data/repositories/schedule_repository_impl.dart';
import 'package:merema/features/schedules/data/sources/schedule_api_service.dart';
import 'package:merema/features/schedules/domain/repositories/schedule_repository.dart';
import 'package:merema/features/schedules/domain/usecases/book_schedule.dart';
import 'package:merema/features/schedules/domain/usecases/get_schedules.dart';
import 'package:merema/features/schedules/domain/usecases/update_schedule_status.dart';
import 'package:merema/features/staffs/data/repositories/staff_repository_impl.dart';
import 'package:merema/features/staffs/data/sources/staff_api_service.dart';
import 'package:merema/features/staffs/domain/repositories/staff_repository.dart';
import 'package:merema/features/staffs/domain/usecases/get_staff_infos.dart';
import 'package:merema/features/staffs/domain/usecases/get_staffs_list.dart';
import 'package:merema/features/staffs/domain/usecases/register_staff.dart';
import 'package:merema/features/staffs/domain/usecases/update_staff.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  sl.registerSingleton<DioClient>(DioClient());

  // Services
  sl.registerSingleton<AuthApiService>(AuthApiServiceImpl());
  sl.registerSingleton<AuthLocalService>(AuthLocalServiceImpl());

  sl.registerSingleton<CommsWebSocketService>(CommsWebSocketService());
  sl.registerSingleton<CommsLocalService>(CommsLocalServiceImpl());
  sl.registerSingleton<CommsNotifier>(CommsNotifier());

  sl.registerSingleton<ProfileApiService>(ProfileApiServiceImpl());
  sl.registerSingleton<ProfileLocalService>(ProfileLocalServiceImpl());

  sl.registerSingleton<RegisterApiService>(RegisterApiServiceImpl());

  sl.registerSingleton<PatientApiService>(PatientApiServiceImpl());

  sl.registerSingleton<StaffApiService>(StaffApiServiceImpl());

  sl.registerSingleton<ScheduleApiService>(ScheduleApiServiceImpl());

  sl.registerSingleton<PrescriptionApiService>(PrescriptionApiServiceImpl());
  sl.registerSingleton<PrescriptionLocalService>(
      PrescriptionLocalServiceImpl());

  // Repositories
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl());

  sl.registerSingleton<CommsRepository>(CommsRepositoryImpl());

  sl.registerSingleton<ProfileRepository>(ProfileRepositoryImpl());

  sl.registerSingleton<PatientRepository>(PatientRepositoryImpl());

  sl.registerSingleton<StaffRepository>(StaffRepositoryImpl());

  sl.registerSingleton<ScheduleRepository>(ScheduleRepositoryImpl());

  sl.registerSingleton<PrescriptionRepository>(PrescriptionRepositoryImpl());

  // Use cases
  sl.registerSingleton<LoginUseCase>(LoginUseCase());
  sl.registerSingleton<RecoveryUseCase>(RecoveryUseCase());
  sl.registerSingleton<RecoveryConfirmUseCase>(RecoveryConfirmUseCase());
  sl.registerSingleton<RecoveryResetUseCase>(RecoveryResetUseCase());
  sl.registerSingleton<IsLoggedInUseCase>(IsLoggedInUseCase());
  sl.registerSingleton<GetTokenUseCase>(GetTokenUseCase());
  sl.registerSingleton<GetUserRoleUseCase>(GetUserRoleUseCase());
  sl.registerSingleton<GetAccIdUseCase>(GetAccIdUseCase());
  sl.registerSingleton<LogoutUseCase>(LogoutUseCase());

  sl.registerSingleton<OpenWsConnectionUseCase>(
      OpenWsConnectionUseCase(authRepository: sl()));
  sl.registerSingleton<CloseWsConnectionUseCase>(CloseWsConnectionUseCase());
  sl.registerSingleton<GetContactsUseCase>(GetContactsUseCase());
  sl.registerSingleton<GetMessagesUseCase>(GetMessagesUseCase());
  sl.registerSingleton<SendMessageUseCase>(SendMessageUseCase());
  sl.registerSingleton<MarkSeenMessageUseCase>(MarkSeenMessageUseCase());

  sl.registerSingleton<GetUserProfileUseCase>(
      GetUserProfileUseCase(authRepository: sl()));
  sl.registerSingleton<UpdateProfileUseCase>(
      UpdateProfileUseCase(authRepository: sl()));

  sl.registerSingleton<GetPatientsListUseCase>(
    GetPatientsListUseCase(authRepository: sl()),
  );
  sl.registerSingleton<GetPatientInfosUseCase>(
    GetPatientInfosUseCase(authRepository: sl()),
  );
  sl.registerSingleton<RegisterPatientUseCase>(
    RegisterPatientUseCase(authRepository: sl()),
  );
  sl.registerSingleton<UpdatePatientUseCase>(
    UpdatePatientUseCase(authRepository: sl()),
  );

  sl.registerSingleton<GetStaffsListUseCase>(
    GetStaffsListUseCase(authRepository: sl()),
  );
  sl.registerSingleton<GetStaffInfosUseCase>(
    GetStaffInfosUseCase(authRepository: sl()),
  );
  sl.registerSingleton<RegisterStaffUseCase>(
    RegisterStaffUseCase(authRepository: sl()),
  );
  sl.registerSingleton<UpdateStaffUseCase>(
    UpdateStaffUseCase(authRepository: sl()),
  );

  sl.registerSingleton<GetSchedulesUseCase>(
    GetSchedulesUseCase(authRepository: sl()),
  );
  sl.registerSingleton<BookScheduleUseCase>(
    BookScheduleUseCase(authRepository: sl()),
  );
  sl.registerSingleton<UpdateScheduleStatusUseCase>(
    UpdateScheduleStatusUseCase(authRepository: sl()),
  );

  sl.registerSingleton<GetMedicationsUseCase>(
    GetMedicationsUseCase(authRepository: sl()),
  );
  sl.registerSingleton<GetMedicationByIdUseCase>(
    GetMedicationByIdUseCase(authRepository: sl()),
  );
  sl.registerSingleton<GetPrescriptionsByPatientUseCase>(
    GetPrescriptionsByPatientUseCase(authRepository: sl()),
  );
  sl.registerSingleton<GetPrescriptionsByRecordUseCase>(
    GetPrescriptionsByRecordUseCase(authRepository: sl()),
  );
  sl.registerSingleton<GetPrescriptionDetailsUseCase>(
    GetPrescriptionDetailsUseCase(authRepository: sl()),
  );
  sl.registerSingleton<CreatePrescriptionUseCase>(
    CreatePrescriptionUseCase(authRepository: sl()),
  );
  sl.registerSingleton<UpdatePrescriptionUseCase>(
    UpdatePrescriptionUseCase(authRepository: sl()),
  );
  sl.registerSingleton<ConfirmReceivedUseCase>(
    ConfirmReceivedUseCase(authRepository: sl()),
  );
  sl.registerSingleton<AddPrescriptionMedicationUseCase>(
    AddPrescriptionMedicationUseCase(authRepository: sl()),
  );
  sl.registerSingleton<UpdatePrescriptionMedicationUseCase>(
    UpdatePrescriptionMedicationUseCase(authRepository: sl()),
  );
  sl.registerSingleton<DeletePrescriptionMedicationUseCase>(
    DeletePrescriptionMedicationUseCase(authRepository: sl()),
  );
}
