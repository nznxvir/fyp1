import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

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
        body: Column(
          children: [
            Container(
              width: double.infinity,
              height: 90,
              alignment: Alignment.topCenter,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                  color: Color(0xFF6F131E)),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: 30,
                      weight: 20,
                      color: Color(0xFFEEE0C9),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    alignment: Alignment.center,
                    height: 90,
                    width: 300,
                    child: Text(
                      _noteTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEEE0C9)),
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
