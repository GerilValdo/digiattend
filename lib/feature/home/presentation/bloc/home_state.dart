part of 'home_bloc.dart';

class HomeState extends Equatable {
  final UserModel? user;
  final List<AttendanceData> history;

  final String trainingTitle;
  final bool loadingUser;
  final bool loadingHistory;

  final bool hasCheckedIn;
  final bool hasCheckedOut;
  final String? checkInTime;
  final String? checkOutTime;

  const HomeState({
    this.user,
    this.history = const [],
    this.trainingTitle = "-",
    this.loadingUser = true,
    this.loadingHistory = true,
    this.hasCheckedIn = false,
    this.hasCheckedOut = false,
    this.checkInTime,
    this.checkOutTime,
  });

  factory HomeState.initial() => const HomeState();

  HomeState copyWith({
    UserModel? user,
    List<AttendanceData>? history,
    String? trainingTitle,
    bool? loadingUser,
    bool? loadingHistory,
    bool? hasCheckedIn,
    bool? hasCheckedOut,
    String? checkInTime,
    String? checkOutTime,
  }) {
    return HomeState(
      user: user ?? this.user,
      history: history ?? this.history,
      trainingTitle: trainingTitle ?? this.trainingTitle,
      loadingUser: loadingUser ?? this.loadingUser,
      loadingHistory: loadingHistory ?? this.loadingHistory,
      hasCheckedIn: hasCheckedIn ?? this.hasCheckedIn,
      hasCheckedOut: hasCheckedOut ?? this.hasCheckedOut,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
    );
  }

  @override
  List<Object?> get props => [
        user,
        history,
        trainingTitle,
        loadingUser,
        loadingHistory,
        hasCheckedIn,
        hasCheckedOut,
        checkInTime,
        checkOutTime,
      ];
}
