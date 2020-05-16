import 'package:flutter/material.dart';
import 'package:memes/api/memes_api.dart';
import 'package:memes/models/meme.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:memes/components/swipeCard.dart';
import 'dart:math';
import 'package:memes/constants/enum.dart';
import 'package:mixpanel_analytics/mixpanel_analytics.dart';
import 'dart:async';


List<Alignment> cardsAlign = [
  Alignment(0.0, 1.0),
  Alignment(0.0, 0.8),
  Alignment(0.0, 0.0)
];
List<Size> cardsSize = List(3);

class SwipeList extends StatefulWidget {
  SwipeList(BuildContext context) {
    cardsSize[0] = Size(MediaQuery.of(context).size.width * 0.9,
        MediaQuery.of(context).size.height * 0.6);
    cardsSize[1] = Size(MediaQuery.of(context).size.width * 0.85,
        MediaQuery.of(context).size.height * 0.55);
    cardsSize[2] = Size(MediaQuery.of(context).size.width * 0.8,
        MediaQuery.of(context).size.height * 0.5);
  }

  @override
  _SwipeListState createState() => _SwipeListState();
}

class _SwipeListState extends State<SwipeList>
    with SingleTickerProviderStateMixin {
  int cardsCounter = 0;
  bool loading = true;
  List<Meme> memes = List();
  List<SwipeCard> cards = List();
  AnimationController _controller;
  MixpanelAnalytics _mixpanelAnalytics;
  final _user$ = StreamController<String>.broadcast();

  final Alignment defaultFrontCardAlign = Alignment(0.0, 0.0);
  Alignment frontCardAlign;
  double frontCardRot = 0.0;

  Future<void> share() async {
    await _mixpanelAnalytics.track(
        event: 'share_mem', properties: {'mem_id': memes[cardsCounter - 3].id});
    await FlutterShare.share(
        title: 'Top Kek memes',
        text: 'Top Kek memes',
        linkUrl: memes[cardsCounter - 3].fileUrl,
        chooserTitle: 'Memes app');
  }

  @override
  void initState() {
    super.initState();

    // Init cards
    getFirstMemes().then((res) {
      for (cardsCounter = 0; cardsCounter < 3; cardsCounter++) {
        cards.add(SwipeCard(res[cardsCounter]));
      }
      setState(() {
        memes = res;
        cards = cards;
        loading = false;
      });
    });

    _mixpanelAnalytics = MixpanelAnalytics(
      token: 'e28bf9b75c9895878a9eb63704b1fc92',
      userId$: _user$.stream,
      verbose: true,
      shouldAnonymize: true,
      shaFn: (value) => value,
      onError: (e) => print(e),
    );

    frontCardAlign = cardsAlign[2];

    // Init the animation controller
    _controller =
        AnimationController(duration: Duration(milliseconds: 700), vsync: this);
    _controller.addListener(() => setState(() {}));
    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) changeCardsOrder();
    });
  }

  @override
  void dispose() {
    _user$.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        memesList(),
        buttonsRow(),
      ],
    );
  }

  Widget memesList() {
    return Expanded(
        child: Stack(
            children: cards.length > 2
                ? <Widget>[
                    backCard(),
                    middleCard(),
                    frontCard(),
                    controller(),
                    loading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                SizedBox(height: 50),
                                CircularProgressIndicator()
                              ])
                        : Container(),
                  ]
                : <Widget>[loader()]));
  }

  Widget controller() {
    return // Prevent swiping if the cards are animating
        _controller.status != AnimationStatus.forward && !loading
            ? SizedBox.expand(
                child: GestureDetector(
                // While dragging the first card
                onPanUpdate: (DragUpdateDetails details) {
                  // Add what the user swiped in the last frame to the alignment of the card
                  setState(() {
                    // 20 is the "speed" at which moves the card
                    frontCardAlign = Alignment(
                        frontCardAlign.x +
                            20 *
                                details.delta.dx /
                                MediaQuery.of(context).size.width,
                        frontCardAlign.y +
                            40 *
                                details.delta.dy /
                                MediaQuery.of(context).size.height);

                    frontCardRot = frontCardAlign.x; // * rotation speed;
                  });
                },
                // When releasing the first card
                onPanEnd: (_) async {
                  // If the front card was swiped far enough to count as swiped
                  if (frontCardAlign.x > 3.0 || frontCardAlign.x < -3.0) {
                    scoreMem(frontCardAlign.x > 0
                        ? Reaction.like
                        : Reaction.dislike);

                    animateCards();
                    await _mixpanelAnalytics.track(
                        event:
                            frontCardAlign.x > 0 ? 'like_mem' : 'dislike_mem',
                        properties: {
                          'mem_id': memes[cardsCounter - 3].id,
                          'feed': 'swipe',
                          'method': 'swipe',
                        });
                  } else {
                    // Return to the initial rotation and alignment
                    setState(() {
                      frontCardAlign = defaultFrontCardAlign;
                      frontCardRot = 0.0;
                    });
                  }
                },
              ))
            : Container();
  }

  Widget buttonsRow() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 48.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          FloatingActionButton(
            heroTag: "report",
            mini: true,
            onPressed: loading
                ? null
                : () async {
                    frontCardAlign = Alignment(-1.0, frontCardAlign.y);
                    scoreMem(Reaction.dislike);
                    animateCards();
                    await _mixpanelAnalytics
                        .track(event: 'report_mem', properties: {
                      'mem_id': memes[cardsCounter - 3].id,
                      'feed': 'swipe',
                    });
                  },
            backgroundColor: Colors.white,
            child: Icon(Icons.report, color: Colors.redAccent),
          ),
          Padding(padding: EdgeInsets.only(right: 8.0)),
          FloatingActionButton(
            heroTag: "dislike",
            onPressed: loading
                ? null
                : () async {
                    frontCardAlign = Alignment(-1.0, frontCardAlign.y);
                    scoreMem(Reaction.dislike);
                    animateCards();
                    await _mixpanelAnalytics
                        .track(event: 'dislike_mem', properties: {
                      'mem_id': memes[cardsCounter - 3].id,
                      'feed': 'swipe',
                      'method': 'button',
                    });
                  },
            backgroundColor: Colors.white,
            child: Icon(Icons.close, color: Colors.red),
          ),
          Padding(padding: EdgeInsets.only(right: 8.0)),
          FloatingActionButton(
            heroTag: "like",
            onPressed: loading
                ? null
                : () async {
                    frontCardAlign = Alignment(1.0, frontCardAlign.y);
                    scoreMem(Reaction.like);
                    animateCards();
                    await _mixpanelAnalytics
                        .track(event: 'like_mem', properties: {
                      'mem_id': memes[cardsCounter - 3].id,
                      'feed': 'swipe',
                      'method': 'button',
                    });
                  },
            backgroundColor: Colors.white,
            child: Icon(Icons.favorite, color: Colors.green),
          ),
          Padding(padding: EdgeInsets.only(right: 8.0)),
          FloatingActionButton(
            heroTag: "share",
            mini: true,
            onPressed: memes.length == 0 ? null : share,
            backgroundColor: Colors.white,
            child: Icon(Icons.share, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget backCard() {
    return Align(
      alignment: _controller.status == AnimationStatus.forward
          ? CardsAnimation.backCardAlignmentAnim(_controller).value
          : cardsAlign[0],
      child: SizedBox.fromSize(
          size: _controller.status == AnimationStatus.forward
              ? CardsAnimation.backCardSizeAnim(_controller).value
              : cardsSize[2],
          child: cards[2]),
    );
  }

  Widget middleCard() {
    return Align(
      alignment: _controller.status == AnimationStatus.forward
          ? CardsAnimation.middleCardAlignmentAnim(_controller).value
          : cardsAlign[1],
      child: SizedBox.fromSize(
          size: _controller.status == AnimationStatus.forward
              ? CardsAnimation.middleCardSizeAnim(_controller).value
              : cardsSize[1],
          child: cards[1]),
    );
  }

  Widget frontCard() {
    return Align(
        alignment: _controller.status == AnimationStatus.forward
            ? CardsAnimation.frontCardDisappearAlignmentAnim(
                    _controller, frontCardAlign)
                .value
            : frontCardAlign,
        child: Transform.rotate(
          angle: (pi / 180.0) * frontCardRot,
          child: SizedBox.fromSize(
              size: cardsSize[0],
              child: Stack(
                children: <Widget>[
                  cards[0],
                  Positioned(
                      left: frontCardAlign.x > 0 ? null : 30.0,
                      right: frontCardAlign.x > 0 ? 30.0 : null,
                      top: 20.0,
                      child: frontCardAlign.x == 0
                          ? Container()
                          : Material(
                              borderRadius: BorderRadius.circular(12.0),
                              color: frontCardAlign.x > 0
                                  ? Color.fromRGBO(0, 255, 0, 0.05)
                                  : Color.fromRGBO(255, 0, 0, 0.05),
                              child: frontCardAlign.x > 0
                                  ? Icon(
                                      Icons.favorite,
                                      color: Colors.green,
                                      size: 60.0,
                                    )
                                  : Icon(Icons.close,
                                      color: Colors.red, size: 60.0),
                            )),
                ],
              )),
        ));
  }

  Widget loader() {
    return Align(
      alignment: Alignment(0, 0),
      child: SizedBox.fromSize(child: CircularProgressIndicator()),
    );
  }

  void changeCardsOrder() {
    setState(() {
      // Swap cards (back card becomes the middle card; middle card becomes the front card, front card becomes a  bottom card)
      var temp = cards[0];
      cards[0] = cards[1];
      cards[1] = cards[2];
      cards[2] = temp;
      frontCardAlign = defaultFrontCardAlign;
      frontCardRot = 0.0;
    });
  }

  void animateCards() {
    _controller.stop();
    _controller.value = 0.0;
    _controller.forward();
  }

  void scoreMem(Reaction reaction) {
    int memeId = memes[cardsCounter - 3].id;
    setState(() {
      loading = true;
    });
    scoreAndGetMem(memeId, reaction, cardsCounter + 1).then((newMem) {
      setState(() {
        loading = false;
        cards[2] = SwipeCard(newMem[0]);
        cardsCounter++;
        memes = memes + newMem;
      });
    });
  }
}

class CardsAnimation {
  static Animation<Alignment> backCardAlignmentAnim(
      AnimationController parent) {
    return AlignmentTween(begin: cardsAlign[0], end: cardsAlign[1]).animate(
        CurvedAnimation(
            parent: parent, curve: Interval(0.4, 0.7, curve: Curves.easeIn)));
  }

  static Animation<Size> backCardSizeAnim(AnimationController parent) {
    return SizeTween(begin: cardsSize[2], end: cardsSize[1]).animate(
        CurvedAnimation(
            parent: parent, curve: Interval(0.4, 0.7, curve: Curves.easeIn)));
  }

  static Animation<Alignment> middleCardAlignmentAnim(
      AnimationController parent) {
    return AlignmentTween(begin: cardsAlign[1], end: cardsAlign[2]).animate(
        CurvedAnimation(
            parent: parent, curve: Interval(0.2, 0.5, curve: Curves.easeIn)));
  }

  static Animation<Size> middleCardSizeAnim(AnimationController parent) {
    return SizeTween(begin: cardsSize[1], end: cardsSize[0]).animate(
        CurvedAnimation(
            parent: parent, curve: Interval(0.2, 0.5, curve: Curves.easeIn)));
  }

  static Animation<Alignment> frontCardDisappearAlignmentAnim(
      AnimationController parent, Alignment beginAlign) {
    return AlignmentTween(
            begin: beginAlign,
            end: Alignment(
                beginAlign.x > 0 ? beginAlign.x + 30.0 : beginAlign.x - 30.0,
                0.0) // Has swiped to the left or right?
            )
        .animate(CurvedAnimation(
            parent: parent, curve: Interval(0.0, 0.5, curve: Curves.easeIn)));
  }
}
