import 'package:flutter/material.dart';
import 'api_service.dart';
import 'post_model.dart';
import 'home_page.dart';
import 'dart:async';

class PostList extends StatefulWidget {
  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  late List<Post> posts;
  int batchSize = 10;
  int visibleItemCount = 10;
  int startIndex = 0;
  TextEditingController searchController = TextEditingController();

  StreamController<List<Post>> _searchResultController =
      StreamController<List<Post>>.broadcast();
  Stream<List<Post>> get searchResults => _searchResultController.stream;

  @override
  void initState() {
    super.initState();
    posts = [];
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      List<Post> fetchedPosts = await ApiService.fetchData();
      setState(() {
        posts.addAll(fetchedPosts);
        updateVisibleItems();
      });
    } catch (error) {
      print("Error fetching data: $error");
    }
  }

  void updateVisibleItems() {
    if (posts.isNotEmpty) {
      visibleItemCount = (batchSize < posts.length) ? batchSize : posts.length;
      startIndex = startIndex.clamp(0, posts.length - 1);
    } else {
      visibleItemCount = 0;
      startIndex = 0;
    }
  }

  void loadMore() {
    setState(() {
      if (startIndex + batchSize < posts.length) {
        visibleItemCount =
            (visibleItemCount + batchSize).clamp(0, posts.length);
        startIndex = (startIndex + batchSize).clamp(0, posts.length - 1);
      }
    });
  }

  void goBack() {
    setState(() {
      if (startIndex - batchSize >= 0) {
        visibleItemCount =
            (visibleItemCount - batchSize).clamp(0, posts.length);
        startIndex = (startIndex - batchSize).clamp(0, posts.length - 1);
      }
    });
  }

  void navigateToHomePage(int postId) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return HomePage(postId: postId);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  void searchPosts() {
    String searchTerm = searchController.text.toLowerCase();
    if (searchTerm.isNotEmpty) {
      List<Post> filteredPosts = posts
          .where((post) =>
              post.id.toString().toLowerCase().contains(searchTerm) ||
              post.title.toLowerCase().contains(searchTerm))
          .toList();
      _searchResultController.add(filteredPosts);
    } else {
      _searchResultController.add(posts);
    }
  }

  @override
  Widget build(BuildContext context) {
    updateVisibleItems();

    searchPosts();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              searchPosts();
            },
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              labelText: 'ค้นหาอัลบั้ม',
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: null,
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Post>>(
            stream: searchResults,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text('ไม่พบผลลัพธ์'),
                );
              }

              List<Post> visiblePosts = snapshot.data!;
              return ListView.builder(
                itemCount: visiblePosts.length,
                itemBuilder: (context, index) {
                  Post post = visiblePosts[index];
                  return GestureDetector(
                    onTap: () {
                      navigateToHomePage(post.id);
                    },
                    child: Hero(
                      tag: 'post_card_${post.id}',
                      child: Card(
                        elevation: 3,
                        margin: EdgeInsets.all(8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(Icons.folder),
                          ),
                          title: Text('อัลบั้ม: ${post.id}'),
                          subtitle: Text('Title: ' + post.title),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchResultController.close();
    super.dispose();
  }
}
