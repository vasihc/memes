import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:memes/constants/enum.dart';
import 'package:memes/constants/api.dart';
import 'package:memes/models/meme.dart';
import 'package:memes/database/database_hepler.dart';

Future<List<Meme>> fetchMemes(page, perPage) async {
  var queryParameters = {
    'page': page.toString(),
    'per_page': perPage.toString(),
  };
  var uri = Uri.http(BASE_URL, MEMES, queryParameters);
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return (json.decode(response.body)['memes'] as List).map((i) {
      return Meme.fromJson(i);
    }).toList();
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load memes');
  }
}

Future<List<Meme>> getFirstMemes() async {
  var token = await getToken();
  print(token);
  if (token == null) {
    return fetchMemes(1, 3);
  }
  final response = await http.get(
    Uri.http(BASE_URL, FIRST_MEMES),
    headers: {"x_forvovka_memes": token},
  );

  print(response.headers);

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    print(json.decode(response.body));
    return (json.decode(response.body)['memes'] as List).map((i) {
      return Meme.fromJson(i);
    }).toList();
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load memes');
  }
}

Future<List<Meme>> scoreAndGetMem(
    int memId, Reaction reaction, int memCount) async {
  String token = await getToken();
  if (token == null) {
    return fetchMemes(memCount, 1);
  }
  var body = {
    'reaction': reaction == Reaction.like ? 'like' : 'dislike',
    'mem_id': memId.toString(),
  };
  final response = await http.post(
    Uri.http(
      BASE_URL,
      SET_REACTION,
    ),
    body: body,
    headers: {"x_forvovka_memes": token},
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,

    return (json.decode(response.body)['memes'] as List).map((i) {
      return Meme.fromJson(i);
    }).toList();
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to score meme');
  }
}
