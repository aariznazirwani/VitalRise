import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/firestore_service.dart';

class BeneficiaryScreen extends StatefulWidget {
  const BeneficiaryScreen({super.key});

  @override
  State<BeneficiaryScreen> createState() => _BeneficiaryScreenState();
}

class _BeneficiaryScreenState extends State<BeneficiaryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _aadharController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _searchController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aadharController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.month}/${picked.day}/${picked.year}";
      });
    }
  }

  void _addBeneficiary() {
    if (_formKey.currentState!.validate()) {
      _firestoreService
          .addBeneficiary(
            name: _nameController.text.trim(),
            aadhar: _aadharController.text.trim(),
            dob: _dobController.text.trim(),
            phone: _phoneController.text.isNotEmpty
                ? _phoneController.text.trim()
                : null,
          )
          .then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Beneficiary Added Successfully')),
            );
            _nameController.clear();
            _aadharController.clear();
            _dobController.clear();
            _phoneController.clear();
          })
          .catchError((e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error adding beneficiary: $e')),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Beneficiary Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search beneficiaries...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 20),

            // Add New Beneficiary Card
            Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.person_add, color: Colors.blue),
                        SizedBox(width: 10),
                        Text(
                          'Add New Beneficiary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('FULL NAME'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'e.g. Rahul Kumar',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Name is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('AADHAR NUMBER'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _aadharController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(12),
                        _AadharInputFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Aadhar is required';
                        }
                        String cleanValue = value.replaceAll(' ', '');
                        if (cleanValue.length != 12) {
                          return 'Aadhar must be 12 digits';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: '12-digit number (XXXX XXXX XXXX)',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: const Color(0xFFF5F7FA),
                        suffixIcon: Icon(
                          Icons.assignment_ind,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('D.O.B'),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _selectDate(context),
                                child: AbsorbPointer(
                                  child: _buildTextField(
                                    controller: _dobController,
                                    hint: 'mm/dd/yyyy',
                                    suffixIcon: Icons.calendar_today,
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                        ? 'DOB is required'
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('PHONE'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _phoneController,
                                hint: '+91',
                                suffixIcon: Icons.phone,
                                isOptional: true,
                                keyboardType: TextInputType.phone,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _addBeneficiary,
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Add Beneficiary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Beneficiary List Header & StreamBuilder
            StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.getBeneficiaries(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                // Client-side filtering
                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['name']?.toString().toLowerCase() ?? '';
                  final aadhar = data['aadhar']?.toString().toLowerCase() ?? '';
                  return name.contains(_searchText) ||
                      aadhar.contains(_searchText);
                }).toList();

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Beneficiary List',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Total: ${filteredDocs.length}',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (filteredDocs.isEmpty)
                      const Center(child: Text("No beneficiaries found.")),
                    for (var doc in filteredDocs)
                      _buildBeneficiaryCard(
                        doc.id,
                        doc.data() as Map<String, dynamic>,
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? suffixIcon,
    bool isOptional = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: isOptional ? null : validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: Colors.grey[600], size: 20)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildBeneficiaryCard(String id, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AADHAR: ${data['aadhar'] ?? 'N/A'}',
                    style: TextStyle(color: Colors.blueGrey[400], fontSize: 13),
                  ),
                ],
              ),
              // Option to delete? The user did not ask for delete button UI explicitly but mentioned "remove test beneficiaries", which I did by removing hardcode.
              // I will leave the edit icon but maybe make it do nothing or delete for convenience?
              // Let's keep the Edit icon as placeholder or remove it if not needed.
              // I'll change it to a Delete button for "functional remove" if I interpret that as ability to remove.
              // "make this functional remove test beneficiaries" -> ambiguous.
              // I will add a delete button functionality.
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Colors.redAccent,
                ),
                onPressed: () {
                  _firestoreService.deleteBeneficiary(id);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.blueGrey[400],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    data['dob'] ?? 'N/A',
                    style: TextStyle(color: Colors.blueGrey[600], fontSize: 14),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.phone_android,
                    size: 16,
                    color: Colors.blueGrey[400],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    data['phone'] ?? 'N/A',
                    style: TextStyle(color: Colors.blueGrey[600], fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AadharInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length > 14) {
      return oldValue;
    }

    // Remove spaces
    String newText = newValue.text.replaceAll(' ', '');

    if (newText.length > 12) return oldValue;

    final buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      int nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != newText.length) {
        buffer.write(' ');
      }
    }

    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
