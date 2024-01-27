import 'package:flutter/material.dart';
import 'api_service_p.dart';
import 'photo.dart';
import 'photo_detail_screen.dart';

class HomePage extends StatefulWidget {
  final int postId;

  const HomePage({Key? key, required this.postId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService();
  List<Photo> photoList = [];

  @override
  void initState() {
    super.initState();
    fetchData(widget.postId);
  }

  Future<void> fetchData(int postId) async {
    try {
      List<Photo> data = await apiService.fetchData();

      List<Photo> filteredData =
          data.where((photo) => photo.albumId == postId).toList();
      setState(() {
        photoList = filteredData;
      });
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ไม่สามารถดึงข้อมูลได้'),
        ),
      );
    }
  }

  void showLargeImage(Photo photo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoDetailScreen(photo: photo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รูปภาพ'),
        backgroundColor: const Color.fromARGB(255, 233, 136, 129),
      ),
      body: photoList.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: photoList.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 5.0,
                  child: GestureDetector(
                    onTap: () {
                      showLargeImage(photoList[index]);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Image.network(
                            photoList[index].url,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Text(
                            'รูปจากอัลบั้มที่:' +
                                photoList[index].albumId.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            photoList[index].title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
