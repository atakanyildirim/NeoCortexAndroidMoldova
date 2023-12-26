import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neocortexapp/config/theme/theme_config.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

Widget defaultBox({Widget child = const Text(""), int index = 0, bool isAppBar = false}) {
  return Padding(
    padding: EdgeInsets.only(top: 0, bottom: 0, left: isAppBar ? 5 : 10, right: isAppBar ? 5 : 10),
    child: Container(
      margin: const EdgeInsets.only(top: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: index == 0 && isAppBar
            ? anaRenk
            : index == 1 && isAppBar
                ? anaAcikRenk
                : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Material(child: child),
    ),
  );
}

double clamp(double x, double min, double max) {
  if (x < min) x = min;
  if (x > max) x = max;

  return x;
}

Widget circularIndicator({
  String text = "",
  TextStyle style = const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
  Color color = Colors.red,
  double percent = 0,
  double radius = 0,
  double lineWidth = 0,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    child: CircularPercentIndicator(
      radius: radius,
      lineWidth: lineWidth,
      animation: true,
      percent: percent,
      center: Text(
        text,
        style: style,
      ),
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: color,
    ),
  );
}

Widget baslikGetir({String baslik = ""}) {
  return Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 0, left: 20, right: 20),
    child: ListTile(
      leading: Text(
        baslik,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(
        CupertinoIcons.right_chevron,
        color: Color(0xff000031),
      ),
    ),
  );
}
