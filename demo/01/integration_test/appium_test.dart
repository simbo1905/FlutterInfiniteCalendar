import 'package:appium_flutter_server/appium_flutter_server.dart';
import 'package:meal_planner_demo/app.dart';

Future<void> main() async {
  await initializeTest(
    app: const MealPlannerApp(),
  );
}
