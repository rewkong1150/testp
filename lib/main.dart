import 'package:flutter/material.dart';
import 'package:test/post_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('อัลบั้ม'),
          backgroundColor: const Color.fromARGB(255, 233, 136, 129),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : PostList(),
      ),
    );
  }
}
