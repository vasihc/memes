import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:memes/models/meme.dart';

const BASE_URL = 'forvovka.ru';
const MEMES_API = '/api/memes';
const SCORE_MEM = '/api/memes/score';

Future<List<Meme>> fetchMemes(page, perPage) async {
  var queryParameters = {
  'page': page.toString(),
  'per_page': perPage.toString(),
  };
  var uri = Uri.http(BASE_URL, MEMES_API, queryParameters);
  final response =
      await http.get(uri);

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

Future<Meme> scoreMem(int id, double score) async {
  var queryParameters = {
  'mem_id': id.toString(),
  'score': score.toString(),
  };
  var uri = Uri.http(BASE_URL, SCORE_MEM, queryParameters);
  final response =
      await http.get(uri);

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    
     return Meme.fromJson(json.decode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load memes');
  }
}