import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:w_app/models/review_model.dart';
import 'package:w_app/models/user.dart';
import 'package:w_app/screens/add/widgets/custom_textfield_widget.dart';
import 'package:w_app/services/api/api_service.dart';
import 'package:w_app/styles/color_style.dart';
import 'package:w_app/widgets/circularAvatar.dart';
import 'package:w_app/widgets/dotters.dart';
import 'package:w_app/widgets/press_transform_widget.dart';
import 'package:w_app/widgets/snackbar.dart';

class CommentBottomSheet extends StatefulWidget {
  final User user;
  final String name;
  final String lastName;
  final String content;

  const CommentBottomSheet(
      {super.key,
      required this.user,
      required this.name,
      required this.lastName,
      required this.content});
  @override
  _CommentBottomSheetState createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet>
    with SingleTickerProviderStateMixin {
  TextEditingController controllerReview = TextEditingController();
  FocusNode focusNodeReview = FocusNode();
  final _formKeyReview = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    focusNodeReview.requestFocus();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Container(
        width: double.maxFinite,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: _reviewPage(context)),
      ),
    );
  }

  Widget _reviewPage(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNodeReview);
    });
    return Form(
      key: _formKeyReview,
      child: Container(
        height: MediaQuery.of(context).size.height -
            MediaQuery.of(context).viewInsets.bottom -
            72,
        child: Stack(
          // mainAxisSize: MainAxisSize.min,
          children: [
            Positioned(
              top: 56,
              left: 0, // Añade esto para posicionar y dar un ancho finito
              right: 0, // Añade esto para posicionar y dar un ancho finito
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                    child: Row(
                      children: [
                        CircularAvatarW(
                          externalRadius: Offset(42, 42),
                          internalRadius: Offset(36, 36),
                          nameAvatar: widget.name.substring(0, 1),
                          isCompany: false,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Flexible(
                          child: SizedBox(
                            width: double.maxFinite,
                            child: Text(
                              "${widget.name} ${widget.lastName}",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 1.5,
                          margin: EdgeInsets.only(left: 36, bottom: 4, top: 4),
                          color: ColorStyle.borderGrey,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 30, bottom: 16),
                                child: Text(
                                  widget.content,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Montserrat',
                                    height: 1.42,
                                    letterSpacing: 0.36,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 0),
                    child: Row(
                      children: [
                        CircularAvatarW(
                          externalRadius: Offset(42, 42),
                          internalRadius: Offset(36, 36),
                          nameAvatar: widget.user.name.substring(0, 1),
                          isCompany: false,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Flexible(
                          child: SizedBox(
                            width: double.maxFinite,
                            child: Text(
                              "${widget.user.name} ${widget.user.lastName}",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 1.5,
                          margin: EdgeInsets.only(left: 36, bottom: 4, top: 4),
                          color: ColorStyle.borderGrey,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.only(
                                      left: 28, right: 16, bottom: 8),
                                  child: CustomTextField(
                                    focusNode: focusNodeReview,
                                    controller: controllerReview,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor escribe una reseña y elige una entidad';
                                      }
                                      // Add more validation if necessary
                                      return null;
                                    },
                                  )),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 28, bottom: 8),
                                child: SvgPicture.asset(
                                  'assets/images/icons/addImage.svg',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0, // Añade esto para posicionar y dar un ancho finito
              right: 0, // Añade esto para posicionar y dar un ancho finito
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            "Cualquiera puede ver",
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: ColorStyle.textGrey,
                                fontFamily: 'Montserrat',
                                fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    PressTransform(
                      onPressed: () async {
                        if (_formKeyReview.currentState!.validate()) {
                          Navigator.of(context).pop({
                            'content': controllerReview.text,
                          });
                        }
                      },
                      child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                              color: ColorStyle.lightGrey,
                              borderRadius: BorderRadius.circular(16)),
                          child: Text(
                            "Publicar",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                                fontSize: 14),
                          )),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0, // Añade esto para posicionar y dar un ancho finito
              right: 0, // Añade esto para posicionar y dar un ancho finito
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 16, bottom: 12),
                    child: Stack(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            "Cancelar",
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Montserrat',
                                fontSize: 15),
                          ),
                        ),
                        const Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Responder",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                  fontSize: 15),
                            )),
                      ],
                    ),
                  ),
                  const Divider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomInput extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final FocusNode focusNode;

  CustomInput(
      {super.key,
      required this.title,
      required this.controller,
      required this.focusNode});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: "Montserrat",
                color: ColorStyle.textGrey,
                fontSize: 14,
                fontWeight: FontWeight.w400),
          ),
          Container(
            width: double.maxFinite,
            height: 48,
            margin: EdgeInsets.only(top: 2),
            padding: EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                color: ColorStyle.borderGrey,
                width: 1.0,
              ),
              color:
                  Colors.white, // Cambia el color de fondo según tu preferencia
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: TextStyle(fontFamily: "Montserrat", fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,

                hintText: 'Input*', // Cambia el texto de marcador de posición
              ),
            ),
          ),
        ],
      ),
    );
  }
}
