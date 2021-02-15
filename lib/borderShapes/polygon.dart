import 'dart:math';

import 'package:flutter/material.dart';
import 'package:morphable_shape/dynamic_path_morph.dart';

import '../morphable_shape_border.dart';

class PolygonShape extends FilledBorderShape {
  final int sides;
  final Length cornerRadius;
  final CornerStyle cornerStyle;
  final DynamicBorderSides borderSides;

  const PolygonShape(
      {this.sides = 5,
      this.cornerStyle = CornerStyle.rounded,
      this.cornerRadius = const Length(0),
      this.borderSides =
          const DynamicBorderSides(width: Length(10), colors: [Colors.black])})
      : assert(sides >= 3);

  PolygonShape.fromJson(Map<String, dynamic> map)
      : cornerStyle =
            parseCornerStyle(map["cornerStyle"]) ?? CornerStyle.rounded,
        cornerRadius = Length.fromJson(map["cornerRadius"]) ?? Length(0),
        sides = map["sides"] ?? 5,
        this.borderSides =
            const DynamicBorderSides(width: Length(10), colors: [Colors.black]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"type": "PolygonShape"};
    rst["sides"] = sides;
    rst["cornerRadius"] = cornerRadius.toJson();
    rst["cornerStyle"] = cornerStyle.toJson();
    return rst;
  }

  PolygonShape copyWith({
    CornerStyle? cornerStyle,
    Length? cornerRadius,
    int? sides,
  }) {
    return PolygonShape(
      cornerStyle: cornerStyle ?? this.cornerStyle,
      sides: sides ?? this.sides,
      cornerRadius: cornerRadius ?? this.cornerRadius,
    );
  }

  @override
  List<Color> borderFillColors() {
    int totalLength =
        generateOuterDynamicPath(Rect.fromLTRB(0, 0, 100, 100)).nodes.length;
    int eachSide = (totalLength / sides).round();
    return [
      Colors.red,
      Colors.red,
      Colors.red,
      Colors.red,
      Colors.red,
      Colors.red,
      Colors.red,
      Colors.red,
      Colors.red,
      Colors.red,
      Colors.red,
      Colors.red,
      Colors.red,
      Colors.red,
    ];
    //return rotateList(List.generate(totalLength, (index) => (index/eachSide).floor()), (eachSide/2).round()).cast<int>();
  }

  DynamicPath generateInnerDynamicPath(Rect rect) {
    double scale = min(rect.width, rect.height);
    double borderWidth = borderSides.width.toPX(constraintSize: scale);
    List<DynamicNode> nodes = [];

    double cornerRadius =
        this.cornerRadius.toPX(constraintSize: scale) - borderWidth;

    final height = scale;
    final width = scale;

    final double section = (2.0 * pi / sides);
    final double polygonSize = min(width, height);
    final double radius = polygonSize / 2 - borderWidth / sin(section / 2);
    final double centerX = width / 2;
    final double centerY = height / 2;

    radius.clamp(0.0, polygonSize / 2);
    cornerRadius = cornerRadius.clamp(0.0, radius * cos(section / 2));

    double arcCenterRadius = radius - cornerRadius / sin(pi / 2 - section / 2);

    double startAngle = -pi / 2;

    for (int i = 0; i < sides; i++) {
      double cornerAngle = startAngle + section * i;
      //if (cornerRadius == 0) {
      //  nodes.add(DynamicNode(
      //      position: Offset((centerX + radius * cos(cornerAngle)),
      //          (centerY + radius * sin(cornerAngle)))));
      //} else {
      double arcCenterX = (centerX + arcCenterRadius * cos(cornerAngle));
      double arcCenterY = (centerY + arcCenterRadius * sin(cornerAngle));
      Offset start = arcToCubicBezier(
              Rect.fromCircle(
                  center: Offset(arcCenterX, arcCenterY), radius: cornerRadius),
              cornerAngle - section / 2,
              section)
          .first;
      Offset end = arcToCubicBezier(
              Rect.fromCircle(
                  center: Offset(arcCenterX, arcCenterY), radius: cornerRadius),
              cornerAngle - section / 2,
              section)
          .last;
      nodes.add(DynamicNode(position: start));
      //}
      switch (cornerStyle) {
        case CornerStyle.rounded:
          nodes.arcTo(
              Rect.fromCircle(
                  center: Offset(arcCenterX, arcCenterY), radius: cornerRadius),
              cornerAngle - section / 2,
              section);
          break;
        case CornerStyle.concave:
          nodes.arcTo(
              Rect.fromCircle(
                  center: Offset(arcCenterX, arcCenterY), radius: cornerRadius),
              cornerAngle - section / 2,
              -(2 * pi - section));
          break;
        case CornerStyle.straight:
          nodes.add(DynamicNode(position: end));
          break;
        case CornerStyle.cutout:
          nodes.add(DynamicNode(position: Offset(arcCenterX, arcCenterY)));
          nodes.add(DynamicNode(position: end));
          break;
      }
    }
    //}

    return DynamicPath(size: Size(width, height), nodes: nodes)
      ..resize(rect.size);
  }

  DynamicPath generateOuterDynamicPath(Rect rect) {
    List<DynamicNode> nodes = [];

    double scale = min(rect.width, rect.height);
    double cornerRadius = this.cornerRadius.toPX(constraintSize: scale);

    final height = scale;
    final width = scale;

    final double section = (2.0 * pi / sides);
    final double polygonSize = min(width, height);
    final double radius = polygonSize / 2;
    final double centerX = width / 2;
    final double centerY = height / 2;

    cornerRadius = cornerRadius.clamp(0, radius * cos(section / 2));

    double arcCenterRadius = radius - cornerRadius / sin(pi / 2 - section / 2);

    double startAngle = -pi / 2;

    for (int i = 0; i < sides; i++) {
      double cornerAngle = startAngle + section * i;
      //if (cornerRadius == 0) {
      //   nodes.add(DynamicNode(
      //     position: Offset((centerX + radius * cos(cornerAngle)),
      //          (centerY + radius * sin(cornerAngle)))));
      // } else {
      double arcCenterX = (centerX + arcCenterRadius * cos(cornerAngle));
      double arcCenterY = (centerY + arcCenterRadius * sin(cornerAngle));
      Offset start = arcToCubicBezier(
              Rect.fromCircle(
                  center: Offset(arcCenterX, arcCenterY), radius: cornerRadius),
              cornerAngle - section / 2,
              section)
          .first;
      Offset end = arcToCubicBezier(
              Rect.fromCircle(
                  center: Offset(arcCenterX, arcCenterY), radius: cornerRadius),
              cornerAngle - section / 2,
              section)
          .last;
      nodes.add(DynamicNode(position: start));
      //}
      switch (cornerStyle) {
        case CornerStyle.rounded:
          nodes.arcTo(
              Rect.fromCircle(
                  center: Offset(arcCenterX, arcCenterY), radius: cornerRadius),
              cornerAngle - section / 2,
              section);
          break;
        case CornerStyle.concave:
          nodes.arcTo(
              Rect.fromCircle(
                  center: Offset(arcCenterX, arcCenterY), radius: cornerRadius),
              cornerAngle - section / 2,
              -(2 * pi - section));
          break;
        case CornerStyle.straight:
          nodes.add(DynamicNode(position: end));
          break;
        case CornerStyle.cutout:
          nodes.add(DynamicNode(position: Offset(arcCenterX, arcCenterY)));
          nodes.add(DynamicNode(position: end));
          break;
      }
      // }
    }

    return DynamicPath(size: Size(width, height), nodes: nodes)
      ..resize(rect.size);
  }
}
