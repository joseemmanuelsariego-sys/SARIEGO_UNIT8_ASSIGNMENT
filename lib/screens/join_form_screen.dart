import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/orgs.dart';
import '../models/registration.dart';

class JoinFormScreen extends StatefulWidget {
  const JoinFormScreen({super.key, required this.org});

  final Org org;

  @override
  State<JoinFormScreen> createState() => _JoinFormScreenState();
}

class _JoinFormScreenState extends State<JoinFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Filled in by each field's onSaved when the form is saved.
  String _fullName = '';
  String _email = '';
  String _studentId = '';
  int? _yearLevel;

  // Inputs outside the TextFormFields: the State owns their values and
  // the widgets only show them (the input loop from the slides).
  Committee _committee = Committee.events;
  double _hours = 3;
  bool _wantsUpdates = true;
  bool _agreed = false;

  static final _emailPattern = RegExp(r'^[\w.+-]+@wvsu\.edu\.ph$');

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final registration = Registration(
      fullName: _fullName,
      email: _email,
      studentId: _studentId,
      yearLevel: _yearLevel ?? 1,
      committee: _committee,
      hoursPerWeek: _hours.round(),
      wantsUpdates: _wantsUpdates,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Welcome to ${widget.org.acronym}, ${registration.fullName}!',
        ),
      ),
    );
    Navigator.of(context).pop(registration);
  }

  void _reset() {
    _formKey.currentState!.reset();
    setState(() {
      _committee = Committee.events;
      _hours = 3;
      _wantsUpdates = true;
      _agreed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text('Join ${widget.org.acronym}')),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              // A validator returns an error message, or null when valid.
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Enter your full name'
                  : null,
              onSaved: (value) => _fullName = value!.trim(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'WVSU email',
                hintText: 'juan.delacruz@wvsu.edu.ph',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) return 'Enter your WVSU email';
                if (!_emailPattern.hasMatch(email)) {
                  return 'Use your school email, like juan@wvsu.edu.ph';
                }
                return null;
              },
              onSaved: (value) => _email = value!.trim(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Student ID number',
                prefixIcon: Icon(Icons.badge),
                border: OutlineInputBorder(),
                helperText: 'Numbers only',
              ),
              keyboardType: TextInputType.number,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) => (value == null || value.length < 6)
                  ? 'Enter at least 6 digits'
                  : null,
              onSaved: (value) => _studentId = value!,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: _yearLevel,
              decoration: const InputDecoration(
                labelText: 'Year level',
                prefixIcon: Icon(Icons.school),
                border: OutlineInputBorder(),
              ),
              items: [
                for (var y = 1; y <= 4; y++)
                  DropdownMenuItem(value: y, child: Text('Year $y')),
              ],
              onChanged: (value) => setState(() => _yearLevel = value),
              validator: (value) =>
                  value == null ? 'Choose your year level' : null,
            ),
            const SizedBox(height: 24),
            Text('Preferred committee', style: textTheme.titleMedium),
            RadioGroup<Committee>(
              groupValue: _committee,
              onChanged: (value) => setState(() => _committee = value!),
              child: Column(
                children: [
                  for (final c in Committee.values)
                    RadioListTile<Committee>(value: c, title: Text(c.label)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hours per week you can help: ${_hours.round()}',
              style: textTheme.titleMedium,
            ),
            Slider(
              value: _hours,
              min: 1,
              max: 10,
              divisions: 9,
              label: '${_hours.round()} h',
              onChanged: (value) => setState(() => _hours = value),
            ),
            SwitchListTile(
              title: const Text('Send me event updates'),
              value: _wantsUpdates,
              onChanged: (value) => setState(() => _wantsUpdates = value),
            ),
            CheckboxListTile(
              title: const Text('I agree to follow the org constitution'),
              value: _agreed,
              onChanged: (value) => setState(() => _agreed = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _reset,
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _agreed ? _submit : null,
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
