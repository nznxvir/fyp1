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
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.12,
            width: MediaQuery.of(context).size.width * 0.5,
            child: Text(
              'Fakta Menarik',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: MediaQuery.of(context).size.width * 0.06,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ),
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
                  final screenWidth = MediaQuery.of(context).size.width;
                  final screenHeight = MediaQuery.of(context).size.height;
                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      screenWidth * 0.06,
                      screenHeight * 0.1,
                      screenWidth * 0.06,
                      screenHeight * 0.1,
                    ),
                    child: AnimatedContainer(
                      duration: Duration(seconds: 1),
                      curve: Curves.elasticInOut,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: screenWidth * 0.04,
                            color: AppColors.secondaryColor,
                          ),
                          left: BorderSide(
                            width:
                                screenWidth * 0.025, // 2.5% of the screen width
                            color: AppColors.secondaryColor,
                          ),
                        ),
                        color: AppColors.thirdColor,
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                      ),
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            fact['title'],
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: screenWidth * 0.07,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            fact['fact'],
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: screenWidth * 0.047,
                              color: AppColors.secondaryColor,
                              fontWeight: FontWeight.w600,
                            ),
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
