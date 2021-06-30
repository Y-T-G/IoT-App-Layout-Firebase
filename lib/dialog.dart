import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iot_app/device.dart';
import 'package:iot_app/app_icons_icons.dart';
import 'dart:convert';

Future<Map<String, List<String>>> fetchDevice() async {
  final response = await http.get(Uri.parse(
      "https://data.energystar.gov/resource/rg68-9xmm.json?\$query=select%20distinct%20brand_name,%20model_number%20order%20by%20brand_name"));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    var _decoded = json.decode(response.body);
    var _brandName;
    var _modelList = [];
    Map<String, List<String>> _acDict = {};

    for (var i = 0; i < _decoded.length;) {
      _brandName = _decoded[i]['brand_name'].toString();
      while (i < _decoded.length && _decoded[i]['brand_name'] == _brandName) {
        _modelList.add(_decoded[i]['model_number'].toString());
        i++;
      }
      _modelList = _modelList.toSet().toList();
      _acDict[_brandName] = [..._modelList];
      _modelList.clear();
    }

    return _acDict;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load device list');
  }
}

class AddDeviceDialogWidget extends StatefulWidget {
  List _devicesList;
  List _deviceWidgetList;
  @override
  _AddDeviceDialogWidgetState createState() => _AddDeviceDialogWidgetState();
  AddDeviceDialogWidget(this._devicesList, this._deviceWidgetList);
}

class _AddDeviceDialogWidgetState extends State<AddDeviceDialogWidget> {
  late Future<Map<String, List<String>>> futureDevice;

  TextEditingController nameFieldController = TextEditingController();

  String _selectedBrand = '';
  String _selectedModel = '';
  List<String> _modelList = [];
  bool first = true;

  @override
  void initState() {
    super.initState();
    futureDevice = fetchDevice();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      child: FutureBuilder<Map<String, List<String>>>(
        future: futureDevice,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (first) {
              _selectedBrand = snapshot.data!.keys.first;
              _selectedModel = snapshot.data!.values.first[0];
              _modelList = snapshot.data!.values.first;
              first = false;
            }
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
              backgroundColor: Colors.white,
              actions: [
                FlatButton(
                  onPressed: () {
                    Device newDevice = Device(
                        brand: _selectedBrand,
                        model: _selectedModel,
                        name: nameFieldController.text);
                    Navigator.of(context).pop();
                    setState(() {
                      widget._devicesList.add(newDevice);
                      widget._deviceWidgetList
                          .add(DeviceWidget(newDevice.name, AppIcons.aircon));
                    });
                  },
                  child: Text('Add'),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
              ],
              content: Container(
                height: 210,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          'Brand',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    DropdownButton<String>(
                      icon: const Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      style: const TextStyle(color: Colors.black),
                      underline: Container(
                        height: 2,
                        color: Colors.blueAccent,
                      ),
                      value: _selectedBrand,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedBrand = newValue as String;
                          _modelList =
                              snapshot.data![_selectedBrand] as List<String>;
                          _selectedModel = _modelList.first;
                        });
                      },
                      items: snapshot.data!.keys
                          .map<DropdownMenuItem<String>>((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: new SizedBox(
                            width: 200.0,
                            child: Text(value),
                          ),
                        );
                      }).toList(),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          'Model',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    DropdownButton<String>(
                      icon: const Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      style: const TextStyle(color: Colors.black),
                      underline: Container(
                        height: 2,
                        color: Colors.blueAccent,
                      ),
                      value: _selectedModel,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedModel = newValue as String;
                        });
                      },
                      items: _modelList.map<DropdownMenuItem<String>>((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: new SizedBox(
                            width: 200.0,
                            child: Text(value),
                          ),
                        );
                      }).toList(),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          'Name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Container(
                      width: 220,
                      child: TextFormField(
                        controller: nameFieldController,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(top: 10, bottom: 8),
                            isDense: true),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
