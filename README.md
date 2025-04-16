# boxing_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


Clear saved data after the update
If you don’t care about older sessions or are still testing, you can just clear old data:
1. Go to training_storage and uncomment clearTrainingHistory()
2. Go to main.dart and replace void main() with this code 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TrainingStorage.clearTrainingHistory();
  runApp(BoxingTimerApp());
}