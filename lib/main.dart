import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:page_transition/page_transition.dart';
import 'cart.dart';
import 'counter.dart';
import 'dummy_data.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  var stream = Firestore.instance.collection('cartItems').snapshots();
  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cart"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add_shopping_cart),
              onPressed: () {
                Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeftWithFade,
                      child: Cart(),
                      duration: Duration(milliseconds: 300),
                      curve: Curves.elasticInOut,
                    ));
              })
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('cartItems').snapshots(),
        builder: (context, snapshot) {
          // _fetchData(snapshot);
          print(snapshot.connectionState);
          return (snapshot.connectionState == ConnectionState.waiting)
              ? Center(
                  child: CircularProgressIndicator(
                    // strokeWidth: 20.0,
                    backgroundColor: Colors.redAccent,
                  ),
                )
              : ListView(
                  physics: BouncingScrollPhysics(),
                  children:
                      List.generate(snapshot.data.documents.length, (index) {
                    var text = snapshot.data.documents[index].data['item'];
                    return GestureDetector(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 15.0),
                            height: 120.0,
                            width: 120.0,
                            child: Image.network(
                              url[index],
                              scale: 1.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            width: 280.0,
                            // height: MediaQuery.of(context).size.height,
                            // width: MediaQuery.of(context).size.width,
                            child: Text(
                              text,
                              style: TextStyle(
                                fontSize: 20.0,
                                fontFamily: 'Google sans',
                              ),)),
                        ],
                      ),
                      onTap: () {
                        var id = snapshot.data.documents[index].documentID;
                        _showingBottomSheet(context, text, id, url[index]);
                      },
                    );
                  }),
                );
        },
      ),
    );
  }

  int counter = 1;
  String randomString =
      "This is a random string explaining the beauty of the product. All users would be tempted to buy the product after reading this sentence";

  void _showingBottomSheet(BuildContext context, String text, String id, String urlReceived) {
    Counter _counter = Counter();

    showModalBottomSheet(
        elevation: 10.0,
        // backgroundColor: Colors.blueAccent,
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.only(top: 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 15.0),
                      height: 150.0,
                      width: 150.0,
                      child: Image.network(
                        urlReceived,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      // padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            text,
                            style: TextStyle(fontSize: 30.0),
                          ),
                          Text(randomString),
                        ],
                      ),
                    ),
                  ],
                ),
                Quantity(_counter, id),
              ],
            ),
          );
        });
  }

  void increment() {
    setState(() {
      counter++;
    });
  }

  void decrement() {
    setState(() {
      counter--;
    });
  }
}

class Quantity extends StatefulWidget {
  Counter _counter;
  String id;
  Quantity(this._counter, this.id);
  @override
  State<StatefulWidget> createState() => QuantityState(_counter, id);
}

class QuantityState extends State<Quantity> {
  Counter _counter;
  String id;

  QuantityState(this._counter, this.id);

  final style = TextStyle(
    fontSize: 20.0,
    color: Colors.black,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {
                setState(() {
                  _counter.counter--;
                });
              },
            ),
            Container(
              height: 40.0,
              width: 60.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: Colors.amber,
              ),
              child: Center(
                child: Text(
                  _counter.counter.toString(),
                  style: TextStyle(
                    fontSize: 25.0,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _counter.counter++;
                });
              },
            ),
          ],
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
          child: FlatButton(
            padding: EdgeInsets.all(15.0),
            onPressed: () {
              addItem(id);
            },
            color: Colors.amberAccent,
            splashColor: Colors.amber,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Text(
              "Add to cart",
              style: style,
            ),
          ),
        ),
      ],
    );
  }

  addItem(String id) async {
    Firestore.instance
        .collection('cartItems')
        .document(id)
        .updateData({'inCart': true, 'itemCount': _counter.counter});

    Navigator.of(context).pop();
  }
}
