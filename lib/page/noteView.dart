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
              margin: EdgeInsets.only(top: 15, left: 10, right: 10),
              width: double.infinity,
              height: 80,
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                  border: Border.all(width: 4, color: AppColors.secondaryColor),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: AppColors.thirdColor),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: AppColors.secondaryColor,
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          size: 20,
                          weight: 5,
                          color: AppColors.thirdColor,
                        )),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    alignment: Alignment.center,
                    height: 90,
                    width: 300,
                    child: Text(
                      _noteTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  )
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
