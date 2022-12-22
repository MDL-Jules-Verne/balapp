import 'dart:convert';

import 'package:balapp/consts.dart';
import 'package:balapp/utils/call_apis.dart';
import 'package:balapp/utils/database_holder.dart';
import 'package:balapp/utils/ticket.dart';
import 'package:balapp/widgets/custom_text_input.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:http/src/response.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class RegisterTicket extends StatefulWidget {
  const RegisterTicket(this.ticketId, this.apiUrl, this.dismiss, {Key? key}) : super(key: key);
  final String ticketId;
  final Uri apiUrl;
  final void Function() dismiss;

  @override
  State<RegisterTicket> createState() => _RegisterTicketState();
}

class _RegisterTicketState extends State<RegisterTicket> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  String? error;
  String? fatalError;
  bool? ignoreError;
  Ticket? ticket;
  bool? isExternal;

  get isReady{
    return isExternal != null && firstNameController.text.isNotEmpty && lastNameController.text.isNotEmpty;
  }

  void setInternalExternal(bool isExternal) {
    setState((){
      this.isExternal = isExternal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipSmoothRect(
      radius: const SmoothBorderRadius.only(
        topLeft: SmoothRadius(
          cornerRadius: 24,
          cornerSmoothing: 1,
        ),
        topRight: SmoothRadius(
          cornerRadius: 24,
          cornerSmoothing: 1,
        ),
      ),
      child: Container(
        color: kWhite,
        height: 40.h,
        width: 100.w,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(31, 18, 33, 0),
          child: FutureBuilder(future: Future(() async {
            if(ignoreError == true) return "done";
            Response result =
                await httpCall("/ticketRegistration/ticketInfo/${widget.ticketId}", HttpMethod.get, widget.apiUrl);

            if (result.statusCode > 299 || result.statusCode < 200) {
              try {
                String res = jsonDecode(result.body)["res"];
                fatalError = res.toString();
                return "done";
              } catch (e,s) {
                print(e);
                print(s);
                fatalError = "Http code non successful nor parsable";
                return "done";
              }
            }
            try {
              Map<String, dynamic> data = Map.castFrom(json.decode(result.body));
              if (data["success"] == false) return {"error": true, "data": "HTTP call not successful"};

              ticket = Ticket.fromJson(data["res"]);
              if(ticket!.prenom == "") {
                return "done";
              } else {
                fatalError = "Ce ticket est déjà utilisé";
                return "done";
              }
            } catch (e, s) {
              print(e);
              print(s);
              fatalError = "Unexpected error (try/catch)";
              return "done";
            }
          }), builder: (context, AsyncSnapshot<Object> res) {
            if (!res.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (fatalError != null) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "Impossible de lire le ticket:",
                      style: h3.apply(color: kRed),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Text(
                      fatalError!,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: (){
                        widget.dismiss();
                      },
                      child: const Text("Ok")
                    ),
                    TextButton(
                        onLongPress: (){
                          setState(() {
                            firstNameController.text = ticket?.prenom ?? "";
                            lastNameController.text = ticket?.nom ?? "";
                            fatalError = null;
                            ignoreError = true;
                          });
                        },
                        onPressed: () {  },
                        child: const Text("Modifier quand même (appui long)")
                    )
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Ticket #${widget.ticketId}",
                      style: h3,
                    ),
                    IconButton(onPressed: widget.dismiss, icon: const Icon(Icons.clear))
                  ],
                ),
                const SizedBox(
                  height: 0,
                ),
                CustomTextInput(
                  callback: (_){
                    setState(() {});
                  },
                  controller: firstNameController,
                  showLabelText: false,
                  label: 'Prénom',
                ),
                const SizedBox(
                  height: 5,
                ),
                CustomTextInput(
                  callback: (String? input){
                    setState(() {});
                  },
                  showLabelText: false,
                  controller: lastNameController,
                  label: 'Nom',
                ),
                if (error != null)
                  Text(
                    error!,
                    style: const TextStyle(color: kRed, fontSize: 18),
                  ),
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setInternalExternal(false);
                          },
                          child: ClipSmoothRect(
                            radius: SmoothBorderRadius(
                              cornerRadius: 9,
                              cornerSmoothing: 1,
                            ),
                            child: Container(
                              // padding: EdgeInsets.fromLTRB(16, 8, 15, 5),
                              width: 64,
                              height: 39,
                              color: isExternal == false ? kGreen : kGreenLight,
                              child: const Center(
                                  child: Text(
                                "INT",
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: kWhite),
                              )),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20.5,
                        ),
                        GestureDetector(
                          onTap: () {
                            setInternalExternal(true);
                          },
                          child: ClipSmoothRect(
                            radius: SmoothBorderRadius(
                              cornerRadius: 9,
                              cornerSmoothing: 1,
                            ),
                            child: Container(
                              // padding: EdgeInsets.fromLTRB(16, 8, 15, 5),
                              width: 64,
                              height: 39,
                              color: isExternal == true ? kPurple : kPurpleLight,
                              child: const Center(
                                  child: Text(
                                "EXT",
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: kWhite),
                              )),
                            ),
                          ),
                        ),
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 1,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: !isReady ? null : () async {
                                ticket!.prenom = firstNameController.text;
                                ticket!.nom = lastNameController.text;
                                ticket!.externe = isExternal!;
                                ticket!.whoEntered = context.read<DatabaseHolder>().scannerName;
                                Response result = await httpCall("/ticketRegistration/enterTicket/", HttpMethod.post, widget.apiUrl, body: jsonEncode(ticket!.toJson()));
                                if (result.statusCode > 299 || result.statusCode < 200) {
                                  setState(() {
                                    error = result.body;
                                  });
                                } else {
                                  widget.dismiss();
                                }
                              },
                              style: TextButton.styleFrom(
                                  padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                                  alignment: Alignment.topCenter,
                                  textStyle:
                                      const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, fontFamily: "Inter"),
                                  foregroundColor: isReady ? kBlack : kBlack.withOpacity(0.5)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.check,),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text("DONE"),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            );
          }),
        ),
      ),
    );
  }
}
