import 'package:flutter/material.dart';

class StarRatingWidget extends StatefulWidget {
  final Function(int) onRatingChanged;
  final int initialRating;

  const StarRatingWidget({
    Key? key,
    required this.onRatingChanged,
    this.initialRating = 0,
  }) : super(key: key);

  @override
  State<StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget> {
  late int _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() => _rating = index + 1);
            widget.onRatingChanged(_rating);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(
              index < _rating ? Icons.star : Icons.star_border,
              size: 48,
              color: const Color(0xFFE8A020),
            ),
          ),
        );
      }),
    );
  }
}
