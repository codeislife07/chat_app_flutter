import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:video_player/video_player.dart';

class PlayVideoScreen extends StatefulWidget{
  String url;
  PlayVideoScreen(this.url);

  @override
  State<StatefulWidget> createState() =>PlayVideoScreenState();

}

class PlayVideoScreenState extends State<PlayVideoScreen> {
  VlcPlayerController? _videoPlayerController;
  VideoPlayerController? controller;
bool load=true;
  @override
  void initState() {
    try{
      _videoPlayerController = VlcPlayerController.network(
        widget.url,
        hwAcc: HwAcc.full,
        autoPlay: false,
        options: VlcPlayerOptions(),
      );
      controller = VideoPlayerController.network(
          widget.url);
      controller!.initialize().then((value) {
        load=false;
        setState(() {

        });
       });
    }catch(e){
      print("Exception===$e");
    }

    super.initState();
  }

  Future<void> initializePlayer() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Center(
          // child: VlcPlayer(
          //   controller: _videoPlayerController!,
          //   aspectRatio: 16 / 9,
          //   placeholder: Center(child: CircularProgressIndicator()),
          // ),
          child: load?Center(child: CircularProgressIndicator(),):Column(
            children: [
              Expanded(child: VideoPlayer(controller!)),
              Row(children: [
                Spacer(),IconButton(onPressed: (){controller!.play();}, icon: Icon(Icons.play_circle)),
                Spacer(),IconButton(onPressed: (){controller!.pause();}, icon: Icon(Icons.pause_circle)),Spacer()
              ],)
            ],
          ),
        )
    );
  }
}