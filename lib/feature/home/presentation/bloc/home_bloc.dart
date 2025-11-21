import 'package:bloc/bloc.dart';
import 'package:digiattend/feature/authentication/data/models/training_model.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

import '../../../../core/service/auth_local_storage.dart';
import '../../../authentication/data/models/user_model.dart';
import '../../../authentication/data/models/attendance_model.dart';
import '../../../authentication/data/service/attendance_api.dart';
import '../../../authentication/data/service/training_api.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeState.initial()) {
    on<LoadHomeData>(_loadHomeData);
    on<RefreshAttendance>(_refreshAttendance);
  }

  // ===========================================================
  // LOAD USER + TRAINING + ATTENDANCE
  // ===========================================================
  Future<void> _loadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(loadingUser: true, loadingHistory: true));

    // USER
    final json = await AuthLocalStorage.getUser();
    UserModel? user;
    if (json != null) user = UserModel.fromJson(json);

    // TRAINING TITLE
    String trainingTitle = "-";
    if (user != null) {
      final list = await TrainingAPI.getTrainingList();
      final training = list.firstWhere(
        (t) => t.id == user!.trainingId,
        orElse: () => TrainingData(title: "Unknown"),
      );
      trainingTitle = training.title ?? "-";
    }

    emit(
      state.copyWith(
        user: user,
        trainingTitle: trainingTitle,
        loadingUser: false,
      ),
    );

    await _loadAttendance(emit);
  }

  // ===========================================================
  // REFRESH ONLY ATTENDANCE
  // ===========================================================
  Future<void> _refreshAttendance(
    RefreshAttendance event,
    Emitter<HomeState> emit,
  ) async {
    await _loadAttendance(emit);
  }

  // ===========================================================
  // INTERNAL FUNCTION
  // ===========================================================
  Future<void> _loadAttendance(Emitter<HomeState> emit) async {
    emit(state.copyWith(loadingHistory: true));

    try {
      final list = await AttendanceAPI.getHistory();

      final today = DateFormat("yyyy-MM-dd").format(DateTime.now());

      final todayData = list.firstWhere(
        (x) => x.attendanceDate == today,
        orElse: () => AttendanceData(attendanceDate: ""),
      );

      emit(
        state.copyWith(
          history: list,
          hasCheckedIn: todayData.checkInTime != null,
          hasCheckedOut: todayData.checkOutTime != null,
          checkInTime: todayData.checkInTime,
          checkOutTime: todayData.checkOutTime,
          loadingHistory: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(loadingHistory: false));
    }
  }
}
