import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// شاشات المستخدم
import 'screens/user/user_login.dart';
import 'screens/user/user_register.dart';

import 'screens/user/progress_monitoring.dart';
import 'screens/user/goal_setting.dart';
import 'screens/user/user_profile_screen.dart';
import 'screens/user/user_activity_tracking_screen.dart';

// شاشات الإداري
import 'screens/admin/admin_login.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/admin_workout_diet_plan.dart';

// شاشة اختيار الدور بين المستخدم والإداري
import 'screens/user_or_admin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(FitnessApp());
}

class FitnessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fitness App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/', // تحديد شاشة البداية
      routes: {
        '/': (context) => UserOrAdminScreen(),
        '/user/login': (context) => UserLoginScreen(),
        '/user/register': (context) => UserRegisterScreen(
              onUserAdded: (String name) {
                // تنفيذ منطق عند إضافة المستخدم
                print('User added: $name');
              },
            ),
        '/user/profile': (context) => ProfileScreen(),
        '/user/activity': (context) => ActivityTrackingScreen(),
        '/user/progress': (context) => ProgressMonitoring(),
        '/user/goals': (context) => GoalSetting(),
        '/admin/login': (context) => AdminLoginScreen(),
        '/admin/dashboard': (context) => AdminDashboard(),
      },
    );
  }
}
