import 'package:flutter/material.dart';

import 'summary_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
    home: const SignUpScreen(),
  );
}

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];
const _gap = SizedBox(height: 12);

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthText = TextEditingController();
  final _emailFocus = FocusNode();

  String? _group;
  DateTime? _birth;
  bool _agreed = false;
  bool _done = false;
  int _pwLength = 0;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm, _birthText]) {
      c.dispose();
    }
    _emailFocus.dispose();
    super.dispose();
  }

  void _dismissKeyboard(PointerDownEvent _) =>
      FocusManager.instance.primaryFocus?.unfocus();

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      setState(() => _done = true);
      _message('Account created');
    }
  }

  Future<void> _pickBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    if (!mounted) return;
    setState(() {
      _birth = picked;
      final d = picked.day.toString().padLeft(2, '0');
      final m = picked.month.toString().padLeft(2, '0');
      _birthText.text = '$d.$m.${picked.year}';
    });
  }

  void _startOver() {
    setState(() {
      for (final c in [_name, _email, _password, _confirm, _birthText]) {
        c.clear();
      }
      _group = null;
      _birth = null;
      _agreed = false;
      _pwLength = 0;
      _done = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign up')),
    body: _done ? _summary() : _form(),
  );

  Widget _summary() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        SummaryCard(
          name: _name.text,
          email: _email.text,
          group: _group ?? '',
          birthDate: _birthText.text,
        ),
        const SizedBox(height: 16),
        TextButton(onPressed: _startOver, child: const Text('Start over')),
      ],
    ),
  );

  Widget _form() => Form(
    key: _formKey,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Name'),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _emailFocus.requestFocus(),
            onTapOutside: _dismissKeyboard,
            validator: (v) => (v ?? '').trim().length < 2
                ? 'Enter at least 2 characters'
                : null,
          ),
          _gap,
          TextFormField(
            controller: _email,
            focusNode: _emailFocus,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'name@kbtu.kz',
            ),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            onTapOutside: _dismissKeyboard,
            validator: (v) {
              final s = (v ?? '').trim();
              final at = s.indexOf('@');
              if (at < 1 || !s.substring(at).contains('.')) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          _gap,
          TextFormField(
            controller: _password,
            decoration: const InputDecoration(
              labelText: 'Password',
              helperText: 'At least 8 characters',
            ),
            obscureText: true,
            textInputAction: TextInputAction.next,
            onChanged: (v) => setState(() => _pwLength = v.length),
            onTapOutside: _dismissKeyboard,
            validator: (v) =>
                (v ?? '').length < 8 ? 'At least 8 characters' : null,
          ),
          Text('$_pwLength of 8'),
          _gap,
          TextFormField(
            controller: _confirm,
            decoration: const InputDecoration(labelText: 'Confirm password'),
            obscureText: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: _agreed ? (_) => _signUp() : null,
            onTapOutside: _dismissKeyboard,
            validator: (v) =>
                v != _password.text ? 'Passwords do not match' : null,
          ),
          _gap,
          DropdownButtonFormField<String>(
            initialValue: _group,
            decoration: const InputDecoration(labelText: 'Group'),
            items: [
              for (final g in groups)
                DropdownMenuItem(value: g, child: Text(g)),
            ],
            onChanged: (g) => setState(() => _group = g),
            validator: (g) => g == null ? 'Choose a group' : null,
          ),
          _gap,
          TextFormField(
            controller: _birthText,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Date of birth',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: _pickBirth,
            validator: (_) => _birth == null ? 'Pick your date of birth' : null,
          ),
          CheckboxListTile(
            value: _agreed,
            onChanged: (v) => setState(() => _agreed = v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('I agree to the rules'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _agreed ? _signUp : null,
            child: const Text('Sign up'),
          ),
        ],
      ),
    ),
  );
}
