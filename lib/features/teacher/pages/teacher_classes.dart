import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/colors.dart';
import '../widgets/teacher_app_bar.dart';
import '../providers/teacher_provider.dart';
import '../../../core/models/class_model.dart';
import 'teacher_class_detail.dart';

class PengajarKelas extends StatefulWidget {
  const PengajarKelas({super.key});

  @override
  State<PengajarKelas> createState() => _PengajarKelasState();
}

class _PengajarKelasState extends State<PengajarKelas> {
  int _selectedMenuIndex = 1; // Index 1 for 'Kelas'

  @override
  Widget build(BuildContext context) {
    return TeacherScaffold(
      title: 'Kelas Saya',
      selectedMenuIndex: _selectedMenuIndex,
      onMenuSelected: (index) => setState(() => _selectedMenuIndex = index),
      onNotificationTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifikasi')),
        );
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddClassDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<TeacherProvider>(
        builder: (context, teacherProvider, child) {
          if (teacherProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final classes = teacherProvider.classes;

          if (classes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.class_outlined,
                      size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada kelas',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddClassDialog(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Buat Kelas Baru'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              return _buildClassCard(classes[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildClassCard(ClassModel classModel) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classModel.className,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${classModel.gradeLevel} • ${classModel.type}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.class_,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow(Icons.schedule, 'Jadwal', classModel.schedule),
            _buildDetailRow(
                Icons.people, 'Murid', '${classModel.studentIds.length} Siswa'),
            _buildDetailRow(Icons.monetization_on, 'Biaya',
                'Rp ${classModel.pricePerSession} / sesi'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeacherClassDetailPage(
                        classModel: classModel,
                      ),
                    ),
                  );
                },
                child: const Text('Lihat Detail'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddClassDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final gradeController = TextEditingController();
    final scheduleController = TextEditingController();
    final maxStudentsController = TextEditingController(text: '10');
    final priceController = TextEditingController(text: '0');
    final totalSessionsController = TextEditingController(text: '0');
    String selectedType = 'regular'; // default

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Buat Kelas Baru'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration:
                          const InputDecoration(labelText: 'Nama Kelas *'),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: gradeController,
                      decoration: const InputDecoration(
                          labelText: 'Jenjang *', hintText: 'Contoh: SD Kelas 1, SMP Kelas 7'),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: scheduleController,
                      decoration: const InputDecoration(
                          labelText: 'Jadwal *', hintText: 'Contoh: Senin 15:00-16:00'),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: 'Tipe Kelas *'),
                      items: const [
                        DropdownMenuItem(
                            value: 'regular', child: Text('Reguler')),
                        DropdownMenuItem(
                            value: 'private', child: Text('Private')),
                        DropdownMenuItem(
                            value: 'semi_private', child: Text('Semi Private')),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setStateDialog(() {
                            selectedType = v;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: maxStudentsController,
                      decoration: const InputDecoration(
                          labelText: 'Maksimal Murid *', hintText: 'Contoh: 10'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Wajib diisi';
                        final num = int.tryParse(v);
                        if (num == null || num <= 0) return 'Harus angka positif';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: priceController,
                      decoration: const InputDecoration(
                          labelText: 'Biaya per Sesi (Rp) *', hintText: 'Contoh: 50000'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Wajib diisi';
                        final num = int.tryParse(v);
                        if (num == null || num < 0) return 'Harus angka >= 0';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: totalSessionsController,
                      decoration: const InputDecoration(
                          labelText: 'Total Sesi *', hintText: 'Contoh: 12'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Wajib diisi';
                        final num = int.tryParse(v);
                        if (num == null || num <= 0) return 'Harus angka positif';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final teacherProvider = context.read<TeacherProvider>();

                    final newClass = ClassModel(
                      className: nameController.text,
                      gradeLevel: gradeController.text,
                      type: selectedType,
                      teacherId: teacherProvider.currentTeacher?.teacherId ??
                          'unknown',
                      maxStudents: int.parse(maxStudentsController.text),
                      pricePerSession: int.parse(priceController.text),
                      totalSessions: int.parse(totalSessionsController.text),
                      schedule: scheduleController.text,
                      createdAt: DateTime.now(),
                    );

                    final success = await teacherProvider.createClass(newClass);

                    if (context.mounted) {
                      Navigator.pop(context);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Kelas berhasil dibuat')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(teacherProvider.error ??
                                  'Gagal membuat kelas')),
                        );
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary),
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }
}
