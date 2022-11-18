import 'package:balapp/consts.dart';
import 'package:balapp/widgets/custom_text_input.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class RegisterTicket extends StatefulWidget {
  const RegisterTicket({Key? key}) : super(key: key);

  @override
  State<RegisterTicket> createState() => _RegisterTicketState();
}

class _RegisterTicketState extends State<RegisterTicket> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

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
          padding: const EdgeInsets.fromLTRB(31, 22, 33, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enregistrer un ticket",
                style: h3,
              ),
              const SizedBox(
                height: 10,
              ),
              CustomTextInput(
                controller: firstNameController,
                label: 'Prénom',
                showTopLabel: false,
              ),
              const SizedBox(
                height: 5,
              ),
              CustomTextInput(
                controller: lastNameController,
                label: 'Nom',
                showTopLabel: false,
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
                      ClipSmoothRect(
                        radius: SmoothBorderRadius(
                          cornerRadius: 9,
                          cornerSmoothing: 1,
                        ),
                        child: Container(
                          // padding: EdgeInsets.fromLTRB(16, 8, 15, 5),
                          width: 64,
                          height: 39,
                          color: kGreenLight,
                          child: const Center(
                              child: Text(
                            "INT",
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: kWhite),
                          )),
                        ),
                      ),
                      const SizedBox(
                        width: 20.5,
                      ),
                      ClipSmoothRect(
                        radius: SmoothBorderRadius(
                          cornerRadius: 9,
                          cornerSmoothing: 1,
                        ),
                        child: Container(
                          // padding: EdgeInsets.fromLTRB(16, 8, 15, 5),
                          width: 64,
                          height: 39,
                          color: kPurpleLight,
                          child: const Center(
                              child: Text(
                            "EXT",
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: kWhite),
                          )),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              print(TextButton(
                                onPressed: () {},
                                child: Container(),
                              ).defaultStyleOf(context));
                            },
                            style: TextButton.styleFrom(
                                padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                                alignment: Alignment.topCenter,
                                textStyle:
                                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, fontFamily: "Inter"),
                                foregroundColor: kBlack),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.check),
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
          ),
        ),
      ),
    );
  }
}
