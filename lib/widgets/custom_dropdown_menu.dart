import 'package:flutter/material.dart';

import 'package:w_app/data/countries_data.dart';
import 'package:w_app/styles/color_style.dart';

class CustomDropdown extends StatefulWidget {
  final String? initialValue;
  final String title;
  final String hintText;
  final List<String> list;
  final ValueChanged<String> onSelected;
  final String? type;
  final EdgeInsetsGeometry? padding;
  final bool? showIcon;
  final TextStyle? style;

  const CustomDropdown(
      {super.key,
      required this.list,
      required this.onSelected,
      required this.title,
      required this.hintText,
      this.initialValue,
      this.type,
      this.padding,
      this.style,
      this.showIcon});

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String _selected = '';
  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue ?? '';
  }

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
          widget.title.isNotEmpty
              ? Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: widget.style ??
                      const TextStyle(
                          fontFamily: "Montserrat",
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                )
              : const SizedBox(),
          Container(
            width: double.maxFinite,
            height: 48,
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.only(left: 12, right: 12),
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
                style: const TextStyle(
                    fontFamily: "Montserrat", color: Colors.black),
                hint: Text(
                  widget.hintText,
                  style: const TextStyle(color: Colors.grey),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selected = newValue!;
                  });
                  widget.onSelected(_selected);
                },
                items:
                    widget.list.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                      value: value,
                      child: ListTile(
                          leading: widget.showIcon ?? false
                              ? Text(countries
                                  .firstWhere((c) =>
                                      c[widget.type ?? "name"] ==
                                      value)["emoji"]
                                  .toString())
                              : null,
                          minLeadingWidth: 0,
                          contentPadding: const EdgeInsets.only(),
                          dense: true,
                          title: Text(
                            value,
                            style: const TextStyle(
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
