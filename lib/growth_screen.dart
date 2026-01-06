import 'package:flutter/material.dart';
import 'growth_data.dart';

class GrowthScreen extends StatefulWidget {
  const GrowthScreen({super.key});

  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen> {
  bool isBoy = true;
  int? selectedAge;
  String resultHeight = "--";
  String resultWeight = "--";

  void calculateGrowth() {
    if (selectedAge == null) return;

    String genderKey = isBoy ? "BOY" : "GIRL";
    var data = growthData[genderKey]?[selectedAge];

    if (data != null) {
      setState(() {
        resultHeight = data["height"]!;
        resultWeight = data["weight"]!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Growth Tracker",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Gender Selection",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _buildGenderCard("Boy", Icons.male, true)),
                const SizedBox(width: 20),
                Expanded(child: _buildGenderCard("Girl", Icons.female, false)),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              "Child's Age",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              initialValue: selectedAge,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.cake, color: Colors.grey),
                labelText: "Child's Age (Months)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              items: List.generate(73, (index) => index).map((age) {
                String label;
                if (age < 12) {
                  label = "$age months";
                } else {
                  int years = age ~/ 12;
                  int months = age % 12;
                  if (months == 0) {
                    label = "$years ${years == 1 ? 'year' : 'years'}";
                  } else {
                    label =
                        "$years ${years == 1 ? 'year' : 'years'} $months ${months == 1 ? 'month' : 'months'}";
                  }
                }
                return DropdownMenuItem<int>(value: age, child: Text(label));
              }).toList(),
              onChanged: (val) => setState(() => selectedAge = val),
            ),
            const SizedBox(height: 8),
            Text(
              "Select age (0 months - 6 years)",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: calculateGrowth,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E60F8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Show Results",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.bar_chart, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "STANDARD GROWTH ESTIMATES",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade500,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildResultRow(
                    "Height",
                    resultHeight,
                    "cm",
                    Icons.swap_vert,
                    Colors.orange.shade100,
                    Colors.orange,
                  ),
                  const SizedBox(height: 20),
                  _buildResultRow(
                    "Weight",
                    resultWeight,
                    "kg",
                    Icons.monitor_weight,
                    Colors.teal.shade100,
                    Colors.teal,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Based on WHO growth standards. Consult a pediatrician for accurate medical assessment.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderCard(String label, IconData icon, bool isMale) {
    bool selected = isBoy == isMale;
    return GestureDetector(
      onTap: () => setState(() => isBoy = isMale),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEBF2FF) : Colors.white,
          border: selected
              ? Border.all(color: const Color(0xFF1E60F8), width: 2)
              : null,
          borderRadius: BorderRadius.circular(15),
          boxShadow: selected
              ? []
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 40,
                    color: selected ? const Color(0xFF1E60F8) : Colors.grey,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: selected ? const Color(0xFF1E60F8) : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Positioned(
                top: 10,
                right: 10,
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xFF1E60F8),
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(
    String label,
    String value,
    String unit,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(width: 20),
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 5),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            unit,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }
}
