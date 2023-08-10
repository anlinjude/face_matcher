import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:face_camera/face_camera.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter_face_api/face_api.dart' as Regula;

class FaceMatchingPage extends StatefulWidget {
  const FaceMatchingPage({super.key});

  @override
  State<FaceMatchingPage> createState() => _FaceMatchingPageState();
}

class _FaceMatchingPageState extends State<FaceMatchingPage> {

  String anlin = "assets/images/anlin";
  List<FaceAsset> faces = [];
  File ?file;

  //
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    faces = [
      FaceAsset(name: "Anlin",url: "assets/images/anlin.jpg"),
      FaceAsset(name: "Pooja",url: "assets/images/pooja.jpeg"),
      FaceAsset(name: "Nadir",url: "assets/images/nadir.jpeg"),
    ];
  }

  //
  loadAssetImage() async {
    final ByteData data = await rootBundle.load('assets/images/anlin.jpg'); // Load the asset
    setImage(true,data.buffer.asUint8List(),5);
  }

  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width*0.8,
              child: ElevatedButton(
                  child: const Text("Use camera"),
                  onPressed: () {
                    showCamera(context);
                  })
            ),
            const SizedBox(height: 10),
            Text("Match Percentage-->${_similarity!.isEmpty?"0.00":_similarity}"),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    faces.firstWhere((element) => element.isMatching!, orElse: ()=>
                        FaceAsset(name: "No Matches")).name!!="No Matches"?"Hi ":""),
                Text(faces.firstWhere((element) => element.isMatching!,orElse: ()=>FaceAsset(name: "No Matches")).name!),
              ],
            ),
            const SizedBox(height: 10),
            isLoading?CircularProgressIndicator(color: Colors.black,):SizedBox()
          ],
        ),
      ),
    );
  }

  //
  setImage(bool first, Uint8List? imageFile, int type,) {
    if (imageFile == null) return;
    setState(() => _similarity = "nil");
    if (first) {
      image1.bitmap = base64Encode(imageFile);
      image1.imageType = type;
    } else {
      image2.bitmap = base64Encode(imageFile);
      image2.imageType = type;
      matchFaces();
    }
  }

  //
  showCamera(BuildContext context) async {

    await showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            content: SmartFaceCamera(
              autoCapture: true,
              defaultCameraLens: CameraLens.front,
              message: 'Center your face in the square',
              showControls: false,
              onCapture: (File? image){
                print("image path-->${image?.path}");
                File file = File(image!.path);
                setImage(false,file.readAsBytesSync(),3);
                Navigator.of(context).pop();
              },
              onFaceDetected: (v){
                print(v);
               // Navigator.of(context).pop();
              },
            ),
          );
        }
    );
  }

  bool isLoading = false;
  //
  String ?_similarity = "";
  var image1 = new Regula.MatchFacesImage();
  var image2 = new Regula.MatchFacesImage();

  //
  matchFaces() {

    setState(() {
      faces = faces.map((e) => e..isMatching=false).toList();
      isLoading = true;
    });
    try{
      faces.forEach((face) async {
        var dynamicImage = Regula.MatchFacesImage();
        double matchPercent = 0.0;
        final ByteData data = await rootBundle.load(face.url!); // Load the asset
        dynamicImage.bitmap = base64Encode(data.buffer.asUint8List());
        dynamicImage.imageType = 5;
        var request = Regula.MatchFacesRequest();
        request.images = [dynamicImage, image2];
        Regula.FaceSDK.matchFaces(jsonEncode(request)).then((value) {
          var response = Regula.MatchFacesResponse.fromJson(json.decode(value));
          Regula.FaceSDK.matchFacesSimilarityThresholdSplit(
              jsonEncode(response!.results), 0.75)
              .then((str) {
            var split = Regula.MatchFacesSimilarityThresholdSplit.fromJson(
                json.decode(str));
            matchPercent = split!.matchedFaces.isNotEmpty
                ? (split.matchedFaces[0]!.similarity! * 100):0;
            faces.forEach((element) {
              if(element.name==face.name&&matchPercent>90){
                faces.firstWhere((element) => element.name==face.name).isMatching=true;
              }
              print(matchPercent);
            });
            if(matchPercent>90){
              setState(() => _similarity = split!.matchedFaces.length > 0
                  ? ((split.matchedFaces[0]!.similarity! * 100).toStringAsFixed(2) +
                  "%")
                  : "error");
            }
          });
        });
      });
    }catch(e){
      setState(() {
        isLoading = false;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

}

class FaceAsset {
  String? name;
  String? url;
  bool? isMatching;
  double ?matchPercentage;

  FaceAsset({this.name, this.url,this.isMatching=false,this.matchPercentage});
}
