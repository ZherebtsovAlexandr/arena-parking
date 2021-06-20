import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class Zone {
  Zone({required this.name, required this.freeSpaces});

  final String name;
  final int freeSpaces;
}

class ZoneListItem extends StatelessWidget {
  ZoneListItem({
    required this.zone,
  }) : super(key: ObjectKey(zone));

  final Zone zone;

  Color _getColor(BuildContext context) {
    return Theme.of(context).primaryColor;
  }

  TextStyle? _getTextStyle(BuildContext context) {
    return TextStyle(color: Colors.black54);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black45),
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(4))),
                child: Text("P${zone.name}",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Roboto',
                      letterSpacing: 0.5,
                      fontSize: 22,
                    )),
              ),
              Container(
                margin: EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.black87),
                width: MediaQuery.of(context).size.width * .50,
                child: FittedBox(
                    child: Text("${zone.freeSpaces}",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Roboto',
                          letterSpacing: 0.5,
                          fontSize: 22,
                        ))),
              )
            ],
          )
        ],
      ),
    );

    return Container(
      margin: EdgeInsets.all(8),
      width: 200,
      constraints: BoxConstraints(
          minWidth: 100, maxWidth: MediaQuery.of(context).size.width * .65),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.blue, borderRadius: BorderRadius.circular(5)),
    );
  }

// @override
// Widget build(BuildContext context) {
//   return ListTile(
//       title: Text("${zone.name} - ${zone.freeSpaces}",
//           style: _getTextStyle(context)),
//       leading: GestureDetector(
//         behavior: HitTestBehavior.translucent,
//         onTap: () {},
//         child: Container(
//           width: 48,
//           height: 48,
//           padding: const EdgeInsets.symmetric(vertical: 4.0),
//           alignment: Alignment.center,
//           child: const CircleAvatar(),
//         ),
//       ));
// }
}

class ZoneList extends StatefulWidget {
  @override
  _ZoneListState createState() => _ZoneListState();
}

class _ZoneListState extends State<ZoneList> {
  late Future<List<Zone>> futureZones;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Zone>>(
      future: futureZones,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Свободные места'),
            ),
            body: Center(
              child: SizedBox(
                  //width: MediaQuery.of(context).size.width * .50,
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    children: snapshot.data!.map((Zone zone) {
                      return ZoneListItem(zone: zone);
                    }).toList(),
                  )),
            ),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot}");
        }

        // By default, show a loading spinner.
        return CircularProgressIndicator();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    futureZones = fetchZones();
  }
}

Future<List<Zone>> fetchZones() async {

  Map<String, String> requestHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'Access-Control-Allow-Origin': '*'
  };

  final response = await http.get(
      Uri.parse('https://belparking.ru/sensors_app/horizon/scoreboards?id=arena8'),
      headers: requestHeaders);

  // List<Zone> zones = <Zone>[
  //   Zone(name: "1", freeSpaces: 100),
  //   Zone(name: '2', freeSpaces: 79),
  //   Zone(name: '3', freeSpaces: 21),
  //   Zone(name: '4', freeSpaces: 11),
  //   Zone(name: '5', freeSpaces: 3),
  //   Zone(name: '6', freeSpaces: 4),
  //   Zone(name: '7', freeSpaces: 9)
  // ];
  // return zones;

  if (response.statusCode == 200) {
    Map<String, dynamic> json = jsonDecode(response.body);
    List<Zone> zones = <Zone>[
      Zone(name: "1", freeSpaces: json["1"]),
      Zone(name: "2", freeSpaces: json["2"]),
      Zone(name: "3", freeSpaces: json["3"]),
      Zone(name: "4", freeSpaces: json["4"]),
      Zone(name: "5", freeSpaces: json["5"]),
      Zone(name: "6", freeSpaces: json["6"]),
      Zone(name: "7", freeSpaces: json["7"])
    ];
    return zones;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load zones');
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Free spaces',
    home: ZoneList(),
  ));
}
