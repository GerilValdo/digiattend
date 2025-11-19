class Endpoint {
  static const baseUrl = 'https://appabsensi.mobileprojp.com';

  static const register = '$baseUrl/api/register';
  static const login = '$baseUrl/api/login';
  static const trainings = '$baseUrl/api/trainings';
  static const trainingBatches = '$baseUrl/api/batches';
  static const updateProfile = '$baseUrl/api/profile';
  static const updateProfilePhoto = '$baseUrl/api/profile/photo';
  static const absenCheckIn = '$baseUrl/api/absen/check-in';
  static const absenCheckOut = '$baseUrl/api/absen/check-out';
  static const attendanceHistory = '$baseUrl/api/absen/history';
}
