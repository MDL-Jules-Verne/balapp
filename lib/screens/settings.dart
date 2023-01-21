import 'package:balapp/consts.dart';
import 'package:balapp/utils/database_holder.dart';
import 'package:balapp/widgets/dialogs/connect_dialog.dart';
import 'package:balapp/widgets/horizontal_line.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 26, 25, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 15.5),
                child: Text(
                  "Settings",
                  style: h2,
                ),
              ),
              SizedBox(height: 3.3.h),
              Consumer<DatabaseHolder>(builder: (context, db, _) {
                  return GestureDetector(
                    onTap: () async {
                      List? wsData = await showConnectDialog(context, true, db.apiUrl.authority);
                      if(wsData == null) return;
                      db.niceWsClose();
                      db.resetDb(wsData[2], wsData[0], );

                    },
                    child: Row(
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(31, 21, 10, 22),
                            decoration: ShapeDecoration(
                              shadows: [
                                BoxShadow(
                                  offset: const Offset(0,7),
                                  color: db.isWebsocketOpen ? kGreenLight.withOpacity(.60) : kRed.withOpacity(.5),
                                  blurRadius: 20
                                )
                              ],
                              color: db.isWebsocketOpen ? kGreen : kRed,
                              shape: SmoothRectangleBorder(
                                borderRadius: SmoothBorderRadius(
                                  cornerRadius: 15,
                                  cornerSmoothing: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  db.isWebsocketOpen ? Icons.wifi_tethering : Icons.wifi_tethering_off,
                                  size: 42,
                                  color: db.isWebsocketOpen ? kBlack : kWhite,
                                  // color: db.isWebsocketOpen ? kBlack : kWhite,
                                ),
                                const SizedBox(width: 20,),
                                Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Connexion au serveur",
                                        style: bodyTitle.apply(
                                          color: db.isWebsocketOpen ? kBlack : kWhite,
                                        ),
                                      ),
                                      const SizedBox(height: 1, ),
                                      const SizedBox(height: 1, ),
                                      Text(
                                        db.isWebsocketOpen ? "Connecté" :"Erreur lors de la connexion",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: db.isWebsocketOpen ? kBlack : kWhite,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              // const HorizontalLine(),
              const SizedBox(height: 19,),
              ListTile(
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 15,
                    cornerSmoothing: 1,
                  ),
                ),
                onTap: () async {
                  DatabaseHolder db = context.read<DatabaseHolder>();
                  await db.writeAllToDisk();
                  await Share.shareXFiles([XFile("${db.dbPath}/db.json", name: "db.json")]);
                },
                // contentPadding: EdgeInsets.fromLTRB(4.w, 1.h, 3.w, 1.h),
                iconColor: Colors.black,
                leading: const Icon(
                  Icons.upload_outlined,
                  size: 42,
                ),
                title: const Text("Exporter les données", style: bodyTitle,),
                subtitle: const Text("Exporter la base locale au format standard", style: body),
              ),
              /*const HorizontalLine(),
              ListTile(
                onTap: () => saveTickets(context),
                contentPadding: EdgeInsets.fromLTRB(4.w, 1.h, 3.w, 1.h),
                iconColor: Colors.black,
                leading: const Icon(
                  Icons.save,
                ),
                title: const Text("Synchroniser les bases"),
                subtitle: const Text(
                    "Statut actuel de synchronisation: inconnu"),
              ),*/
              /*const HorizontalLine(),
              ListTile(
                onTap: () async {
                  await showConfirmDialog(context, "Supprimer base locale",
                      "ATTENTION, entraîne la perte de toutes les données non syncronisées", () async {
                    var db = context.read<DatabaseHolder>();
                    await File('${db.dbPath}/db.csv').delete();
                    db.rebuildApp();
                  });
                },
                contentPadding: EdgeInsets.fromLTRB(4.w, 1.h, 3.w, 1.h),
                iconColor: Colors.black,
                leading: const Icon(
                  Icons.delete,
                ),
                title: const Text("Supprimer la base locale"),
                subtitle: const Text(
                    "Attention, cette action est définitive et entraîne la perte de toutes les données qui n'ont pas été synchronisées"),
              ),*/
              /*const HorizontalLine(),
              ListTile(
                onTap: () {
                  showConfirmDialog(context, "Copier la base locale sur le serveur",
                      "ATTENTION, cela supprime TOUTES les données présentes sur le serveur", () async {
                    var db = context.read<DatabaseHolder>();
                    var res = await httpCall("/upload/initDb", HttpMethod.post, db.localServer,
                        body: jsonEncode({"data": db.noHeaderValue, "firstLine": db.value[0]}));
                    // ignore: use_build_context_synchronously
                    showSuccessBanner(context, res, successMessage: "Copie effectuée");
                  });
                },
                contentPadding: EdgeInsets.fromLTRB(4.w, 1.h, 3.w, 1.h),
                iconColor: Colors.black,
                leading: const Icon(
                  Icons.cloud_upload,
                ),
                title: const Text("Copier la base locale sur le serveur"),
                subtitle: const Text("Attention, cela supprime toutes les données présentes sur le serveur"),
              )*/
            ],
          ),
        ),
      ),
    );
  }
}

void showSuccessBanner(BuildContext context, Response res, {String successMessage = 'Action effectuée'}) {
  bool callSuccess = res.statusCode >= 200 && res.statusCode < 299;

  var scaffoldMessenger = ScaffoldMessenger.of(context);

  Future.delayed(const Duration(seconds: 4), () => {scaffoldMessenger.hideCurrentMaterialBanner()});

  // ignore: use_build_context_synchronously
  scaffoldMessenger.showMaterialBanner(MaterialBanner(
    elevation: 5,
    backgroundColor: Colors.white,
    leading: Icon(
      callSuccess ? Icons.check : Icons.clear,
      color: callSuccess ? Colors.green : Colors.red,
    ),
    content: Text(
      callSuccess ? successMessage : "Error occured when calling API",
      style: TextStyle(color: callSuccess ? Colors.green : Colors.red, fontSize: callSuccess ? null : 21),
    ),
    actions: fakeWidgetArray,
  ));
}
