import 'package:balapp/utils/db.dart';
import 'package:balapp/widgets/prefs_inherited.dart';
import 'package:balapp/widgets/custom_text_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TicketRegister extends StatefulWidget {
  const TicketRegister({Key? key}) : super(key: key);

  @override
  State<TicketRegister> createState() => _TicketRegisterState();
}

class _TicketRegisterState extends State<TicketRegister> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  String currentlySelectedOrigin = "internal";
  String ticketId = "";

  @override
  void dispose() {
    super.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    ticketId = args as String;
    return Scaffold(
      appBar: PreferredSize(preferredSize: Size(100.w, 6.5.h), child: AppBar(),),
      body: Consumer<DatabaseHolder>(builder: (context, db, _) {
        TicketUsableState ticketValidity = db.isUsable(ticketId);
        if (!ticketValidity.isUsable) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Column(children: [
              SizedBox(
                width: 100.w,
                height: 15.h,
              ),
              Text(
                ticketValidity.reason ?? "Erreur inconnue, essayez un autre QR code",
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 2.h,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(65.w, 7.h),
                  textStyle: TextStyle(fontSize: 2.85.h, fontWeight: FontWeight.w500),
                ),
                // color: Colors.blue,
                child: const Text("Scanner à nouveau"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(
                height: 2.h,
              ),
              if(InheritedPreferences.of(context)?.prefs.getString("scannerName") == "debug") ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(65.w, 7.h),
                  textStyle: TextStyle(fontSize: 2.85.h, fontWeight: FontWeight.w500),
                ),
                // color: Colors.blue,
                child: const Text("Supprimer"),
                onPressed: () {
                  db.resetTicket(ticketId);
                  Navigator.pop(context);
                },
              ),
            ]),
          );
        }
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 4.w,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 9.h,
              ),
              Center(
                  child: Text(
                "Nouveau billet (#$ticketId)",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              )),
              SizedBox(
                height: 5.h,
              ),

              // First name
              CustomTextInput(controller: firstNameController, label: "Prénom"),
              const Text("Seules lettres et tirets autorisés (accents inclus)"),
              SizedBox(
                height: 2.h,
              ),

              // Last name
              CustomTextInput(controller: lastNameController, label: "Nom", ),
              const Text("Seules lettres et tirets autorisés (accents inclus)"),

              SizedBox(
                height: 3.h,
              ),
              StatefulBuilder(builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Radio<String>(
                            visualDensity: VisualDensity.compact,
                            value: "internal",
                            groupValue: currentlySelectedOrigin,
                            onChanged: (String? value) {
                              setState(() {
                                currentlySelectedOrigin = value!;
                              }); //selected value
                            }),
                        const Text("Interne"),
                      ],
                    ),
                    Row(
                      children: [
                        Radio<String>(
                          visualDensity: VisualDensity.compact,
                          value: "external",
                          groupValue: currentlySelectedOrigin,
                          onChanged: (String? value) {
                            setState(() {
                              currentlySelectedOrigin = value!;
                            }); //selected value
                          },
                        ),
                        const Text("Externe")
                      ],
                    ),
                  ],
                );
              }),
              SizedBox(
                height: 7.h,
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(65.w, 7.h),
                    textStyle: TextStyle(fontSize: 2.85.h, fontWeight: FontWeight.w500),
                  ),
                  // color: Colors.blue,
                  child: const Text("CONFIRMER"),
                  onPressed: () {
                    // Add to db
                    String? scannerName = InheritedPreferences.of(context)?.prefs.getString("scannerName");
                    if (scannerName == null){
                      throw ErrorDescription("Scanner name not found in context");
                    }
                    db.registerTicket(ticketId, scannerName,
                        firstName: firstNameController.text.toLowerCase(),
                        lastName: lastNameController.text.toLowerCase(),
                        isExternal: currentlySelectedOrigin == "external");
                    Navigator.pop(context);
                    // Navigator.of(context).pushNamed("/");
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
