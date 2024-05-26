import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:fyp1/page/Colors.dart';

class NoteView extends StatefulWidget {
  final String chapterid;
  final String sub;
  const NoteView({Key? key, required this.chapterid, required this.sub})
      : super(key: key);

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  late String _noteTitle = '';
  late String _sub = '';
  late String _pdf = '';
  bool _isPDFReady = false;
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _fetchNotesData();
  }

  void _fetchNotesData() async {
    if (widget.chapterid.isNotEmpty) {
      final QuerySnapshot notesQuery = await FirebaseFirestore.instance
          .collection('notes')
          .where('chapter', isEqualTo: widget.chapterid)
          .where('sub', isEqualTo: widget.sub)
          .get();

      if (notesQuery.docs.isNotEmpty) {
        final DocumentSnapshot notesDoc = notesQuery.docs.first;
        setState(() {
          _noteTitle = notesDoc['title'];
          _sub = notesDoc['sub'];
          _pdf = notesDoc['notepdf'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.02,
                left: MediaQuery.of(context).size.width * 0.04,
                right: MediaQuery.of(context).size.width * 0.04,
              ),
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.1,
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 4,
                  color: AppColors.secondaryColor,
                ),
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: AppColors.thirdColor,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      player.play(AssetSource('audio/pop.mp3'));
                      Future.delayed(Duration(milliseconds: 500), () {
                        Navigator.pop(context);
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.05,
                      ),
                      width: MediaQuery.of(context).size.width * 0.12,
                      height: MediaQuery.of(context).size.width * 0.12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: AppColors.secondaryColor,
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: MediaQuery.of(context).size.width * 0.05,
                        color: AppColors.thirdColor,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.05,
                    ),
                    alignment: Alignment.centerLeft,
                    height: MediaQuery.of(context).size.height * 0.12,
                    width: MediaQuery.of(context).size.width * 0.67,
                    child: Text(
                      _noteTitle,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: MediaQuery.of(context).size.width * 0.043,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: _pdf.isNotEmpty
                    ? PDF(
                        enableSwipe: true,
                        swipeHorizontal: true,
                        autoSpacing: false,
                        pageFling: false,
                        onError: (error) {
                          print(error.toString());
                        },
                        onViewCreated: (PDFViewController viewController) {
                          viewController
                              .getPageCount()
                              .then((count) => setState(() {
                                    _isPDFReady = true;
                                  }));
                        },
                      ).cachedFromUrl(_pdf)
                    : CircularProgressIndicator(),
              ),
            ),
            if (!_isPDFReady)
              Text(
                'Loading PDF...',
                style: TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
