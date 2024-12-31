import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Online Book Store"),
      ),
      body: const BookList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text("Add Book"),
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text("Title:"),
                    ),
                    TextField(
                      controller: titleController,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text("Author:"),
                    ),
                    TextField(
                      controller: authorController,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text("Price:"),
                    ),
                    TextField(
                      controller: priceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
                ),
                actions: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Back",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty &&
                          authorController.text.isNotEmpty &&
                          priceController.text.isNotEmpty) {
                        Map<String, dynamic> newBook = {
                          "title": titleController.text,
                          "author": authorController.text,
                          "price": double.tryParse(priceController.text) ?? 0.0,
                        };

                        FirebaseFirestore.instance
                            .collection("books")
                            .add(newBook)
                            .whenComplete(() {
                          Navigator.of(context).pop();
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please fill all fields')),
                        );
                      }
                    },
                    child: const Text("Save",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              );
            },
          );
        },
        tooltip: 'Add Book',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class BookList extends StatelessWidget {
  const BookList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('books').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: 80),
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            // Format harga tanpa bagian desimal jika harga adalah bulat
            final price = document['price'];
            final priceFormatted = NumberFormat.currency(
                    locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                .format(price);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
              child: Card(
                child: ListTile(
                  onTap: () {},
                  title: Text(document['title']), // Judul buku
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(document['author']), // Nama penulis
                      Text(priceFormatted,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)), // Harga buku
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tombol Hapus
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection("books")
                              .doc(document.id)
                              .delete()
                              .catchError((e) {
                            print(e);
                          });
                        },
                      ),
                      // Tombol Edit
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          TextEditingController titleController =
                              TextEditingController(text: document['title']);
                          TextEditingController authorController =
                              TextEditingController(text: document['author']);
                          TextEditingController priceController =
                              TextEditingController(
                                  text: document['price'].toString());

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Update Book"),
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    const Text("Title:"),
                                    TextField(
                                      controller: titleController,
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(top: 20),
                                      child: Text("Author:"),
                                    ),
                                    TextField(
                                      controller: authorController,
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(top: 20),
                                      child: Text("Price:"),
                                    ),
                                    TextField(
                                      controller: priceController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                    ),
                                  ],
                                ),
                                actions: <Widget>[
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("Back",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (titleController.text.isNotEmpty &&
                                          authorController.text.isNotEmpty &&
                                          priceController.text.isNotEmpty) {
                                        Map<String, dynamic> updatedBook = {
                                          "title": titleController.text,
                                          "author": authorController.text,
                                          "price": double.tryParse(
                                                  priceController.text) ??
                                              0.0,
                                        };

                                        FirebaseFirestore.instance
                                            .collection("books")
                                            .doc(document.id)
                                            .update(updatedBook)
                                            .whenComplete(() {
                                          Navigator.of(context).pop();
                                        });
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Please fill all fields')));
                                      }
                                    },
                                    child: const Text("Update",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
