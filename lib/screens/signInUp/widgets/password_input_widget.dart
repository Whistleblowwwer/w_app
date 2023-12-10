import 'package:flutter/material.dart';
import 'package:w_app/styles/color_style.dart';

class PasswordInputWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType inputType;
  final bool obscureText;
  final String hintText;
  final FocusNode focusNode;
  final Function(String)? onFieldSubmitted;
  final Function()? onTapVisibility;
  final String? Function(String?)? validator;

  const PasswordInputWidget({
    Key? key,
    required this.label,
    required this.controller,
    required this.inputType,
    required this.obscureText,
    required this.hintText,
    required this.focusNode,
    this.onFieldSubmitted,
    this.onTapVisibility,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Visibility(
            visible: label.isNotEmpty,
            child: Text(label,
                style: const TextStyle(fontSize: 14, fontFamily: "Anuphan"))),
        Container(
          width: double.maxFinite,
          margin: const EdgeInsets.only(top: 4, bottom: 16),
          child: TextFormField(
            keyboardType: TextInputType.visiblePassword,
            cursorColor: Colors.grey[600],
            controller: controller,
            obscureText: obscureText,
            focusNode: focusNode,
            validator: validator,
            decoration: InputDecoration(
                suffixIcon: onTapVisibility != null
                    ? GestureDetector(
                        onTap: onTapVisibility,
                        child: Icon(
                            obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: ColorStyle.grey),
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                filled: true,
                fillColor: ColorStyle.sectionBase,
                hintText: '************',
                hintStyle:
                    TextStyle(color: Colors.grey[600], fontFamily: "Anuphan"),
                border: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(2),
                  borderSide: BorderSide.none,
                )),
          ),
        ),
      ],
    );
  }
}
