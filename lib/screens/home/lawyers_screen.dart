import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:w_app/styles/color_style.dart';

class LawyersScreen extends StatefulWidget {
  const LawyersScreen();

  @override
  _LawyersScreenState createState() => _LawyersScreenState();
}

class _LawyersScreenState extends State<LawyersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {});
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
                  "Abogados",
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
                                "Abogado ${index}",
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
