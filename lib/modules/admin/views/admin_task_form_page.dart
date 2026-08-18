import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/animations/app_animations.dart';
import '../../../data/models/hk_task_model.dart';
import '../controllers/admin_tasks_controller.dart';

/// Yangi housekeeping vazifasi yaratish formasi
/// (web'dagi yaratish dialogi bilan bir xil maydonlar).
class AdminTaskFormPage extends StatefulWidget {
  const AdminTaskFormPage({super.key});

  @override
  State<AdminTaskFormPage> createState() => _AdminTaskFormPageState();
}

class _AdminTaskFormPageState extends State<AdminTaskFormPage> {
  final controller = Get.find<AdminTasksController>();

  String? branchId;
  String? roomId;
  String taskType = 'CLEANING';
  String priority = 'MEDIUM';
  String? assigneeId;
  DateTime scheduledDate = DateTime.now();
  final notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (controller.branches.length == 1) {
      branchId = controller.branches.first.id;
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  String get _dateLabel =>
      '${scheduledDate.year}-${scheduledDate.month.toString().padLeft(2, '0')}-${scheduledDate.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.onSurface,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text('Yangi vazifa'.tr, style: AppTextStyles.h2()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Obx(() {
          final branches = controller.branches;
          // Bitta filial bo'lsa u REAKTIV aniqlanadi — initState paytida
          // filiallar hali yuklanmagan bo'lishi mumkin edi
          final effBranch =
              branchId ?? (branches.length == 1 ? branches.first.id : null);
          final rooms = effBranch == null
              ? controller.rooms
              : controller.rooms.where((r) => r.branchId == effBranch).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (branches.length > 1) ...[
                _label('Filial'.tr),
                _dropdown<String>(
                  value: branchId,
                  hint: 'Filialni tanlang'.tr,
                  items: branches
                      .map(
                        (b) => DropdownMenuItem(
                          value: b.id,
                          child: Text(b.name, style: AppTextStyles.bodyMd()),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() {
                    branchId = v;
                    roomId = null;
                  }),
                ),
                const SizedBox(height: 16),
              ],
              _label('Xona'.tr),
              _dropdown<String>(
                value: roomId,
                hint: 'Xonani tanlang'.tr,
                items: rooms
                    .map(
                      (r) => DropdownMenuItem(
                        value: r.id,
                        child: Text(
                          r.roomNumber,
                          style: AppTextStyles.bodyMd(),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => roomId = v),
              ),
              const SizedBox(height: 16),
              _label('Vazifa turi'.tr),
              _dropdown<String>(
                value: taskType,
                items: HkTaskModel.taskTypes
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(
                          HkTaskModel.typeLabel(t),
                          style: AppTextStyles.bodyMd(),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => taskType = v ?? 'CLEANING'),
              ),
              const SizedBox(height: 16),
              _label('Muhimlik'.tr),
              _dropdown<String>(
                value: priority,
                items: HkTaskModel.priorities
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text(
                          HkTaskModel.priorityLabel(p),
                          style: AppTextStyles.bodyMd(),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => priority = v ?? 'MEDIUM'),
              ),
              const SizedBox(height: 16),
              _label('Mas\'ul xodim'.tr),
              _dropdown<String>(
                value: assigneeId,
                hint: 'Biriktirilmagan'.tr,
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(
                      'Biriktirilmagan'.tr,
                      style: AppTextStyles.bodyMd(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  ...controller.employees.map(
                    (s) => DropdownMenuItem(
                      value: s.id,
                      child: Text(s.name, style: AppTextStyles.bodyMd()),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => assigneeId = v),
              ),
              const SizedBox(height: 16),
              _label('Sana'.tr),
              Pressable(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  decoration: _fieldDecoration(),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.event_rounded,
                        size: 20,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 10),
                      Text(_dateLabel, style: AppTextStyles.bodyMd()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _label('Izoh'.tr),
              TextField(
                controller: notesController,
                maxLines: 3,
                style: AppTextStyles.bodyMd(),
                decoration: InputDecoration(
                  hintText: 'Qo\'shimcha izoh yozish...'.tr,
                  hintStyle: AppTextStyles.bodyMd(color: AppColors.outline),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLowest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.outlineVariant,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.outlineVariant,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _buildSubmitButton(),
              const SizedBox(height: 20),
            ],
          );
        }),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text.toUpperCase(), style: AppTextStyles.labelCaps()),
  );

  BoxDecoration _fieldDecoration() => BoxDecoration(
    color: AppColors.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: AppColors.outlineVariant),
  );

  Widget _dropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _fieldDecoration(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: hint == null
              ? null
              : Text(
                  hint,
                  style: AppTextStyles.bodyMd(color: AppColors.outline),
                ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.onSurfaceVariant,
          ),
          borderRadius: BorderRadius.circular(14),
          dropdownColor: AppColors.surfaceContainerLowest,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: scheduledDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => scheduledDate = picked);
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      final submitting = controller.isSubmitting.value;
      return Pressable(
        onTap: submitting ? null : _submit,
        child: AnimatedContainer(
          duration: AppMotion.base,
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: submitting
                  ? [AppColors.outlineVariant, AppColors.outlineVariant]
                  : const [
                      AppColors.primaryContainer,
                      AppColors.secondaryContainer,
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: submitting
                ? null
                : AppShadows.glow(AppColors.primary, alpha: 0.3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (submitting)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.onPrimary,
                  ),
                )
              else
                const Icon(Icons.add_task_rounded, color: AppColors.onPrimary),
              const SizedBox(width: 8),
              Text(
                submitting ? 'Yaratilmoqda...'.tr : 'Vazifa yaratish'.tr,
                style: AppTextStyles.bodyLg(color: AppColors.onPrimary),
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _submit() async {
    if (roomId == null) {
      Get.snackbar(
        'Xatolik'.tr,
        'Iltimos, xonani tanlang'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorContainer,
        colorText: AppColors.onErrorContainer,
      );
      return;
    }
    // Filial TANLANGAN XONANING O'ZIDAN olinadi — boshqa filial xonasiga
    // vazifa noto'g'ri filial bilan yaratilib qolmasin
    final matching = controller.rooms.where((r) => r.id == roomId).toList();
    final branch = (matching.isNotEmpty ? matching.first.branchId : null) ??
        branchId ??
        (controller.branches.length == 1
            ? controller.branches.first.id
            : null);
    if (branch == null) {
      Get.snackbar(
        'Xatolik'.tr,
        'Filialni tanlang'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorContainer,
        colorText: AppColors.onErrorContainer,
      );
      return;
    }

    final success = await controller.createTask(
      branchId: branch,
      roomId: roomId!,
      taskType: taskType,
      priority: priority,
      assignedTo: assigneeId,
      notes: notesController.text.trim().isEmpty
          ? null
          : notesController.text.trim(),
      scheduledDate: _dateLabel,
    );
    if (success) Get.back();
  }
}
