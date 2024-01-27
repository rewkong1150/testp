import 'dart:convert';
import 'package:http/http.dart' as http;

import 'post_model.dart';

class ApiService {
  static const String apiUrl = 'https://jsonplaceholder.typicode.com/albums';

  static Future<List<Post>> fetchData() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('ไม่พบ');
    }
  }
}
