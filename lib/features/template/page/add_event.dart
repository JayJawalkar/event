// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'package:dotted_border/dotted_border.dart';
import 'package:event/core/common/widgets/custom_container.dart';
import 'package:event/core/constants/image_constants.dart';
import 'package:event/features/home/page/home.dart';
import 'package:event/features/payment/views/razorpay_api.dart';
import 'package:event/features/template/widgets/button_text.dart';
import 'package:event/features/template/widgets/circle_avatar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddEvent extends StatefulWidget {
  final String eventId;
  const AddEvent({super.key, required this.eventId});

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> fetchEvent() async {
    try {
      final event = await supabase
          .from('events')
          .select('name, description, date, genre, time, datetime')
          .eq('id', widget.eventId)
          .single();
      return event;
    } catch (e) {
      return {}; // Return empty map if error occurs
    }
  }

  String eventName = '';
  String eventDescription = '';
  String eventImageUrl = '';
  DateTime? eventDateTime;
  Duration remainingTime = Duration.zero;
  Timer? countdownTimer;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final data = await fetchEvent();
    setState(() {
      eventName = data['name'] ?? '';
      eventDescription = data['description'] ?? '';
      eventImageUrl = data['image_url'] ?? '';

      final String datetimeString = data['datetime'] ?? data['date'] ?? '';
      eventDateTime = DateTime.tryParse(datetimeString);
      if (eventDateTime != null) {
        updateRemainingTime();
        startCountdown();
      }
    });
  }

  void updateRemainingTime() {
    if (eventDateTime != null) {
      setState(() {
        remainingTime = eventDateTime!.difference(DateTime.now());
      });
    }
  }

  void startCountdown() {
    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      updateRemainingTime();
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    final isNegative = duration.isNegative;
    final absDuration = duration.abs();

    final days = absDuration.inDays;
    final hours = absDuration.inHours % 24;
    final minutes = absDuration.inMinutes % 60;
    final seconds = absDuration.inSeconds % 60;

    return isNegative
        ? "Started ${days}d ${hours}h ${minutes}m ${seconds}s ago"
        : "Starts in: ${days}d ${hours}h ${minutes}m ${seconds}s";
  }

  String getEventStatus() {
    if (eventDateTime == null) return "";

    final now = DateTime.now();
    if (now.isBefore(eventDateTime!)) {
      return "Upcoming";
    } else if (now.difference(eventDateTime!).inHours < 6) {
      return "Ongoing";
    } else {
      return "Ended";
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Upcoming":
        return Colors.orange;
      case "Ongoing":
        return Colors.green;
      case "Ended":
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = getEventStatus();
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: false,
              backgroundColor: Colors.white,
              leading: IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Home(),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_back),
              ),
              expandedHeight: 270,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(top: 5),
                centerTitle: true,
                background: eventImageUrl.isNotEmpty
                    ? Image.network(eventImageUrl, fit: BoxFit.cover)
                    : SvgPicture.asset("assets/banner/codeBanner.svg"),
                title: Text(
                  eventName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                collapseMode: CollapseMode.parallax,
                stretchModes: const [StretchMode.fadeTitle],
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    if (eventDateTime != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          children: [
                            Text(
                              "Event Time: ${eventDateTime!.toLocal().toString().substring(0, 16)}",
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.black),
                            ),
                            const SizedBox(height: 5),
                            customContainer(
                                vPadding: 5,
                                hPadding: 15,
                                borderColor: Colors.black,
                                containerColor: Colors.transparent,
                                bRadius: 10,
                                child: Column(
                                  children: [
                                    Text(
                                      formatDuration(remainingTime),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: remainingTime.isNegative
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      status,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: getStatusColor(status),
                                      ),
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ),
                    _rating(context),
                    _about(eventDescription),
                    CircleAvatarExplicit(path: ImageConstants.female),
                    ButtonText(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RazorpayApiIntegration(amount: 100, eventId: widget.eventId,),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget _rating(BuildContext context) {
  return DottedBorder(
    color: Colors.grey,
    strokeWidth: 1,
    dashPattern: const [10, 4],
    child: Container(
      decoration: const BoxDecoration(shape: BoxShape.rectangle),
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          const Column(
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber),
                  Text("00/10", style: TextStyle(fontSize: 17)),
                  Text("  Your rating matters",
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
              SizedBox(height: 7),
              Row(
                children: [
                  Text("Add your Ratings and Reviews",
                      style: TextStyle(fontSize: 16)),
                ],
              ),
            ],
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.blue, width: 1),
            ),
            child: TextButton(
              onPressed: () {
                rateComment(context);
              },
              child: const Text("Rate Now", style: TextStyle(fontSize: 15)),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<dynamic> rateComment(BuildContext context) {
  final ImagePicker _picker = ImagePicker();

  Future<void> pickMedia({required bool isImage}) async {
    final XFile? media = isImage
        ? await _picker.pickImage(source: ImageSource.gallery)
        : await _picker.pickVideo(source: ImageSource.gallery);

    if (media != null) {
      if (kDebugMode) {
        print('Selected media path: ${media.path}');
      }
    }
  }

  return showDialog(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Dialog(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.only(bottom: 15),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ],
                  ),
                  RatingBar.builder(
                    initialRating: 3,
                    minRating: 0,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      if (kDebugMode) {
                        print(rating);
                      }
                    },
                  ),
                  const SizedBox(height: 35),
                  Container(
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: TextFormField(maxLines: 10),
                  ),
                  DottedBorder(
                    dashPattern: const [8, 3],
                    child: TextButton.icon(
                      icon: const Icon(Icons.comment),
                      onPressed: () {
                        pickMedia(isImage: true);
                      },
                      label: const Text("Add Photos or Videos"),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 150, 222, 255),
                    ),
                    child: const Text("Submit"),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _about(String data) {
  return Container(
    margin: const EdgeInsets.all(10),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text("About", style: TextStyle(fontSize: 18)),
        Text(data),
      ],
    ),
  );
}
