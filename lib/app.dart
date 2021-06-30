import 'package:iot_app/device.dart';
import 'package:flutter/material.dart';
import 'package:iot_app/main.dart';
import 'package:iot_app/dialog.dart';

// void main() {
//   runApp(MaterialApp(home: MyApp()));
// }

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Device> _deviceList = [];
  List<DeviceWidget> _deviceWidgetList = [];

  Widget logoutButton() {
    return FlatButton(
        onPressed: () => Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) => Login())),
        child: Icon(
          Icons.logout,
          color: Colors.white,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final title = 'My Home';
    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [logoutButton()],
        ),
        body: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          children: _deviceWidgetList,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) {
                return AddDeviceDialogWidget(_deviceList, _deviceWidgetList);
              }),
          child: const Icon(Icons.add),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }
}
