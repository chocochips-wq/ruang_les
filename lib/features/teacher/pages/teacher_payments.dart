import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // import provider
import 'package:intl/intl.dart'; // import intl for date formatting
import '../../../core/utils/colors.dart';
import '../widgets/teacher_app_bar.dart';
import '../providers/teacher_provider.dart';
import '../../../core/models/student_model.dart';
import '../../../core/models/payment_model.dart';

class PengajarPembayaran extends StatefulWidget {
  const PengajarPembayaran({super.key});

  @override
  State<PengajarPembayaran> createState() => _PengajarPembayaranState();
}

class _PengajarPembayaranState extends State<PengajarPembayaran> {
  int _selectedMenuIndex = 5;

  @override
  Widget build(BuildContext context) {
    return TeacherScaffold(
      title: 'Riwayat Pembayaran',
      selectedMenuIndex: _selectedMenuIndex,
      onMenuSelected: (index) => setState(() => _selectedMenuIndex = index),
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

          // Filter only paid payments
          final paidPayments = teacherProvider.classPayments
              .where((p) => p.status == 'paid')
              .toList();

          // Sort by paidAt descending (newest first)
          paidPayments.sort((a, b) {
            final aTime = a.paidAt ?? DateTime(2000);
            final bTime = b.paidAt ?? DateTime(2000);
            return bTime.compareTo(aTime);
          });

          if (paidPayments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment_outlined,
                      size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada pembayaran lunas',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: paidPayments.length,
            itemBuilder: (context, index) {
              final payment = paidPayments[index];
              final student = teacherProvider.students.firstWhere(
                (s) => s.studentId == payment.studentId,
                orElse: () => StudentModel(
                  userId: 'unknown',
                  studentId: 'unknown',
                  fullName: 'Unknown Student',
                  nickname: '',
                  gradeLevel: '',
                  createdAt: DateTime.now(),
                ),
              );

              return _buildPembayaranCard(payment, student);
            },
          );
        },
      ),
    );
  }

  Widget _buildPembayaranCard(PaymentModel payment, StudentModel student) {
    final dateFormatter = DateFormat('dd MMMM yyyy');
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green.withOpacity(0.1),
            child: const Icon(Icons.check, color: Colors.green),
          ),
          title: Text(
            student.fullName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          subtitle: Text(
            'Tenggat: ${dateFormatter.format(payment.dueDate)}',
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
                      'Jumlah', currencyFormatter.format(payment.amount)),
                  _buildDetailRow(
                      'Tanggal Bayar',
                      payment.paidAt != null
                          ? dateFormatter.format(payment.paidAt!)
                          : '-'),
                  _buildDetailRow(
                      'Sesi Terbayar', '${payment.sessionsPaid} Sesi'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
