import 'package:flutter/material.dart';
import 'package:w_app/models/user.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/press_transform_widget.dart';

class ReviewAction {
  final Color? color;
  final String text;
  final VoidCallback onPressed;

  ReviewAction({required this.text, required this.onPressed, this.color});
}

class ReviewBottomSheet extends StatelessWidget {
  final User user;
  final List<ReviewAction> actions; // Lista de acciones
  final VoidCallback onReport;

  const ReviewBottomSheet(
      {super.key,
      required this.user,
      required this.actions, // Acepta la lista de acciones
      required this.onReport});

  @override
  Widget build(BuildContext context) {
    // final sizeW = MediaQuery.of(context).size.width / 100;
    // final sizeH = MediaQuery.of(context).size.height / 100;
    return Container(
      width: double.maxFinite,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 48,
                  height: 4,
                  margin: const EdgeInsets.only(top: 16, bottom: 24),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: ColorStyle.borderGrey),
                ),
                OptionsWidget(actions: actions),
                Container(
                  margin:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 56),
                  width: double.maxFinite,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                      color: ColorStyle.lightGrey,
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PressTransform(
                        animation: false,
                        onPressed: onReport,
                        child: Container(
                          color: ColorStyle.lightGrey,
                          width: double.maxFinite,
                          padding: const EdgeInsets.all(16),
                          child: const Text(
                            "Envía tu reporte a reportes@whistleblowwer.com",
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12,
                                color: ColorStyle.accentRed,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OptionsWidget extends StatelessWidget {
  final List<ReviewAction> actions;

  const OptionsWidget({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      width: double.maxFinite,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: ColorStyle.lightGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: actions.asMap().entries.map((entry) {
          int idx = entry.key;
          ReviewAction action = entry.value;

          return Column(
            children: [
              PressTransform(
                animation: false,
                onPressed: () {
                  action.onPressed();
                  Navigator.of(context).pop();
                },
                child: Container(
                  color: ColorStyle.lightGrey,
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    action.text,
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        color: action.color ?? Colors.black),
                  ),
                ),
              ),
              // Agregar Divider si no es el último elemento
              if (idx != actions.length - 1)
                const Divider(
                  height: 1,
                  color: ColorStyle.borderGrey,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
