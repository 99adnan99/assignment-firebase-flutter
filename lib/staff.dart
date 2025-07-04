// staff.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Staff data model
class Staff {
  String name;
  String id;
  int age;

  Staff({required this.name, required this.id, required this.age});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'id': id,
      'age': age,
    };
  }

  factory Staff.fromMap(Map<String, dynamic> map) {
    return Staff(
      name: map['name'],
      id: map['id'],
      age: map['age'] is int ? map['age'] : int.tryParse(map['age'].toString()) ?? 0,
    );
  }
}

// Staff input form page
class StaffFormPage extends StatefulWidget {
  const StaffFormPage({super.key});

  @override
  _StaffFormPageState createState() => _StaffFormPageState();
}

class _StaffFormPageState extends State<StaffFormPage> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _ageController = TextEditingController();

  void _submitForm() {
    if (_nameController.text.isEmpty ||
        _idController.text.isEmpty ||
        _ageController.text.isEmpty) {
      return;
    }

    final newStaff = Staff(
      name: _nameController.text,
      id: _idController.text,
      age: int.tryParse(_ageController.text) ?? 0,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StaffListPage(staff: newStaff)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Name')),
            SizedBox(height: 16),
            TextField(controller: _idController, decoration: InputDecoration(labelText: 'ID Staff')),
            SizedBox(height: 16),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Age'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: _submitForm,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

// Staff list page
class StaffListPage extends StatefulWidget {
  final Staff staff;
  const StaffListPage({super.key, required this.staff});

  @override
  _StaffListPageState createState() => _StaffListPageState();
}

class _StaffListPageState extends State<StaffListPage> {
  final CollectionReference staffCollection = FirebaseFirestore.instance.collection('staff');

  @override
  void initState() {
    super.initState();
    _addStaffToFirestore(widget.staff);
  }

  Future<void> _addStaffToFirestore(Staff staff) async {
    await staffCollection.add(staff.toMap());
  }

  Future<void> _deleteStaff(String docId) async {
    await staffCollection.doc(docId).delete();
  }

  Future<void> _editStaff(String docId, Staff updatedStaff) async {
    await staffCollection.doc(docId).update(updatedStaff.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: staffCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error loading data'));
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final staff = Staff.fromMap(data);
              final docId = docs[index].id;

              return Card(
                color: Colors.green[50],
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(staff.name),
                  subtitle: Text('${staff.id}\n${staff.age}', style: TextStyle(height: 1.5)),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _showEditDialog(docId, staff),
                        icon: Icon(Icons.edit, color: Colors.black54),
                      ),
                      IconButton(
                        onPressed: () => _deleteStaff(docId),
                        icon: Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StaffFormPage())),
        child: Text('Add Staff'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showEditDialog(String docId, Staff staff) {
    final nameController = TextEditingController(text: staff.name);
    final idController = TextEditingController(text: staff.id);
    final ageController = TextEditingController(text: staff.age.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Staff'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
            SizedBox(height: 12),
            TextField(controller: idController, decoration: InputDecoration(labelText: 'ID')),
            SizedBox(height: 12),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Age'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final updatedStaff = Staff(
                name: nameController.text,
                id: idController.text,
                age: int.tryParse(ageController.text) ?? staff.age,
              );
              _editStaff(docId, updatedStaff);
              Navigator.of(context).pop();
            },
            child: Text('Save'),
          )
        ],
      ),
    );
  }
}
