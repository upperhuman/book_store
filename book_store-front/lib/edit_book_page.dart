import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:book_store_front/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'book_repository.dart';



class EditBookPage extends StatefulWidget {
  final void Function()? reloadBooksCallback;
  final Book? book;
  const EditBookPage(this.book ,this.reloadBooksCallback, {super.key});

  @override
  State<EditBookPage> createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {

  final _formKey = GlobalKey<FormState>();
  final controllerTitle = TextEditingController();
  final controllerDescription = TextEditingController();
  final controllerAuthor = TextEditingController();
  final controllerPrice =TextEditingController();
  Uint8List previewBytes = Uint8List(0);

  @override
  void initState() {
    if (widget.book != null){
      controllerTitle.text = widget.book!.title;
      controllerDescription.text = widget.book!.description;
      controllerAuthor.text = widget.book!.author;
      controllerPrice.text = widget.book!.price.toString();
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          previewBytes = base64Decode(widget.book!.preview);
        });
      });
    }
    super.initState();
  }

  void postBook(String title, String description, String author, String price) async {
    Map<String, String> headers= {
      HttpHeaders.authorizationHeader: credentials!,
    };
    Map<String, dynamic> map = {
      "title": title,
      "description": description,
      "author": author,
      "price": double.parse(price),
      "preview" : base64Encode(previewBytes)
    };

    var post = await http.post(Uri.parse('http://localhost:8081/book'),
        body: jsonEncode(map),
        headers: headers
    );

    var postImg = await http.post(Uri.parse('http://localhost:8081/book/img/post?title=$title'),
        body: previewBytes,
        headers: headers
    );

    if (widget.reloadBooksCallback != null) {
      widget.reloadBooksCallback!();
    }

    if (!mounted) return;

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    super.dispose();
    controllerTitle.dispose();
    controllerDescription.dispose();
    controllerAuthor.dispose();
    controllerPrice.dispose();
  }

  void uploadImg () async{
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.first.bytes != null) {
      setState(() {
        previewBytes = result.files.first.bytes!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("page.edit_book".tr()),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width -400,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 50,),
                  TextFormField(
                    controller: controllerTitle,
                    decoration: InputDecoration(
                        labelText: "page.edit_book.enter.name".tr()
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'page.edit_book.enter.text'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20,),
                  TextFormField(
                    minLines: 3,
                    maxLines: null,
                    controller: controllerDescription,
                    decoration: InputDecoration(
                      labelText: 'page.edit_book.enter.description'.tr(),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'page.edit_book.enter.text'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20,),
                  TextFormField(
                    controller: controllerAuthor,
                    decoration: InputDecoration(
                      labelText: 'page.edit_book.enter.author'.tr(),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'page.edit_book.enter.text'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10,),
                  TextFormField(
                    controller: controllerPrice,
                    decoration: InputDecoration(
                      labelText: 'page.edit_book.enter.price'.tr(),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty || double.tryParse(value) == null) {
                        return 'page.edit_book.enter.num'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    children: [
                      SizedBox(
                        width: 150,
                        height: 200,
                        child:
                          previewBytes.isEmpty
                              ? const Center(
                            child: Text(
                              "?",
                              style: TextStyle(fontSize: 30),
                            ),
                          )
                            : Image.memory(previewBytes),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextButton(
                              onPressed: uploadImg,
                              child: Row(
                                children: [
                                  const Icon(Icons.upload),
                                  const SizedBox(width: 10,),
                                  Text('page.edit_book.upload.preview'.tr())
                                ],
                              )
                          ),
                          const SizedBox(height: 20,),
                          TextButton(
                              onPressed: (){
                                setState(() {
                                  previewBytes = Uint8List(0);
                                });
                              },
                              child: Row(
                                children: [
                                  const Icon(Icons.close),
                                  const SizedBox(width: 10,),
                                  Text('page.edit_book.clear.preview'.tr())
                                ],
                              )
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30,),
                  Row(
                    children: [
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final title = controllerTitle.text;
                            final description = controllerDescription.text;
                            final author = controllerAuthor.text;
                            final price = controllerPrice.text;
                            postBook(title, description, author, price);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          child: Text(
                            'submit'.tr(),
                            style: const TextStyle(
                                fontSize: 20
                            ),
        
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
