import 'dart:convert';
import 'dart:io';

import 'package:balapp/consts.dart';
import 'package:balapp/utils/call_apis.dart';
import 'package:balapp/utils/database_holder.dart';
import 'package:balapp/widgets/dialogs/confirm_dialog.dart';
import 'package:balapp/widgets/dialogs/connect_dialog.dart';
import 'package:balapp/widgets/horizontal_line.dart';
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
      appBar: PreferredSize(
        preferredSize: Size(100.w, 6.5.h),
        child: AppBar(),
      ),
      body: ListView(
        children: [
          StatefulBuilder(builder: (context, setState) {
            return Consumer<DatabaseHolder>(
              builder: (context, db, _) {
                return ListTile(
                  onTap: () async {
                    await showConnectDialog(context, true);
                    setState(() {});
                  },
                  contentPadding: EdgeInsets.fromLTRB(4.w, 1.h, 3.w, 1.h),
                  iconColor: Colors.black,
                  leading: Icon(Icons.wifi_tethering,
                      color: db.isWebsocketOpen
                          ? Colors.lightGreen
                          : db.isWebsocketOpen == false
                          ? Colors.redAccent
                          : null),
                  title: const Text("Connexion au serveur local"),
                  subtitle: Text(db.isWebsocketOpen == true
                      ? "Connexion établie"
                      : db.isWebsocketOpen == false
                      ? "Erreur lors de la connexion"
                      : "Vérification..."),
                );
              }
            );
          }),
          const HorizontalLine(),
          ListTile(
            onTap: () async {

              Share.shareXFiles([XFile("${context.read<DatabaseHolder>().dbPath}/db.json", name: "database.json")]);
            },
            contentPadding: EdgeInsets.fromLTRB(4.w, 1.h, 3.w, 1.h),
            iconColor: Colors.black,
            leading: const Icon(
              Icons.send_rounded,
            ),
            title: const Text("Exporter les données"),
            subtitle: const Text("Exporter la base locale au format standard"),
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
