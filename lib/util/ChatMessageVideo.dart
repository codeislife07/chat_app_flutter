import 'dart:io';
import 'dart:typed_data';

// import 'package:cached_video_player/cached_video_player.dart';
import 'package:chat_ui_kit/src/models/message_base.dart';
import 'package:chat_ui_kit/src/utils/enums.dart';
import 'package:chat_ui_kit/src/utils/extensions.dart';
import 'package:chat_ui_kit/src/widgets/core/messages_list_tile.dart';
import 'package:chat_ui_kit/src/widgets/helpers/message_container.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/util/date_formatter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../Screen/PlayVideoScreen.dart';

/// A default Widget that can be used to show a video preview.
/// One would play the video upon clicking the item.
/// This is more an example to give you an idea how to structure your own Widget,
/// since too many aspects would require to be customized, for instance
/// implementing your own image loader, padding, constraints, footer etc.
class ChatMessageVideo extends StatefulWidget {
  final int index;

  final MessageBase message;

  final MessagePosition? messagePosition;

  final MessageFlow messageFlow;

  const ChatMessageVideo(
      this.index, this.message, this.messagePosition, this.messageFlow,
      {Key? key})
      : super(key: key);

  @override
  _ChatMessageVideoState createState() => _ChatMessageVideoState();
}

class _ChatMessageVideoState extends State<ChatMessageVideo> {
  Future<VideoData?>? _videoData;
  Future<Uint8List?>? _videoThumbnail;
   VideoPlayerController? controller;
  bool load=true;
  double get _maxSize => MediaQuery.of(context).size.width * 0.5;
  // late CachedVideoPlayerController controller;
  @override
  void initState() {
    _videoData = getVideoInfo(File(widget.message.url));
    _videoThumbnail = VideoThumbnail.thumbnailData(
      video: widget.message.url,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 200,
      // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 100,
    );
    load=false;
    setState(() {
    });
    print("$_videoData $_videoThumbnail");
    print("url video ${ widget.message.url}");
    // controller = VideoPlayerController.network(
    //     widget.message.url);
    // setState(() {});
    // controller!.initialize().then((value) {
    //  setState(() {
    //    load=false;
    //  });
    // });
    super.initState();
  }

  /// Retrieve video metaData
  Future<VideoData?> getVideoInfo(File file) {
    final videoInfo = FlutterVideoInfo();
    return videoInfo.getVideoInfo(file.path);
  }

  @override
  Widget build(BuildContext context) {
    final Widget _footer = Padding(
        padding: EdgeInsets.all(8),
        child:Stack(
            children: [
              Center(
                child:IconButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (_)=>PlayVideoScreen(widget.message.url)));
                  },icon: FaIcon(FontAwesomeIcons.play,color: Colors.white,size: 50,),),

              ),
              Positioned(
                  bottom: 3,right: 10,
                  child: Text("${DateFormatter.getVerboseDateTimeRepresentation(context, widget.message.createdAt)}"))
            ],
          ),

    );

    return SizedBox(
        height: 200,
        width: 250,
        child: load?Center(child: CircularProgressIndicator()):FutureBuilder(
            future: _videoThumbnail,
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data != null) {
                return MessageContainer(
                    constraints:
                    BoxConstraints(maxWidth: _maxSize, maxHeight: _maxSize),
                    padding: EdgeInsets.zero,
                    decoration: messageDecoration(context,
                        messagePosition: widget.messagePosition,
                        color: Colors.transparent,
                        messageFlow: widget.messageFlow),
                    child: Stack(
                      alignment: AlignmentDirectional.bottomEnd,
                      children: [
                        Image.memory(snapshot.data as Uint8List,
                            fit: BoxFit.cover,
                            width: _maxSize,
                            height: _maxSize),
                        _footer
                      ],
                    ));
              }

              return Container();
            }));
  }
}
class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({
    Key? key,
    required this.name,
  }) : super(key: key);

  final String name;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoPlayerController;
  var _isLoading = true;
  late Future<void> initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  void _initPlayer() async {
    final _url =widget.name;
    _videoPlayerController = VideoPlayerController.network(_url);
    initializeVideoPlayerFuture = _videoPlayerController!.initialize();
    _isLoading = false;
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    if(_isLoading) {
      return CircularProgressIndicator();
    }
    return FutureBuilder(
      future: initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _videoPlayerController!.value.aspectRatio,
            child: VideoPlayer(_videoPlayerController!),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}