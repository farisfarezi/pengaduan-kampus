import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'add_report_page.dart';
import 'auth_service.dart';
import 'database_helper.dart';
import 'detail_page.dart';
import 'login_page.dart';
import 'report.dart';

Color statusColor(String s) {
  switch (s) {
    case 'Diproses':
      return Colors.orange;
    case 'Selesai':
      return Colors.green;
    default:
      return Colors.grey;
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _user = AuthService.currentUser!;
  String? _filter;
  late Future<List<Report>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() => _future =
        DatabaseHelper.instance.getAll(userId: _user.isAdmin ? null : _user.id));
  }

  Future<void> _open(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    _reload();
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false);
  }

  Widget _stat(String label, int n, Color c, IconData icon) => Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Icon(icon, color: c),
                const SizedBox(height: 4),
                Text('$n',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                Text(label, style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_user.isAdmin ? 'Dashboard Admin' : 'Beranda',
                style: const TextStyle(fontSize: 18)),
            Text('Halo, ${_user.name}',
                style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              tooltip: 'Keluar'),
        ],
      ),
      body: FutureBuilder<List<Report>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final all = snap.data!;
          int count(String s) => all.where((r) => r.status == s).length;
          final list =
              _filter == null ? all : all.where((r) => r.status == _filter).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    _stat('Total', all.length, Colors.indigo, Icons.description),
                    _stat('Menunggu', count('Menunggu'), Colors.grey,
                        Icons.hourglass_empty),
                    _stat('Diproses', count('Diproses'), Colors.orange,
                        Icons.autorenew),
                    _stat('Selesai', count('Selesai'), Colors.green,
                        Icons.check_circle),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      _user.isAdmin ? 'Semua Laporan' : 'Laporan Saya',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
              ),
              SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  children: [
                    for (final s in [null, ...Report.statuses])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(s ?? 'Semua'),
                          selected: _filter == s,
                          onSelected: (_) => setState(() => _filter = s),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: list.isEmpty
                    ? const Center(child: Text('Belum ada laporan'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: list.length,
                        itemBuilder: (_, i) {
                          final r = list[i];
                          final date =
                              DateFormat('d MMM yyyy').format(r.createdAt);
                          return Card(
                            child: ListTile(
                              leading: r.photoPath != null &&
                                      File(r.photoPath!).existsSync()
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(File(r.photoPath!),
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover),
                                    )
                                  : const Icon(Icons.report_problem, size: 40),
                              title: Text(r.title),
                              subtitle: Text(
                                  '${r.category} • $date${_user.isAdmin && r.userName != null ? "\nOleh ${r.userName}" : ""}'),
                              isThreeLine: _user.isAdmin,
                              trailing: Chip(
                                label: Text(r.status,
                                    style:
                                        const TextStyle(color: Colors.white)),
                                backgroundColor: statusColor(r.status),
                              ),
                              onTap: () => _open(DetailPage(
                                  report: r, isAdmin: _user.isAdmin)),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _user.isAdmin
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _open(const AddReportPage()),
              icon: const Icon(Icons.add),
              label: const Text('Lapor'),
            ),
    );
  }
}
