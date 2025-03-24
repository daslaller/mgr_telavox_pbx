import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mouse Region',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Mouse Region'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  String title;
  MyHomePage({required this.title});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String status = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Mouse Status : $status'),
            SizedBox(
              height: 30,
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              opaque: false,
              onEnter: (s) {
                setState(() {
                  status = 'Mouse Entered in region';
                });
              },
              onHover: (s) {
                setState(() {
                  status = 'Mouse hovering on region';
                });
              },
              onExit: (s) {
                setState(() {
                  status = 'Mouse exit from region';
                });
              },
              child: Container(
                height: 180.0,
                width: 80.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: Colors.blueAccent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}