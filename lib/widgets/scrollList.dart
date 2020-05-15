import 'package:flutter/material.dart';
import 'package:memes/components/scrollList/controls/onscreen_controls.dart';
import 'package:memes/components/scrollList/scroll_card.dart';
import 'package:memes/constants/enum.dart';
import 'package:memes/models/meme.dart';
import 'package:memes/api/memes_api.dart';

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

  @override
  void initState() {
    super.initState();

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

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        onPageChanged: (page) {
          var newMem = page + 3;
          var reaction = Reaction.like;
          if (memes.length < newMem) {
            setState(() {
              loading = true;
            });
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
        },
        scrollDirection: Axis.vertical,
        itemBuilder: (context, position) {
          return Container(
            child: Stack(
              children: <Widget>[
                memes.length < 2
                    ? SizedBox.fromSize(child: CircularProgressIndicator())
                    : cards[position],
                onScreenControls()
              ],
            ),
          );
        },
        itemCount: cards.length);
  }
}
