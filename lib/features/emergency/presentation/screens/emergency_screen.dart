import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionmate/core/constants/app_constants.dart';
import 'package:visionmate/core/constants/semantic_labels.dart';
import 'package:visionmate/core/theme/app_colors.dart';
import 'package:visionmate/shared/widgets/accessible_header.dart';
import 'package:visionmate/features/emergency/presentation/controllers/emergency_controller.dart';

class EmergencyScreen extends ConsumerStatefulWidget {
  const EmergencyScreen({super.key});

  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen> {
  void _showAddContactDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        title: const Text('Add Emergency Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: AppColors.warmWhite),
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: AppColors.warmWhite),
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                ref.read(emergencyControllerProvider.notifier).addContact(
                      nameController.text,
                      phoneController.text,
                    );
                Navigator.pop(dialogCtx);
              }
            },
            child: const Text('Save Contact'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(emergencyControllerProvider);
    final controller = ref.read(emergencyControllerProvider.notifier);

    return Scaffold(
      appBar: const AccessibleHeader(
        title: 'Emergency Assistance',
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: state.isAlarmActive
                      ? AppColors.crimson.withValues(alpha: 0.2)
                      : AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: state.isAlarmActive ? AppColors.crimson : AppColors.surfaceBorder,
                    width: 1.5,
                  ),
                ),
                child: Semantics(
                  liveRegion: true,
                  label: state.statusText,
                  child: Text(
                    state.statusText,
                    style: TextStyle(
                      color: state.isAlarmActive ? AppColors.crimson : AppColors.warmWhite,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                flex: 3,
                child: Center(
                  child: Semantics(
                    button: true,
                    label: state.isAlarmActive
                        ? 'Stop Emergency SOS Alarm'
                        : SemanticLabels.emergencyButton,
                    child: SizedBox(
                      width: 210,
                      height: 210,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: state.isAlarmActive ? AppColors.amberFocus : AppColors.crimson,
                          foregroundColor: state.isAlarmActive ? AppColors.obsidian : AppColors.warmWhite,
                          shape: const CircleBorder(),
                          elevation: 6,
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          if (state.isAlarmActive) {
                            controller.stopSos();
                          } else {
                            controller.triggerSos();
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              state.isAlarmActive ? Icons.stop_rounded : Icons.emergency_rounded,
                              size: 64,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              state.isAlarmActive ? 'STOP ALARM' : 'SOS BEACON',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Emergency Contacts',
                    style: theme.textTheme.titleMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.amberFocus),
                    tooltip: 'Add emergency contact',
                    onPressed: _showAddContactDialog,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                flex: 2,
                child: ListView.builder(
                  itemCount: state.contacts.length,
                  itemBuilder: (context, index) {
                    final contact = state.contacts[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.phone_outlined, size: 20, color: AppColors.amberFocus),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  contact.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.warmWhite,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  contact.phoneNumber,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.crimson),
                            tooltip: 'Remove contact ${contact.name}',
                            onPressed: () => controller.removeContact(contact.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
