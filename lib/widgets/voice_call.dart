import 'dart:async';
import 'dart:io';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ios_voip_kit/flutter_ios_voip_kit.dart';
import 'package:papucon/main.dart';
import 'package:papucon/model/model.dart';
import 'package:papucon/theme.dart';
import 'package:papucon/widgets/app_key.dart';
import 'package:easy_localization/easy_localization.dart';

class voiceCallPage extends StatefulWidget {
  Map<String, dynamic> chatInfo;

  final String channelName;

  /// non-modifiable client role of the page
  final ClientRole role;

  final FlutterIOSVoIPKit callKit;

  /// Creates a call page with given channel name.
  voiceCallPage(
      {Key key, this.chatInfo, this.channelName, this.role, this.callKit})
      : super(key: key);
  @override
  _VoiceCallPageState createState() => _VoiceCallPageState();
}

class _VoiceCallPageState extends State<voiceCallPage> {
  Timer _timmerInstance;
  int _start = 0;
  String _timmer = '';
  static final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  bool speaker = false;

  final assetsAudioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();
    // initialize agora sdk

    //startTimmer();

    assetsAudioPlayer.open(
        Playlist(audios: [
          Audio("assets/sound/bensound-anewbeginning.mp3"),
        ]),
        loopMode: LoopMode.playlist //loop the full playlist
        );
    assetsAudioPlayer.play();
    initialize();
  }

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk

    print('dispose');
    print(_timmerInstance.toString());
    AgoraRtcEngine.leaveChannel();
    Firestore.instance
        .collection('Room')
        .document(widget.channelName)
        .collection('Message')
        .add(Map<String, dynamic>.from(widget.chatInfo['endMsg']));
    AgoraRtcEngine.destroy();

    assetsAudioPlayer.stop();
    super.dispose();
  }

  Future<bool> _willPopCallback() async {
    //widget.callKit.endCall();
    _users.clear();
    // destroy sdk
    print('dispose');
    _timmerInstance.cancel();
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();

    assetsAudioPlayer.stop();
    Navigator.pop(context);

    return true;
  }

  Future<void> initialize() async {
    print('VOICE INIT');
    sleep(const Duration(seconds: 1));
    if (APP_ID.isEmpty) {
      setState(() {
        print(
          'APP_ID missing, please provide your APP_ID in settings.dart'.tr(),
        );
        print('Agora Engine is not starting'.tr());
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await AgoraRtcEngine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = Size(0, 0);
    await AgoraRtcEngine.setVideoEncoderConfiguration(configuration);
    await AgoraRtcEngine.joinChannel(null, widget.channelName, null, 0);
    AgoraRtcEngine.setEnableSpeakerphone(speaker);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    await AgoraRtcEngine.create(APP_ID);
    await AgoraRtcEngine.enableVideo();
    await AgoraRtcEngine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await AgoraRtcEngine.setClientRole(widget.role);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onError = (dynamic code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onJoinChannelSuccess = (
      String channel,
      int uid,
      int elapsed,
    ) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onLeaveChannel = () {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        print(info + '-----------------------------');

        assetsAudioPlayer.stop();

        _infoStrings.add(info);
        _users.add(uid);
        //  if(_users.length>1){startTimmer();}
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      setState(() {
        final info = 'userOffline: $uid';
        // _infoStrings.add(info);
        print(info);
        _users.remove(uid);
        print('유저 나감 몇명>?${_users.length}-------------------------');

        if (_users.isEmpty) {
          // _timmerInstance.cancel;
          //widget.callKit.endCall();
          Navigator.pop(context);
        }
      });
    };

    AgoraRtcEngine.onFirstRemoteVideoFrame = (
      int uid,
      int width,
      int height,
      int elapsed,
    ) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    };
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<AgoraRenderWidget> list = [];
    if (widget.role == ClientRole.Broadcaster) {
      list.add(AgoraRenderWidget(0, local: true, preview: true));
    }
    _users.forEach((int uid) => list.add(AgoraRenderWidget(uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
    }
    return Container();
  }

  /// Toolbar layout
  Widget _toolbar() {
    if (widget.role == ClientRole.Audience) return Container();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return null;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _infoStrings[index],
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
    widget.callKit.endCall();
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    AgoraRtcEngine.muteLocalAudioStream(muted);
  }

  void _onToggleSpeaker() {
    setState(() {
      speaker = !speaker;
    });
    AgoraRtcEngine.setEnableSpeakerphone(speaker);
  }

  void _onSwitchCamera() {
    AgoraRtcEngine.switchCamera();
  }

  void startTimmer() {
    var oneSec = Duration(seconds: 1);
    _timmerInstance = Timer.periodic(
        oneSec,
        (Timer timer) => setState(() {
              if (!mounted) return;
              if (_start < 0) {
                _timmerInstance.cancel();
              } else {
                _start = _start + 1;
                _timmer = getTimerTime(_start);
              }
            }));
  }

  String getTimerTime(int start) {
    int minutes = (start ~/ 60);
    String sMinute = '';
    if (minutes.toString().length == 1) {
      sMinute = '0' + minutes.toString();
    } else
      sMinute = minutes.toString();

    int seconds = (start % 60);
    String sSeconds = '';
    if (seconds.toString().length == 1) {
      sSeconds = '0' + seconds.toString();
    } else
      sSeconds = seconds.toString();

    return sMinute + ':' + sSeconds;
  }

  String mergeUsername(List<Profile> user) {
    List<String> result = List<String>();
    user.forEach((element) {
      result.add(element.nickname);
    });
    return result.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
        body: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: const Color(0xfff2f3f6),
            ),
            padding: EdgeInsets.all(50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 0.0,
                ),
                /* Text(
                'VOICE CALL',
                style: TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontWeight: FontWeight.w300,
                    fontSize: 15),
              ),*/
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  mergeUsername(widget.chatInfo['withUser']),
                  style: TextStyle(
                      color: Color(0xff1a1a1a),
                      fontWeight: FontWeight.w500,
                      fontSize: 30),
                ),
                Text(
                  _timmer,
                  style: TextStyle(
                      color: MyColors.primaryColor,
                      fontWeight: FontWeight.w300,
                      fontSize: 15),
                ),
                SizedBox(
                  height: 20.0,
                ),
                widget.chatInfo['photoUrl'] != null
                    ? CircleAvatar(
                        backgroundImage:
                            NetworkImage(widget.chatInfo['photoUrl']),
                        radius: 80.0)
                    : CircleAvatar(
                        backgroundImage: AssetImage('assets/img/noface.png'),
                        radius: 80.0),
                SizedBox(
                  height: 40.0,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: [
                        RawMaterialButton(
                          onPressed: _onToggleSpeaker,
                          child: Icon(
                            Icons.volume_up,
                            color: speaker ? Colors.white : Color(0xff1a1a1a),
                            size: 40.0,
                          ),
                          shape: CircleBorder(),
                          elevation: 4.0,
                          fillColor:
                              speaker ? Color(0xff1a1a1a) : Color(0xfff2f3f6),
                          padding: EdgeInsets.all(12.0),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child:
                              Text('스피커', style: TextStyle(fontSize: 12)).tr(),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        RawMaterialButton(
                          onPressed: _onToggleMute,
                          child: Icon(
                            muted ? Icons.mic_off : Icons.mic,
                            color: muted ? Colors.white : Color(0xff1a1a1a),
                            size: 40.0,
                          ),
                          shape: CircleBorder(),
                          elevation: 4.0,
                          fillColor:
                              muted ? Color(0xff1a1a1a) : Color(0xfff2f3f6),
                          padding: EdgeInsets.all(12.0),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child:
                              Text('음소거', style: TextStyle(fontSize: 12)).tr(),
                        )
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 20.0,
                ),
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      child: FloatingActionButton(
                        onPressed: () {
                          _onCallEnd(context);
                        },
                        elevation: 4.0,
                        mini: false,
                        child: Icon(
                          Icons.call_end,
                          size: 35,
                          color: Color(0xFFffffff),
                        ),
                        backgroundColor: Color(0xffd50000),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Text('전화 끊기', style: TextStyle(fontSize: 12)).tr(),
                    )
                  ],
                ),
                Container(
                  width: 0,
                  height: 0,
                  child: _viewRows(),
                )
                //
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FunctionalButton extends StatefulWidget {
  final title;
  final icon;
  final Function() onPressed;

  const FunctionalButton({Key key, this.title, this.icon, this.onPressed})
      : super(key: key);

  @override
  _FunctionalButtonState createState() => _FunctionalButtonState();
}

class _FunctionalButtonState extends State<FunctionalButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        RawMaterialButton(
          onPressed: widget.onPressed,
          splashColor: MyColors.primaryColor,
          fillColor: Colors.white,
          elevation: 10.0,
          shape: CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Icon(
              widget.icon,
              size: 30.0,
              color: MyColors.primaryColor,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
          child: Text(
            widget.title,
            style: TextStyle(fontSize: 15.0, color: MyColors.primaryColor),
          ),
        )
      ],
    );
  }
}
