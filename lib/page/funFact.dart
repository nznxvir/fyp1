import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp1/page/Colors.dart';

class FactsView extends StatefulWidget {
  const FactsView({super.key});

  @override
  State<FactsView> createState() => _FactsViewState();
}

class _FactsViewState extends State<FactsView> {
  final PageController _pageController = PageController();
  List<DocumentSnapshot> _facts = [];
  bool _isLoading = false;
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _fetchFacts();
  }

  Future<void> _fetchFacts() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('funfact').get();
      setState(() {
        _facts = snapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching facts: $e');
      setState(() => _isLoading = false);
    }
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, right: 10, left: 10),
      width: double.infinity,
      height: 80,
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
          border: Border.all(width: 4, color: AppColors.secondaryColor),
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: AppColors.thirdColor),
      child: Row(
        children: [
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              player.play(AssetSource('audio/pop.mp3'));
              Future.delayed(Duration(milliseconds: 500), () {
                Navigator.pop(context);
              });
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
                  size: 30,
                  weight: 5,
                  color: AppColors.thirdColor,
                )),
          ),
          const SizedBox(width: 10),
          Container(
            alignment: Alignment.center,
            height: 90,
            width: 300,
            child: Text(
              'Fakta menarik',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: _buildCustomAppBar(context),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: _facts.length,
                itemBuilder: (context, index) {
                  final fact = _facts[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(25, 80, 25, 80),
                    child: AnimatedContainer(
                      duration: Duration(seconds: 1),
                      curve: Curves.elasticInOut,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              width: 16, color: AppColors.secondaryColor),
                          left: BorderSide(
                              width: 10, color: AppColors.secondaryColor),
                        ),
                        color: AppColors.thirdColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            fact['title'],
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 27,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            fact['fact'],
                            style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 21,
                                color: AppColors.secondaryColor,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
