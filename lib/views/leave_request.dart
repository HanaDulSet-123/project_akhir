import 'package:flutter/material.dart';

// void main() {
//   runApp(const LeaveRequestApp());
// }

// class LeaveRequestApp extends StatelessWidget {
//   const LeaveRequestApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Cudi - Leave Request',
//       theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
//       home: const LeaveRequestScreen(),
//     );
//   }
// }

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedLeaveType = 'Annual Leave';
  String _selectedDuration = 'Full Day';
  DateTime? _startDate;
  DateTime? _endDate;

  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<String> _leaveTypes = [
    'Annual Leave',
    'Sick Leave',
    'Personal Leave',
    'Maternity Leave',
    'Paternity Leave',
    'Emergency Leave',
  ];

  final List<String> _durations = [
    'Full Day',
    'Half Day (Morning)',
    'Half Day (Afternoon)',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Request'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Navigate to leave history
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Leave type dropdown
              _buildFormField(
                label: 'Leave Type',
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedLeaveType,
                  items: _leaveTypes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedLeaveType = newValue!;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Duration dropdown
              _buildFormField(
                label: 'Duration',
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedDuration,
                  items: _durations.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedDuration = newValue!;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Date range picker
              Row(
                children: [
                  Expanded(
                    child: _buildFormField(
                      label: 'Start Date',
                      child: TextFormField(
                        readOnly: true,
                        controller: TextEditingController(
                          text: _startDate != null
                              ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                              : 'Select date',
                        ),
                        onTap: () => _selectStartDate(context),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFormField(
                      label: 'End Date',
                      child: TextFormField(
                        readOnly: true,
                        controller: TextEditingController(
                          text: _endDate != null
                              ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                              : 'Select date',
                        ),
                        onTap: () => _selectEndDate(context),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Reason field
              _buildFormField(
                label: 'Reason',
                child: TextFormField(
                  controller: _reasonController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    hintText: 'Enter the reason for your leave',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a reason';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Additional notes
              _buildFormField(
                label: 'Additional Notes (Optional)',
                child: TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    hintText: 'Any additional information',
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Submit button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Submit Leave Request',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

              // Leave balance info
              // Card(
              //   elevation: 2,
              //   child: Padding(
              //     padding: const EdgeInsets.all(16.0),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         const Text(
              //           'Your Leave Balance',
              //           style: TextStyle(
              //             fontSize: 16,
              //             fontWeight: FontWeight.bold,
              //           ),
              //         ),
              //         const SizedBox(height: 12),
              //         Row(
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           children: [
              //             _buildLeaveBalanceItem('Annual Leave', '12 days'),
              //             _buildLeaveBalanceItem('Sick Leave', '8 days'),
              //           ],
              //         ),
              //         const SizedBox(height: 8),
              //         Row(
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           children: [
              //             _buildLeaveBalanceItem('Personal Leave', '5 days'),
              //             _buildLeaveBalanceItem('Emergency', '3 days'),
              //           ],
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildLeaveBalanceItem(String type, String balance) {
    return Column(
      children: [
        Text(type, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 4),
        Text(
          balance,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a start date')),
        );
        return;
      }

      if (_endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an end date')),
        );
        return;
      }

      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Leave Request Submitted'),
            content: const Text(
              'Your leave request has been submitted successfully and is pending approval.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Clear form
                  _formKey.currentState!.reset();
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                    _selectedLeaveType = 'Annual Leave';
                    _selectedDuration = 'Full Day';
                  });
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
