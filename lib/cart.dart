import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Cart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CartState();
}

class CartState extends State<Cart> {
  List<String> items = [];
  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors,
      appBar: AppBar(
        title: Text("Cart"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('cartItems').snapshots(),
        builder: (context, snapshot) {
          // _fetchData(snapshot);
          return (snapshot.connectionState == ConnectionState.waiting)
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ListView(
                  children:
                      List.generate(snapshot.data.documents.length, (index) {
                    var text = snapshot.data.documents[index].data['item'];
                    int counter =
                        snapshot.data.documents[index].data['itemCount'];
                    if (snapshot.data.documents[index].data['inCart'] == true) {
                      return ListTile(
                        title: Text(
                          text,
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black
                          ),
                        ),
                        subtitle: Text("Quantity : x" + counter.toString(),
                        style: TextStyle(
                          color: Colors.black,
                        ),),
                        trailing: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.remove_circle),
                              onPressed: () {
                                var id =
                                    snapshot.data.documents[index].documentID;

                                if (counter <= 1) {
                                  removeItem(id);
                                  showSnackBar(context);
                                } else {
                                  decrementCounter(id, counter);
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle),
                              onPressed: () {
                                var id =
                                    snapshot.data.documents[index].documentID;
                                incrementCounter(id, counter);
                              },
                            ),
                            Container(
                              height: 30.0,
                              width: 60.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3.0),
                                color: Colors.red,
                              ),
                              child: FlatButton(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                ),
                                child: Center(
                                  child: Text(
                                    "Remove",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 10.0),
                                  ),
                                ),
                                onPressed: () {
                                  var id =
                                      snapshot.data.documents[index].documentID;
                                  removeItem(id);
                                  showSnackBar(context);
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    } else
                      return Container();
                  }),
                );
        },
      ),
    );
  }

  removeItem(String id) async {
    Firestore.instance
        .collection('cartItems')
        .document(id)
        .updateData({'inCart': false, 'itemCount': 0});
  }

  void showSnackBar(BuildContext context) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("Item removed!"),
      duration: Duration(seconds: 1),
    ));
  }

  decrementCounter(String id, int counter) async {
    counter--;
    Firestore.instance
        .collection('cartItems')
        .document(id)
        .updateData({'itemCount': counter});
  }

  incrementCounter(String id, int counter) async {
    counter++;
    Firestore.instance
        .collection('cartItems')
        .document(id)
        .updateData({'itemCount': counter});
  }
}
