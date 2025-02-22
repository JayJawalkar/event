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
  final SupabaseClient supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> fetchEvent() async {
    try {
      final event = await supabase.from('users').select('name').single();
      return event;
    } catch (e) {
      return {}; // Return empty map if error occurs
    }
  }

  void loadData() async {
    final data = await fetchEvent();
    setState(() {
      name = data['name'] ?? '';
      // Add other fields as needed
    });
  }

  @override
  void initState() {
    super.initState();
    deptGen.add(
      {"Managment": Colors.blueGrey, "Gender": gender.toString()},
    );
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("@$name"),
        actions: [
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
          _remBody(_isLoading, name),
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

Widget _remBody(isLoading, String name) {
  return isLoading
      ? const Skeletonizer.zone(
          child: Card(
            child: ListTile(
              leading: Bone.circle(size: 48),
              title: Bone.text(words: 2),
              subtitle: Bone.text(),
              trailing: Bone.icon(),
            ),
          ),
        )
      : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            name,
            style: const TextStyle(fontSize: 18),
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
    child: SvgPicture.asset(path), // Corrected the recursive call
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
