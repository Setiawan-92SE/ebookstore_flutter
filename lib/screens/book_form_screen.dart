import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/book.dart';
import 'package:ebookstore/database/database.helper.dart';

/// Layar Form Buku — digunakan untuk Tambah & Ubah data
/// Setara dengan tampilan input di slide "Insert Data Baru" & "Ubah Data"
class BookFormScreen extends StatefulWidget {
  final Book? book; // null = mode Tambah, non-null = mode Ubah

  const BookFormScreen({super.key, this.book});

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dbHelper = DatabaseHelper();

  // Controller untuk setiap field (setara EditText di Android)
  late TextEditingController _judulCtrl;
  late TextEditingController _penulisCtrl;
  late TextEditingController _hargaCtrl;
  late TextEditingController _deskripsiCtrl;
  late TextEditingController _stokCtrl;

  String _selectedKategori = 'Fiksi';
  bool _isLoading = false;

  final List<String> _kategoriList = [
    'Fiksi',
    'Non-Fiksi',
    'Pengembangan Diri',
    'Teknologi',
    'Bisnis',
    'Sains',
    'Sejarah',
    'Agama',
  ];

  bool get _isEditMode => widget.book != null;

  @override
  void initState() {
    super.initState();
    // Isi form jika mode Ubah
    _judulCtrl = TextEditingController(text: widget.book?.judul ?? '');
    _penulisCtrl = TextEditingController(text: widget.book?.penulis ?? '');
    _hargaCtrl = TextEditingController(
      text: widget.book?.harga.toStringAsFixed(0) ?? '',
    );
    _deskripsiCtrl = TextEditingController(text: widget.book?.deskripsi ?? '');
    _stokCtrl = TextEditingController(
      text: widget.book?.stok.toString() ?? '0',
    );
    if (widget.book != null) {
      _selectedKategori = widget.book!.kategori;
    }
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _penulisCtrl.dispose();
    _hargaCtrl.dispose();
    _deskripsiCtrl.dispose();
    _stokCtrl.dispose();
    super.dispose();
  }

  // ─── Simpan / Ubah Data ───────────────────────────────────────────────────
  Future<void> _simpanData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final book = Book(
        id: widget.book?.id,
        judul: _judulCtrl.text.trim(),
        penulis: _penulisCtrl.text.trim(),
        kategori: _selectedKategori,
        harga: double.parse(_hargaCtrl.text.trim()),
        deskripsi: _deskripsiCtrl.text.trim(),
        stok: int.parse(_stokCtrl.text.trim()),
      );

      int result;
      if (_isEditMode) {
        // UPDATE — memperbarui baris pada database
        result = await _dbHelper.updateBook(book);
      } else {
        // INSERT — menambahkan baris ke database
        result = await _dbHelper.insertBook(book);
      }

      if (!mounted) return;

      if (result > 0) {
        _showSnackBar(
          _isEditMode
              ? 'Buku berhasil diperbarui!'
              : 'Buku berhasil ditambahkan!',
          isSuccess: true,
        );
        Navigator.pop(context, true); // Kembalikan true = ada perubahan
      } else {
        _showSnackBar('Gagal menyimpan data.', isSuccess: false);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isSuccess: false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Hapus Data ───────────────────────────────────────────────────────────
  Future<void> _hapusData() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Hapus Buku', style: TextStyle(color: Colors.white)),
        content: Text(
          'Yakin ingin menghapus "${widget.book!.judul}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi != true || !mounted) return;

    setState(() => _isLoading = true);
    try {
      // DELETE — menghapus baris dari database
      final result = await _dbHelper.deleteBook(widget.book!.id!);
      if (!mounted) return;
      if (result > 0) {
        _showSnackBar('Buku berhasil dihapus!', isSuccess: true);
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnackBar('Gagal menghapus: $e', isSuccess: false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? const Color(0xFFB8973A) : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        foregroundColor: Colors.white,
        title: Text(
          _isEditMode ? 'Ubah Buku' : 'Tambah Buku',
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: _isLoading ? null : _hapusData,
              tooltip: 'Hapus Buku',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFB8973A)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Judul Buku'),
                    _buildTextField(
                      controller: _judulCtrl,
                      hint: 'Masukkan judul buku',
                      validator: (v) => v!.isEmpty ? 'Judul wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Nama Penulis'),
                    _buildTextField(
                      controller: _penulisCtrl,
                      hint: 'Masukkan nama penulis',
                      validator: (v) =>
                          v!.isEmpty ? 'Penulis wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Kategori'),
                    _buildDropdown(),
                    const SizedBox(height: 16),

                    _buildLabel('Harga (Rp)'),
                    _buildTextField(
                      controller: _hargaCtrl,
                      hint: 'Contoh: 85000',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v!.isEmpty) return 'Harga wajib diisi';
                        if (double.tryParse(v) == null)
                          return 'Harga tidak valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Stok'),
                    _buildTextField(
                      controller: _stokCtrl,
                      hint: 'Jumlah stok tersedia',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) => v!.isEmpty ? 'Stok wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Deskripsi'),
                    _buildTextField(
                      controller: _deskripsiCtrl,
                      hint: 'Deskripsi singkat buku...',
                      maxLines: 4,
                      validator: (v) =>
                          v!.isEmpty ? 'Deskripsi wajib diisi' : null,
                    ),
                    const SizedBox(height: 32),

                    // Tombol Simpan / Ubah
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _simpanData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB8973A),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          _isEditMode ? 'UBAH' : 'SIMPAN',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tombol Batal
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'BATAL',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFB8973A),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFB8973A), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedKategori,
          isExpanded: true,
          dropdownColor: const Color(0xFF1E1E1E),
          style: const TextStyle(color: Colors.white),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFB8973A)),
          items: _kategoriList
              .map((k) => DropdownMenuItem(value: k, child: Text(k)))
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => _selectedKategori = value);
          },
        ),
      ),
    );
  }
}
