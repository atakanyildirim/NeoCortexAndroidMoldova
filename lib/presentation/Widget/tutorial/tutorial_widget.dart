import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:neocortexapp/config/theme/theme_config.dart';
import 'package:neocortexapp/presentation/pages/login_page.dart';
import 'package:video_player/video_player.dart';

// ignore: must_be_immutable
class TutorialSliderWidget extends StatefulWidget {
  final PageController sliderController;

  const TutorialSliderWidget({super.key, required this.sliderController});

  @override
  State<TutorialSliderWidget> createState() => _TutorialSliderWidgetState();
}

class _TutorialSliderWidgetState extends State<TutorialSliderWidget> {
  late VideoPlayerController video0;
  late VideoPlayerController video1;
  late VideoPlayerController video2;
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    setTutorialVideos();
  }

  @override
  Widget build(BuildContext context) {
    final tutorialPages = List.generate(
        3,
        (index) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 100,
                ),
                AspectRatio(
                    aspectRatio: video0.value.aspectRatio,
                    child: VideoPlayer(index == 0
                        ? video0
                        : index == 1
                            ? video1
                            : video2)),
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Text(
                    index == 0
                        ? AppLocalizations.of(context)!.onboardTitleOne
                        : index == 1
                            ? AppLocalizations.of(context)!.onboardTitleTwo
                            : AppLocalizations.of(context)!.onboardTitleThree,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 17,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Text(
                    index == 0
                        ? AppLocalizations.of(context)!.onboardTextOne
                        : index == 1
                            ? AppLocalizations.of(context)!.onboardTextTwo
                            : AppLocalizations.of(context)!.onboardTextThree,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: anaRenk,
                            shadowColor: Colors.greenAccent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
                            minimumSize: const Size(335, 40),
                          ),
                          child: Text(
                            currentPage != 3
                                ? AppLocalizations.of(context)!.ileri
                                : AppLocalizations.of(context)!.girisYap,
                            style: const TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          onPressed: () {
                            // Son slide aktif ise artık giriş yapacak
                            if (currentPage == 3) {
                              Navigator.of(context)
                                  .pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()));
                            } else {
                              widget.sliderController
                                  .nextPage(duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
                            }
                          }),
                    ),
                  ),
                ),
              ],
            ));

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: PageView.builder(
          physics: const NeverScrollableScrollPhysics(),
          controller: widget.sliderController,
          onPageChanged: (page) {
            if (currentPage == 1) {
              video0.pause();
              video1.play();
            } else if (currentPage == 2) {
              video1.pause();
              video2.play();
            }
            setState(() {
              currentPage++;
            });
          },
          itemBuilder: (_, index) {
            return tutorialPages[index % tutorialPages.length];
          },
        ),
      ),
    );
  }

  void setTutorialVideos() {
    video0 = VideoPlayerController.asset('assets/videos/onboard-0.mp4');
    video0.setLooping(false);
    video0.initialize().then((_) => setState(() {}));
    video0.play();

    video1 = VideoPlayerController.asset('assets/videos/onboard-1.mp4');
    video1.setLooping(false);
    video1.initialize().then((_) => setState(() {}));

    video2 = VideoPlayerController.asset('assets/videos/onboard-2.mp4');
    video2.setLooping(false);
    video2.initialize().then((_) => setState(() {}));
  }
}
