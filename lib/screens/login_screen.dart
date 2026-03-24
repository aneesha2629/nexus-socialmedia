import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override ConsumerState<LoginScreen> createState() => _State();
}

class _State extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  bool _isLogin = true, _loading = false, _obscure = true;
  String _error = '';
  final _nameCtrl = TextEditingController();
  final _userCtrl = TextEditingController(text: 'yusuf');
  final _passCtrl = TextEditingController(text: 'password123');
  final _ageCtrl = TextEditingController();
  late AnimationController _ac;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..forward();
  }

  @override
  void dispose() { 
    _nameCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    _ageCtrl.dispose();
    _ac.dispose(); 
    super.dispose(); 
  }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = ''; });
    String? err;
    if (_isLogin) {
      err = await ref.read(authProvider.notifier).login(_userCtrl.text, _passCtrl.text);
    } else {
      final age = int.tryParse(_ageCtrl.text) ?? 0;
      err = await ref.read(authProvider.notifier).register(_nameCtrl.text, _userCtrl.text, _passCtrl.text, age);
    }
    if (!mounted) return;
    setState(() { _loading = false; _error = err ?? ''; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFFFF6B9D)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: SafeArea(child: FadeTransition(
          opacity: CurvedAnimation(parent: _ac, curve: Curves.easeOut),
          child: Center(child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Logo
              Container(width: 76, height: 76,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5)),
                child: const Center(child: Text('◈', style: TextStyle(fontSize: 36, color: Colors.white)))),
              const SizedBox(height: 14),
              const Text('Nexus', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1.5)),
              const Text('Connect with your world', style: TextStyle(fontSize: 13, color: Colors.white70)),
              const SizedBox(height: 32),

              // Card
              Container(padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 32, offset: const Offset(0,12))]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  // Tab
                  Container(decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.all(4),
                    child: Row(children: [
                      _tab('Sign In',  _isLogin,  () => setState(() { _isLogin = true;  _error = ''; })),
                      _tab('Sign Up', !_isLogin,  () => setState(() { _isLogin = false; _error = ''; })),
                    ])),
                  const SizedBox(height: 22),

                  if (!_isLogin) ...[
                    _label('Full Name'),
                    const SizedBox(height: 6),
                    TextField(controller: _nameCtrl, textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(hintText: 'Yusuf Al-Amin', prefixIcon: Icon(Icons.person_outline, size: 20))),
                    const SizedBox(height: 14),
                    
                    _label('Age'),
                    const SizedBox(height: 6),
                    TextField(controller: _ageCtrl, keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: '18', prefixIcon: Icon(Icons.cake_outlined, size: 20))),
                    const SizedBox(height: 14),
                  ],

                  _label('Username'),
                  const SizedBox(height: 6),
                  TextField(controller: _userCtrl, decoration: const InputDecoration(hintText: 'your_username', prefixIcon: Icon(Icons.alternate_email, size: 20))),
                  const SizedBox(height: 14),
                  _label('Password'),
                  const SizedBox(height: 6),
                  TextField(controller: _passCtrl, obscureText: _obscure,
                    decoration: InputDecoration(hintText: '••••••••', prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                        onPressed: () => setState(() => _obscure = !_obscure)))),

                  if (_error.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Text(_error, style: TextStyle(fontSize: 12, color: Colors.red.shade700))),
                  ],
                  const SizedBox(height: 20),

                  SizedBox(height: 48, child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_isLogin ? 'Sign In' : 'Create Account', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  )),
                  const SizedBox(height: 10),
                  Text(_isLogin ? 'Any username + password works for demo' : 'Sahi naam, age (13+) aur strong password daliye',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                ])),

              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(_isLogin ? "Don't have an account? " : 'Already have an account? ', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                GestureDetector(
                  onTap: () => setState(() { _isLogin = !_isLogin; _error = ''; }),
                  child: Text(_isLogin ? 'Sign Up' : 'Sign In', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13))),
              ]),
            ]),
          )),
        )),
      ),
    );
  }

  Widget _tab(String label, bool active, VoidCallback onTap) => Expanded(
    child: GestureDetector(onTap: onTap,
      child: AnimatedContainer(duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: active ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(8),
          boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8)] : []),
        child: Text(label, textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            color: active ? T.primary : Colors.grey.shade500)))));

  Widget _label(String t) => Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151)));
}
