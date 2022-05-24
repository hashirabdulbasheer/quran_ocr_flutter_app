import 'package:flutter/material.dart';
import 'package:noble_quran/models/word.dart';
import 'package:quran_ocr_app/models/result_model.dart';
import 'package:string_similarity/string_similarity.dart';
import '../main.dart';
import '../models/qrword_model.dart';
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
        body: FutureBuilder<List<QRResultModel>>(
          future: QRNetwork.getText(imageFilePath), // async work
          builder: (BuildContext context, AsyncSnapshot<List<QRResultModel>> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Center(child: CircularProgressIndicator());
              default:
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<QRResultModel> ocrTextList = snapshot.data as List<QRResultModel>;
                  // sort results based on score
                  ocrTextList
                      .sort((QRResultModel a, QRResultModel b) => a.score.compareTo(b.score));
                  if (ocrTextList.isNotEmpty) {
                    List<QRWord> searchResult = [];
                    for (QRResultModel detected in ocrTextList) {
                      List<NQWord> similarWords = qrWords
                          .where((element) =>
                              detected.text.similarityTo(QRUtils.normalise(element.ar)) > 0.5)
                          .toList();
                      if (similarWords.isNotEmpty) {
                        searchResult.addAll(similarWords.map((e) {
                          // print(
                          //     "${e.ar} -> ${detected.text.similarityTo(QRUtils.normalise(e.ar))}");
                          return QRWord(
                              word: e,
                              similarityScore: detected.text.similarityTo(QRUtils.normalise(e.ar)));
                        }).toList());
                      }
                    }

                    if (searchResult.isNotEmpty) {
                      searchResult = QRUtils.removeDuplicates(searchResult);
                      searchResult.sort(
                          (QRWord a, QRWord b) => b.similarityScore.compareTo(a.similarityScore));

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
                                              child: Text(searchResult[index].word.ar,
                                                  style: const TextStyle(fontSize: 30),
                                                  textAlign: TextAlign.center)),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                              child: Text(searchResult[index].word.tr,
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
                  }
                  return const Center(child: Text('Unable to identify'));
                }
            }
          },
        ));
  }
}
