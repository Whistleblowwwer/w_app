import 'package:flutter/material.dart';
import 'package:w_app/styles/color_style.dart';

class CustomTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final String labelText;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputType? type;

  const CustomTextFormField(
      {super.key,
      required this.controller,
      this.focusNode,
      this.nextFocusNode,
      required this.labelText,
      this.obscureText = false,
      this.validator,
      this.onFieldSubmitted,
      this.type});

  @override
  CustomTextFormFieldState createState() => CustomTextFormFieldState();
}

class CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.type,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
        ),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          labelText: widget.labelText,
          floatingLabelStyle: const TextStyle(
              color: ColorStyle.textGrey,
              fontSize: 16,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600),
          labelStyle: const TextStyle(
              color: ColorStyle.textGrey,
              fontFamily: 'Montserrat',
              fontSize: 14,
              fontWeight: FontWeight.w600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide:
                const BorderSide(color: ColorStyle.borderGrey, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(
                color: ColorStyle.borderGrey,
                width: 1.0), // Color y grosor cuando está enfocado
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(
                color: ColorStyle.borderGrey,
                width:
                    1.0), // Color y grosor cuando está habilitado pero no enfocado
          ),
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: ColorStyle.borderGrey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
        ),
        focusNode: widget.focusNode,
        validator: widget.validator,
        obscureText: widget.obscureText ? _obscureText : false,
        onFieldSubmitted: (value) {
          if (widget.nextFocusNode != null) {
            FocusScope.of(context).requestFocus(widget.nextFocusNode);
          }
          if (widget.onFieldSubmitted != null) {
            widget.onFieldSubmitted!(value);
          }
        },
      ),
    );
  }
}
