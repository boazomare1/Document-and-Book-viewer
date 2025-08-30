// TODO: Implement SearchPanel with Syncfusion PDF viewer
// This widget will be implemented when Syncfusion integration is complete
/*
import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_pdfviewer/syncfusion_flutter_pdfviewer.dart';

class SearchPanel extends StatefulWidget {
  final Function(String) onSearch;
  final VoidCallback onClose;
  final PdfTextSearchResult searchResult;
  final PdfViewerController controller;

  const SearchPanel({
    super.key,
    required this.onSearch,
    required this.onClose,
    required this.searchResult,
    required this.controller,
  });

  @override
  State<SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends State<SearchPanel> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  String _currentSearchText = '';
  int _currentMatchIndex = 0;
  int _totalMatches = 0;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    
    widget.searchResult.addListener(() {
      if (mounted) {
        setState(() {
          _totalMatches = widget.searchResult.totalInstanceCount;
          _currentMatchIndex = widget.searchResult.currentInstanceIndex;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch(String text) {
    setState(() {
      _currentSearchText = text;
      _currentMatchIndex = 0;
      _totalMatches = 0;
    });
    widget.onSearch(text);
  }

  void _nextMatch() {
    if (_totalMatches > 0) {
      widget.searchResult.nextInstance();
    }
  }

  void _previousMatch() {
    if (_totalMatches > 0) {
      widget.searchResult.previousInstance();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    widget.searchResult.clear();
    setState(() {
      _currentSearchText = '';
      _currentMatchIndex = 0;
      _totalMatches = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // Search input
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Search in document...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _currentSearchText.isNotEmpty
                              ? IconButton(
                                  onPressed: _clearSearch,
                                  icon: const Icon(Icons.clear),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: _performSearch,
                        onSubmitted: _performSearch,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Close button
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close),
                    color: Colors.white,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black26,
                    ),
                  ),
                ],
              ),
              
              if (_currentSearchText.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Previous match
                    IconButton(
                      onPressed: _totalMatches > 0 ? _previousMatch : null,
                      icon: const Icon(Icons.keyboard_arrow_up),
                      color: Colors.white,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black26,
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Match info
                    Expanded(
                      child: Text(
                        _totalMatches > 0
                            ? '${_currentMatchIndex + 1} of $_totalMatches'
                            : 'No matches found',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Next match
                    IconButton(
                      onPressed: _totalMatches > 0 ? _nextMatch : null,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      color: Colors.white,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black26,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
*/ 