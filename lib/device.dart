import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iot_app/app_icons_icons.dart';

class Device {
  final String brand;
  final String model;
  final String name;

  Device({required this.brand, required this.model, required this.name});
}

class DeviceWidget extends StatefulWidget {
  var _deviceName;
  IconData _deviceIcon;
  @override
  _DeviceWidgetState createState() => _DeviceWidgetState();
  DeviceWidget(this._deviceName, this._deviceIcon);
}

class _DeviceWidgetState extends State<DeviceWidget> {
  var _powerText = 'Off';
  Color _iconColor = Colors.grey;
  void toggleColor() {
    setState(() {
      if (_iconColor == Colors.grey) {
        _iconColor = Colors.blue;
        _powerText = 'ON';
      } else {
        _iconColor = Colors.grey;
        _powerText = 'OFF';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      elevation: 3.0,
      shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.2),
          borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 15),
              child: Row(
                children: [
                  Icon(
                    widget._deviceIcon,
                    color: _iconColor,
                    size: 50,
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(AppIcons.powerbutton),
                        iconSize: 35,
                        color: _iconColor,
                        onPressed: () => toggleColor(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(widget._deviceName),
            ),
            Row(children: [
              Padding(
                padding: EdgeInsets.only(right: 5),
                child: Icon(
                  Icons.circle,
                  size: 10,
                  color: _iconColor,
                ),
              ),
              Container(
                child: Text(_powerText),
              )
            ]),
          ],
        ),
      ),
    );
  }
}
