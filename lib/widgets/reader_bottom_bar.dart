// TODO: Implement ReaderBottomBar with Syncfusion PDF viewer
// This widget will be implemented when Syncfusion integration is complete
/*
import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_pdfviewer/syncfusion_flutter_pdfviewer.dart';

class ReaderBottomBar extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final PdfViewerController controller;
  final Function(int) onPageChanged;

  const ReaderBottomBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.controller,
    required this.onPageChanged,
  });

  @override
  State<ReaderBottomBar> createState() => _ReaderBottomBarState();
}

class _ReaderBottomBarState extends State<ReaderBottomBar> {
  late TextEditingController _pageController;
  late FocusNode _pageFocusNode;

  @override
  void initState() {
    super.initState();
    _pageController = TextEditingController(text: widget.currentPage.toString());
    _pageFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pageFocusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ReaderBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPage != widget.currentPage) {
      _pageController.text = widget.currentPage.toString();
    }
  }

  void _goToPage() {
    final pageText = _pageController.text.trim();
    if (pageText.isNotEmpty) {
      final pageNumber = int.tryParse(pageText);
      if (pageNumber != null && pageNumber >= 1 && pageNumber <= widget.totalPages) {
        widget.controller.jumpToPage(pageNumber);
        widget.onPageChanged(pageNumber);
      }
    }
    _pageFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.4),
            Colors.black.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Previous page
              IconButton(
                onPressed: widget.currentPage > 1
                    ? () {
                        final newPage = widget.currentPage - 1;
                        widget.controller.previousPage();
                        widget.onPageChanged(newPage);
                      }
                    : null,
                icon: const Icon(Icons.chevron_left),
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black26,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Page input
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _pageController,
                          focusNode: _pageFocusNode,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                            hintText: 'Page',
                            hintStyle: TextStyle(color: Colors.white54),
                          ),
                          onSubmitted: (_) => _goToPage(),
                        ),
                      ),
                      if (widget.totalPages > 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Text(
                            'of ${widget.totalPages}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Next page
              IconButton(
                onPressed: widget.currentPage < widget.totalPages
                    ? () {
                        final newPage = widget.currentPage + 1;
                        widget.controller.nextPage();
                        widget.onPageChanged(newPage);
                      }
                    : null,
                icon: const Icon(Icons.chevron_right),
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black26,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/ 