import 'package:flutter/material.dart';

class LoadMoreWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback onLoadMore;
  final bool isLoading;
  final bool hasMore;
  final bool showDefaultLoading;
  final Widget? footerBuilder;
  final Widget? customLoader; // ✅ New loader widget

  const LoadMoreWrapper({
    super.key,
    required this.child,
    required this.onLoadMore,
    required this.isLoading,
    required this.hasMore,
    this.showDefaultLoading = true,
    this.footerBuilder,
    this.customLoader, // ✅ Include in constructor
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 300 && !isLoading && hasMore) {
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
    if (isLoading) {
      if (customLoader != null) {
        return Padding(
          key: const ValueKey('custom_loader'),
          padding: const EdgeInsets.all(16),
          child: Center(child: customLoader),
        );
      } else if (showDefaultLoading) {
        return const Padding(
          key: ValueKey('default_loader'),
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        );
      }
    }

    if (!hasMore && footerBuilder != null) {
      return Container(
        key: const ValueKey('footer'),
        padding: const EdgeInsets.all(16),
        child: footerBuilder,
      );
    }

    return const SizedBox.shrink(key: ValueKey('empty'));
  }
}
