import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Misc {
  Padding getSpacer() => Padding(
        padding: EdgeInsets.only(top: 30),
        child: Row(
          children: List.generate(
              150 ~/ 10,
              (index) => Expanded(
                    child: Column(
                      children: [
                        Container(
                          color: index % 2 == 0
                              ? Colors.transparent
                              : Colors.black,
                          height: 2,
                        ),
                        SizedBox(height: 2),
                        Container(
                          color: index % 2 == 0
                              ? Colors.transparent
                              : Colors.black,
                          height: 2,
                        ),
                      ],
                    ),
                  )),
        ),
      );

  TextStyle getStyle({double size = 26}) =>
      TextStyle(fontSize: size, fontWeight: FontWeight.bold, fontFamily: 'ITC');

  Text getTitle(String title, {double size = 40}) => Text(
        title,
        style: TextStyle(fontSize: size, fontFamily: 'Yeseva'),
      );

  Text getTaskTitle(String title, bool isConcluded) => Text(title,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontFamily: "ITC",
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          decoration: isConcluded == true
              ? TextDecoration.lineThrough
              : TextDecoration.none));

  Builder getCachedImage(String url) => Builder(builder: (context) {
        return CachedNetworkImage(
          imageUrl: url,
          errorListener: (value) => Icon(Icons.error_outline_rounded),
          placeholder: (context, url) => Center(
            child: SizedBox(
                height: 50, width: 50, child: CircularProgressIndicator()),
          ),
          fit: BoxFit.cover,
          height: 100.0,
          width: MediaQuery.of(context).size.width,
        );
      });

  Row getIconButtonList(List<(IconData i, Color, Function()?)> list) => new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: list
          .map((element) => new IconButton(
              icon: Icon(element.$1),
              style: ButtonStyle(iconSize: MaterialStatePropertyAll(32)),
              color: element.$2,
              onPressed: element.$3))
          .toList());
}
