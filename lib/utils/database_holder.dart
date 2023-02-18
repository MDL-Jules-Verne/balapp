import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:balapp/utils/call_apis.dart';
import 'package:balapp/utils/init_future.dart';
import 'package:balapp/utils/ticket.dart';
import 'package:balapp/widgets/dialogs/connect_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DatabaseHolder extends ChangeNotifier {
  List<Ticket> db = [];
  String scannerName;
  BuildContext context;
  late List<Ticket> lastScanned;
  void Function() restartApp;
  AppMode appMode;

  bool isOfflineMode;
  bool isWebsocketOpen = false;
  String dbPath;

  int reconnectTries = 5;
  late Stream wsStream;
  late Stream timeout;
  StreamSubscription? timeoutStreamSubscription;
  late WebSocketChannel ws;
  Uri? apiUrl;
  bool ignoreNextDisconnect = false;

  // late List<Ticket> lastScannedGlobal;
  void resetDb(List value, Uri? apiUrl, [bool isFromConstructor = false]) {
    if (!isFromConstructor) {
      this.apiUrl = apiUrl;
    }
    if (!isOfflineMode) {
      ws = WebSocketChannel.connect(this.apiUrl!);
      wsStream = ws.stream.asBroadcastStream();
      isWebsocketOpen = ws.closeCode == null;
      _listenToStream();
      reconnectTries = 5;
    }
    _repopulateDb(value);
    if (appMode == AppMode.bal) {
      lastScanned = db.where((Ticket e) => e.whoScanned == scannerName).toList();
      lastScanned.sort((a, b) => b.timestamps["entered"].compareTo(a.timestamps["entered"]));
    } else if (appMode == AppMode.buy) {
      lastScanned = db.where((Ticket e) => e.whoEntered == scannerName).toList();
      // print(lastScanned.where((e)=>e.timestamps[]));
      lastScanned.sort((a, b) => b.timestamps["registered"].compareTo(a.timestamps["registered"]));
    }
    notifyListeners();
    writeAllToDisk();
  }

  void editAndSaveTicket(Ticket newTicket, int ticketIndex) {
    if (isOfflineMode) newTicket.isNotSync = true;
    db[ticketIndex] = newTicket;
    writeAllToDisk();
  }

  void startOfflineMode() {
    isOfflineMode = true;
    niceWsClose();
    notifyListeners();
  }

  void stopOfflineMode(Uri apiUrl) async {
    List<Ticket> unsavedTickets = db.where((element) => element.isNotSync == true).toList();
    Response result = await httpCall("/syncOfflineMode", HttpMethod.post, apiUrl,
        body: jsonEncode(unsavedTickets.map((e) => e.toJson()).toList()));
    if (result.statusCode < 200 && result.statusCode > 299) {
      return;
    }
    this.apiUrl = apiUrl;
    await reDownloadDb(true);
    restartApp();
  }

  void _repopulateDb(List dbAsJson) {
    db = [];
    for (var e in dbAsJson) {
      db.add(Ticket.fromJson(e));
    }
  }

  void niceWsClose() {
    ignoreNextDisconnect = true;
    isWebsocketOpen = false;
    timeoutStreamSubscription?.cancel();
    ws.sink.close();
    notifyListeners();
  }

  void tryReconnect() async {
    if (isOfflineMode) throw Exception("Offline mode, cannot try to reconnect");
    niceWsClose();
    List? wsData = await connectToServer(context, false, uri: apiUrl!, setError: (e) => print(e))
        .timeout(const Duration(milliseconds: 7500), onTimeout: () => null);
    if (wsData != null) resetDb(wsData[2], wsData[0]);
    Timer.periodic(const Duration(milliseconds: 7500), (Timer timer) async {
      if (!isWebsocketOpen) {
        wsData = await connectToServer(context, false, uri: apiUrl!, setError: (e) => print(e));
        if (wsData != null) resetDb(wsData![2], wsData![0]);
      } else {
        timer.cancel();
      }
    });
  }

  void setContext(BuildContext context) {
    this.context = context;
  }

  void _listenToStream() {
    ws.sink.add("name$scannerName");
    wsStream.listen((message) async {
      if (message == "testConnection") {
        ws.sink.add("testConnection");
      } else {
        Map messagePayload = jsonDecode(message);
        if (messagePayload["messageType"] == "sync") {
          Ticket ticketUpdate = Ticket.fromJson(messagePayload["fullTicket"]);

          int index = db.indexWhere((element) => element.id == ticketUpdate.id);
          if (index != -1) {
            db[index] = ticketUpdate;
            await writeAllToDisk();
          }
          ws.sink.add(jsonEncode({"messageType": "updateReceived", "ticket": ticketUpdate.id}));
          notifyListeners();
        }
      }
    }, onDone: () {
      if (ignoreNextDisconnect == true) {
        ignoreNextDisconnect = false;
        return;
      }
      print("done");
      isWebsocketOpen = false;
      notifyListeners();
      tryReconnect();
    }, onError: (err) {
      if (ignoreNextDisconnect == true) {
        ignoreNextDisconnect = false;
        return;
      }
      print(err);
      isWebsocketOpen = false;
      notifyListeners();
      tryReconnect();
    });
    Stream timeoutStream = wsStream.timeout(const Duration(milliseconds: kDebugMode ? 20000 : 5000), onTimeout: (_) {
      niceWsClose();
      print("clear3");
      tryReconnect();
    });
    timeoutStreamSubscription = timeoutStream.listen((event) {});
  }

  Future<void> writeAllToDisk() async {
    await File("$dbPath/db.json").writeAsString(jsonEncode(db.map((e) => e.toJson()).toList()));
  }

  DatabaseHolder(List value, this.dbPath, this.apiUrl, this.scannerName, this.context, this.appMode, this.restartApp,
      this.isOfflineMode) {
    resetDb(value, apiUrl, true);
  }

  Future<void> reDownloadDb([bool force = false]) async {
    if ((isOfflineMode || apiUrl == null) && !force) throw Exception("Offline mode, cannot download database");
    Response result = await httpCall("/downloadDb", HttpMethod.get, apiUrl!);
    if (result.statusCode >= 200 && result.statusCode < 299) {
      List ticketsAsJson = jsonDecode(result.body);
      _repopulateDb(ticketsAsJson);
      await writeAllToDisk();
    } else {
      throw Exception("No connection to server, cannot download DB");
    }
    notifyListeners();
  }

  List<Locker> getLockers() {
    //TODO trouver une manière de récupérer les vestiaires (sûrement les envoyer avec chaque sync)
    Map<String, List<int>> totalPerLocker = {
      "Sac": [for (int i = 0; i < 7; i++) 0],
      "Vetement": [for (int i = 0; i < 7; i++) 0],
      "Relou": [for (int i = 0; i < 7; i++) 0]
    };
    for (Ticket ticket in db) {
      for (Cloth cloth in ticket.clothes) {
        totalPerLocker[cloth.clothType]![cloth.idNumber]++;
      }
    }
    List<Locker> returnValue = [];
    int index = 0;
    for (int i in totalPerLocker["Sac"]!) {
      Locker locker = Locker(i + 1, remainingSpace: {}, totalSpace: {});
      for (String type in ["Sac", "Vetement", "Relou"]) {
        locker.remainingSpace[type] = totalPerLocker[type]![index];
        locker.totalSpace[type] = totalPerLocker[type]![index];
      }

      returnValue.add(locker);
      index++;
    }
    return returnValue;
  }
}

class Locker {
  int idNumber;
  Map<String, int> remainingSpace;
  Map<String, int> totalSpace;

  Locker(this.idNumber, {required this.remainingSpace, required this.totalSpace});

  @override
  String toString() {
    return "{idNumber: $idNumber, remainingSpace: $remainingSpace, totalSpace: $totalSpace}";
  }
}
