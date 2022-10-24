import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(100.w, 6.5.h),
        child: AppBar(
          actions: [
            IconButton(
              onPressed: () async {
                Navigator.pushNamed(context, "/settings");
              },
              icon: const Icon(Icons.settings),
            ),
            SizedBox(
              width: 3.w,
            )
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var e in [
            ["/scanner", "Register a ticket"],
            ["/validate", "Validate a ticket"],
            ["/changingRoom", "Check changing room"],
            ["/browseTickets", "Search for a ticket"],
          ])
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, e[0]),
                child: SizedBox(
                  width: 70.w,
                  height: 7.h,
                  child: Center(
                    child: Text(
                      e[1],
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
