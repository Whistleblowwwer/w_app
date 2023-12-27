import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:w_app/styles/color_style.dart';

class CodeField extends StatefulWidget {
  final ValueChanged<String>? onCodeChanged;
  final VoidCallback? onCodeCompleted;
  final List<FocusNode> focusNodes;
  final List<TextEditingController> controllers;

  const CodeField(
      {Key? key,
      this.onCodeChanged,
      this.onCodeCompleted,
      required this.focusNodes,
      required this.controllers})
      : super(key: key);

  @override
  _CodeFieldState createState() => _CodeFieldState();
}

class _CodeFieldState extends State<CodeField> {
  //Definir el cursor siempre antes del número
  void _handleTextFieldTap(int index) {
    int cursorPosition = widget.controllers[index].text.isEmpty ? 0 : 1;
    widget.focusNodes[index].requestFocus();
    widget.controllers[index].selection =
        TextSelection.collapsed(offset: cursorPosition);
  }

  // Esta función maneja el evento de pegar el texto.
  void _handlePaste(String value) {
    // Itera a través de los controladores de texto para encontrar el campo de entrada enfocado.
    for (int i = 0; i < widget.controllers.length; i++) {
      if (widget.focusNodes[i].hasPrimaryFocus) {
        // Una vez que encuentra el campo enfocado, itera a través del texto pegado y asigna cada carácter
        // a los campos de entrada siguientes, comenzando por el campo enfocado.
        for (int j = 0; j < value.length; j++) {
          if (i + j < 4) {
            widget.controllers[i + j].text = value[j];
            // Si no es el último campo de entrada, pasa el enfoque al siguiente campo.
            if (i + j < 3) {
              // Agrega una pequeña demora antes de cambiar el enfoque
              Future.delayed(const Duration(milliseconds: 15), () {
                FocusScope.of(context)
                    .requestFocus(widget.focusNodes[i + j + 1]);
              });
            } else {
              // Si es el último campo de entrada, quita el enfoque.

              widget.focusNodes[i + j].unfocus();
            }
          }
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < 4; i++)
          Container(
            width: 46,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              controller: widget.controllers[i],
              focusNode: widget.focusNodes[i],
              autofocus: i == 0,
              maxLength: 1,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              showCursor: false,
              cursorColor: ColorStyle.darkPurple,
              style: const TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Bolyar',
                  color: Colors.black),
              decoration: InputDecoration(
                counterText: '',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFFD7D7D7), width: 1)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: widget.controllers[i].text.isNotEmpty
                        ? ColorStyle.darkPurple
                        : Colors.grey, // Color por defecto
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: ColorStyle.darkPurple,
                      width: 2 // Color por defecto
                      ),
                  borderRadius: BorderRadius.circular(10),
                ),
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 24),
              ),
              onChanged: (value) {
                if (value.length == 1) {
                  if (i < 3) {
                    FocusScope.of(context)
                        .requestFocus(widget.focusNodes[i + 1]);
                  } else {
                    widget.focusNodes[i].unfocus();
                  }
                } else if (value.isEmpty && i > 0) {
                  FocusScope.of(context).requestFocus(widget.focusNodes[i - 1]);
                }
                widget.onCodeChanged!.call(widget.controllers
                    .map((controller) => controller.text)
                    .join());
              },
              inputFormatters: [
                PasteAwareFormatter(onPaste: _handlePaste),
              ],
              onTap: () {
                //Cuando se toque un input se llama la función para acomodar el cursor
                _handleTextFieldTap(i);
              },
            ),
          ),
      ],
    );
  }
}

class PasteAwareFormatter extends TextInputFormatter {
  // Se define una función de devolución de llamada que se ejecutará cuando se pegue texto en un campo de entrada.
  final Function(String) onPaste;

  PasteAwareFormatter({required this.onPaste});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Si el nuevo valor es diferente al antiguo y su longitud es mayor que 1,
    // significa que el usuario ha pegado algo en lugar de escribir un solo carácter.
    if (newValue.text != oldValue.text && newValue.text.length > 1) {
      // Llama a la función de devolución de llamada con el valor pegado.
      onPaste(newValue.text);

      // Configura el valor del campo actual con el primer carácter del texto pegado
      // y mueve el cursor al final de ese carácter.
      return TextEditingValue(
          text: newValue.text.substring(0, 1),
          selection: const TextSelection.collapsed(offset: 1));
    }

    // Si el usuario no pegó nada, simplemente devuelve el nuevo valor sin cambios.
    return newValue;
  }
}
