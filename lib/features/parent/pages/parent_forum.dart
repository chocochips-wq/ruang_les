import 'package:flutter/material.dart';
import '../../../core/utils/colors.dart';
import '../widgets/parent_drawer.dart';
import '../widgets/parent_bottom_nav.dart';

class ForumOrangtua extends StatefulWidget {
  const ForumOrangtua({super.key});

  @override
  State<ForumOrangtua> createState() => _ForumOrangtuaState();
}

class _ForumOrangtuaState extends State<ForumOrangtua> {
  final List<Map<String, dynamic>> _forumPosts = [
    {
      'nama': 'Ibu Siti',
      'waktu': '2 jam yang lalu',
      'judul': 'Tips Mendampingi Anak Belajar Matematika',
      'isi':
          'Halo parents! Saya mau share tips efektif mendampingi anak belajar matematika di rumah. Pertama, buat jadwal rutin...',
      'replies': 5,
      'likes': 12,
      'isOwner': false,
    },
    {
      'nama': 'Pak Budi',
      'waktu': '5 jam yang lalu',
      'judul': 'Rekomendasi Buku Bacaan untuk Anak SD',
      'isi':
          'Ada yang punya rekomendasi buku bacaan yang bagus untuk anak kelas 4 SD? Anak saya mulai suka membaca nih...',
      'replies': 8,
      'likes': 15,
      'isOwner': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Forum Diskusi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Fungsi pencarian
            },
          ),
        ],
      ),
      drawer: const ParentDrawer(),
      body: Column(
        children: [
          // Button Lihat Forum Diskusi
          Padding(
            padding: const EdgeInsets.all(16),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 2,
              child: InkWell(
                onTap: () {
                  _showCreatePostDialog();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline,
                          color: AppColors.primary, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Buat Diskusi Baru',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // List Forum Posts
          Expanded(
            child: _forumPosts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _forumPosts.length,
                    itemBuilder: (context, index) {
                      return _buildForumPostCard(_forumPosts[index], index);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const ParentBottomNav(selectedIndex: 2),
    );
  }

  Widget _buildForumPostCard(Map<String, dynamic> post, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - Avatar & Info
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    post['nama'][0],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['nama'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      post['waktu'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                onPressed: () {
                  _showPostOptions(context, post, index);
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Judul Post
          Text(
            post['judul'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),

          const SizedBox(height: 8),

          // Isi Post
          Text(
            post['isi'],
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 12),

          // Footer - Likes & Replies
          Row(
            children: [
              _buildActionButton(
                icon: Icons.favorite_border,
                label: '${post['likes']}',
                color: Colors.red,
                onTap: () {},
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                label: '${post['replies']} Balasan',
                color: Colors.blue,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.forum_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada diskusi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai diskusi pertama Anda!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _showPostOptions(
      BuildContext context, Map<String, dynamic> post, int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Option: Laporkan (untuk post orang lain)
              if (!post['isOwner'])
                ListTile(
                  leading:
                      const Icon(Icons.flag_outlined, color: Colors.orange),
                  title: const Text(
                    'Laporkan',
                    style: TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showReportDialog(context);
                  },
                ),

              // Option: Edit (hanya untuk post sendiri)
              if (post['isOwner'])
                ListTile(
                  leading: const Icon(Icons.edit_outlined, color: Colors.blue),
                  title: const Text(
                    'Edit',
                    style: TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditPostDialog(post, index);
                  },
                ),

              // Option: Hapus (hanya untuk post sendiri)
              if (post['isOwner'])
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Hapus',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(context, index);
                  },
                ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text(
                'Hapus Diskusi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin menghapus diskusi ini? Tindakan ini tidak dapat dibatalkan.',
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _forumPosts.removeAt(index);
                });
                Navigator.pop(context);

                // Tampilkan snackbar konfirmasi
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Diskusi berhasil dihapus'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'Hapus',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(Icons.flag, color: Colors.orange, size: 26),
              SizedBox(width: 8),
              Text(
                'Laporkan Diskusi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: const Text(
            'Terima kasih atas laporannya. Tim kami akan meninjau konten ini.',
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showEditPostDialog(Map<String, dynamic> post, int index) {
    final TextEditingController judulController =
        TextEditingController(text: post['judul']);
    final TextEditingController isiController =
        TextEditingController(text: post['isi']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Edit Diskusi',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: judulController,
                  decoration: InputDecoration(
                    labelText: 'Judul Diskusi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: isiController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Isi Diskusi',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (judulController.text.isNotEmpty &&
                    isiController.text.isNotEmpty) {
                  setState(() {
                    _forumPosts[index]['judul'] = judulController.text;
                    _forumPosts[index]['isi'] = isiController.text;
                    _forumPosts[index]['waktu'] = 'Baru saja (diedit)';
                  });
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Diskusi berhasil diperbarui'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showCreatePostDialog() {
    final TextEditingController judulController = TextEditingController();
    final TextEditingController isiController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Buat Diskusi Baru',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: judulController,
                  decoration: InputDecoration(
                    labelText: 'Judul Diskusi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: isiController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Isi Diskusi',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Logic untuk menambahkan post baru
                if (judulController.text.isNotEmpty &&
                    isiController.text.isNotEmpty) {
                  setState(() {
                    _forumPosts.insert(0, {
                      'nama': 'Agustina Suraisa',
                      'waktu': 'Baru saja',
                      'judul': judulController.text,
                      'isi': isiController.text,
                      'replies': 0,
                      'likes': 0,
                      'isOwner': true, // Tandai sebagai post milik user
                    });
                  });
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Diskusi berhasil dipublikasikan'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Posting'),
            ),
          ],
        );
      },
    );
  }
}
