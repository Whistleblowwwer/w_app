import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

class ArrowBackWidget extends StatelessWidget {
  const ArrowBackWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: const Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16, right: 8),
            child: Icon(FeatherIcons.arrowLeft),
          ),
          Text(
            "Atrás",
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
