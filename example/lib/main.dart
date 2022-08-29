import 'dart:math';

import 'package:drag_and_swipe/drag_and_swipe.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Drag And Swipe'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _incrementCounter() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        title: Text(widget.title),
      ),
      body: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemBuilder: (context, index) => Builder(builder: (context) {
                return MessageWidget(
                  textMessage: faker.lorem.sentence(),
                );
              })),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    Key? key,
    required this.textMessage,
  }) : super(key: key);
  final String textMessage;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final x = Random().nextBool();
    return DragAndSwipe(
      alignment: x ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: size.width * .60,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xffFFD8E4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            textMessage,
            style: const TextStyle(color: Color(0xff31111D)),
          ),
        ),
      ),
    );
  }
}
