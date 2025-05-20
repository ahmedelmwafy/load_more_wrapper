
# load_more_wrapper

A stateless and reusable Flutter widget to add load-more functionality to scrollable widgets like ListView and GridView, with optional animated loader and footer.

---

## Features

- Supports any scrollable widget (ListView, GridView, etc.)
- No StatefulWidget required
- Optional animated loading indicator
- Customizable footer when no more data to load
- Simple API with `hasMore` and `onLoadMore` callbacks

---

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  load_more_wrapper: ^4.0.0
```

Then run:

```bash
flutter pub get
```

---

## Usage

Wrap your scrollable widget (e.g., `ListView.builder`) with `LoadMoreWrapper` and provide:

- `hasMore`: a boolean to indicate if more data can be loaded
- `onLoadMore`: a callback to load more data
- Optional `isLoading` boolean to control loading state
- Optional `footerBuilder` widget for the end message
- Optional `showDefaultLoading` to show/hide default loading animation

### Simple example:

```dart
LoadMoreWrapper(
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (_, index) => ListTile(title: Text(items[index])),
  ),
  isLoading: isLoading,
  hasMore: hasMore,
  onLoadMore: loadMoreItems,
  showDefaultLoading: true,
  footerBuilder: Padding(
    padding: const EdgeInsets.all(16),
    child: Center(child: Text('No more items')),
  ),
);
```

---

### Complete example with StatefulWidget:

```dart
import 'package:flutter/material.dart';
import 'load_more_wrapper.dart'; // import your widget here

class LoadMoreExample extends StatefulWidget {
  const LoadMoreExample({super.key});

  @override
  State<LoadMoreExample> createState() => _LoadMoreExampleState();
}

class _LoadMoreExampleState extends State<LoadMoreExample> {
  List<String> items = List.generate(20, (index) => 'Item ${index + 1}');
  bool isLoading = false;
  bool hasMore = true;

  Future<void> loadMoreItems() async {
    if (isLoading || !hasMore) return;
    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    final newItems = List.generate(10, (index) => 'Item ${items.length + index + 1}');

    setState(() {
      items.addAll(newItems);
      isLoading = false;
      if (items.length >= 50) hasMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Load More Example')),
      body: LoadMoreWrapper(
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, index) => ListTile(title: Text(items[index])),
        ),
        isLoading: isLoading,
        hasMore: hasMore,
        onLoadMore: loadMoreItems,
        showDefaultLoading: true,
        footerBuilder: const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No more items')),
        ),
      ),
    );
  }
}
```

---

## License

MIT License © 2025 Ahmed Elmwafy

---

Feel free to open issues or contribute!

---

