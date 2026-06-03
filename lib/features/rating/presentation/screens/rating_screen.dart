import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_button.dart';
import '../bloc/rating_bloc.dart';
import '../widgets/star_rating_widget.dart';

class RatingScreen extends StatefulWidget {
  final String rideId;
  final String userId;
  final String driverId;
  final String driverName;
  final String driverPhoto;

  const RatingScreen({
    Key? key,
    required this.rideId,
    required this.userId,
    required this.driverId,
    required this.driverName,
    required this.driverPhoto,
  }) : super(key: key);

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Your Ride'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocListener<RatingBloc, RatingState>(
            listener: (context, state) {
              if (state is RatingSubmitted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rating submitted!')),
                );
                Navigator.pop(context, true);
              } else if (state is RatingFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: NetworkImage(widget.driverPhoto),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.driverName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'How was your ride?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Center(
                  child: StarRatingWidget(
                    onRatingChanged: (rating) => setState(() => _rating = rating),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Add a comment (optional)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _commentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Share your experience...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                BlocBuilder<RatingBloc, RatingState>(
                  builder: (context, state) {
                    final isLoading = state is RatingLoading;
                    return AppButton(
                      onPressed: _rating > 0 && !isLoading
                          ? () => _submitRating()
                          : null,
                      text: isLoading ? 'Submitting...' : 'Submit Rating', label: '',
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitRating() {
    context.read<RatingBloc>().add(
          SubmitRatingEvent(
            rideId: widget.rideId,
            ratedBy: widget.userId,
            ratedTo: widget.driverId,
            score: _rating,
            comment: _commentController.text.isEmpty ? null : _commentController.text,
          ),
        );
  }
}
