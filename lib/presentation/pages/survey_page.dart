import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:need_resume/need_resume.dart';
import 'package:neocortexapp/config/theme/theme_config.dart';
import 'package:neocortexapp/core/map/location.dart';
import 'package:neocortexapp/dataaccess/survey_repository.dart';
import 'package:neocortexapp/entities/customer.dart';
import 'package:neocortexapp/presentation/pages/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SurveyPage extends StatefulWidget {
  final Customer customerSurvey;
  const SurveyPage({super.key, required this.customerSurvey});

  @override
  _SurveyPageState createState() => _SurveyPageState();
}

class _SurveyPageState extends ResumableState<SurveyPage> {
  final List<Question> questionHistory = [];
  final Map<int, int> selectedAnswers = {};
  final Map<int, String> textAnswers = {};
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Position? position;
  bool isLoading = false;
  var resimler = [];
  var eklenenAltSorular = [];
  TextEditingController dateinput = TextEditingController();
  @override
  void initState() {
    dateinput.text = "";
    super.initState();
    loadSurvey();
    determinePosition().then((value) {
      setState(() {
        position = value;
      });
    });
  }

  void loadSurvey() async {
    _prefs.then((SharedPreferences prefs) {
      if (prefs.getString('resimler') != null) {
        resimler = jsonDecode(prefs.getString('resimler').toString());
      }
    });

    String jsonString = await SurveyRepository.getSurveys();
    setState(() {
      var l = json.decode(jsonString)["content"].length;
      for (var i = 0; i < l; i++) {
        questionHistory.add(parseQuestions(jsonString, i));
      }
    });
  }

  @override
  void onResume() {
    _prefs.then((SharedPreferences prefs) {
      if (prefs.getString('resimler') != null) {
        resimler = jsonDecode(prefs.getString('resimler').toString());
      }
    });
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    deleteAllPhoto();
  }

  deleteAllPhoto() async {
    for (var i = 0; i < resimler.length; i++) {
      await File(resimler[i]).delete();
    }
    resimler.clear();
    _prefs.then((SharedPreferences prefs) {
      prefs.remove('resimler');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (questionHistory.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: anaRenk,
          title: Text(AppLocalizations.of(context)!.anketYukleniyor),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: anaRenk,
          title: Text(AppLocalizations.of(context)!.anket),
        ),
        body: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(8),
          children: questionHistory
              .map((question) => buildQuestion(question))
              .toList(),
        ),
        bottomNavigationBar: SizedBox(
          width: double.infinity,
          height: 150,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: anaRenk,
                          borderRadius: BorderRadius.circular(5)),
                      width: 70,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                            color: anaRenk,
                            borderRadius: BorderRadius.circular(5)),
                        child: IconButton(
                          tooltip: "Resim Çek",
                          icon: const Icon(Icons.camera_alt),
                          iconSize: 20,
                          color: Colors.white,
                          onPressed: position != null
                              ? () {
                                  push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CameraApp(
                                              customerSurver:
                                                  widget.customerSurvey,
                                              position: position,
                                            )),
                                  );
                                }
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: resimler.length,
                        itemBuilder: (context, i) {
                          if (resimler[i] != null) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Stack(
                                children: [
                                  Image.file(
                                    fit: BoxFit.cover,
                                    File(
                                      resimler[i],
                                    ),
                                    scale: 5,
                                  ),
                                  Positioned(
                                    top: 18,
                                    left: 12,
                                    child: GestureDetector(
                                      onTap: () async {
                                        await File(resimler[i]).delete();
                                        resimler.removeAt(i);
                                        _prefs.then((SharedPreferences prefs) {
                                          prefs.remove('resimler');
                                        });
                                        setState(() {});
                                      },
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: anaRenk),
                    onPressed: isLoading ||
                            resimler.isEmpty ||
                            questionHistory
                                .last.answers.last.subQuestions.isNotEmpty ||
                            selectedAnswers.isEmpty ||
                            selectedAnswers.length + textAnswers.length !=
                                questionHistory.length
                        ? null
                        : () async {
                            setState(() {
                              isLoading = true;
                            });
                            List<dynamic> list = [];
                            var chk = false;
                            textAnswers.forEach((key, value) {
                              if (value.isEmpty) {
                                chk = true;
                              }

                              list.add({
                                "answer_index": 0,
                                "question_id": key,
                                "answer_text": value
                              });
                            });

                            if (chk) {
                              Fluttertoast.showToast(
                                  msg: "Text alanları boş bırakmayınız.",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                              setState(() {
                                isLoading = false;
                              });
                              return;
                            }

                            selectedAnswers.forEach((key, value) {
                              list.add({
                                "answer_index": value,
                                "question_id": key,
                                "answer_text": ""
                              });
                            });
                            //print(list);
                            //return;
                            await SurveyRepository.postSurvey(
                                    jsonEncode(list),
                                    widget.customerSurvey.customerSapCode
                                        .toString(),
                                    resimler,
                                    context)
                                .then((value) {
                              deleteAllPhoto();
                              setState(() {
                                isLoading = false;
                              });
                            });
                          },
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : Text(AppLocalizations.of(context)!.ziyaretiBitir),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      onWillPop: () async {
        bool cik = false;
        if ((selectedAnswers.length + textAnswers.length) > 0) {
          await showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(AppLocalizations.of(context)!.eminMisiniz),
                  titleTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 20),
                  actionsOverflowButtonSpacing: 20,
                  actions: [
                    ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(backgroundColor: anaRenk),
                        onPressed: () {
                          Navigator.pop(context);
                          cik = false;
                        },
                        child: Text(AppLocalizations.of(context)!.devamEt)),
                    ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(backgroundColor: anaRenk),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          cik = true;
                        },
                        child: Text(
                          AppLocalizations.of(context)!.cikisYap,
                          style: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.bold),
                        )),
                  ],
                  content: Text(AppLocalizations.of(context)!.cikmakEmin),
                );
              });
          return cik;
        } else {
          true;
        }
        return true;
      },
    );
  }

  Widget buildQuestion(Question question) {
    switch (question.questionType) {
      case 1:
        return buildMultipleChoiceQuestion(question);
      case 3:
        if (textAnswers[question.questionId] == null) {
          textAnswers[question.questionId] = "";
        }
        return buildTextQuestion(question);
      case 5:
        if (textAnswers[question.questionId] == null) {
          textAnswers[question.questionId] = "";
        }
        return buildDateQuestion(question);
      default:
        return Container(); // Handle other question types if necessary
    }
  }

  Widget buildMultipleChoiceQuestion(Question question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(question.questionText,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ),
        Row(
          children: [
            ...question.answers.map((answer) {
              int answerIndex = question.answers.indexOf(answer);
              bool isSelected =
                  selectedAnswers[question.questionId] == answerIndex;
              return Expanded(
                child: ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off),
                      Text(
                        answer.answerText,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                  onTap: isSelected
                      ? null
                      : () {
                          setState(() {
                            // Eski cevapları remove etmek için aşağıdaki satırları ekleyin
                            selectedAnswers.remove(question.questionId);
                            textAnswers.remove(question.questionId);
                            // Yeni cevapları ekleyin
                            selectedAnswers[question.questionId] = answerIndex;
                            if (answer.subQuestions.isNotEmpty) {
                              for (var i =
                                      questionHistory.indexOf(question) + 1;
                                  i < questionHistory.length;
                                  i++) {
                                selectedAnswers
                                    .remove(questionHistory[i].questionId);
                                textAnswers
                                    .remove(questionHistory[i].questionId);
                              }
                              /*
                              questionHistory.removeRange(
                                  questionHistory.indexOf(question) + 1,
                                  questionHistory.length);
                              */
                              if (!questionHistory.any((q) =>
                                  q.questionId ==
                                  answer.subQuestions.first.questionId)) {
                                questionHistory.insertAll(
                                    questionHistory.indexOf(question) + 1,
                                    answer.subQuestions);
                                eklenenAltSorular.add(question.questionId);
                              }
                            } else {
                              for (var i = 0;
                                  i < eklenenAltSorular.length;
                                  i++) {
                                var x = eklenenAltSorular[i];
                                if (x == question.questionId) {
                                  questionHistory.removeAt(
                                      questionHistory.indexOf(question) + 1);
                                  eklenenAltSorular.removeAt(i);
                                }
                              }
                              print('Anket Tamlandı!');
                            }
                          });
                        },
                ),
              );
            }).toList(),
          ],
        )
      ],
    );
  }

  Widget buildTextQuestion(Question question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
              textAlign: TextAlign.left,
              question.questionText,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        TextField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          onChanged: (String value) {
            if (value.isNotEmpty) {
              setState(() {
                textAnswers[question.questionId] = value;
              });
            } else {
              if (textAnswers.containsKey(question.questionId)) {
                setState(() {
                  textAnswers.remove(question.questionId);
                });
              }
            }
          },
        ),
      ],
    );
  }

  Widget buildDateQuestion(Question question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
              textAlign: TextAlign.left,
              question.questionText,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        TextField(
          controller: dateinput,
          readOnly: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101));

            if (pickedDate != null) {
              print(pickedDate);
              String formattedDate =
                  DateFormat('yyyy-MM-dd').format(pickedDate);
              setState(() {
                dateinput.text = formattedDate;
              });

              if (formattedDate.isNotEmpty) {
                setState(() {
                  textAnswers[question.questionId] = formattedDate;
                });
              } else {
                if (textAnswers.containsKey(question.questionId)) {
                  setState(() {
                    textAnswers.remove(question.questionId);
                  });
                }
              }
            } else {
              print("Date is not selected");
            }
          },
        ),
      ],
    );
  }

  Question parseQuestions(String jsonResponse, int i) {
    final jsonData = json.decode(jsonResponse)["content"][i];
    return Question.fromJson(jsonData);
  }
}

class Question {
  final String questionText;
  final int questionId;
  final int questionType;
  final List<Answer> answers;

  Question({
    required this.questionText,
    required this.questionId,
    required this.questionType,
    required this.answers,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionText: json['question'],
      questionId: json['question_id'],
      questionType: json['question_type'],
      answers: (json['children'] as List)
          .map((answerJson) => Answer.fromJson(answerJson))
          .toList(),
    );
  }
}

class Answer {
  final String answerText;
  final int answerIndex;
  final List<Question> subQuestions;

  Answer({
    required this.answerText,
    required this.answerIndex,
    required this.subQuestions,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      answerText: json['answer'],
      answerIndex: json['answer_index'],
      subQuestions: (json['children'] as List?)
              ?.map((questionJson) => Question.fromJson(questionJson))
              .toList() ??
          [],
    );
  }
}
