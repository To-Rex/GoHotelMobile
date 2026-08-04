import 'package:get/get.dart';
import '../../../data/models/task_model.dart';
import '../../../data/services/data_service.dart';

class TasksController extends GetxController {
  final _dataService = DataService();

  final tasks = <TaskModel>[].obs;
  final selectedTab = 0.obs;
  final isLoading = false.obs;

  List<TaskModel> get pendingTasks =>
      tasks.where((t) => t.status == TaskStatus.pending).toList();
  List<TaskModel> get inProgressTasks =>
      tasks.where((t) => t.status == TaskStatus.inProgress).toList();
  List<TaskModel> get completedTasks =>
      tasks.where((t) => t.status == TaskStatus.completed).toList();

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  Future<void> loadTasks() async {
    isLoading.value = true;
    try {
      tasks.value = await _dataService.getTasks();
      tasks.refresh();
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  void startTask(String taskId) {
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      tasks[index] = tasks[index].copyWith(status: TaskStatus.inProgress);
      tasks.refresh();
      _dataService.startTask(taskId);
    }
  }

  void updateTaskProgress(String taskId, int progress) {
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final newStatus = progress >= 100
          ? TaskStatus.completed
          : TaskStatus.inProgress;
      tasks[index] = tasks[index].copyWith(
        progress: progress,
        status: newStatus,
      );
      tasks.refresh();
      _dataService.updateTaskProgress(taskId, progress);
    }
  }

  void toggleChecklistItem(String taskId, String itemId) {
    final taskIndex = tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final task = tasks[taskIndex];
      final newChecklist = task.checklist.map((item) {
        if (item.id == itemId) {
          return item.copyWith(isCompleted: !item.isCompleted);
        }
        return item;
      }).toList();
      final completed = newChecklist.where((c) => c.isCompleted).length;
      final progress = newChecklist.isEmpty
          ? 0
          : (completed / newChecklist.length * 100).round();
      tasks[taskIndex] = task.copyWith(
        checklist: newChecklist,
        progress: progress,
        status: TaskStatus.inProgress,
      );
      tasks.refresh();
      _dataService.toggleChecklistItem(taskId, itemId);
    }
  }
}
