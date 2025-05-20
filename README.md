
# 📦 LoadMoreWrapper

A lightweight and reusable Flutter widget to easily implement "load more" functionality with any scrollable widget such as `ListView` or `GridView`.

---

## 🚀 Features

- 📦 Works with `ListView`, `GridView`, or any scrollable widget
- 🔄 Automatically detects when user scrolls near the bottom
- ⚙️ Stateless — easy to plug into any widget tree
- 🌀 Optional built-in loading animation
- ✨ Support for custom footer widgets like "No more items"

---

## 🛠️ Usage

```dart
LoadMoreWrapper(
  child: ListView.builder(...),
  isLoading: isLoading,
  hasMore: hasMore,
  onLoadMore: loadMoreItems,
  showDefaultLoading: true,
  footerBuilder: Text("No more items"),
)
```

---


## 📁 Structure

```
load_more_wrapper/
├── lib/
│   └── load_more_wrapper.dart
├── example/
│   └── main.dart
├── pubspec.yaml
├── README.md
└── LICENSE
```

---

## 📄 License

This project is licensed under the MIT License.
