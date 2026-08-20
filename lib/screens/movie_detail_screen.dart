import 'package:bookmyshowclone/models/constants.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../api_services/tmdb_api.dart';
import '../components/common/movie_poster_image.dart';
import '../models/movie_detail_model.dart';
import 'select_location_screen.dart';
import '../services/api_client.dart';

class MovieDetailScreen extends StatelessWidget {
  final int movieId;
  final String movieTitle;
  const MovieDetailScreen(
      {super.key, required this.movieId, required this.movieTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF0F0E0E),
        appBar: AppBar(
          title: Text(
            "Movie Details",
            style: TextStyle(
                fontFamily: secondaryFonts,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          centerTitle: false,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        bottomNavigationBar: FutureBuilder<MovieDetail>(
          future: ApiService().fetchMovieDetails(movieId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 50,
                child: Center(
                    child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 15, 14, 14),
                )),
              );
            } else if (snapshot.hasError || !snapshot.hasData) {
              return const SizedBox(height: 50);
            }

            final movie = snapshot.data!;
            return Container(
              color: Colors.transparent,
              padding: const EdgeInsets.only(
                  right: 20, left: 20, bottom: 40, top: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 65, 2, 2),
                  elevation: 5,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  final castList =
                      movie.cast.map((actor) => actor.name).toList();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SelectLocationScreen(
                        movieId: movieId,
                        movieTitle: movie.title,
                        castList: castList,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Proceed",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            );
          },
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 0, 0, 0),
                Color.fromARGB(255, 49, 1, 1),
              ],
            ),
          ),
          child: FutureBuilder<MovieDetail>(
            future: ApiService().fetchMovieDetails(movieId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: LoadingAnimationWidget.waveDots(
                    color: const Color.fromARGB(158, 93, 18, 18),
                    size: 50,
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData) {
                return const Center(child: Text("No data found"));
              }

              final movie = snapshot.data!;

              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: MoviePosterImage(
                        url: movie.backdropPath,
                        height: 200,
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 20, bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              movie.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.72),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.yellow, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  movie.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(color: Colors.white24, thickness: 1),
                    ),
                    _ExpandableInfoBox(
                      title: "About",
                      content: movie.overview,
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(12.0, 6, 12.0, 14),
                      child: Text(
                        "Cast",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: movie.cast.length,
                        itemBuilder: (_, index) {
                          final actor = movie.cast[index];
                          return Container(
                            width: 100,
                            margin: const EdgeInsets.only(left: 10),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: MoviePosterImage(
                                    url: actor.profilePath,
                                    height: 80,
                                    width: 80,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  actor.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.white),
                                ),
                                Text(
                                  actor.character,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                      child: Text(
                        "Reviews",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (movie.reviews.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          "",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    else
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: movie.reviews.length,
                        itemBuilder: (_, index) {
                          final review = movie.reviews[index];
                          return _ExpandableCommentCard(
                            username: review.author,
                            comment: review.content,
                          );
                        },
                      ),
                    const SizedBox(height: 6),
                    FutureBuilder<dynamic>(
                      future: ApiClient.getJson('/movies/${movie.id}/reviews'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          );
                        }

                        if (snapshot.hasError || !snapshot.hasData) {
                          return const SizedBox.shrink();
                        }

                        final userReviews = (snapshot.data as List<dynamic>)
                            .map((item) =>
                                Map<String, dynamic>.from(item as Map))
                            .toList();

                        if (userReviews.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: userReviews.length,
                          itemBuilder: (context, index) {
                            final reviewData = userReviews[index];
                            final username =
                                (reviewData['username'] ?? 'Anonymous')
                                    .toString();
                            final comment =
                                (reviewData['comments'] ?? '').toString();

                            return _ExpandableCommentCard(
                              username: username,
                              comment: comment,
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
          ),
        ));
  }
}

class _ExpandableInfoBox extends StatefulWidget {
  final String title;
  final String content;

  const _ExpandableInfoBox({
    required this.title,
    required this.content,
  });

  @override
  State<_ExpandableInfoBox> createState() => _ExpandableInfoBoxState();
}

class _ExpandableInfoBoxState extends State<_ExpandableInfoBox> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final content = widget.content.isNotEmpty
        ? widget.content
        : 'No description available.';
    final canExpand = content.length > 150;

    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            maxLines: _expanded ? null : 3,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            textAlign: TextAlign.justify,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.45,
            ),
          ),
          if (canExpand)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(
                  _expanded ? 'Less' : 'More',
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ExpandableCommentCard extends StatefulWidget {
  final String username;
  final String comment;

  const _ExpandableCommentCard({
    required this.username,
    required this.comment,
  });

  @override
  State<_ExpandableCommentCard> createState() => _ExpandableCommentCardState();
}

class _ExpandableCommentCardState extends State<_ExpandableCommentCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment.isNotEmpty ? widget.comment : '(No comment)';
    final canExpand = comment.length > 150;

    return Card(
      color: const Color.fromARGB(255, 0, 0, 0),
      shadowColor: const Color.fromARGB(255, 255, 255, 255),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.username,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              comment,
              maxLines: _expanded ? null : 3,
              overflow:
                  _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                height: 1.35,
              ),
            ),
            if (canExpand)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  child: Text(
                    _expanded ? 'Less' : 'More',
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
