import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

enum Gender { male, female }

class _ProfileState extends State<Profile> {
  String name = "";
  var gender = Gender.male;
  final List<Map<String, dynamic>> deptGen = [];
  bool _isLoading = true;
  String _errorMessage = "";
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> fetchUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      // Make sure we're authenticated first
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        setState(() {
          _errorMessage = "No authenticated user found";
          _isLoading = false;
        });
        return;
      }

      // Use .maybeSingle() instead of .single() to avoid the error when no rows are found
      final response = await supabase
          .from('users')
          .select('name')
          .eq('id', currentUser.id)
          .maybeSingle();

      print("Supabase response: $response"); // Debug print

      if (mounted) {
        setState(() {
          // Check if response contains data
          if (response != null && response.containsKey('name')) {
            name = response['name'] ?? '';
          } else {
            // User exists but no data found
            _errorMessage =
                "No user profile found. You may need to create one.";
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e"); // Debug print
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load data: $e";
          _isLoading = false;
        });
      }
    }
  }

  // Method to create a new user profile if one doesn't exist
  Future<void> createUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        setState(() {
          _errorMessage = "No authenticated user found";
          _isLoading = false;
        });
        return;
      }

      // Create a default profile for this user
      await supabase.from('users').insert({
        'id': currentUser.id,
        'name': 'New User', // Default name
        'created_at': DateTime.now().toIso8601String(),
      });

      // Fetch the newly created profile
      await fetchUserData();
    } catch (e) {
      print("Error creating user profile: $e");
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to create profile: $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    deptGen.add(
      {"Managment": Colors.blueGrey, "Gender": gender.toString()},
    );
    // Fetch user data when the widget initializes
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_isLoading ? "Loading..." : "@$name"),
        actions: [
          IconButton(
            onPressed: fetchUserData, // Refresh functionality
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: gender == Gender.male
                ? profilePicMale(context)
                : profilePicFemale(context),
          ),
          const SizedBox(height: 20),
          // Show error message if there is one
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  // If we couldn't find a profile, offer to create one
                  if (_errorMessage.contains("No user profile found"))
                    ElevatedButton(
                      onPressed: createUserProfile,
                      child: const Text("Create Profile"),
                    ),
                ],
              ),
            ),
          if (!_isLoading && _errorMessage.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                name.isEmpty ? "No name found" : name,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          if (_isLoading)
            const Skeletonizer.zone(
              child: Card(
                child: ListTile(
                  leading: Bone.circle(size: 48),
                  title: Bone.text(words: 2),
                  subtitle: Bone.text(),
                  trailing: Bone.icon(),
                ),
              ),
            ),
          const SizedBox(height: 10),
          Expanded(
            child: _role(context),
          ),
        ],
      ),
    );
  }

  Container profilePicFemale(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(130),
        color: const Color.fromARGB(255, 255, 91, 146),
      ),
      child: SvgPicture.asset(
        fit: BoxFit.contain,
        "assets/profileImg/profileFemale.svg",
        height: MediaQuery.of(context).size.height * 1 / 12,
        width: MediaQuery.of(context).size.width * 1 / 12,
      ),
    );
  }

  Container profilePicMale(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(130),
        color: const Color.fromARGB(255, 255, 102, 92),
      ),
      child: SvgPicture.asset(
        fit: BoxFit.contain,
        "assets/profileImg/profileMale.svg",
        height: MediaQuery.of(context).size.height * 1 / 12,
        width: MediaQuery.of(context).size.width * 1 / 12,
      ),
    );
  }

  Widget _role(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 0.75,
      children: [
        functNality(context, "assets/searchImg/debate.svg"),
        functNality(context, "assets/searchImg/coding.svg"),
        functNality(context, "assets/searchImg/singing.svg"),
        functNality(context, "assets/searchImg/e-sports.svg"),
        functNality(context, "assets/searchImg/sports.svg"),
      ],
    );
  }

  GestureDetector functNality(BuildContext context, String path) {
    return GestureDetector(
      child: pickPicker(path),
      onTap: () {
        _showExpandedImage(context, path);
      },
      onLongPress: () {
        _showExpandedImage(context, path);
      },
    );
  }

  Container pickPicker(String path) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(0, 244, 244, 255),
        backgroundBlendMode: BlendMode.hue,
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SvgPicture.asset(path),
    );
  }

  void _showExpandedImage(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop(); // Close dialog on tap
          },
          child: Dialog(
            backgroundColor: Colors.white,
            child: Hero(
              tag: 'expandedImage',
              child: InteractiveViewer(
                child: SvgPicture.asset(path), // Image for expansion
              ),
            ),
          ),
        );
      },
    );
  }
}
