import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/annotation_provider.dart';
// import '../models/annotation.dart'; // TODO: Uncomment when annotation model is used

class PageNavigator extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageSelected;
  final VoidCallback? onClose;

  const PageNavigator({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageSelected,
    this.onClose,
  });

  @override
  State<PageNavigator> createState() => _PageNavigatorState();
}

class _PageNavigatorState extends State<PageNavigator>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  int _selectedPage = 1;

  @override
  void initState() {
    super.initState();
    _selectedPage = widget.currentPage;
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentPage();
    });
  }

  @override
  void didUpdateWidget(PageNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPage != widget.currentPage) {
      setState(() {
        _selectedPage = widget.currentPage;
      });
      _scrollToCurrentPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _scrollToCurrentPage() {
    if (_scrollController.hasClients) {
      final itemWidth = 120.0; // Width of each thumbnail
      final spacing = 8.0; // Spacing between thumbnails
      final offset = (_selectedPage - 1) * (itemWidth + spacing);

      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      ),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Page Navigator',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Semantics(
                    label: 'Close page navigator',
                    button: true,
                    child: IconButton(
                      onPressed: () {
                        _animationController.reverse().then((_) {
                          widget.onClose?.call();
                        });
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ],
              ),
            ),

            // Page thumbnails
            Expanded(
              child: Consumer<AnnotationProvider>(
                builder: (context, annotationProvider, child) {
                  return ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: widget.totalPages,
                    itemBuilder: (context, index) {
                      final pageNumber = index + 1;
                      final isSelected = pageNumber == _selectedPage;
                      final hasBookmark = annotationProvider.hasAnnotations(
                        pageNumber,
                      );
                      final annotationCount = annotationProvider
                          .getAnnotationCount(pageNumber);

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Semantics(
                          label:
                              'Page $pageNumber${isSelected ? ', selected' : ''}',
                          button: true,
                          selected: isSelected,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPage = pageNumber;
                              });
                              widget.onPageSelected(pageNumber);
                            },
                            child: Container(
                              width: 120,
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer
                                        : Theme.of(
                                          context,
                                        ).colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    isSelected
                                        ? Border.all(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                          width: 2,
                                        )
                                        : null,
                              ),
                              child: Stack(
                                children: [
                                  // Page thumbnail placeholder
                                  Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.description,
                                            size: 32,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Page $pageNumber',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Bookmark indicator
                                  if (hasBookmark)
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.bookmark,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),

                                  // Annotation count indicator
                                  if (annotationCount > 0)
                                    Positioned(
                                      bottom: 4,
                                      right: 4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          '$annotationCount',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Page info
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Page $_selectedPage of ${widget.totalPages}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Consumer<AnnotationProvider>(
                    builder: (context, annotationProvider, child) {
                      // TODO: Implement bookmark functionality
                      // final bookmark = annotationProvider.getBookmarkForPage(_selectedPage);
                      // if (bookmark != null) {
                      //   return Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       const Icon(
                      //         Icons.bookmark,
                      //         size: 16,
                      //         color: Colors.green,
                      //       ),
                      //       const SizedBox(width: 4),
                      //       Text(
                      //         bookmark.title,
                      //         style: Theme.of(context).textTheme.bodySmall,
                      //       ),
                      //     ],
                      //   );
                      // }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
