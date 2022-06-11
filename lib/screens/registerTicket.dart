import 'dart:io';
import 'package:flutter/services.dart';
import 'package:balapp/widgets/custom_text_input.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';


class TicketRegister extends StatelessWidget {
  const TicketRegister({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String ticketId = "";
    final args = ModalRoute.of(context)!.settings.arguments;
    ticketId = args as String;

    debugPrint(ticketId);
    return FutureBuilder(
      future: (() async {
        int time = DateTime.now().millisecondsSinceEpoch;
        //Todo: Load ça dans la ram au lancement c'est que 40ko
        String db = await rootBundle.loadString('db/db.csv');
        print(DateTime.now().millisecondsSinceEpoch - time);
        print(db);
        // return "";
      })(),
      builder: (context, res){
        return TicketRegisterCore(ticketId: ticketId,);
      }
    );
  }
}


class TicketRegisterCore extends StatefulWidget {
  const TicketRegisterCore({Key? key, required this.ticketId}) : super(key: key);
  final String ticketId;
  @override
  State<TicketRegisterCore> createState() => _TicketRegisterCoreState();
}

class _TicketRegisterCoreState extends State<TicketRegisterCore> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  String currentlySelectedOrigin = "internal";

  @override
  void dispose(){
    super.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w,),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: 8.h,),
          const Center(child: Text("Nouveau billet", style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),)),
          SizedBox(height: 6.h,),

          // First name
          CustomTextInput(controller: firstNameController, label: "Prénom"),
          SizedBox(height: 2.h,),

          // Last name
          CustomTextInput(controller: lastNameController, label: "Nom"),

          SizedBox(height: 3.h,),
          StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Radio<String>(
                        visualDensity: VisualDensity.compact,
                        value: "internal",
                        groupValue: currentlySelectedOrigin,
                        onChanged: (String? value){
                          setState((){
                            currentlySelectedOrigin = value!;
                          }); //selected value
                        }
                      ),
                      const Text("Interne"),
                    ],
                  ),
                  Row(
                    children: [
                      Radio<String>(
                          visualDensity: VisualDensity.compact,
                          value: "external",
                          groupValue: currentlySelectedOrigin,
                          onChanged: (String? value){
                            setState((){
                              currentlySelectedOrigin = value!;
                            }); //selected value
                          },
                      ),
                      const Text("Externe")
                    ],
                  ),
                ],
              );
            }
          ),
          SizedBox(height: 7.h,),
          Align(
            alignment: Alignment.topCenter,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(65.w, 7.h),
                textStyle: TextStyle(fontSize: 2.85.h, fontWeight: FontWeight.w500),
              ),
              // color: Colors.blue,
              child: const Text("CONFIRMER"),
              onPressed: () async {
                // Add to db
                String path = (await getApplicationDocumentsDirectory()).path;
                await File('$path/data.txt').writeAsString("${firstNameController.text},${lastNameController.text},${widget.ticketId}");
                print(File('$path/data.txt').readAsStringSync());
                // ignore: use_build_context_synchronously
                // Navigator.of(context).popAndPushNamed("/");

                // Navigator.of(context).pushNamed("/");
              },
            ),
          ),
        ],),
      ),
    );
  }
}

