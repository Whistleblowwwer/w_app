import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:w_app/styles/color_style.dart';

class AdvisorScreen extends StatefulWidget {
  const AdvisorScreen();

  @override
  _AdvisorScreenState createState() => _AdvisorScreenState();
}

class _AdvisorScreenState extends State<AdvisorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // await widget.userRepository.deleteToken();

      // _fetchUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: Platform.isIOS ? 72 : 40,
                    bottom: 32),
                height: 56,
                width: double.maxFinite,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.white),
                child: Text(
                  "Asesores",
                  style: TextStyle(
                      fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
                ),
              ),
              Column(
                children: List.generate(
                    10,
                    (index) => Container(
                          margin: EdgeInsets.only(
                              left: 24, right: 24, top: 8, bottom: 8),
                          height: 104,
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 24, right: 24),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    color: ColorStyle.lightGrey,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Icon(
                                  FeatherIcons.user,
                                  size: 32,
                                ),
                              ),
                              Text(
                                "Asesor ${index}",
                                style: TextStyle(fontFamily: 'Montserrat'),
                              ),
                            ],
                          ),
                        )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
