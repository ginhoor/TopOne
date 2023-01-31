// import 'package:flutter/material.dart';
// import 'package:share_plus/share_plus.dart';

// void _onShareWithResult(BuildContext context) async {
//   final box = context.findRenderObject() as RenderBox?;
//   final scaffoldMessenger = ScaffoldMessenger.of(context);
//   ShareResult shareResult;
//   // if (imagePaths.isNotEmpty) {
//   //   final files = <XFile>[];
//   //   for (var i = 0; i < imagePaths.length; i++) {
//   //     files.add(XFile(imagePaths[i], name: imageNames[i]));
//   //   }
//   //   shareResult = await Share.shareXFiles(files,
//   //       text: text,
//   //       subject: subject,
//   //       sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
//   // } else {
//   //   shareResult = await Share.shareWithResult(text,
//   //       subject: subject,
//   //       sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
//   // }
//   // scaffoldMessenger.showSnackBar(getResultSnackBar(shareResult));
// }

// SnackBar getResultSnackBar(ShareResult result) {
//   return SnackBar(
//     content: Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("Share result: ${result.status}"),
//         if (result.status == ShareResultStatus.success)
//           Text("Shared to: ${result.raw}")
//       ],
//     ),
//   );
// }
