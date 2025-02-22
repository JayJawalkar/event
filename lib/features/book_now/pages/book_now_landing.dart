import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';

class BookNowLanding extends StatefulWidget {
  const BookNowLanding({super.key});

  @override
  State<BookNowLanding> createState() => _BookNowLandingState();
}

class _BookNowLandingState extends State<BookNowLanding> {
  @override
  Widget build(BuildContext context) {
    final spacing = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color.fromRGBO(253, 183, 234, 1),
      appBar: AppBar(),
      body: Center(
        child: Column(
          spacing: spacing.height * 0.05,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DelayedDisplay(
              delay: Duration(milliseconds: 120),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.white),
                ),
                onPressed: () {},
                child: Text('Coming UP soon'),
              ),
            ),
            DelayedDisplay(
              delay: Duration(milliseconds: 160),
              child: Text(
                'We are currently integrating RAZORPAY',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
