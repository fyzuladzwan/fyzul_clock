// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

import 'container_hand.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

/// A basic analog clock.
///
/// You can do better than this!
class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  DateTime _dateTime = DateTime.now();
  var _now = DateTime.now();
  var _temperature = '';
  var _temperatureRange = '';
  var _condition = '';
  var _location = '';
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose(); //from digital_clock
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _temperatureRange = '(${widget.model.low} - ${widget.model.highString})';
      _condition = widget.model.weatherString;
      _location = widget.model.location;
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      _dateTime = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // There are many ways to apply themes to your clock. Some are:
    //  - Inherit the parent Theme (see ClockCustomizer in the
    //    flutter_clock_helper package).
    //  - Override the Theme.of(context).colorScheme.
    //  - Create your own [ThemeData], demonstrated in [AnalogClock].
    //  - Create a map of [Color]s to custom keys, demonstrated in
    //    [DigitalClock].
    final baseRef = MediaQuery.of(context).size.width;
    final colorFont = Colors.white;
    final time = DateFormat.Hms().format(DateTime.now());

    //from digital_clock
    final hour =
    DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final date = DateFormat('dd MMM yyyy').format(_dateTime);

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
        color: Color(0xFF3C4043),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              width: baseRef / 2.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _condition == 'cloudy'
                      ? Icon(
                    Icons.cloud,
                    color: Colors.grey,
                    size: baseRef / 10.28571429,
                  )
                      : _condition == 'foggy'
                      ? Icon(Icons.blur_on,
                      color: Colors.grey, size: baseRef / 10.28571429)
                      : _condition == 'rainy'
                      ? Icon(Icons.beach_access,
                      color: Colors.blue,
                      size: baseRef / 10.28571429)
                      : _condition == 'snowy'
                      ? Icon(Icons.ac_unit,
                      color: Colors.lightBlueAccent,
                      size: baseRef / 10.28571429)
                      : _condition == 'sunny'
                      ? Icon(Icons.wb_sunny,
                      color: Colors.yellowAccent,
                      size: baseRef / 10.28571429)
                      : _condition == 'thunderstorm'
                      ? Icon(Icons.flash_on,
                      color: Colors.yellowAccent,
                      size: baseRef / 10.28571429)
                      : Icon(Icons.gesture,
                      color: Colors.grey,
                      size: baseRef / 10.28571429),
                  Text(
                    _condition[0].toUpperCase() + _condition.substring(1),
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: colorFont,
                      fontSize: baseRef / 27.42857143,
                    ),
                  ),
                  Text(
                    _temperature,
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      color: colorFont,
                      fontSize: baseRef / 20.57142857,
                    ),
                  ),
                  Text(
                    _temperatureRange,
                    style: TextStyle(
                      fontFamily: 'Quantico',
                      color: colorFont,
                      fontSize: baseRef / 27.42857143,
                    ),
                  ),
                  Text(
                    _location,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: colorFont,
                      fontSize: baseRef / 27.42857143,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  height: baseRef / 2,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white10,
                              width: baseRef / 9.142857143),
                          color: Color(0xFF3C4043),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Color(0xFF3C4043),
                              width: baseRef / 13.71428571),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white10,
                              width: baseRef / 27.42857143),
                        ),
                      ),
                      Center(
                        child: Stack(
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  hour + ':' + minute,
                                  style: TextStyle(
                                    fontFamily: 'Orbitron',
                                    fontWeight: FontWeight.bold,
                                    fontSize: baseRef / 13.71428571,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  date,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: baseRef / 27.42857143,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ContainerHand(
                        color: Colors.transparent,
                        size: 0.5,
                        angleRadians: _now.second * radiansPerTick,
                        child: Transform.translate(
                          offset: Offset(0.0, -baseRef / 2.571428571),
                          child: Container(
                            width: baseRef / 27.42857143,
                            height: baseRef / 4.571428571,
                            decoration: BoxDecoration(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      ContainerHand(
                        color: Colors.transparent,
                        size: 0.5,
                        angleRadians: _now.minute * radiansPerTick,
                        child: Transform.translate(
                          offset: Offset(0.0, -baseRef / 2.837438424),
                          child: Container(
                            width: baseRef / 27.42857143,
                            height: baseRef / 6.857142857,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ),
                      ContainerHand(
                        color: Colors.transparent,
                        size: 0.5,
                        angleRadians: _now.hour * radiansPerHour +
                            (_now.minute / 60) * radiansPerHour,
                        child: Transform.translate(
                          offset: Offset(0.0, -baseRef / 3.164835165),
                          child: Container(
                            width: baseRef / 27.42857143,
                            height: baseRef / 13.71428571,
                            decoration: BoxDecoration(
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
