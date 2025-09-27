import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'alarm_form_screen.dart';
import 'alarm_model.dart';
import 'alarm_provider.dart';
import 'notification_service.dart';

class AlarmListScreen extends StatefulWidget {
  const AlarmListScreen({Key? key}) : super(key: key);

  @override
  State<AlarmListScreen> createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends State<AlarmListScreen> {
  int generateUniqueId() => DateTime.now().millisecondsSinceEpoch;

  Future<void> _addOrEditAlarm([Alarm? alarm]) async {
    final result = await Navigator.push<Alarm?>(
      context,
      MaterialPageRoute(
        builder: (context) => AlarmFormScreen(alarm: alarm),
      ),
    );

    if (result != null) {
      final alarmProvider = context.read<AlarmProvider>();
      if (alarm == null) {
        final newAlarm = result.copyWith(id: generateUniqueId());
        alarmProvider.addAlarm(newAlarm);
        await NotificationService().scheduleAlarmNotification(newAlarm);
      } else {
        final updatedAlarm = result.id == alarm.id ? result : result.copyWith(id: alarm.id);
        alarmProvider.updateAlarm(updatedAlarm);
        await NotificationService().scheduleAlarmNotification(updatedAlarm);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Alarm ${alarm == null ? 'added' : 'updated'}')),
        );
      }
    }
  }

  Future<void> _deleteAlarm(Alarm alarm) async {
    try {
      print('Deleting alarm with ID: ${alarm.id}');
      final alarmProvider = context.read<AlarmProvider>();
      await NotificationService().cancelNotification(alarm.id);
      print('Notification cancelled for ID: ${alarm.id}');
      alarmProvider.removeAlarm(alarm.id);
      print('Alarm removed from provider');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alarm deleted')),
        );
      }
    } catch (e) {
      print('Failed to delete alarm: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete alarm: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarm Manager'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/image1.png',
              fit: BoxFit.cover,
            ),
          ),
          Consumer<AlarmProvider>(
            builder: (context, alarmProvider, _) {
              final alarms = alarmProvider.alarms;
              if (alarms.isEmpty) {
                return const Center(
                  child: Text(
                    'No alarms set. Tap + to add one.',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              return ListView.builder(
                itemCount: alarms.length,
                itemBuilder: (context, index) {
                  final alarm = alarms[index];
                  return ListTile(
                    title: Text(
                      alarm.label.isNotEmpty ? alarm.label : 'Alarm',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      alarm.dateTime.toLocal().toString(),
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: alarm.enabled,
                          onChanged: (val) async {
                            final updated = alarm.copyWith(enabled: val);
                            alarmProvider.updateAlarm(updated);
                            if (val) {
                              await NotificationService().scheduleAlarmNotification(updated);
                            } else {
                              await NotificationService().cancelNotification(updated.id);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: () => _deleteAlarm(alarm),
                        ),
                      ],
                    ),
                    onTap: () => _addOrEditAlarm(alarm),
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditAlarm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
