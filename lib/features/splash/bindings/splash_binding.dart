import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../../../data/repositories/poem_repository.dart';

class SplashBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(
      () {
        try {
          // Try to get the PoemRepository if it's available
          final poemRepository = Get.find<PoemRepository>();
          return SplashController(poemRepository: poemRepository);
        } catch (e) {
          // If PoemRepository is not available, create a fallback controller
          return SplashController(poemRepository: null);
        }
      },
    );
  }
}
