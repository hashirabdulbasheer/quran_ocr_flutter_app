import 'package:flutter/material.dart';
import 'package:noble_quran/models/word.dart';
import 'package:string_similarity/string_similarity.dart';
import '../main.dart';
import '../network/network.dart';
import '../utils/utils.dart';

class QAResultsScreen extends StatelessWidget {
  final String imageFilePath;

  const QAResultsScreen({Key? key, required this.imageFilePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Result"),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Icon(Icons.refresh)),
        body: FutureBuilder<List<String>>(
          future: QRNetwork.getText(imageFilePath), // async work
          builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Center(child: CircularProgressIndicator());
              default:
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<String> ocrTextList = snapshot.data as List<String>;
                  if (ocrTextList.isNotEmpty) {
                    List<NQWord> searchResult = [];
                    for (String detected in ocrTextList) {
                      searchResult.addAll(qrWords
                          .where((element) =>
                              detected.similarityTo(QRUtils.normalise(element.ar)) > 0.5)
                          .toList());
                    }
                    searchResult = QRUtils.removeDuplicates(searchResult);
                    return ListView.builder(
                      itemCount: searchResult.length,
                      itemBuilder: (context, index) {
                        return Center(
                          child: SizedBox(
                            height: 200,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Card(
                                elevation: 8,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                            child: Text(searchResult[index].ar,
                                                style: const TextStyle(fontSize: 30),
                                                textAlign: TextAlign.center)),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                            child: Text(searchResult[index].tr,
                                                style: const TextStyle(fontSize: 25),
                                                textAlign: TextAlign.center)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: Text('Error: Some error occurred'));
                }
            }
          },
        ));
  }
}
