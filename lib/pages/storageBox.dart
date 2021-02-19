import 'dart:collection';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery/image_gallery.dart';
import 'package:papucon/model/model.dart';
import 'package:papucon/pages/home_page.dart';
import 'package:papucon/pages/setting_page.dart';
import 'package:papucon/widgets/share_page.dart';
import 'package:papucon/stores/login_store.dart';
import 'package:papucon/theme.dart';
import 'package:papucon/widgets/loading.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

double zeheight = 0;

//김동선
class StorageBox extends StatefulWidget {
  final Profile currentProfile;

  StorageBox({Key key, @required this.currentProfile}) : super(key: key);

  @override
  StorageBoxState createState() => StorageBoxState();
}

class StorageBoxState extends State<StorageBox> {
  File _image;
  bool isChangeSearch;
  bool progressbar = false;
  bool progressUpload = false;
  bool loadmarked = false;
  bool isLoading;
  String imageUrl;
  String fileNames;
  SharedPreferences prefs;
  int fileSize;
  String uid;
  var usingStorage = 0;
  String markFileByte;
  String fileDownName = '';
  double markFileSize = 0.0;
  double taskProgressNum = 0.0;
  double taskProgressUpload = 0.0;
  int sizeLimit = 0;
  int fileViewCtn = 0;
  int fileViewCode = 0;
  int _selectedIndex = 2;

  final FocusNode focusNode = FocusNode();

  final ScrollController listScrollController = ScrollController();

  void getChangeSearch() {
    focusNode.unfocus();
    setState(() {
      isChangeSearch = !isChangeSearch;
    });
  }

  Future<void> getLists() async {
    prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uid') ?? '';

    Firestore.instance
        .collection('Downloads')
        .where('uid', isEqualTo: uid)
        .getDocuments()
        .then((value) {
      if (value.documents.first['volume'] != 0 ||
          value.documents.first['volume'] != null) {
        Firestore.instance.collection('Downloads').document(uid).updateData(
            {'volume': value.documents.first['volume'], 'uid': uid});
        usingStorage = value.documents.first['volume'];
      }
    });
  }

  @override
  void initState() {
    isChangeSearch = false;

    loadImageList();
    getLists();

    super.initState();
  }

  Future<void> _handleStorage() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.storage],
    );
  }

  Future<void> fileSaver(content) async {
    Firestore.instance
        .collection('Downloads')
        .document(uid)
        .collection('storages')
        .document('keepfile')
        .delete();
    var volumes =
        Firestore.instance.collection('Downloads').document(uid).get();
    volumes.then((value) => {
          if (value.data['volume'] == null || value.data['volume'] == 0)
            {
              Firestore.instance
                  .collection('Downloads')
                  .document(uid)
                  .updateData({'volume': fileSize})
            }
          else
            {
              Firestore.instance
                  .collection('Downloads')
                  .document(uid)
                  .updateData({'volume': value.data['volume'] + fileSize})
            }
        });

    Firestore.instance
        .collection('Downloads')
        .document(uid)
        .collection('storages')
        .document(DateTime.now().millisecondsSinceEpoch.toString())
        .setData({
      'content': content,
      'fileName': fileNames,
      'timeStamp': DateTime.now().millisecondsSinceEpoch.toString(),
      'size': fileSize
    });
  }

  Future<File> getFile() async {
    // 1. 텍스트 파일, 2. 문서 파일, 3. 이미지 파일, 4. 비디오 파일, 5. 오디오 파일, 6. 이북 파일, 7. 압축 파일
    File anyFile = await FilePicker.getFile(
      type: FileType.custom,
      allowedExtensions: [
        'txt',
        'log',
        'odt',
        'snb',
        'TXT',
        'LOG',
        'ODT',
        'SNB',
        'csv',
        'xls',
        'xlsx',
        'xml',
        'doc',
        'docx',
        'ppt',
        'pptx',
        'pub',
        'hwp',
        'show',
        'pdf',
        'pages',
        'numbers',
        'key',
        'keynote',
        'odf',
        'ods',
        'odp',
        'tsv',
        'CSV',
        'XLS',
        'XLSX',
        'XML',
        'DOC',
        'DOCX',
        'PPT',
        'PPTX',
        'PUB',
        'HWP',
        'SHOW',
        'PDF',
        'PAGES',
        'NUMBERS',
        'KEY',
        'KEYNOTE',
        'ODF',
        'ODS',
        'ODP',
        'TSV',
        '3gp',
        'avi',
        'mov',
        'mp4',
        'mpeg',
        'mpg',
        'wmv',
        'm4v',
        'flv',
        'ts',
        'ogv',
        '3GP',
        'AVI',
        'MOV',
        'MP4',
        'MPEG',
        'MPG',
        'WMV',
        'M4V',
        'FLV',
        'TS',
        'OGV',
        'm4a',
        'mp3',
        'ogg',
        'wav',
        'wma',
        'flac',
        'aac',
        'tta',
        'tak',
        'M4A',
        'MP3',
        'OGG',
        'WAV',
        'WMA',
        'FLAC',
        'AAC',
        'TTA',
        'TAK',
        'epub',
        'mobi',
        'EPUB',
        'MOBI',
        'zip',
        '7z',
        'rar',
        'alz',
        'egg',
        'ZIP',
        '7Z',
        'RAR',
        'ALZ',
        'EGG',
        'pat',
        'abr',
        'PAT',
        'ABR',
        'ttf',
        'otf',
        'TTF',
        'OTF',
      ],
    );
    return anyFile;
  }

  Future<File> getImgFile() async {
    File anyFile = await FilePicker.getFile(
      type: FileType.image,
    );
    return anyFile;
  }

  Future uploadFile(File file) async {
    String fileName = path.basename(file.path);
    StorageReference reference = FirebaseStorage.instance
        .ref()
        .child(uid + '/' + 'storages/' + fileName);
    StorageUploadTask uploadTask = reference.putFile(file);
    uploadTask.events.listen((event) {
      //여기기
      print('------upload file--------');

      double res = event.snapshot.bytesTransferred / 1024.0;
      double res2 = event.snapshot.totalByteCount / 1024.0;
      fileSize = event.snapshot.bytesTransferred;
      setState(() {
        progressbar = true;
        progressUpload = true;
        taskProgressUpload = res / res2;
      });
    });
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;

    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      fileNames = path.basename(file.path);
      setState(() {
        progressUpload = false;
        isLoading = false;

        Firestore.instance
            .collection('Downloads')
            .document(uid)
            .get()
            .then((value) {
          sizeLimit = value.data['volume'];
          if (sizeLimit + fileSize <= 3221225472) {
            fileSaver(imageUrl);
          } else {
            Fluttertoast.showToast(
                msg: '보관함 용량이 부족합니다.'.tr(),
                backgroundColor: MyColors.primaryColor,
                textColor: Colors.white);
          }
        });
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: '이미지 파일이 아닙니다.'.tr());
    });
  }

  void _onTabMenu(int index) {
    setState(() {
      debugPrint('Click');
      debugPrint(index.toString());
      _selectedIndex = index;

      if (index == 0) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => HomePage()),
            (Route<dynamic> route) => false);
      } else if (index == 1) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => HomePage(menuNum: 2)),
            (Route<dynamic> route) => false);
      } else if (index == 3) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => SettingPage()),
            (Route<dynamic> route) => false);
      }
    });
  }

  Future<void> deleteFile(int fileSized) async {
    Firestore.instance
        .collection('Downloads')
        .document(uid)
        .get()
        .then((value) {
      Firestore.instance
          .collection('Downloads')
          .document(uid)
          .updateData({'volume': value.data['volume'] - fileSized});
    }); // Cloud Firestore

    FirebaseStorage.instance
        .ref()
        .child(uid)
        .child('storages/' + fileDownName)
        .delete();
  }

  void deleteFileAll() {
    Firestore.instance
        .collection('Downloads')
        .document(uid)
        .collection('storages')
        .getDocuments()
        .then((value) {
      Firestore.instance
          .collection('Downloads')
          .document(uid)
          .updateData({'volume': 0});
      for (DocumentSnapshot doc in value.documents) {
        doc.reference.delete();
      }
      Firestore.instance
          .collection('Downloads')
          .document(uid)
          .collection('storages')
          .document('keepfile')
          .setData({'content': 'Just keep file'});
    });

//    FirebaseStorage.instance.ref().child(uid+'/storages/').delete();  // Firebase Storage
  }

  String stripQueryStringAndHashFromPath(url) {
    return url.split("?")[0];
  }

  Future<String> _findLocalPath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory() // Android Path
        : await getApplicationDocumentsDirectory(); //iOS Path
    return directory.path;
  }

  Future<String> dirCreator() async {
    String localPath =
        (await _findLocalPath()) + Platform.pathSeparator + 'files';
    final savedDir = Directory(localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  Future<void> download(String fileurl, String fileName) async {
    //dirCreator();
    _handleStorage();
    String localPath =
        (await _findLocalPath()) + Platform.pathSeparator + 'PapuconDownload';
    final savedDir = Platform.isIOS
        ? Directory(localPath)
        : Directory('storage/emulated/0/PapuconDownload');
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    final taskId = FlutterDownloader.enqueue(
      url: fileurl,
      savedDir: savedDir.path,
      fileName: fileName,
      showNotification: true,
      // show download progress in status bar (for Android)
      openFileFromNotification:
          true, // click on notification to open downloaded file (for Android)
    );
  }

  void fileCategories(int nums) {
    setState(() {
      fileViewCtn = nums;
    });
  }

  void fileView(int nums) {
    setState(() {
      fileViewCode = nums == 1 ? 1 : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    zeheight = statusBarHeight;
    // 김동선
    return Consumer<LoginStore>(builder: (_, loginStore, __) {
      if (Platform.isIOS) {
        return
//        appBar: E_appBar(),

            Scaffold(
          appBar: E_appBar(),
          body: Center(
            child: Column(
              children: <Widget>[
                fileViewCode == 0
                    ? Expanded(
                        child: Column(
                          children: <Widget>[
                            gigabar(),
                            categoriesView(),
                          ],
                        ),
                      )
                    : Expanded(
                        child: Column(
                          children: <Widget>[
                            backbar(),
                            fileViewCtn == 0
                                ? fileListView(7)
                                : fileViewCtn == 1
                                    ? fileListView(0)
                                    : fileViewCtn == 2
                                        ? fileListView(1)
                                        : fileViewCtn == 3
                                            ? fileListView(2)
                                            : fileViewCtn == 4
                                                ? fileListView(3)
                                                : fileViewCtn == 5
                                                    ? fileListView(4)
                                                    : fileViewCtn == 6
                                                        ? fileListView(5)
                                                        : fileListView(6),
                          ],
                        ),
                      ),
                Visibility(
                  //upload profress bar
                  visible: progressUpload,
                  child: LinearPercentIndicator(
                    padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
                    width: MediaQuery.of(context).size.width,
                    lineHeight: 8.0,
                    percent: taskProgressUpload,
                    linearStrokeCap: LinearStrokeCap.butt,
                    progressColor: MyColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        return Scaffold(
          appBar: E_appBar(),
          body: Center(
            child: Column(
              children: <Widget>[
                fileViewCode == 0
                    ? Expanded(
                        child: Column(
                          children: <Widget>[
                            gigabar(),
                            categoriesView(),
                          ],
                        ),
                      )
                    : Expanded(
                        child: Column(
                          children: <Widget>[
                            backbar(),
                            fileViewCtn == 0
                                ? fileListView(7)
                                : fileViewCtn == 1
                                    ? fileListView(0)
                                    : fileViewCtn == 2
                                        ? fileListView(1)
                                        : fileViewCtn == 3
                                            ? fileListView(2)
                                            : fileViewCtn == 4
                                                ? fileListView(3)
                                                : fileViewCtn == 5
                                                    ? fileListView(4)
                                                    : fileViewCtn == 6
                                                        ? fileListView(5)
                                                        : fileListView(6),
                          ],
                        ),
                      ),
                Visibility(
                  //upload profress bar
                  visible: progressUpload,
                  child: LinearPercentIndicator(
                    padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
                    width: MediaQuery.of(context).size.width,
                    lineHeight: 8.0,
                    percent: taskProgressUpload,
                    linearStrokeCap: LinearStrokeCap.butt,
                    progressColor: MyColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });
  }

  Widget gigabar() {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFFf2f3f6)),
      child: Column(
        children: <Widget>[
          SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Neumorphic(
                  style: NeumorphicStyle(
                    border:
                        NeumorphicBorder(width: 0.5, color: Color(0xFFf0f0f0)),
                    shape: NeumorphicShape.flat,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
                    shadowDarkColor: Colors.black.withOpacity(0.5),
                    shadowLightColor: Colors.white,
                    depth: 3,
                    intensity: 1,
                    color: Color(0xFFf2f3f6),
                  ),
                  child: loadmarked == false
                      ? Column(
                          children: <Widget>[
                            ListTile(
                              title: Container(
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text('저장공간',
                                                style:
                                                    TextStyle(fontSize: 13.0))
                                            .tr(),
                                        strMarking(),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              subtitle: intProgress(),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 0.5,
                                          color: Color(0xFFdedede)))),
                            ),
                          ],
                        )
                      : Loading()),
            ),
          )
        ],
      ),
    );
  }

  Widget backbar() {
    return Container(
      child: Container(
        color: Color(0xFFf2f3f6),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                height: 70,
                child: Neumorphic(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  style: NeumorphicStyle(
                    border:
                        NeumorphicBorder(width: 0.5, color: Color(0xFFf0f0f0)),
                    shape: NeumorphicShape.flat,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                    shadowDarkColor: Colors.black.withOpacity(0.5),
                    shadowLightColor: Colors.white,
                    depth: 2,
                    intensity: 0.7,
                    color: Color(0xFFf8f8f8),
                  ),
                  child: InkWell(
                    onTap: () {
                      fileView(0);
                      fileCategories(0);
                    },
                    child: Container(
                      height: 50,
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 50,
                            height: 30,
                            margin: EdgeInsets.fromLTRB(10.0, 10.0, 5.0, 10.0),
                            decoration: BoxDecoration(
                                color: Color(0xFFf8f8f8),
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Neumorphic(
                                style: NeumorphicStyle(
                                  shape: NeumorphicShape.flat,
                                  boxShape: NeumorphicBoxShape.roundRect(
                                      BorderRadius.circular(16)),
                                  depth: 0,
                                  intensity: 0.7,
                                  color: Color(0xFFf8f8f8),
                                ),
                                child: MaterialButton(
                                  padding: EdgeInsets.all(0.0),
                                  child: Icon(Icons.keyboard_backspace,
                                      size: 25, color: Color(0xFF000000)),
                                )),
                          ),
                          Container(
                              margin: EdgeInsets.only(bottom: 8.0, top: 4.0),
                              child: Text(
                                '돌아가기',
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold),
                              ).tr()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget categoriesView() {
    return Expanded(
      child: Container(
        color: Color(0xFFf2f3f6),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: <Widget>[
              //1
              Neumorphic(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                style: NeumorphicStyle(
                  border:
                      NeumorphicBorder(width: 0.5, color: Color(0xFFf0f0f0)),
                  shape: NeumorphicShape.flat,
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                  shadowDarkColor: Colors.black.withOpacity(0.5),
                  shadowLightColor: Colors.white,
                  depth: 2,
                  intensity: 0.7,
                  color: Colors.white,
                ),
                child: InkWell(
                  onTap: () {
                    fileView(1);
                    fileCategories(0);
                  },
                  child: Container(
                    height: 70,
                    child: Stack(
                      children: [
                        Container(
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 50,
                                height: 50,
                                margin:
                                    EdgeInsets.fromLTRB(10.0, 10.0, 15.0, 10.0),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Neumorphic(
                                    style: NeumorphicStyle(
                                      shape: NeumorphicShape.flat,
                                      boxShape: NeumorphicBoxShape.roundRect(
                                          BorderRadius.circular(16)),
                                      depth: 0,
                                      intensity: 0.7,
                                      color: Color(0xFFf2f3f6),
                                    ),
                                    child: MaterialButton(
                                      padding: EdgeInsets.all(0.0),
                                      child: Icon(Icons.folder,
                                          size: 28, color: Color(0xFFd0393e)),
                                    )),
                              ),
                              Container(
                                  margin:
                                      EdgeInsets.only(bottom: 8.0, top: 4.0),
                                  child: Text(
                                    '전체보기',
                                    style: TextStyle(fontSize: 13.0),
                                  ).tr()),
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          margin: EdgeInsets.only(right: 18),
                          child: Icon(Icons.keyboard_arrow_right,
                              size: 28, color: Colors.black.withOpacity(0.3)),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              //2
              Neumorphic(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                style: NeumorphicStyle(
                  border:
                      NeumorphicBorder(width: 0.5, color: Color(0xFFf0f0f0)),
                  shape: NeumorphicShape.flat,
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                  shadowDarkColor: Colors.black.withOpacity(0.5),
                  shadowLightColor: Colors.white,
                  depth: 2,
                  intensity: 0.7,
                  color: Colors.white,
                ),
                child: InkWell(
                  onTap: () {
                    fileView(1);
                    fileCategories(1);
                  },
                  child: Container(
                    height: 70,
                    child: Stack(
                      children: [
                        Container(
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 50,
                                height: 50,
                                margin:
                                    EdgeInsets.fromLTRB(10.0, 10.0, 15.0, 10.0),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Neumorphic(
                                    style: NeumorphicStyle(
                                      shape: NeumorphicShape.flat,
                                      boxShape: NeumorphicBoxShape.roundRect(
                                          BorderRadius.circular(16)),
                                      depth: 0,
                                      intensity: 0.7,
                                      color: Color(0xFFf2f3f6),
                                    ),
                                    child: MaterialButton(
                                      padding: EdgeInsets.all(0.0),
                                      child: Icon(Icons.image,
                                          size: 28, color: Color(0xFF5908c1)),
                                    )),
                              ),
                              Container(
                                  margin:
                                      EdgeInsets.only(bottom: 8.0, top: 4.0),
                                  child: Text(
                                    '사진',
                                    style: TextStyle(fontSize: 13.0),
                                  ).tr()),
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          margin: EdgeInsets.only(right: 18),
                          child: Icon(Icons.keyboard_arrow_right,
                              size: 28, color: Colors.black.withOpacity(0.3)),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              //3
              Neumorphic(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                style: NeumorphicStyle(
                  border:
                      NeumorphicBorder(width: 0.5, color: Color(0xFFf0f0f0)),
                  shape: NeumorphicShape.flat,
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                  shadowDarkColor: Colors.black.withOpacity(0.5),
                  shadowLightColor: Colors.white,
                  depth: 2,
                  intensity: 0.7,
                  color: Colors.white,
                ),
                child: InkWell(
                  onTap: () {
                    fileView(1);
                    fileCategories(2);
                  },
                  child: Container(
                    height: 70,
                    child: Stack(
                      children: [
                        Container(
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 50,
                                height: 50,
                                margin:
                                    EdgeInsets.fromLTRB(10.0, 10.0, 15.0, 10.0),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Neumorphic(
                                    style: NeumorphicStyle(
                                      shape: NeumorphicShape.flat,
                                      boxShape: NeumorphicBoxShape.roundRect(
                                          BorderRadius.circular(16)),
                                      depth: 0,
                                      intensity: 0.7,
                                      color: Color(0xFFf2f3f6),
                                    ),
                                    child: MaterialButton(
                                      padding: EdgeInsets.all(0.0),
                                      child: Icon(Icons.movie_creation,
                                          size: 28, color: Color(0xFFe83a3a)),
                                    )),
                              ),
                              Container(
                                  margin:
                                      EdgeInsets.only(bottom: 8.0, top: 4.0),
                                  child: Text(
                                    '동영상',
                                    style: TextStyle(fontSize: 13.0),
                                  ).tr()),
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          margin: EdgeInsets.only(right: 18),
                          child: Icon(Icons.keyboard_arrow_right,
                              size: 28, color: Colors.black.withOpacity(0.3)),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              //4
              Neumorphic(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                style: NeumorphicStyle(
                  border:
                      NeumorphicBorder(width: 0.5, color: Color(0xFFf0f0f0)),
                  shape: NeumorphicShape.flat,
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                  shadowDarkColor: Colors.black.withOpacity(0.5),
                  shadowLightColor: Colors.white,
                  depth: 2,
                  intensity: 0.7,
                  color: Colors.white,
                ),
                child: InkWell(
                  onTap: () {
                    fileView(1);
                    fileCategories(3);
                  },
                  child: Container(
                    height: 70,
                    child: Stack(
                      children: [
                        Container(
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 50,
                                height: 50,
                                margin:
                                    EdgeInsets.fromLTRB(10.0, 10.0, 15.0, 10.0),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Neumorphic(
                                    style: NeumorphicStyle(
                                      shape: NeumorphicShape.flat,
                                      boxShape: NeumorphicBoxShape.roundRect(
                                          BorderRadius.circular(16)),
                                      depth: 0,
                                      intensity: 0.7,
                                      color: Color(0xFFf2f3f6),
                                    ),
                                    child: MaterialButton(
                                      padding: EdgeInsets.all(0.0),
                                      child: Icon(Icons.insert_drive_file,
                                          size: 28, color: Color(0xFF4a55f4)),
                                    )),
                              ),
                              Container(
                                  margin:
                                      EdgeInsets.only(bottom: 8.0, top: 4.0),
                                  child: Text(
                                    '문서',
                                    style: TextStyle(fontSize: 13.0),
                                  ).tr()),
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          margin: EdgeInsets.only(right: 18),
                          child: Icon(Icons.keyboard_arrow_right,
                              size: 28, color: Colors.black.withOpacity(0.3)),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              //5
              Neumorphic(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                style: NeumorphicStyle(
                  border:
                      NeumorphicBorder(width: 0.5, color: Color(0xFFf0f0f0)),
                  shape: NeumorphicShape.flat,
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                  shadowDarkColor: Colors.black.withOpacity(0.5),
                  shadowLightColor: Colors.white,
                  depth: 2,
                  intensity: 0.7,
                  color: Colors.white,
                ),
                child: InkWell(
                  onTap: () {
                    fileView(1);
                    fileCategories(4);
                  },
                  child: Container(
                    height: 70,
                    child: Stack(
                      children: [
                        Container(
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 50,
                                height: 50,
                                margin:
                                    EdgeInsets.fromLTRB(10.0, 10.0, 15.0, 10.0),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Neumorphic(
                                    style: NeumorphicStyle(
                                      shape: NeumorphicShape.flat,
                                      boxShape: NeumorphicBoxShape.roundRect(
                                          BorderRadius.circular(16)),
                                      depth: 0,
                                      intensity: 0.7,
                                      color: Color(0xFFf2f3f6),
                                    ),
                                    child: MaterialButton(
                                      padding: EdgeInsets.all(0.0),
                                      child: Icon(Icons.music_note,
                                          size: 28, color: Color(0xFFe83a75)),
                                    )),
                              ),
                              Container(
                                  margin:
                                      EdgeInsets.only(bottom: 8.0, top: 4.0),
                                  child: Text(
                                    '오디오',
                                    style: TextStyle(fontSize: 13.0),
                                  ).tr()),
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          margin: EdgeInsets.only(right: 18),
                          child: Icon(Icons.keyboard_arrow_right,
                              size: 28, color: Colors.black.withOpacity(0.3)),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              //6
              Neumorphic(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                style: NeumorphicStyle(
                  border:
                      NeumorphicBorder(width: 0.5, color: Color(0xFFf0f0f0)),
                  shape: NeumorphicShape.flat,
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                  shadowDarkColor: Colors.black.withOpacity(0.5),
                  shadowLightColor: Colors.white,
                  depth: 2,
                  intensity: 0.7,
                  color: Colors.white,
                ),
                child: InkWell(
                  onTap: () {
                    fileView(1);
                    fileCategories(5);
                  },
                  child: Container(
                    height: 70,
                    child: Stack(
                      children: [
                        Container(
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 50,
                                height: 50,
                                margin:
                                    EdgeInsets.fromLTRB(10.0, 10.0, 15.0, 10.0),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Neumorphic(
                                    style: NeumorphicStyle(
                                      shape: NeumorphicShape.flat,
                                      boxShape: NeumorphicBoxShape.roundRect(
                                          BorderRadius.circular(16)),
                                      depth: 0,
                                      intensity: 0.7,
                                      color: Color(0xFFf2f3f6),
                                    ),
                                    child: MaterialButton(
                                      padding: EdgeInsets.all(0.0),
                                      child: Icon(Icons.assignment,
                                          size: 28, color: Color(0xFFffbe3e)),
                                    )),
                              ),
                              Container(
                                  margin:
                                      EdgeInsets.only(bottom: 8.0, top: 4.0),
                                  child: Text(
                                    '텍스트',
                                    style: TextStyle(fontSize: 13.0),
                                  ).tr()),
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          margin: EdgeInsets.only(right: 18),
                          child: Icon(Icons.keyboard_arrow_right,
                              size: 28, color: Colors.black.withOpacity(0.3)),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              //7
              Neumorphic(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                style: NeumorphicStyle(
                  border:
                      NeumorphicBorder(width: 0.5, color: Color(0xFFf0f0f0)),
                  shape: NeumorphicShape.flat,
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                  shadowDarkColor: Colors.black.withOpacity(0.5),
                  shadowLightColor: Colors.white,
                  depth: 2,
                  intensity: 0.7,
                  color: Colors.white,
                ),
                child: InkWell(
                  onTap: () {
                    fileView(1);
                    fileCategories(6);
                  },
                  child: Container(
                    height: 70,
                    child: Stack(
                      children: [
                        Container(
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 50,
                                height: 50,
                                margin:
                                    EdgeInsets.fromLTRB(10.0, 10.0, 15.0, 10.0),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Neumorphic(
                                    style: NeumorphicStyle(
                                      shape: NeumorphicShape.flat,
                                      boxShape: NeumorphicBoxShape.roundRect(
                                          BorderRadius.circular(16)),
                                      depth: 0,
                                      intensity: 0.7,
                                      color: Color(0xFFf2f3f6),
                                    ),
                                    child: MaterialButton(
                                      padding: EdgeInsets.all(0.0),
                                      child: Icon(Icons.archive,
                                          size: 28, color: Color(0xFF3ba725)),
                                    )),
                              ),
                              Container(
                                  margin:
                                      EdgeInsets.only(bottom: 8.0, top: 4.0),
                                  child: Text(
                                    '압축파일',
                                    style: TextStyle(fontSize: 13.0),
                                  ).tr()),
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          margin: EdgeInsets.only(right: 18),
                          child: Icon(Icons.keyboard_arrow_right,
                              size: 28, color: Colors.black.withOpacity(0.3)),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              //8
              Neumorphic(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                style: NeumorphicStyle(
                  border:
                      NeumorphicBorder(width: 0.5, color: Color(0xFFf0f0f0)),
                  shape: NeumorphicShape.flat,
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                  shadowDarkColor: Colors.black.withOpacity(0.5),
                  shadowLightColor: Colors.white,
                  depth: 2,
                  intensity: 0.7,
                  color: Colors.white,
                ),
                child: InkWell(
                  onTap: () {
                    fileView(1);
                    fileCategories(7);
                  },
                  child: Container(
                    height: 70,
                    child: Stack(
                      children: [
                        Container(
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 50,
                                height: 50,
                                margin:
                                    EdgeInsets.fromLTRB(10.0, 10.0, 15.0, 10.0),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Neumorphic(
                                    style: NeumorphicStyle(
                                      shape: NeumorphicShape.flat,
                                      boxShape: NeumorphicBoxShape.roundRect(
                                          BorderRadius.circular(16)),
                                      depth: 0,
                                      intensity: 0.7,
                                      color: Color(0xFFf2f3f6),
                                    ),
                                    child: MaterialButton(
                                      padding: EdgeInsets.all(0.0),
                                      child: Icon(Icons.library_books,
                                          size: 28, color: Color(0xFF7a7a7a)),
                                    )),
                              ),
                              Container(
                                  margin:
                                      EdgeInsets.only(bottom: 8.0, top: 4.0),
                                  child: Text(
                                    '그 외',
                                    style: TextStyle(fontSize: 13.0),
                                  ).tr()),
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          margin: EdgeInsets.only(right: 18),
                          child: Icon(Icons.keyboard_arrow_right,
                              size: 28, color: Colors.black.withOpacity(0.3)),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              // 밑 여백
              Container(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget E_appBar() {
    return AppBar(
      title: Text('보관함',
              style: TextStyle(color: Colors.black, fontSize: 26, height: 0.5))
          .tr(),
      toolbarHeight: 60,
      backgroundColor: Color(0xFFf2f3f6),
      brightness: Platform.isIOS ? Brightness.light : null,
      elevation: 0.0,
      bottom: PreferredSize(
        child: SizedBox(height: 10),
      ),
      bottomOpacity: 0.1,
      actions: <Widget>[
        Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Neumorphic(
              margin: EdgeInsets.only(right: 14.0),
              padding: EdgeInsets.all(0),
              style: NeumorphicStyle(
                color: Color.fromRGBO(242, 243, 246, 255),
                boxShape: NeumorphicBoxShape.circle(),
                depth: 3,
                shape: NeumorphicShape.concave,
              ),
              child: usingStorage >= 3221225472 ? maxStorage() : E_Driveadd(),
            )),
        Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Neumorphic(
              margin: EdgeInsets.only(right: 14.0),
              padding: EdgeInsets.all(0),
              style: NeumorphicStyle(
                color: Color.fromRGBO(242, 243, 246, 255),
                boxShape: NeumorphicBoxShape.circle(),
                depth: 3,
                shape: NeumorphicShape.concave,
              ),
              child: E_morevert(),
            ))
      ],
    );
  }

  Widget E_morevert() {
    return IconButton(
      icon: Icon(Icons.more_vert, color: Colors.black),
      onPressed: () {
        showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel:
                MaterialLocalizations.of(context).modalBarrierDismissLabel,
            barrierColor: Colors.black.withAlpha(1),
            transitionDuration: Duration(milliseconds: 100),
            pageBuilder: (BuildContext buildContext, Animation animation,
                Animation secondaryAnimation) {
              return Stack(
                alignment: Alignment.topRight,
                children: <Widget>[
                  Container(
                    width: 200,
                    height: 60,
                    margin: EdgeInsets.only(top: 68.0, right: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          spreadRadius: 0,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Material(
                      elevation: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              child: ListTile(
                                title: Text('보관함 비우기',
                                        style: TextStyle(fontSize: 15))
                                    .tr(),
                                onTap: () async {
                                  Navigator.pop(this.context);
                                  await showDialog(
                                    context: context,
                                    child: SimpleDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      children: <Widget>[
                                        SimpleDialogOption(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.rectangle,
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 15, 0, 0),
                                              child: Column(
                                                children: <Widget>[
                                                  Text('보관함을 모두 비우시겠습니까?').tr(),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      FlatButton(
                                                          child: Text('네').tr(),
                                                          onPressed: () {
                                                            deleteFileAll();
                                                            Navigator.pop(
                                                                this.context);
                                                            Fluttertoast
                                                                .showToast(
                                                              msg:
                                                                  '보관함을 모두 비웠습니다.'
                                                                      .tr(),
                                                              gravity:
                                                                  ToastGravity
                                                                      .TOP,
                                                              backgroundColor:
                                                                  Colors.black
                                                                      .withOpacity(
                                                                          0.7),
                                                              textColor:
                                                                  Colors.white,
                                                            );
                                                          }),
                                                      FlatButton(
                                                          child:
                                                              Text('아니요').tr(),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                this.context);
                                                          }),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            });
      },
    );
  }

  Widget E_Driveadd() {
    return Neumorphic(
        style: NeumorphicStyle(
          border: NeumorphicBorder(width: 0.5, color: Color(0xFFf0f0f0)),
          shape: NeumorphicShape.flat,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(50)),
          shadowDarkColor: Colors.black.withOpacity(0.5),
          shadowLightColor: Colors.white,
          depth: 3,
          intensity: 0.7,
          color: Color(0xFFf2f3f6),
        ),
        child: IconButton(
          icon: Icon(Icons.add, color: Colors.black),
          onPressed: () {
            showModalBottomSheet<void>(
                backgroundColor: Colors.transparent,
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    height: 172,
                    padding: EdgeInsets.only(
                        left: 20, top: 10, right: 20, bottom: 0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25.0),
                          topRight: Radius.circular(25.0),
                        )),
                    child: Column(
                      children: <Widget>[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 80,
                              child: FlatButton(
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.image,
                                          color: Color(0xFF1a1a1a),
                                        ),
                                        SizedBox(width: 20),
                                        Text(
                                          '앨범',
                                          style: TextStyle(fontSize: 15),
                                        ).tr()
                                      ],
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(this.context);
                                    showAlertDialog(context);
                                    // getImgFile().then((value) {
                                    //   print(value.toString());
                                    //   uploadFile(value);
                                    // }).then((val) {
                                    // });
                                  }),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: FlatButton(
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.attach_file,
                                        color: Color(0xFF1a1a1a),
                                      ),
                                      SizedBox(width: 20),
                                      Text(
                                        '파일',
                                        style: TextStyle(fontSize: 15),
                                      ).tr(),
                                    ],
                                  ),
                                  onPressed: () {
                                    getFile().then((value) {
                                      print(value.toString());
                                      uploadFile(value);
                                    }).then((val) {
                                      Navigator.pop(this.context);
                                    });
                                  }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                });
//            getFile().then((value) {
//              print(value.toString());
//              uploadFile(value);
//            });
          },
        ));
  }

  Widget maxStorage() {
    return IconButton(
      icon: Icon(Icons.add, color: Colors.black),
      onPressed: () {
        Fluttertoast.showToast(
            msg: "용량을 초과하였습니다.".tr(),
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: MyColors.primaryColor,
            textColor: Colors.white,
            fontSize: 15.0);
      },
    );
  }

  Widget fileListView(int nums) {
    return Expanded(
        child: Container(
      color: Color(0xFFf2f3f6),
      child: FutureBuilder(
          future:
              Future<String>.delayed(Duration(seconds: 0), () => 'Data Loaded'),
          builder: (context, snapshot) {
            return StreamBuilder(
                stream: Firestore.instance
                    .collection('Downloads')
                    .document(uid)
                    .collection('storages')
                    .orderBy('timeStamp', descending: true)
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return Loading();
                  } else {
                    return ListView.builder(
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.all(0),
                        scrollDirection: Axis.vertical,
                        controller: listScrollController,
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          fileDownName =
                              snapshot.data.documents[index]['fileName'];

                          if (snapshot.data.documents[index]['size'] > 1024 &&
                              snapshot.data.documents[index]['size'] <
                                  (1024 * 1024)) {
                            markFileSize =
                                snapshot.data.documents[index]['size'] / 1024;
                            markFileByte = "'KB'";
                          } else if (snapshot.data.documents[index]['size'] >
                                  (1024 * 1024) &&
                              snapshot.data.documents[index]['size'] <
                                  (1024 * 1024 * 1024)) {
                            markFileSize = snapshot.data.documents[index]
                                    ['size'] /
                                (1024 * 1024);
                            markFileByte = "'MB'";
                          } else if (snapshot.data.documents[index]['size'] >
                              (1024 * 1024 * 1024)) {
                            markFileSize = snapshot.data.documents[index]
                                    ['size'] /
                                (1024 * 1024 * 1024);
                            markFileByte = "'GB'";
                          }
                          var mimes = snapshot.data.documents[index]['fileName']
                              .split('.');
                          var mimes2 = mimes[mimes.length - 1];
                          var categoryFiles = [
                            [
                              'bmp',
                              'jpeg',
                              'jpg',
                              'png',
                              'tif',
                              'tiff',
                              'tga',
                              'ai',
                              'eps',
                              'psd',
                              'BMP',
                              'JPEG',
                              'JPG',
                              'PNG',
                              'TIF',
                              'TIFF',
                              'TGA',
                              'AI',
                              'EPS',
                              'PSD'
                            ], // image file
                            [
                              '3gp',
                              'avi',
                              'mov',
                              'mp4',
                              'mpeg',
                              'mpg',
                              'wmv',
                              'm4v',
                              'flv',
                              'ts',
                              'ogv',
                              '3GP',
                              'AVI',
                              'MOV',
                              'MP4',
                              'MPEG',
                              'MPG',
                              'WMV',
                              'M4V',
                              'FLV',
                              'TS',
                              'OGV'
                            ], // video file
                            [
                              'csv',
                              'xls',
                              'xlsx',
                              'xml',
                              'doc',
                              'docx',
                              'ppt',
                              'pptx',
                              'pub',
                              'hwp',
                              'show',
                              'pdf',
                              'pages',
                              'numbers',
                              'key',
                              'keynote',
                              'odf',
                              'ods',
                              'odp',
                              'tsv',
                              'CSV',
                              'XLS',
                              'XLSX',
                              'XML',
                              'DOC',
                              'DOCX',
                              'PPT',
                              'PPTX',
                              'PUB',
                              'HWP',
                              'SHOW',
                              'PDF',
                              'PAGES',
                              'NUMBERS',
                              'KEY',
                              'KEYNOTE',
                              'ODF',
                              'ODS',
                              'ODP',
                              'TSV'
                            ], // document file
                            [
                              'm4a',
                              'mp3',
                              'ogg',
                              'wav',
                              'wma',
                              'flac',
                              'aac',
                              'tta',
                              'tak',
                              'M4A',
                              'MP3',
                              'OGG',
                              'WAV',
                              'WMA',
                              'FLAC',
                              'AAC',
                              'TTA',
                              'TAK'
                            ], // audio file
                            [
                              'txt',
                              'log',
                              'odt',
                              'snb',
                              'TXT',
                              'LOG',
                              'ODT',
                              'SNB'
                            ], // text file
                            [
                              'zip',
                              '7z',
                              'rar',
                              'alz',
                              'egg',
                              'ZIP',
                              '7Z',
                              'RAR',
                              'ALZ',
                              'EGG'
                            ], // compressor file
                            [
                              'epub',
                              'mobi',
                              'EPUB',
                              'MOBI',
                              'pat',
                              'abr',
                              'PAT',
                              'ABR',
                              'ttf',
                              'otf',
                              'TTF',
                              'OTF',
                            ], // other file
                            [
                              'txt',
                              'log',
                              'odt',
                              'snb',
                              'TXT',
                              'LOG',
                              'ODT',
                              'SNB',
                              'csv',
                              'xls',
                              'xlsx',
                              'xml',
                              'doc',
                              'docx',
                              'ppt',
                              'pptx',
                              'pub',
                              'hwp',
                              'show',
                              'pdf',
                              'pages',
                              'numbers',
                              'key',
                              'keynote',
                              'odf',
                              'ods',
                              'odp',
                              'tsv',
                              'CSV',
                              'XLS',
                              'XLSX',
                              'XML',
                              'DOC',
                              'DOCX',
                              'PPT',
                              'PPTX',
                              'PUB',
                              'HWP',
                              'SHOW',
                              'PDF',
                              'PAGES',
                              'NUMBERS',
                              'KEY',
                              'KEYNOTE',
                              'ODF',
                              'ODS',
                              'ODP',
                              'TSV',
                              'bmp',
                              'jpeg',
                              'jpg',
                              'png',
                              'tif',
                              'tiff',
                              'tga',
                              'ai',
                              'eps',
                              'psd',
                              'BMP',
                              'JPEG',
                              'JPG',
                              'PNG',
                              'TIF',
                              'TIFF',
                              'TGA',
                              'AI',
                              'EPS',
                              'PSD',
                              '3gp',
                              'avi',
                              'mov',
                              'mp4',
                              'mpeg',
                              'mpg',
                              'wmv',
                              'm4v',
                              'flv',
                              'ts',
                              'ogv',
                              '3GP',
                              'AVI',
                              'MOV',
                              'MP4',
                              'MPEG',
                              'MPG',
                              'WMV',
                              'M4V',
                              'FLV',
                              'TS',
                              'OGV',
                              'm4a',
                              'mp3',
                              'ogg',
                              'wav',
                              'wma',
                              'flac',
                              'aac',
                              'tta',
                              'tak',
                              'M4A',
                              'MP3',
                              'OGG',
                              'WAV',
                              'WMA',
                              'FLAC',
                              'AAC',
                              'TTA',
                              'TAK',
                              'epub',
                              'mobi',
                              'EPUB',
                              'MOBI',
                              'zip',
                              '7z',
                              'rar',
                              'alz',
                              'egg',
                              'ZIP',
                              '7Z',
                              'RAR',
                              'ALZ',
                              'EGG',
                              'pat',
                              'abr',
                              'PAT',
                              'ABR',
                              'ttf',
                              'otf',
                              'TTF',
                              'OTF',
                            ] // all file
                          ];

                          return categoryFiles[nums].indexOf(mimes2) > -1
                              ? Container(
                                  color: Color(0xFFf2f3f6),
                                  height: 76,
                                  child: Neumorphic(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 5),
                                      style: NeumorphicStyle(
                                        border: NeumorphicBorder(
                                            width: 0.5,
                                            color: Color(0xFFf0f0f0)),
                                        shape: NeumorphicShape.flat,
                                        boxShape: NeumorphicBoxShape.roundRect(
                                            BorderRadius.circular(20)),
                                        shadowDarkColor:
                                            Colors.black.withOpacity(0.5),
                                        shadowLightColor: Colors.white,
                                        depth: 2,
                                        intensity: 0.7,
                                        color: Colors.white,
                                      ),
                                      child: ListTile(
                                        leading: Container(
                                            margin:
                                                EdgeInsets.only(bottom: 6.0),
                                            child: categoryFiles[2].indexOf(mimes2) >
                                                    -1 //document file
                                                ? Container(
                                                    width: 40,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                        color: Color(0xFF4a55f4)
                                                            .withOpacity(0.2),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                15)),
                                                    child: Icon(
                                                        Icons.insert_drive_file,
                                                        size: 25.0,
                                                        color:
                                                            Color(0xFF4a55f4)))
                                                : categoryFiles[1].indexOf(mimes2) >
                                                        -1 //video file
                                                    ? Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                            color: Color(0xFFe83a3a).withOpacity(0.2),
                                                            borderRadius: BorderRadius.circular(15)),
                                                        child: Icon(Icons.movie, size: 25.0, color: Color(0xFFe83a3a)))
                                                    : categoryFiles[0].indexOf(mimes2) > -1 //image file
                                                        ? Container(width: 40, height: 40, decoration: BoxDecoration(color: Color(0xFF5908c1).withOpacity(0.2), borderRadius: BorderRadius.circular(15)), child: Icon(Icons.image, size: 25.0, color: Color(0xFF5908c1)))
                                                        : categoryFiles[3].indexOf(mimes2) > -1 // audio file
                                                            ? Container(width: 40, height: 40, decoration: BoxDecoration(color: Color(0xFFe83a75).withOpacity(0.2), borderRadius: BorderRadius.circular(15)), child: Icon(Icons.audiotrack, size: 25.0, color: Color(0xFFe83a75)))
                                                            : categoryFiles[5].indexOf(mimes2) > -1 // compressor file
                                                                ? Container(width: 40, height: 40, decoration: BoxDecoration(color: Color(0xFF3ba725).withOpacity(0.2), borderRadius: BorderRadius.circular(15)), child: Icon(Icons.archive, size: 25.0, color: Color(0xFF3ba725)))
                                                                : categoryFiles[4].indexOf(mimes2) > -1 // text file
                                                                    ? Container(width: 40, height: 40, decoration: BoxDecoration(color: Color(0xFFffbe3e).withOpacity(0.2), borderRadius: BorderRadius.circular(15)), child: Icon(Icons.assignment, size: 25.0, color: Color(0xFFffbe3e)))
                                                                    : Container(width: 40, height: 40, decoration: BoxDecoration(color: Color(0xFF7a7a7a).withOpacity(0.2), borderRadius: BorderRadius.circular(15)), child: Icon(Icons.library_books, size: 25.0, color: Color(0xFF7a7a7a)) // digital book file
                                                                        )),
                                        title: Text(
                                            snapshot
                                                        .data
                                                        .documents[index]
                                                            ['fileName']
                                                        .toString()
                                                        .length >
                                                    25
                                                ? snapshot
                                                        .data
                                                        .documents[index]
                                                            ['fileName']
                                                        .toString()
                                                        .substring(0, 25) +
                                                    '...'
                                                : snapshot.data.documents[index]
                                                    ['fileName'],
                                            style: TextStyle(fontSize: 15.0)),
                                        subtitle: Text(
                                                DateFormat(
                                                        "yyyy-MM-dd HH:mm:ss         ${markFileSize.toStringAsFixed(2)}${markFileByte}")
                                                    .format(DateTime
                                                        .fromMillisecondsSinceEpoch(
                                                            int.parse(snapshot
                                                                        .data
                                                                        .documents[
                                                                    index][
                                                                "timeStamp"]))),
                                                style:
                                                    TextStyle(fontSize: 10.0))
                                            .tr(),
                                        onTap: () async {
                                          await showDialog(
                                            context: this.context,
                                            child: SimpleDialog(
                                              children: <Widget>[
                                                SimpleDialogOption(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 23.0,
                                                      vertical: 12.0),
                                                  child: Text('저장하기').tr(),
                                                  onPressed: () {
                                                    download(
                                                        snapshot.data.documents[
                                                            index]['content'],
                                                        snapshot.data.documents[
                                                            index]['fileName']);
                                                    Navigator.pop(this.context);
                                                    Fluttertoast.showToast(
                                                      msg: '디바이스에 저장했습니다.'.tr(),
                                                      gravity: ToastGravity.TOP,
                                                      backgroundColor: Colors
                                                          .black
                                                          .withOpacity(0.7),
                                                      textColor: Colors.white,
                                                    );
                                                  },
                                                ),
                                                SimpleDialogOption(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 23.0,
                                                      vertical: 12.0),
                                                  child: Text('공유하기').tr(),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    Navigator.push(
                                                        this.context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                FileSharePage(
                                                                    filename: snapshot
                                                                            .data
                                                                            .documents[index]
                                                                        [
                                                                        'fileName'])));
                                                  },
                                                ),
                                                SimpleDialogOption(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 23.0,
                                                      vertical: 12.0),
                                                  child: Text('삭제하기 ').tr(),
                                                  onPressed: () {
                                                    deleteFile(snapshot.data
                                                            .documents[index]
                                                        ['size']);
                                                    Firestore.instance
                                                        .collection('Downloads')
                                                        .document(uid)
                                                        .collection('storages')
                                                        .document(snapshot
                                                                .data.documents[
                                                            index]['timeStamp'])
                                                        .delete();
                                                    Navigator.pop(this.context);
                                                    Fluttertoast.showToast(
                                                      msg: '파일을 삭제했습니다.'.tr(),
                                                      gravity: ToastGravity.TOP,
                                                      backgroundColor: Colors
                                                          .black
                                                          .withOpacity(0.7),
                                                      textColor: Colors.white,
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      )))
                              : Container();
                        });
                  }
                });
          }),
    ));
  }

  Widget strMarking() {
    return Expanded(
        child: FutureBuilder(
            future: Future<String>.delayed(
                Duration(microseconds: 0), () => 'Data Loaded'),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Loading();
              return StreamBuilder(
                  stream: Firestore.instance
                      .collection('Downloads')
                      .document(uid)
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return Loading();
                    }
                    if (snapshot.data['volume'].toString() == 'null')
                      return Loading();
                    return Container(
                      alignment: Alignment.centerRight,
                      margin: EdgeInsets.only(right: 5.0),
                      child: Text(
                          '${((snapshot.data['volume'] / 3221225472) * 3).toStringAsFixed(2)}GB/3GB',
                          style: TextStyle(fontSize: 13.0)),
                    );
                  });
            }));
  }

  Widget intProgress() {
    return Container(
        child: FutureBuilder(
            future: Future<String>.delayed(
                Duration(seconds: 0), () => 'Data Loaded'),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Loading();
              return StreamBuilder(
                  stream: Firestore.instance
                      .collection('Downloads')
                      .document(uid)
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return Loading();
                    } else {
                      return Container(
                          child: LinearPercentIndicator(
                        padding: EdgeInsets.only(left: 15, right: 15, top: 5),
                        width: MediaQuery.of(context).size.width - 72.0,
                        lineHeight: 10.0,
                        percent: (snapshot.data['volume'] / 3221225472),
                        linearStrokeCap: LinearStrokeCap.roundAll,
                        progressColor: MyColors.primaryColor,
                      ));
                    }
                  });
            }));
  }

  void showAlertDialog(BuildContext context) async {
    String result = await showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              contentPadding: EdgeInsets.all(5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              content: Builder(
                builder: (context) {
                  // Get available height and width of the build area of this widget. Make a choice depending on the size.
                  var height = MediaQuery.of(context).size.height;
                  var width = MediaQuery.of(context).size.width;

                  return Container(
                      height: height - 200,
                      width: width,
                      margin: EdgeInsets.only(top: 10),
                      child: Container(
                        child: Stack(
                          children: <Widget>[
                            Text('  Gallery',
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            _buildGrid(),
                          ],
                        ),
                      )
                      //_buildGrid(),

                      );
                },
              ),
            ));
  }

  Map<dynamic, dynamic> allImageInfo = new HashMap();
  List allImage = new List();
  List allNameList = new List();

  Future<void> loadImageList() async {
    List vx = [];
    var /* Map<dynamic, dynamic> */ allImageTemp;
    allImageTemp = await FlutterGallaryPlugin.getAllImages;
    print("call ${allImageTemp.length}");

    setState(() {
      this.allImage =
          Platform.isIOS ? allImageTemp : allImageTemp['URIList'] as List;
      this.allNameList = allImageTemp['DISPLAY_NAME'] as List;
      this.allImage = this.allImage.reversed.toList();
      this.allNameList = this.allNameList.reversed.toList();

      int aa = 0;
      for (final data in allImage) {
        aa++;
        if (aa <= 50) {
          vx.add(data);
        } else {
          break;
        }
      }
      this.allImage = vx;
    });
  }

  Widget _buildGrid() {
    return Container(
        margin: EdgeInsets.only(top: 40),
        child: GridView.extent(
            maxCrossAxisExtent: 130,
            padding: const EdgeInsets.all(0),
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            children: _buildGridTileList(allImage.length)));
  }

  List<Container> _buildGridTileList(int count) {
    return List<Container>.generate(
        count,
        (int index) => Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
            child: GestureDetector(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.file(
                  File(allImage[index].toString()),
                  cacheHeight: 200,
                  cacheWidth: 200,
                  fit: BoxFit.cover,
                ),
              ),
              onTap: () {
                uploadFile(File(allImage[index].toString()));
                //uploadPicture(File(allImage[index].toString()));
                // getImgFile().then((value) {
                //   print(value.toString());
                //
                // }).then((val) {
                //   Navigator.pop(this.context);
                // });
                Navigator.of(context).pop();
              },
            )));
  }
}
