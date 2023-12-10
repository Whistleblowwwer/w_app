import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:w_app/styles/color_style.dart';

class CustomDropdown extends StatefulWidget {
  final String title;
  final String hintText;
  final List<String> list;
  final ValueChanged<String> onSelected;
  final EdgeInsetsGeometry? padding;
  final bool? showIcon;
  final TextStyle? style;

  CustomDropdown(
      {required this.list,
      required this.onSelected,
      required this.title,
      required this.hintText,
      this.padding,
      this.style,
      this.showIcon});

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String _selected = '';

  @override
  void didUpdateWidget(CustomDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si la lista anterior no es igual a la lista nueva y la selección actual no está en la nueva lista, restablece la selección
    if (oldWidget.list != widget.list && !widget.list.contains(_selected)) {
      setState(() {
        _selected = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ??
          const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: widget.style ??
                const TextStyle(
                    fontFamily: "Montserrat",
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
          ),
          Container(
            width: double.maxFinite,
            height: 48,
            margin: EdgeInsets.only(top: 2),
            padding: EdgeInsets.only(left: 12, right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                color: ColorStyle.borderGrey,
                width: 1.0,
              ),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selected.isEmpty ? null : _selected,
                style: TextStyle(fontFamily: "Montserrat", color: Colors.black),
                hint: Text(
                  widget.hintText,
                  style: TextStyle(color: Colors.grey),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selected = newValue!;
                  });
                  widget.onSelected(_selected);
                },
                icon: Icon(
                  FeatherIcons.chevronDown,
                  size: 20,
                  color: ColorStyle.textGrey,
                ),
                items:
                    widget.list.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                      value: value,
                      child: ListTile(
                          leading: widget.showIcon ?? false
                              ? Icon(
                                  Icons.flag,
                                  size: 24,
                                )
                              : null,
                          minLeadingWidth: 0,
                          contentPadding: EdgeInsets.only(),
                          dense: true,
                          title: Text(
                            value,
                            style: TextStyle(
                                fontFamily: "Montserrat", color: Colors.black),
                          )));
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
