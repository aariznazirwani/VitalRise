import 'package:flutter/material.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, dynamic>> categories = [
    {"title": "Pregnant", "icon": Icons.pregnant_woman, "factor": 159},
    {"title": "Lactating", "icon": Icons.baby_changing_station, "factor": 159},
    {"title": "6 months - 3 years", "icon": Icons.child_care, "factor": 150},
    {"title": "3 years - 6 years", "icon": Icons.face, "factor": 274},
    {"title": "Adolescent", "icon": Icons.school, "factor": 150},
    {"title": "SAM", "icon": Icons.medical_services, "factor": 224},
  ];

  final Map<int, double> _totals = {};

  void _updateTotal(int index, double value) {
    setState(() {
      _totals[index] = value;
    });
  }

  double get _grandTotal => _totals.values.fold(0, (sum, item) => sum + item);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Developer'),
              subtitle: Text('Ruhan Nabi'),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Nutrition Tracker",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return NutritionCard(
                  title: categories[index]['title'],
                  icon: categories[index]['icon'],
                  factor: categories[index]['factor'],
                  onTotalChanged: (val) => _updateTotal(index, val),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Grand Total Grams",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _grandTotal.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NutritionCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final int factor;
  final Function(double) onTotalChanged;

  const NutritionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.factor,
    required this.onTotalChanged,
  });

  @override
  State<NutritionCard> createState() => _NutritionCardState();
}

class _NutritionCardState extends State<NutritionCard> {
  bool _isExpanded = false;
  final TextEditingController _controller = TextEditingController();
  double _calculatedValue = 0;

  void _calculate(String value) {
    double input = double.tryParse(value) ?? 0;
    // Formula: factor * 25 * input
    double result = widget.factor * 25 * input;

    setState(() {
      _calculatedValue = result;
    });
    widget.onTotalChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _isExpanded ? const Color(0xFFE8F5E9) : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.icon,
              color: _isExpanded ? Colors.green : Colors.grey[600],
              size: 24,
            ),
          ),
          title: Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          trailing: Icon(
            _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: _isExpanded ? Colors.green : Colors.grey,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Nutritional Value",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    onChanged: _calculate,
                    decoration: InputDecoration(
                      hintText: "Enter value",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      suffixText: "grams",
                      suffixStyle: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.green),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: Colors.grey[200], thickness: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Grams",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      Text(
                        _calculatedValue.toStringAsFixed(0),
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
