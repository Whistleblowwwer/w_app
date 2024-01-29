import 'package:flutter/material.dart';
import 'package:w_app/styles/color_style.dart';

class CustomTextField extends StatefulWidget {
  final FocusNode focusNode; // Añade esta línea
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const CustomTextField(
      {super.key,
      required this.focusNode,
      required this.controller,
      this.validator}); // Añade este constructor

  @override
  CustomTextFieldState createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: ColorStyle.lightGrey,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTextField(),
          _buildCounter(),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return Flexible(
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        maxLines: 8,
        minLines: 1,
        textCapitalization: TextCapitalization.sentences,
        validator: widget.validator,
        style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            fontFamily: 'Montserrat'),
        decoration: InputDecoration(
          hintText: 'Escribe algo...',
          contentPadding: const EdgeInsets.only(bottom: 16),
          errorStyle: const TextStyle(
              fontFamily: 'Montserrat',
              color: ColorStyle.accentRed,
              fontSize: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  Widget _buildCounter() {
    return Align(
      alignment: Alignment.centerLeft,
      child: ValueListenableBuilder(
        valueListenable: widget.controller,
        builder: (context, value, child) {
          return Text(
            '${widget.controller.text.length}/1200',
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              fontFamily: 'Montserrat',
              color: ColorStyle.textGrey,
            ),
          );
        },
      ),
    );
  }
}
