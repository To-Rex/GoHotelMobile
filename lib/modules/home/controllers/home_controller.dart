import 'package:get/get.dart';
import '../../../core/storage/local_storage.dart';
import '../../../data/models/task_model.dart';
import '../../../data/services/data_service.dart';
import '../../tasks/controllers/tasks_controller.dart';

class HomeController extends GetxController {
  TasksController get _tasksController => Get.find<TasksController>();
  final _storage = LocalStorage();
  final _dataService = DataService();

  final completedTasks = 0.obs;
  final pendingTasks = 0.obs;
  final problemTasks = 0.obs;
  final overallProgress = 0.0.obs;
  final todayTasks = <TaskModel>[].obs;
  final isLoading = false.obs;

  Worker? _tasksWorker;

  @override
  void onInit() {
    super.onInit();
    // Vazifalar serverdan keyinroq kelganda ham statistika avtomatik
    // yangilanadi — aks holda birinchi ochilishda sahifa bo'sh qoladi.
    _tasksWorker = ever(_tasksController.tasks, (_) => _updateStats());
    _initApp();
  }

  @override
  void onClose() {
    _tasksWorker?.dispose();
    super.onClose();
  }

  Future<void> _initApp() async {
    if (!_storage.isLoggedIn) {
      Get.offAllNamed('/login');
      return;
    }

    try {
      await _dataService.getCurrentUser();
    } catch (_) {}

    if (_storage.isLoggedIn) {
      _updateStats();
    }
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      await _tasksController.loadTasks();
      _updateStats();
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  void loadData() {
    _updateStats();
  }

  void _updateStats() {
    final tasks = _tasksController.tasks;
    completedTasks.value = tasks
        .where((t) => t.status == TaskStatus.completed)
        .length;
    pendingTasks.value = tasks
        .where((t) => t.status == TaskStatus.pending)
        .length;
    problemTasks.value = tasks.where((t) => t.isUrgent).length;

    final inProgress = tasks
        .where((t) => t.status == TaskStatus.inProgress)
        .fold<int>(0, (s, t) => s + t.progress);
    final completed = completedTasks.value * 100;
    final total = tasks.length * 100;
    overallProgress.value = total > 0 ? (inProgress + completed) / total : 0.0;

    todayTasks.value = tasks
        .where((t) => t.status != TaskStatus.completed)
        .toList();
  }
}
