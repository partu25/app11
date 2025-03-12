
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RestApi extends StatefulWidget {
  const RestApi({super.key});

  @override
  State<RestApi> createState() => _RestApiState();
}

class _RestApiState extends State<RestApi> {
  List<Map<String, dynamic>> datalist = [];
  var nameController = TextEditingController();
  var ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final response = await http.get(Uri.parse('https://67d16b23825945773eb43f3d.mockapi.io/p1/users1'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      setState(() {
        datalist = jsonData.cast<Map<String, dynamic>>();
      });
    }
    print(datalist);
  }

  Future<void> update(String id, Map<String, dynamic> map) async {
    try {
      final response = await http.put(
        Uri.parse('https://67d16b23825945773eb43f3d.mockapi.io/p1/users1/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        print('Update successful');
        getData();
      } else {
        print('Failed to update: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error updating data: $error');
    }
  }

  Future<void> postData(Map<String, dynamic> map) async {
    final response = await http.post(
      Uri.parse('https://67d16b23825945773eb43f3d.mockapi.io/p1/users1'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(map),
    );
    if (response.statusCode == 201) {
      print('Post successful');
      getData();
    } else {
      print('Failed to post');
    }
  }

  Future<void> deleteData(String id) async {
    final response = await http.delete(Uri.parse('https://67d16b23825945773eb43f3d.mockapi.io/p1/users1/$id'));
    if (response.statusCode == 200) {
      print("delete successfully");
    } else {
      print("error :: :");
    }
    getData();
  }

  void showBottom(BuildContext context, {Map<String, dynamic>? existingData}) {
    if (existingData != null) {
      nameController.text = existingData['name'];
      ageController.text = existingData['age'].toString();
    } else {
      nameController.clear();
      ageController.clear();
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: ageController,
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: () {
                  Map<String, dynamic> map = {
                    'name': nameController.text,
                    'age': int.tryParse(ageController.text) ?? 0,
                  };
                  if (existingData != null) {
                    update(existingData['id'].toString(), map);
                  } else {
                    postData(map);
                  }
                  Navigator.pop(context);
                },
                child: Text(existingData != null ? "Update" : "Add"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ElevatedButton(
        onPressed: () {
          showBottom(context);
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text('REST API CRUD'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: datalist.length,
                itemBuilder: (context, index) {
                  var item = datalist[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(item['id']),
                    ),
                    title: Text(item['name']),
                    subtitle: Text('Age: ${item['age']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            showBottom(context, existingData: item);
                          },
                          icon: Icon(Icons.edit),
                        ),
                        SizedBox(width: 10),
                        IconButton(
                          onPressed: () {
                            deleteData(item['id'].toString());
                          },
                          icon: Icon(Icons.delete),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
