import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart'; // make sure you created ApiService

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<String> alarmTones = ['alarm1.mp3', 'alarm2.mp3', 'alarm3.wav'];
  String selectedTone = '';
  double volume = 1.0;
  DateTime? scheduledDate;
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedTone = prefs.getString('alarmTone') ?? alarmTones[0];
      volume = prefs.getDouble('alarmVolume') ?? 1.0;
      int? savedDate = prefs.getInt('alarmDate');
      if (savedDate != null) {
        scheduledDate = DateTime.fromMillisecondsSinceEpoch(savedDate);
      }
    });
  }

  Future<void> _savePrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('alarmTone', selectedTone);
    prefs.setDouble('alarmVolume', volume);
    if (scheduledDate != null) {
      prefs.setInt('alarmDate', scheduledDate!.millisecondsSinceEpoch);
    }
  }

  void _previewSound() {
    audioPlayer.setVolume(volume);
    audioPlayer.play(AssetSource(selectedTone));
  }

  Future<void> _pickDateTime() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          scheduledDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });

        // Save preferences locally
        _savePrefs();

        // Save event to backend
        final event = {
          "title": "Alarm Event", // later we can make this user-input
          "date": scheduledDate!.toIso8601String(),
          "tone": selectedTone,
        };

        try {
          await ApiService.addEvent(event);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Event saved to backend ✅")),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to save event ❌: $e")),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alarm Settings')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Tone selector
            DropdownButton<String>(
              value: selectedTone,
              items: alarmTones
                  .map((tone) =>
                  DropdownMenuItem(value: tone, child: Text(tone)))
                  .toList(),
              onChanged: (tone) {
                setState(() => selectedTone = tone!);
                _savePrefs();
              },
            ),
            // Volume slider
            Slider(
              value: volume,
              min: 0,
              max: 1,
              divisions: 10,
              label: 'Volume: ${(volume * 100).toStringAsFixed(0)}%',
              onChanged: (v) {
                setState(() => volume = v);
                _savePrefs();
              },
            ),
            ElevatedButton(
              onPressed: _previewSound,
              child: const Text('Preview Alarm Sound'),
            ),
            ElevatedButton(
              onPressed: _pickDateTime,
              child: const Text('Pick Date & Time + Save Event'),
            ),
          ],
        ),
      ),
    );
  }
}
