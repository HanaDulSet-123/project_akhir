class Endpoint {
  static const String baseURL = "https://appabsensi.mobileprojp.com/api";
  static const String register = "$baseURL/register";
  static const String profile = "$baseURL/profile";
  static const String login = "$baseURL/login";
  static const String checkIn = "$baseURL/absen/check-in";
  static const String checkOut = "$baseURL/absen/check-out";
  static const String izin = "$baseURL/izin";
  static const String absenToday = "$baseURL/absen/today";
  static const String training = "$baseURL/trainings";
  static const String batch = "$baseURL/batches";
  static const String historyAbsen = "$baseURL/absen/history";
  static const String editFoto = "$baseURL/profile/photo";
  static const String editProfile = "$baseURL/profile";
  static const String forgotPassword =
      "$baseURL/forgot-password"; // <-- TAMBAHKAN INI
  static const String resetPassword = "$baseURL/reset-password";
  static const String absenStats = "$baseURL/absen/stats";
}
