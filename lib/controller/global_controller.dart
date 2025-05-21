import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class GlobalController extends GetxController {
  final RxBool _isLoading = true.obs;
  final RxDouble _latitude = 0.0.obs;
  final RxDouble _longitude = 0.0.obs;

  // Getters
  RxBool get isLoading => _isLoading;
  RxDouble get latitude => _latitude;
  RxDouble get longitude => _longitude;

  @override
  void onInit() {
    super.onInit();
    getLocation();
  }

  Future<void> getLocation() async {
    try {
      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error("Location services are disabled.");
      }

      // Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error("Location permissions are denied.");
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Future.error("Location permissions are permanently denied.");
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _latitude.value = position.latitude;
      _longitude.value = position.longitude;
      _isLoading.value = false;

    } catch (e) {
      print("Error getting location: $e");
      _isLoading.value = false;
    }
  }
}
