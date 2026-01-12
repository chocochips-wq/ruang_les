import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_seeding.dart';

/// Dialog untuk membantu developer seed data
/// Gunakan ini untuk development/testing saja
class DataSeededDialog extends StatefulWidget {
  const DataSeededDialog({super.key});

  @override
  State<DataSeededDialog> createState() => _DataSeededDialogState();
}

class _DataSeededDialogState extends State<DataSeededDialog> {
  bool _isLoading = false;
  bool _isClearing = false;
  String? _message;
  Color? _messageColor;

  Future<void> _seedData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMessage('User not found', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      // Get student ID and first class ID from Firestore
      final studentDoc = await FirebaseFirestore.instance
          .collection('students')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (studentDoc.docs.isEmpty) {
        _showMessage('Student data not found', Colors.red);
        return;
      }

      final studentId = studentDoc.docs.first.id;
      
      // Get first class for this student
      final classDoc = await FirebaseFirestore.instance
          .collection('classes')
          .where('students', arrayContains: studentId)
          .limit(1)
          .get();

      final classId = classDoc.docs.isNotEmpty 
          ? classDoc.docs.first.id 
          : null;

      await FirebaseSeeding.seedAllData(studentId, classId: classId);
      _showMessage('Data berhasil ditambahkan! 🎉', Colors.green);
    } catch (e) {
      _showMessage('Error: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMessage('User not found', Colors.red);
      return;
    }

    setState(() {
      _isClearing = true;
      _message = null;
    });

    try {
      // Get student ID from Firestore
      final studentDoc = await FirebaseFirestore.instance
          .collection('students')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (studentDoc.docs.isEmpty) {
        _showMessage('Student data not found', Colors.red);
        return;
      }

      final studentId = studentDoc.docs.first.id;
      await FirebaseSeeding.clearAllData(studentId);
      _showMessage('Data berhasil dihapus!', Colors.green);
    } catch (e) {
      _showMessage('Error: $e', Colors.red);
    } finally {
      setState(() {
        _isClearing = false;
      });
    }
  }

  void _showMessage(String message, Color color) {
    setState(() {
      _message = message;
      _messageColor = color;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _message = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Data Seeding (Development Only)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Gunakan untuk menambah/menghapus dummy data progress dan achievements.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            if (_message != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _messageColor?.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _messageColor!),
                ),
                child: Text(
                  _message!,
                  style: TextStyle(
                    color: _messageColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _seedData,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Seed Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isClearing ? null : _clearData,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Clear Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
