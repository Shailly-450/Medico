import 'package:flutter/material.dart';

class SortOptionsDialog extends StatelessWidget {
  final ValueChanged<bool> onSortByPrice;
  final ValueChanged<bool> onSortByRating;
  final ValueChanged<bool> onSortByDistance;

  const SortOptionsDialog({
    Key? key,
    required this.onSortByPrice,
    required this.onSortByRating,
    required this.onSortByDistance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Implement sorting options UI
    return SimpleDialog(
      title: const Text('Sort Providers'),
      children: [
        SimpleDialogOption(
          child: const Text('Price: Low to High'),
          onPressed: () {
            onSortByPrice(true);
            Navigator.of(context).pop();
          },
        ),
        SimpleDialogOption(
          child: const Text('Price: High to Low'),
          onPressed: () {
            onSortByPrice(false);
            Navigator.of(context).pop();
          },
        ),
        SimpleDialogOption(
          child: const Text('Rating: High to Low'),
          onPressed: () {
            onSortByRating(false);
            Navigator.of(context).pop();
          },
        ),
        SimpleDialogOption(
          child: const Text('Distance: Near to Far'),
          onPressed: () {
            onSortByDistance(true);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
} 