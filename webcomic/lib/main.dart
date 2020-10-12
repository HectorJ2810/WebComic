import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

void main() {
  runApp(MyApp());
}

Future<WebComic> fetchWebComic(int num) async {
  http.Response response = await http.get('https://xkcd.com/info.0.json');
  if (num != 0) {
    response =
        await http.get('https://xkcd.com/' + num.toString() + '/info.0.json');
  }
  if (response.statusCode == 200) {
    return WebComic.fromJson(json.decode(response.body));
  } else {
    throw Exception('No hay archivos mas recientes, porfavor reinicie la app');
  }
}

class WebComic {
  final int num1;
  final String link;

  WebComic({this.num1, this.link});

  factory WebComic.fromJson(Map<String, dynamic> json) {
    return WebComic(
      num1: json['num'],
      link: json['img'],
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebComic',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'WebComic'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<WebComic> futureWebComic;

  @override
  void initState() {
    super.initState();
    futureWebComic = fetchWebComic(0);
  }

  void _searchNext(int num1) {
    setState(() {
      futureWebComic = fetchWebComic(num1 + 1);
    });
  }

  void _searchPrevious(int num1) {
    setState(() {
      futureWebComic = fetchWebComic(num1 - 1);
    });
  }

  void _searchRandom(int num1) {
    setState(() {
      /*crea un random y guardalo en numRandom y luego haces estan funcion */
      var rng = new Random();
      num1 = rng.nextInt(2370);
      futureWebComic = fetchWebComic(num1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: FutureBuilder<WebComic>(
        future: futureWebComic,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                Container(
                  height: 180.0,
                  width: MediaQuery.of(context).size.width,
                  child: Image.network(snapshot.data.link),
                ),
                Text(snapshot.data.num1.toString()),
                Container(
                  child: RaisedButton(
                    //boton
                    onPressed: () => {_searchPrevious(snapshot.data.num1)},
                    child: Text('Anterior'),
                    textColor: Colors.black,
                  ),
                ),
                Container(
                  child: RaisedButton(
                    //boton
                    onPressed: () => {_searchRandom(snapshot.data.num1)},
                    child: Text('Random'),
                    textColor: Colors.black,
                  ),
                ),
                Container(
                  child: RaisedButton(
                    //boton
                    onPressed: () => {_searchNext(snapshot.data.num1)},
                    child: Text('Siguiente'),
                    textColor: Colors.black,
                  ),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.start,
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return CircularProgressIndicator();
        },
      )),
    );
  }
}
