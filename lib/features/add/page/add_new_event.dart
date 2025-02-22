// ignore_for_file: file_names, use_build_context_synchronously, no_leading_underscores_for_local_identifiers

import 'dart:io';
import 'package:event/core/constants/image_constants.dart';
import 'package:event/features/home/page/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:random_string/random_string.dart';

class Addnewevent extends StatefulWidget {
  const Addnewevent({super.key});

  @override
  State<Addnewevent> createState() => _AddneweventState();
}

class _AddneweventState extends State<Addnewevent> {
  String id = randomAlphaNumeric(10);
  final SupabaseClient supabase = Supabase.instance.client;
  File? _selectedImage;
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String? formattedDate;
  List<String> list = ['Art', 'Sports', 'Coding', 'E-Sports', 'Other'];
  String? selection;
  bool isSelected = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a valid image file."),
        ),
      );
    }
  }

Future<String?> uploadImage() async {
  if (_selectedImage == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please select a valid image file.")),
    );
    return null;
  }

  final fileName = '${id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
  final filePath = 'event_banners/$fileName';

  try {
    // Add loading indicator first
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // Check file size
    final fileSize = await _selectedImage!.length();
    if (fileSize > 5 * 1024 * 1024) {
      Navigator.pop(context); // Remove loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image file size must be less than 5MB")),
      );
      return null;
    }
    
    // First check if bucket exists
    try {
      final buckets = await supabase.storage.listBuckets();
      final bucketExists = buckets.any((bucket) => bucket.id == 'event_banners');
      
      if (!bucketExists) {
        // Try to create the bucket if it doesn't exist
        try {
          await supabase.storage.createBucket(
            'event_banners',
            const BucketOptions(
              public: true,
              fileSizeLimit: '5MB',
            ),
          );
        } catch (e) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Unable to create storage bucket. Please contact administrator."),
            ),
          );
          return null;
        }
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to access storage. Please check your permissions."),
        ),
      );
      return null;
    }


    // Get public URL
    final imageUrl = supabase.storage.from('event_banners').getPublicUrl(filePath);
    
    Navigator.pop(context); // Remove loading indicator
    
    if (imageUrl.isEmpty) {
      throw Exception('Failed to get public URL for uploaded image');
    }

    return imageUrl;

  } catch (e) {
    Navigator.pop(context); // Remove loading indicator
    
    String errorMessage = 'Image upload failed: ';
    if (e is StorageException) {
      errorMessage += 'Storage error - ${e.message}';
    } else if (e is SocketException) {
      errorMessage += 'Network connection error';
    } else {
      errorMessage += e.toString();
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );

    return null;
  }
}

Future<void> insertData() async {
  // Validate required fields
  if (nameController.text.trim().isEmpty ||
      descriptionController.text.trim().isEmpty ||
      formattedDate == null ||
      selection == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please fill in all required fields")),
    );
    return;
  }

  String? imageUrl;
  if (_selectedImage != null) {
    imageUrl = await uploadImage();
    if (imageUrl == null) {
      // If image upload failed, return early
      return;
    }
  }

  try {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // Prepare the data to be inserted
    final eventData = {
      'id': id,
      'name': nameController.text.trim(),
      'description': descriptionController.text.trim(),
      'date': formattedDate,
      'genere': selection,
      if (imageUrl != null) 'image_url': imageUrl, // Include image_url only if it's not null
    };

    await supabase.from('events').insert(eventData);

    Navigator.pop(context); // Remove loading indicator

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event Added Successfully!')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Home()),
    );
  } catch (e) {
    Navigator.pop(context); // Remove loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to create event: ${e.toString()}')),
    );
  }
}


  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'This Field is required';
    }
    if (value.length < 2) {
      return 'This Field must be at least 2 characters';
    }
    return null;
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
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
              titlePadding: const EdgeInsets.only(top: 20),
              centerTitle: true,
              background: SvgPicture.asset(
                ImageConstants.event,
                height: 100,
                width: 100,
              ),
              title: Container(
                padding: const EdgeInsets.all(10),
                child: const Text(
                  "Add New Event",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _forms(nameController, descriptionController,validateName),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromARGB(255, 255, 130, 130),
                  ),
                  margin: const EdgeInsets.all(20),
                  child: DropdownButton<String>(
                    hint: const Text(
                      "Select Genre",
                    ),
                    value: selection,
                    onChanged: (String? newValue) {
                      setState(() {
                        selection = newValue;
                      });
                    },
                    items: list.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2001),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      formattedDate =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                      setState(() {});
                    }
                  },
                  child: _schedule(
                    formattedDate.toString().trim(),
                  ),
                ),
                _imageGetter(_pickImage, _selectedImage, width * 0.7,
                    height * 0.5, width * 0.8),
                const SizedBox(height: 20),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    fixedSize: Size(width * 0.7, 60),
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: insertData,
                  child: const Text(
                    'Create Event',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          )
        ],
      ),
    );
  }
}

Widget _forms(TextEditingController nameController, TextEditingController descriptionController,String? Function(String?)? validator  ) {
  return SafeArea(
    child: Column(
      children: [
        Container(
          margin: const EdgeInsets.all(20),
          child: TextFormField(
            validator: validator,
            controller: nameController,
            decoration: const InputDecoration(
              hintText: "Enter Event Name",
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(20),
          child: TextFormField(
            validator: validator,
            controller: descriptionController,
            maxLines: 10,
            decoration: const InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                ),
              ),
              focusColor: Colors.grey,
              hintText: "Enter Event Description",
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _schedule(String dateText) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: Colors.grey[300],
    ),
    margin: const EdgeInsets.all(10),
    child: Column(
      children: [
        const Text(
          'Selected Date',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          dateText == 'null' ? 'No date selected' : dateText,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
      ],
    ),
  );
}

Widget _imageGetter(
  Function() pickImage,
  File? selectedImage,
  double width,
  double imageHeight,
  double imageWidth,
) {
  return Container(
    margin: const EdgeInsets.all(10),
    child: Column(
      children: [
        const Text(
          "Enter an Banner Image",
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: const Text(
            "Enter an image only",
            style: TextStyle(
              backgroundColor: Color.fromARGB(255, 255, 250, 206),
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            fixedSize: Size(width, 60),
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onPressed: pickImage,
          child: const Text(
            "Select",
            style: TextStyle(fontSize: 18),
          ),
        ),
        const SizedBox(height: 20),
        selectedImage == null
            ? const Text("No image selected")
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(),
                ),
                child: Image.file(
                  selectedImage,
                  height: imageHeight,
                  width: imageWidth,
                ),
              ),
      ],
    ),
  );
}