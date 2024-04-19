// import 'package:flutter_driver/flutter_driver.dart';

// Future<bool> isPresent(FlutterDriver driver, SerializableFinder finder) async {
//   try {
//     await driver.waitFor(finder, timeout: const Duration(seconds: 2));
//     return true;
//   } catch (e) {
//     return false;
//   }
// }

// Future<bool> isVisible(FlutterDriver driver, SerializableFinder finder) async {
//   try {
//     final element =
//         await driver.waitFor(finder, timeout: const Duration(seconds: 2));
//     final rect = await driver.getRect(element);
//     final screenSize = await driver.getScreenSize();
//     return rect != null &&
//         rect.top >= 0 &&
//         rect.left >= 0 &&
//         rect.bottom <= screenSize.height &&
//         rect.right <= screenSize.width;
//   } catch (e) {
//     return false;
//   }
// }
