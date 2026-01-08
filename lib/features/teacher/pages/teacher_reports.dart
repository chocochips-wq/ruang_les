import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/colors.dart';
import '../widgets/teacher_app_bar.dart';
import '../providers/teacher_provider.dart';
import '../../../core/models/student_model.dart';
// import '../../../core/models/session_model.dart';

class PengajarNilai extends StatefulWidget {
  const PengajarNilai({super.key});

  @override
  State<PengajarNilai> createState() => _PengajarNilaiState();
}

class _PengajarNilaiState extends State<PengajarNilai> {
  int _selectedMenuIndex = 4;

  @override
  Widget build(BuildContext context) {
    return TeacherScaffold(
      title: 'Laporan Anak',
      selectedMenuIndex: _selectedMenuIndex,
      onMenuSelected: (index) {
        setState(() => _selectedMenuIndex = index);
      },
      onNotificationTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifikasi')),
        );
      },
      body: Consumer<TeacherProvider>(
        builder: (context, teacherProvider, child) {
          if (teacherProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final students = teacherProvider.students;

          if (students.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_ind_outlined,
                      size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada siswa terdaftar',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              return _buildSiswaCard(students[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildSiswaCard(StudentModel siswa) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage:
                siswa.avatarUrl != null ? NetworkImage(siswa.avatarUrl!) : null,
            child: siswa.avatarUrl == null
                ? Text(
                    siswa.fullName.isNotEmpty
                        ? siswa.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: AppColors.primary),
                  )
                : null,
          ),
          title: Text(
            siswa.fullName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          subtitle: Text(
            'Kelas: ${siswa.gradeLevel}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.star_rounded,
                    'Total Poin',
                    '${siswa.totalPoints} Poin',
                    Colors.orange,
                  ),
                  _buildDetailRow(
                    Icons.school_rounded,
                    'Level Belajar',
                    'Level ${siswa.learningLevel}',
                    Colors.blue,
                  ),
                  _buildDetailRow(
                    Icons.verified_rounded,
                    'Badges',
                    siswa.badges.isEmpty ? '-' : '${siswa.badges.length} Badge',
                    Colors.purple,
                  ),
                  _buildDetailRow(
                    Icons.calendar_today_rounded,
                    'Bergabung',
                    '${siswa.createdAt.day}/${siswa.createdAt.month}/${siswa.createdAt.year}',
                    Colors.grey,
                  ),
                  // Placeholder for "Catatan" feature if requested later
                  // const SizedBox(height: 8),
                  // SizedBox(
                  //   width: double.infinity,
                  //   child: OutlinedButton.icon(
                  //     onPressed: () {
                  //        ScaffoldMessenger.of(context).showSnackBar(
                  //          const SnackBar(content: Text('Fitur edit catatan akan segera hadir')),
                  //        );
                  //     },
                  //     icon: const Icon(Icons.edit_note, size: 18),
                  //     label: const Text('Lihat/Edit Catatan'),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      IconData icon, String label, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
