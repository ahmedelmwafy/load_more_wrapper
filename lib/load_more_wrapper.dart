
import 'package:flutter/material.dart';

class LoadMoreWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback onLoadMore;
  final bool isLoading;
  final bool hasMore;
  final bool showDefaultLoading;
  final Widget? footerBuilder;

  const LoadMoreWrapper({
    Key? key,
    required this.child,
    required this.onLoadMore,
    required this.isLoading,
    required this.hasMore,
    this.showDefaultLoading = true,
    this.footerBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final isScrollEnd = notification is ScrollEndNotification;
        final isNearBottom = notification.metrics.extentAfter < 500;

        if (isScrollEnd && isNearBottom && hasMore && !isLoading) {
          onLoadMore();
        }
        return false;
      },
      child: Column(
        children: [
          Expanded(child: child),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildFooter(),
          ),
        ],
      ),
    );
  }

  Widget? _buildFooter() {
    if (isLoading && showDefaultLoading) {
      return const Padding(
        key: ValueKey('loader'),
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (!hasMore && footerBuilder != null) {
      return Container(
        key: const ValueKey('footer'),
        padding: const EdgeInsets.all(16),
        child: footerBuilder,
      );
    } else {
      return const SizedBox.shrink(key: ValueKey('empty'));
    }
  }
}
