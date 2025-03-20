import 'package:event/core/constants/image_constants.dart';
import 'package:event/core/image/image.dart';
import 'package:event/features/add/page/add_new_event.dart';
import 'package:event/features/fav/page/fav.dart';
import 'package:event/features/profile/page/profile.dart';
import 'package:event/features/search/page/search.dart';
import 'package:event/features/template/page/add_event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  bool isEditor = true;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  final SupabaseClient supabase = Supabase.instance.client;
  Future<List> data() async {
    final res = await supabase
        .from('events')
        .select('id, name, description, date, genere, color');
    return res;
  }

  Color hexToColor(String hex) {
    hex = hex.replaceFirst('#', ''); // Remove '#' if present
    if (hex.length == 6) {
      hex = "FF$hex"; // Add alpha value if missing
    }
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    String location = "Pune, Hadapsar";

    return Scaffold(
      // Conditionally show the AppBar only for Home Page (_selectedIndex == 0)
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: const Color.fromRGBO(28, 88, 242, 1),
              leading: Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: const Icon(
                        size: 30,
                        Icons.stacked_bar_chart_sharp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              title: Center(
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Current Location",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        )
                      ],
                    ),
                    Text(
                      location,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                GestureDetector(
                  onTap: () {},
                  child: const Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            )
          : null, // Hide AppBar for all other pages
      // Main Body with PageView for navigation
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swiping
        children: <Widget>[
          // Pages corresponding to BottomNavigationBar items
          _buildHomePage(height * 0.14, width * 0.14),
          const Search(),
          const Addnewevent(),
          const Fav(),
          const Profile(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Keeps all items visible
        currentIndex: _selectedIndex,
        items: [
          btmItem(const Icon(Icons.home), "Home"),
          btmItem(const Icon(Icons.search), "Search"),
          isEditor
              ? btmItem(const Icon(CupertinoIcons.add_circled), "Add")
              : btmItem(const Icon(Icons.rate_review), "Wattle"),
          btmItem(const Icon(CupertinoIcons.heart), "Favourites"),
          btmItem(const Icon(Icons.person), "Profile"),
        ],
        elevation: 2,
      ),
    );
  }

  BottomNavigationBarItem btmItem(Icon icon, String label) =>
      BottomNavigationBarItem(icon: icon, label: label);

  // Define the Home Page content
  Widget _buildHomePage(double height, double width) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                margin: const EdgeInsets.all(5),
                child: const Text(
                  "Suggested",
                  style: TextStyle(fontSize: 22),
                ),
              ),
              const Spacer(),
              Container(
                margin: const EdgeInsets.all(5),
                child: const Text(
                  "See all >",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: data(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator()); // Show loading
              }
              if (snapshot.hasError) {
                return Center(
                    child: Text("Error: ${snapshot.error}")); // Show error
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text("No events found!"),
                ); // Handle empty data
              }

              // Extract list of event names
              List events = snapshot.data!;
              return ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  String eventColor = events[index]['color'] ??
                      '#FFC700'; // Default color if null

                  return Container(
                    margin: const EdgeInsets.all(15),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: hexToColor(eventColor), // Apply dynamic color
                    ),
                    child: Row(
                      children: [
                        ImageSvg(
                          path: ImageConstants.codeBanner,
                          height: height,
                          width: width,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                events[index]['name'],
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                softWrap: true,
                                maxLines: 3,
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddEvent(
                                          eventId: events[index]['id']),
                                    ),
                                  );
                                },
                                label: const Text("Participate"),
                                icon: const Icon(Icons.join_right_sharp),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
