// TODO: Implement ReaderAppBar with Syncfusion PDF viewer
// This widget will be implemented when Syncfusion integration is complete
/*
import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_pdfviewer/syncfusion_flutter_pdfviewer.dart';
import 'package:modern_pdf_reader/models/pdf_document.dart';

class ReaderAppBar extends StatelessWidget {
  final PdfDocument document;
  final int currentPage;
  final int totalPages;
  final VoidCallback onBack;
  final VoidCallback onSearch;
  final VoidCallback onToggleBottomBar;
  final PdfViewerController controller;

  const ReaderAppBar({
    super.key,
    required this.document,
    required this.currentPage,
    required this.totalPages,
    required this.onBack,
    required this.onSearch,
    required this.onToggleBottomBar,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.black.withOpacity(0.4),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Back button
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black26,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Document info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      document.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (totalPages > 0)
                      Text(
                        'Page $currentPage of $totalPages',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Zoom out
                  IconButton(
                    onPressed: () => controller.zoomLevel = 
                        (controller.zoomLevel - 0.25).clamp(0.25, 3.0),
                    icon: const Icon(Icons.zoom_out),
                    color: Colors.white,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black26,
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Zoom in
                  IconButton(
                    onPressed: () => controller.zoomLevel = 
                        (controller.zoomLevel + 0.25).clamp(0.25, 3.0),
                    icon: const Icon(Icons.zoom_in),
                    color: Colors.white,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black26,
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Search
                  IconButton(
                    onPressed: onSearch,
                    icon: const Icon(Icons.search),
                    color: Colors.white,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black26,
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Toggle bottom bar
                  IconButton(
                    onPressed: onToggleBottomBar,
                    icon: const Icon(Icons.more_vert),
                    color: Colors.white,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black26,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/ 