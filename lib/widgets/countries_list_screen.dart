import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:w_app/styles/color_style.dart';

class CountriesListScreen extends StatefulWidget {
  final bool? showIcon;
  final String title;
  final List<Map<String, dynamic>> listDrop;

  const CountriesListScreen(
      {super.key, required this.listDrop, this.showIcon, required this.title});
  @override
  _CountriesListScreenState createState() => _CountriesListScreenState();
}

class _CountriesListScreenState extends State<CountriesListScreen> {
  List<Map<String, dynamic>> filteredlistDrop = [];

  @override
  void initState() {
    super.initState();
    filteredlistDrop = widget.listDrop;
  }

  void filterSearchResults(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredlistDrop = widget.listDrop;
      });
      return;
    }

    List<Map<String, dynamic>> dummyListData = [];
    for (var item in widget.listDrop) {
      if (item["name"].toString().toLowerCase().contains(query.toLowerCase())) {
        dummyListData.add(item);
      }
    }

    setState(() {
      filteredlistDrop = dummyListData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 40,
            width: double.maxFinite,
            margin: EdgeInsets.only(left: 16, right: 16, bottom: 0, top: 8),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: TextField(
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar',
                hintStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ColorStyle.textGrey),
                contentPadding: const EdgeInsets.only(),
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: ColorStyle.lightGrey,
                prefixIcon: Icon(FeatherIcons.search,
                    size: 18, color: ColorStyle.textGrey),
                /*suffixIcon: controllerSearch.text.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      controllerSearch.clear();
                                    },
                                    icon: Icon(Icons.clear,
                                        size: 20, color: ColorStyle.textGrey),
                                  )
                                : null,*/
              ),
              onChanged: (value) {
                filterSearchResults(value);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredlistDrop.length,
              padding: EdgeInsets.only(bottom: 128),
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                  leading: widget.showIcon ?? false
                      ? Text(filteredlistDrop[index]["emoji"])
                      : null,
                  minLeadingWidth: 0,
                  minVerticalPadding: 0,
                  title: Text(
                    filteredlistDrop[index]["name"],
                    style: TextStyle(fontFamily: 'Montserrat'),
                  ),
                  onTap: () {
                    // Aquí puedes retornar el mapa del país seleccionado
                    print(filteredlistDrop[index]);

                    Navigator.of(context).pop(filteredlistDrop[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
