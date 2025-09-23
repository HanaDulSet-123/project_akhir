import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tugas_ujk/utils/theme.dart';
import 'package:tugas_ujk/views/about.dart';

class SettingsPresensi extends StatefulWidget {
  static const id = '/setting';
  const SettingsPresensi({super.key});

  @override
  State<SettingsPresensi> createState() => _SettingsPresensiState();
}

class _SettingsPresensiState extends State<SettingsPresensi> {
  bool _notifikasi = true;
  String _bahasa = "Indonesia";

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pengaturan",
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // === Tema Aplikasi ===
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(Icons.color_lens, color: colorScheme.primary),
              title: const Text("Tema Aplikasi"),
              subtitle: Text(_getThemeText(themeProvider.themeMode)),
              trailing: DropdownButton<ThemeMode>(
                value: themeProvider.themeMode,
                underline: const SizedBox(),
                onChanged: (mode) {
                  if (mode != null) {
                    themeProvider.setThemeMode(mode);
                  }
                },
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text("Mengikuti Sistem"),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text("Terang"),
                  ),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text("Gelap")),
                ],
              ),
            ),
          ),

          // === Notifikasi ===
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              value: _notifikasi,
              activeColor: colorScheme.primary,
              title: const Text("Notifikasi"),
              subtitle: const Text("Terima notifikasi presensi"),
              onChanged: (value) {
                setState(() {
                  _notifikasi = value;
                });
              },
            ),
          ),

          // === Bahasa ===
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(Icons.language, color: colorScheme.primary),
              title: const Text("Bahasa"),
              subtitle: Text(_bahasa),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _showBahasaDialog,
            ),
          ),

          // === Privasi ===
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(Icons.info, color: colorScheme.primary),
              title: const Text("Tentang Aplikasi"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // ScaffoldMessenger.of(context).showSnackBar(
                //   const SnackBar(content: Text("Fitur akan datang!")),
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AboutAPPScreen()),
                );
              },
            ),
          ),

          const SizedBox(height: 30),

          // === Tombol Simpan ===
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Pengaturan berhasil disimpan!")),
              );
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Simpan",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 12),

          // === Tombol Reset ===
          OutlinedButton(
            onPressed: () {
              setState(() {
                _notifikasi = true;
                _bahasa = "Indonesia";
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Pengaturan berhasil di-reset ke default!"),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Reset Pengaturan",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showBahasaDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Pilih Bahasa"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text("Indonesia"),
                value: "Indonesia",
                groupValue: _bahasa,
                onChanged: (value) {
                  setState(() {
                    _bahasa = value!;
                  });
                  Navigator.pop(context);
                },
              ),
              // RadioListTile<String>(
              //   title: const Text("English"),
              //   value: "English",
              //   groupValue: _bahasa,
              //   onChanged: (value) {
              //     setState(() {
              //       _bahasa = value!;
              //     });
              //     Navigator.pop(context);
              //   },
              // ),
            ],
          ),
        );
      },
    );
  }

  String _getThemeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return "Terang";
      case ThemeMode.dark:
        return "Gelap";
      case ThemeMode.system:
        return "Mengikuti Sistem";
      default:
        return "Mengikuti Sistem";
    }
  }
}
