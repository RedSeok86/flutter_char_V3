import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:papucon/pages/friend_list.dart';
import 'package:papucon/theme.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/rendering.dart';

/// This is the screen that you'll see when the app starts
class ParkingService extends StatefulWidget {
  @override
  _ParkingServiceState createState() => _ParkingServiceState();
}

class _ParkingServiceState extends State<ParkingService> {
  GlobalKey _globalKey = new GlobalKey();

  @override
  void initState() {
    print('get UID $uid');
    super.initState();
    _requestPermission();
  }

  Future<dynamic> _capturePng() async {
    try {
      print('inside');
      RenderRepaintBoundary boundary =
          _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData.buffer.asUint8List();
      var bs64 = base64Encode(pngBytes);

      print(pngBytes);
      print(bs64);
      setState(() {});
      return pngBytes;
    } catch (e) {
      print(e);
    }
  }

  Future<String> _createFileFromQR(var encodedStr) async {
    //final encodedStr = "...";
    print(encodedStr.runtimeType);
    Uint8List bytes = base64.decode(encodedStr);
    String dir = (await getApplicationDocumentsDirectory()).path;
    String fullPath = '$dir/parking.png';
    print("local file full path ${fullPath}");
    File file = File(fullPath);
    await file.writeAsBytes(bytes).then((value) => print('파일 쓰기 ${value}'));
    print(file.path);

    final result = await ImageGallerySaver.saveImage(bytes)
        .then((value) => print('결과는?? $value'));

    return file.path;
  }

  void _capture() async {
    print("START CAPTURE");
    var renderObject = _globalKey.currentContext.findRenderObject();
    if (renderObject is RenderRepaintBoundary) {
      var boundary = renderObject;
      ui.Image image = await boundary.toImage();
      final directory = (await getApplicationDocumentsDirectory()).path;
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      print(pngBytes);
      File imgFile = new File('$directory/screenshot.png');
      imgFile.writeAsBytes(pngBytes);
      print("FINISH CAPTURE ${imgFile.path}");
    }
  }

  _saveScreen() async {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final result =
        await ImageGallerySaver.saveImage(byteData.buffer.asUint8List())
            .then((value) => print('save $value'));
    //print(result);
    // _toastInfo(result.toString());
  }

  _requestPermission() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.storage],
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    final message =
        // ignore: lines_longer_than_80_chars
        'http://parking.papucon.com:3000/' + uid;

    final qrFutureBuilder = FutureBuilder(
      future: _loadOverlayImage(),
      builder: (ctx, snapshot) {
        final size = 280.0;
        if (!snapshot.hasData) {
          return Container(width: size, height: size);
        }
        return CustomPaint(
          size: Size.square(size),
          painter: QrPainter(
            emptyColor: Colors.white,
            data: message,
            version: QrVersions.auto,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Color(0xFFD0393e),
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Colors.black,
            ),
            // size: 320.0,
            embeddedImage: snapshot.data,
            embeddedImageStyle: QrEmbeddedImageStyle(
              size: Size.square(60),
            ),
          ),
        );
      },
    );

    return Container(
      color: const Color(0xFFf2f3f6),
      padding: EdgeInsets.only(top: 23.0),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text('주차 알림 서비스',
                  style:
                      TextStyle(color: Colors.black, fontSize: 23, height: 1))
              .tr(),
          toolbarHeight: 60,
          backgroundColor: Color(0xFFf2f3f6),
          elevation: 0.0,
          bottom: PreferredSize(
            child: SizedBox(height: 10),
          ),
          bottomOpacity: 0.1,
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
        ),
        body: Material(
          color: Color(0xFFf2f3f6),
          child: SafeArea(
            top: true,
            bottom: true,
            child: Container(
              child: Column(
                children: <Widget>[
                  RepaintBoundary(
                      key: _globalKey,
                      child: Container(
                        padding: EdgeInsets.all(50),
                        decoration: BoxDecoration(
                          color: Color(0xFFf2f3f6),
                        ),
                        child: Center(
                          child: qrFutureBuilder,
                        ),
                      )),
                  SizedBox(height: 30),
                  FlatButton(
                      color: Color(0xFF3C3C3C),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2,
                        height: 56,
                        alignment: Alignment.center,
                        child:
                            Text('다운로드', style: TextStyle(color: Colors.white))
                                .tr(),
                      ),
                      onPressed: () async {
                        final directory =
                            (await getExternalStorageDirectory()).path;
                        File imgFile = File('$directory/screenshot.png');
                        //                    imgFile.writeAsBytes(await _capturePng()).then((value) => print(value));
                        final result = await ImageGallerySaver.saveImage(
                            Uint8List.fromList(await _capturePng()),
                            quality: 60,
                            name: "parking");
                        print(result);
                        OpenFile.open(
                            result.toString().replaceAll('file://', ''));
                        //  return file.path;
                      }),
//                Padding(
//                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40)
//                      .copyWith(bottom: 40),
//                  child: Text(message),
//                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<ui.Image> _loadOverlayImage() async {
    final completer = Completer<ui.Image>();
    final byteData = await rootBundle.load('assets/icon/ic_launcher.png');
    ui.decodeImageFromList(byteData.buffer.asUint8List(), completer.complete);

    return completer.future;
  }
}
