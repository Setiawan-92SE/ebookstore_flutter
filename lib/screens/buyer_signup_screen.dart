import 'package:flutter/material.dart';
import '../database/database.helper.dart';
import '../models/user.dart';
import 'main_buyer_screen.dart';

class BuyerSignupScreen extends StatefulWidget {
  const BuyerSignupScreen({super.key});

  @override
  State<BuyerSignupScreen> createState() => _BuyerSignupScreenState();
}

class _BuyerSignupScreenState extends State<BuyerSignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper();
  bool _isLoading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final existing = await _db.getUserByEmail(_emailCtrl.text.trim());
      if (existing != null) {
        _showError('Email sudah terdaftar.');
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final user = User(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
        role: 'buyer',
        createdAt: DateTime.now().toIso8601String(),
      );
      final id = await _db.insertUser(user);
      if (!mounted) return;
      if (id > 0) {
        user.id = id;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainBuyerScreen(user: user)));
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        foregroundColor: Colors.white,
        title: const Text('Daftar Buyer', style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Icon(Icons.person_add, size: 64, color: Colors.blueAccent),
                const SizedBox(height: 32),
                _buildField(_nameCtrl, 'Nama', 'Masukkan nama lengkap', Icons.person_outline, false, null),
                const SizedBox(height: 16),
                _buildField(_emailCtrl, 'Email', 'Masukkan email', Icons.email_outlined, false, null),
                const SizedBox(height: 16),
                _buildField(_passCtrl, 'Password', 'Min. 6 karakter', Icons.lock_outlined, true, (v) {
                  if (v!.isEmpty) return 'Password wajib diisi';
                  if (v.length < 6) return 'Minimal 6 karakter';
                  return null;
                }),
                const SizedBox(height: 16),
                _buildField(_confirmCtrl, 'Konfirmasi Password', 'Ulangi password', Icons.lock_outlined, true, (v) {
                  if (v != _passCtrl.text) return 'Password tidak cocok';
                  return null;
                }),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('DAFTAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, String hint, IconData icon, bool obscure, String? Function(String?)? validator) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure && _obscure,
      style: const TextStyle(color: Colors.white),
      validator: validator ?? (v) => v!.isEmpty ? '$label wajib diisi' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.blueAccent),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        suffixIcon: obscure
            ? IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white38),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.blueAccent)),
      ),
    );
  }
}
