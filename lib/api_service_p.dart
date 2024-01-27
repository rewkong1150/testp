import 'dart:convert';
import 'package:http/http.dart' as http;
import 'photo.dart';

class ApiService {
  Future<List<Photo>> fetchData() async {
    final response = await http
        .get(Uri.parse('https://jsonplaceholder.typicode.com/photos'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Photo.fromJson(json)).toList();
    } else {
      throw Exception('ไม่พบ');
    }
  }
}
