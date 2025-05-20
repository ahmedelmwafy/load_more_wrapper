
import 'package:flutter/material.dart';
import 'package:load_more_wrapper/load_more_wrapper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Load More Demo',
      home: LoadMoreDemoScreen(),
    );
  }
}

class LoadMoreDemoScreen extends StatefulWidget {
  const LoadMoreDemoScreen({super.key});

  @override
  State<LoadMoreDemoScreen> createState() => _LoadMoreDemoScreenState();
}

class _LoadMoreDemoScreenState extends State<LoadMoreDemoScreen> {
  final List<String> _items = List.generate(20, (i) => 'Item ${i + 1}');
  bool _isLoading = false;
  bool _hasMore = true;

  Future<void> _loadMore() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (_items.length >= 50) {
      _hasMore = false;
    } else {
      _items.addAll(List.generate(10, (i) => 'Item ${_items.length + i + 1}'));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Load More GridView')),
      body: LoadMoreWrapper(
        isLoading: _isLoading,
        hasMore: _hasMore,
        onLoadMore: _loadMore,
        showDefaultLoading: true,
        footerBuilder: const Text('🎉 No more items'),
        child: GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.5,
          ),
          itemCount: _items.length,
          itemBuilder: (_, i) => Card(
            child: Center(child: Text(_items[i])),
          ),
        ),
      ),
    );
  }
}
