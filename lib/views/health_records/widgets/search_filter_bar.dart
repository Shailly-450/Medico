import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SearchFilterBar extends StatelessWidget {
  final String searchQuery;
  final bool showImportantOnly;
  final Function(String) onSearchChanged;
  final VoidCallback onImportantToggle;

  const SearchFilterBar({
    Key? key,
    required this.searchQuery,
    required this.showImportantOnly,
    required this.onSearchChanged,
    required this.onImportantToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search health records...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () => onSearchChanged(''),
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey[400],
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Filter Toggle
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onImportantToggle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: showImportantOnly ? AppColors.primary : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: showImportantOnly ? AppColors.primary : Colors.grey[300]!,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: showImportantOnly ? Colors.white : Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Important Only',
                          style: TextStyle(
                            color: showImportantOnly ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 