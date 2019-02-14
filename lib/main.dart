import 'package:flutter/material.dart';

import 'paging.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('title'),
      ),
      body: _buildBody(context),
    );
  }

  Future<List<String>> _load(BuildContext context, int offset, int count) async {
    print('_load offset:$offset count:$count');
    return Future.delayed(Duration(seconds: 2), () {
      return List<String>.generate(offset > 30 ? 0 : count, (i) => 'item ${offset + i}');
    });
  }

  Widget _buildBody(BuildContext context) => Paging<String>(
    pageSize: 10,
    pageFuture: _load,
    pageBuilder: (context, status, data) => ListView.builder(
      itemCount: data.length + (status == LoadMoreStatus.Loading ? 1 : 0),
      itemBuilder: (context, position) {
        bool isProgress = position >= data.length;
        return _buildRow(context, isProgress, isProgress ? null : data[position]);
      },
    ),
  );

  Widget _buildRow(BuildContext context, bool isProgress, String data) => ListTile(
    title: isProgress ? Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        CircularProgressIndicator(),
        Text('loading...'),
      ],
    ) : Text(data),
  );
}
