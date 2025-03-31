// ignore_for_file: file_names, use_build_context_synchronously, no_leading_underscores_for_local_identifiers

import 'package:event/core/common/widgets/custom_container.dart';
import 'package:event/core/constants/image_constants.dart';
import 'package:event/features/add/widgets/schedule.dart';
import 'package:event/features/home/page/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:random_string/random_string.dart';

class Addnewevent extends StatefulWidget {
  const Addnewevent({super.key});

  @override
  State<Addnewevent> createState() => _AddneweventState();
}

class _AddneweventState extends State<Addnewevent> {
  // Constants for field validation
  static const int maxNameLength = 255;
  static const int maxDescriptionLength = 255;

  String id = randomAlphaNumeric(10);
  final SupabaseClient supabase = Supabase.instance.client;

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String? formattedDate;
  List<String> genreList = ['Art', 'Sports', 'Coding', 'E-Sports', 'Other'];
  String? selectedGenre;
  Color selectedColor = Colors.blue;
  bool isLoading = false;

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'Name is required';
    if (value.length > maxNameLength)
      return 'Name too long (max $maxNameLength chars)';
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) return 'Description is required';
    if (value.length > maxDescriptionLength) {
      return 'Description too long (max $maxDescriptionLength chars)';
    }
    return null;
  }

  Future<void> insertData() async {
    // Validate all fields
    final nameError = _validateName(nameController.text.trim());
    final descriptionError =
        _validateDescription(descriptionController.text.trim());

    if (nameError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(nameError)),
      );
      return;
    }

    if (descriptionError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(descriptionError)),
      );
      return;
    }

    if (formattedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Date is required")),
      );
      return;
    }

    if (selectedGenre == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Genre is required")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final eventData = {
        'id': id,
        'created_at': DateTime.now().toIso8601String(),
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'date': formattedDate,
        'genre': selectedGenre,
        'color': '#${selectedColor.value.toRadixString(16).substring(2)}',
      };

      await supabase.from('events').insert(eventData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event Added Successfully!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create event: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            centerTitle: true,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Home(),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_back),
            ),
            expandedHeight: 250,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: SvgPicture.asset(
                ImageConstants.event,
                height: 100,
                width: 100,
              ),
              title: const Text(
                "Add New Event",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Updated forms widget with both validators
                  Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Event Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: _validateName,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: _validateDescription,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Genre',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    hint: const Text("Select Genre"),
                    value: selectedGenre,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedGenre = newValue;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Genre is required' : null,
                    items:
                        genreList.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child:
                            Text(value, style: const TextStyle(fontSize: 16)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2001),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          formattedDate =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                        });
                      }
                    },
                    child: schedule(formattedDate ?? "Pick a date"),
                  ),
                  const SizedBox(height: 16),
                  customContainer(
                    onTap: () => _showColorPicker(context),
                    vPadding: height * 0.02,
                    hPadding: width * 0.02,
                    bRadius: width * 0.01,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: selectedColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Pick Color',
                            style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : insertData,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Create Event',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  selectedColor = color;
                });
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
