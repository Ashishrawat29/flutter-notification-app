import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';

import 'alarm_model.dart';

class AlarmConstants {
  static const List<String> soundAssets = [
    'assets/sound1.mp3',
    'assets/sound2.mp3',
  ];
}

class AlarmFormScreen extends StatefulWidget {
  final Alarm? alarm;

  const AlarmFormScreen({super.key, this.alarm});

  @override
  State<AlarmFormScreen> createState() => _AlarmFormScreenState();
}

class _AlarmFormScreenState extends State<AlarmFormScreen> {
  late DateTime _selectedDateTime;
  String _selectedSound = AlarmConstants.soundAssets[0];
  double _volume = 1.0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _labelController = TextEditingController();
  RecurringType _recurring = RecurringType.none;

  @override
  void initState() {
    super.initState();
    if (widget.alarm != null) {
      _selectedDateTime = widget.alarm!.dateTime;
      _selectedSound = widget.alarm!.sound;
      _volume = widget.alarm!.volume;
      _labelController.text = widget.alarm!.label;
      _recurring = widget.alarm!.recurring;
    } else {
      _selectedDateTime = DateTime.now().add(const Duration(minutes: 1));
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (date == null) return;
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _previewSound() async {
    try {
      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.play(AssetSource(_selectedSound.split('/').last));
    } catch (_) {}
  }

  bool get _isDateTimeInPast => _selectedDateTime.isBefore(DateTime.now());

  void _save() {
    if (_isDateTimeInPast) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a future date/time')));
      return;
    }

    Navigator.pop(
      context,
      Alarm(
        id: widget.alarm?.id ?? DateTime.now().millisecondsSinceEpoch,
        dateTime: _selectedDateTime,
        sound: _selectedSound,
        volume: _volume,
        enabled: true,
        label: _labelController.text.trim(),
        recurring: _recurring,
      ),
    );
  }

  String _formatDateTime(DateTime datetime) {
    final formatter = DateFormat('MMM dd, yyyy hh:mm a');
    return formatter.format(datetime.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: Text(widget.alarm == null ? 'Add Alarm' : 'Edit Alarm')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextButton.icon(
              onPressed: _pickDateTime,
              icon: const Icon(Icons.calendar_today),
              label: Text('Pick Date/Time: ${_formatDateTime(_selectedDateTime)}'),
            ),
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Alarm Label (optional)',
                prefixIcon: Icon(Icons.label),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Alarm Sound'),
              value: _selectedSound,
              items: AlarmConstants.soundAssets.map((sound) {
                return DropdownMenuItem<String>(
                  value: sound,
                  child: Text(sound.split('/').last),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedSound = val);
              },
            ),
            ElevatedButton(
              onPressed: _previewSound,
              child: const Text('Preview Sound'),
            ),
            const SizedBox(height: 20),
            Text('Volume: ${(100 * _volume).round()}%'),
            Slider(
              value: _volume,
              min: 0,
              max: 1,
              divisions: 10,
              label: '${(100 * _volume).round()}%',
              onChanged: (val) => setState(() => _volume = val),
            ),
            DropdownButtonFormField<RecurringType>(
              decoration: const InputDecoration(labelText: 'Recurring'),
              value: _recurring,
              items: RecurringType.values.map((rec) {
                return DropdownMenuItem<RecurringType>(
                  value: rec,
                  child: Text(rec.name[0].toUpperCase() + rec.name.substring(1)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _recurring = val);
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isDateTimeInPast ? null : _save,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Save Alarm'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
