import 'package:flutter/material.dart';
// import 'package:memes/components/scrollList/controls/onscreen_controls.dart';
import 'package:memes/components/scrollList/scroll_card.dart';
import 'package:memes/constants/enum.dart';
import 'package:memes/models/meme.dart';
import 'package:memes/api/memes_api.dart';
// import 'package:mixpanel_analytics/mixpanel_analytics.dart';
// import 'dart:async';

class ScrollList extends StatefulWidget {
  @override
  _ScrollListState createState() => _ScrollListState();
}

class _ScrollListState extends State<ScrollList> {
  int cardsCounter = 0;
  int currentMemIndex = 0;
  bool loading = true;
  List<Meme> memes = List();
  List<ScrollCard> cards = List();
  // MixpanelAnalytics _mixpanelAnalytics;
  // final _user$ = StreamController<String>.broadcast();

  @override
  void initState() {
    super.initState();

    // _mixpanelAnalytics = MixpanelAnalytics(
    //   token: 'e28bf9b75c9895878a9eb63704b1fc92',
    //   userId$: _user$.stream,
    //   verbose: true,
    //   shouldAnonymize: true,
    //   shaFn: (value) => value,
    //   onError: (e) => print(e),
    // );

    // Init cards
    getFirstMemes().then((res) {
      for (cardsCounter = 0; cardsCounter < 3; cardsCounter++) {
        cards.add(ScrollCard(res[cardsCounter]));
      }
      setState(() {
        memes = res;
        cards = cards;
        loading = false;
      });
    });
  }

  // @override
  // void dispose() {
  //   _user$.close();
  //   super.dispose();
  // }

  _onPageChange(int page) async {
    var newMem = page + 3;
    var reaction = Reaction.like;
    if (memes.length < newMem) {
      setState(() {
        loading = true;
      });
      // await _mixpanelAnalytics.track(event: 'score_mem', properties: {
      //   'feed': 'scroll',
      //   'mem_id': memes[currentMemIndex].id,
      //   'reaction': reaction
      // });
      scoreAndGetMem(memes[currentMemIndex].id, reaction, newMem).then((res) {
        setState(() {
          loading = false;
          cards.add(ScrollCard(res[0]));
          cardsCounter++;
          memes = memes + res;
        });
      });
      setState(() {
        currentMemIndex = page;
      });
    }
    // await _mixpanelAnalytics.track(
    //     event: 'change_mem',
    //     properties: {'feed': 'scroll', 'mem_id': memes[currentMemIndex].id});
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        onPageChanged: _onPageChange,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, position) {
          return Container(
            child: Stack(
              children: <Widget>[
                memes.length < 2
                    ? SizedBox.fromSize(child: CircularProgressIndicator())
                    : cards[position],
                // onScreenControls(_mixpanelAnalytics, memes[currentMemIndex])
              ],
            ),
          );
        },
        itemCount: cards.length);
  }
}
