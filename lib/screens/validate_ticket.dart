import 'package:balapp/utils/db.dart';
import 'package:balapp/widgets/app_bar.dart';
import 'package:balapp/widgets/validate_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class TicketValidator extends StatelessWidget {
  const TicketValidator({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    MobileScannerController controller = MobileScannerController();
    List lastBarcodes = [];
    return Consumer<DatabaseHolder>(builder: (context, db, _) {
      return Scaffold(
        appBar: CustomAppBar(
          scannerName: db.scannerName,
        ),
        body: MobileScanner(
          controller: controller,
          allowDuplicates: true,
          onDetect: (Barcode barcode, MobileScannerArguments? args) async {
            // TODO: use barcode.offset to add a mask
            // TODO: add torch control
            // Ripoff of the builtin allowDuplicates but this ones forgets barcodes after 500ms
            if(lastBarcodes.contains(barcode.rawValue)) return;
            lastBarcodes.add(barcode.rawValue);
            Future.delayed(const Duration(milliseconds: 500), ()=>lastBarcodes.remove(barcode.rawValue));

            controller.stop();
            if (barcode.rawValue == null) {
              debugPrint('Failed to scan Barcode');
            } else {
              final String code = barcode.rawValue!;
              debugPrint('Barcode found! $code');

              int ticketIndex = db.findTicketIndex(code);
              if (ticketIndex == -1) {
                await showErrorValidateDialog(context, "Erreur", "Ce ticket n'existe pas", ValidateErrorReasons.notFound);
                return controller.start();
              }

              Ticket ticket = db.returnTicketAsClass(db.value[ticketIndex]);
              if (ticket.hasEntered == true) {
                await showErrorValidateDialog(context, "Erreur", "Ce ticket a déjà été utilisé", ValidateErrorReasons.alreadyEntered);
                return controller.start();
              } else if (ticket.nom == "") {
                await showErrorValidateDialog(context, "Erreur", "Ce ticket n'a pas été acheté", ValidateErrorReasons.notBought);
                return controller.start();
              }

              // ignore: use_build_context_synchronously
              await showValidateDialog(context, TicketWithIndex.fromTicket(ticket, ticketIndex), db);
              controller.start();
            }
          },

        ),
      );
    });
  }
}
