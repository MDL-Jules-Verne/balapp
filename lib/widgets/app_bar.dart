import 'package:balapp/consts.dart';
import 'package:balapp/utils/is_local_server_connected.dart';
import 'package:balapp/widgets/connect_dialog.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CustomAppBar extends PreferredSize {
  CustomAppBar({Key? key, required this.scannerName}) : super(key: key, child: Container(), preferredSize: Size(100.w, 6.5.h));
  final String scannerName;

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size(100.w, 6.5.h),
      child: AppBar(
        title: Text(scannerName),
        actions: [
          StatefulBuilder(builder: (context, setState) {
            return FutureBuilder(
                future: isLocalServerConnected(context),
                builder: (context, res) {
                  return IconButton(
                    onPressed: () async {
                      await showConnectDialog(context);
                      setState(() {});
                    },
                    icon: Icon(Icons.wifi_tethering,
                        color: res.data == true
                            ? Colors.lightGreen
                            : res.data == false
                            ? Colors.redAccent
                            : null),
                  );
                });
          }),
          IconButton(
            onPressed: () async {
              Navigator.pushNamed(context, "/browseTickets");
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: ()=> saveTickets(context),
            icon: const Icon(Icons.save),
          ),
          IconButton(
            onPressed: () async {
              Navigator.pushNamed(context, "/settings");
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
    );
  }
}
