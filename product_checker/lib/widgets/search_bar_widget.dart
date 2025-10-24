import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearch;
  final Function(String) onTextChanged;
  final String? errorText;
  
  const SearchBarWidget({
    super.key,
    required this.onSearch,
    required this.onTextChanged,
    this.errorText,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: widget.errorText != null 
              ? Border.all(color: Colors.red, width: 1)
              : null,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow,
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Enter product name, brand, or CPR number',
              hintStyle: Theme.of(context).textTheme.bodySmall,
              prefixIcon: Icon(
                Icons.search, 
                color: widget.errorText != null 
                  ? Colors.red
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onChanged: (value) {
              widget.onTextChanged(value);
            },
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                widget.onSearch(value.trim());
              }
            },
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.errorText!,
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}