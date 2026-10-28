import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'home_page.dart' show statusColor;
import 'report.dart';

class DetailPage extends StatefulWidget {
  final Report report;
  final bool isAdmin;
  const DetailPage({super.key, required this.report, required this.isAdmin});
  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late String _status = widget.report.status;

  Future<void> _setStatus(String s) async {
    await DatabaseHelper.instance.updateStatus(widget.report.id!, s);
    setState(() => _status = s);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus laporan?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (ok == true) {
      await DatabaseHelper.instance.delete(widget.report.id!);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.report;
    final hasPhoto = r.photoPath != null && File(r.photoPath!).existsSync();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
        actions: [
          if (widget.isAdmin)
            IconButton(onPressed: _delete, icon: const Icon(Icons.delete)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (hasPhoto)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(r.photoPath!),
                  height: 220, fit: BoxFit.cover),
            ),
          const SizedBox(height: 12),
          Text(r.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('${r.category} • ${DateFormat('d MMM yyyy, HH:mm').format(r.createdAt)}'),
          const SizedBox(height: 12),
          Chip(
            label: Text(_status, style: const TextStyle(color: Colors.white)),
            backgroundColor: statusColor(_status),
          ),
          const Divider(height: 32),
          const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(r.description.isEmpty ? '-' : r.description),
          const SizedBox(height: 12),
          const Text('Lokasi', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(r.locationNote),
          if (r.userName != null) ...[
            const SizedBox(height: 12),
            const Text('Pelapor', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(r.userName!),
          ],
          if (r.latitude != null)
            Text('GPS: ${r.latitude!.toStringAsFixed(5)}, ${r.longitude!.toStringAsFixed(5)}'),
          if (widget.isAdmin) ...[
            const Divider(height: 32),
            const Text('Ubah status (Admin)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                for (final s in Report.statuses)
                  ButtonSegment(value: s, label: Text(s))
              ],
              selected: {_status},
              onSelectionChanged: (v) => _setStatus(v.first),
            ),
          ],
        ],
      ),
    );
  }
}
