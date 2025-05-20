
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
  load_more_wrapper: ^5.0.0
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
example with cubit and view 

cubit.dart 

```dart
class SearchCubit extends Cubit<SearchState> {
class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchInitial()) {
    searchController.addListener(onSearchChanged);
  }

  static SearchCubit get(context) => BlocProvider.of(context);
  TextEditingController searchController = TextEditingController();
  // ServicesModel? servicesModel; // This variable is not used and can be removed.
  Timer? _debounce;

  void onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // When the search text changes, it's a new search, so reset pagination.
      getServices(isLoadMore: false);
    });
  }

  bool isLoading = false; // General loading state for main UI or initial load
  bool hasMore = true; // Indicates if there's more data to fetch
  int currentPage = 1;
  List<Service> allServices = [];
  bool isLoadMoreLoading = false; // Specific loading state for scroll-to-load indicator

  static const int _itemsPerPage = 1; // Constant for pagination limit

  Future<void> getServices({bool isLoadMore = false}) async {
    // Prevent multiple concurrent requests
    if (isLoading) return;

    // If attempting to load more but no more data exists, do nothing.
    if (isLoadMore && !hasMore) {
      return;
    }

    // Set appropriate loading flags
    isLoading = true; // General loading state is always true when fetching
    if (isLoadMore) {
      isLoadMoreLoading = true; // Specific flag for the load more indicator
    } else {
      // If it's a fresh load (initial or search), reset pagination and clear existing data
      currentPage = 1;
      allServices.clear();
      emit(ServiceLoading()); // Emit state for initial/search loading UI
    }

    try {
      final response = await DioHelper.getData(
        path: 'services',
        queryParameters: {
          'page': currentPage,
          'per_page': _itemsPerPage, // Use the constant for consistent pagination
          // Add search query if controller has text
          if (searchController.text.isNotEmpty) 'name': searchController.text,
        },
      );

      final newServicesModel = ServicesModel.fromJson(response!.data);
      final newServices = newServicesModel.data?.services ?? [];

      if (isLoadMore) {
        allServices.addAll(newServices);
      } else {
        allServices = newServices;
      }

      // Determine if there's more data to load based on the number of items received
      hasMore = newServices.length == _itemsPerPage;
      if (hasMore) {
        currentPage++; // Increment page only if there might be more data
      }

      emit(ServiceSuccess()); // Emit success state to rebuild UI with new data
    } catch (error) {
      emit(ServiceError());
    } finally {
      // Always reset loading flags after the operation completes (success or error)
      isLoading = false;
      isLoadMoreLoading = false;
    }
  }

  // Clean up the timer and listener when the cubit is closed
  @override
  Future<void> close() {
    searchController.removeListener(onSearchChanged);
    _debounce?.cancel();
    return super.close();
  }
}
```



view.dart
```dart

class ClientSearchScreen extends StatelessWidget {
  final bool? showAppBar;
  const ClientSearchScreen({super.key, this.showAppBar});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchCubit()..getServices(), // Initial load of services
      child: Builder(builder: (context) {
        SearchCubit cubit = SearchCubit.get(context);
        return BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            return Scaffold(
              appBar: CustomWhiteAppBar(), // Use your custom app bar
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CustomTextField(
                      onChanged: (p0) {
                        // Debounce is handled inside cubit's onSearchChanged
                        cubit.onSearchChanged();
                      },
                      hint: 'search'.tr(),
                      controller: cubit.searchController,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                      ),
                      child: (cubit.isLoading && cubit.allServices.isEmpty)
                          ? GridView.builder(
                              padding: EdgeInsets.zero,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 20.h,
                                crossAxisSpacing: 10.w,
                              ),
                              itemCount: 6, // Show 6 shimmer items for initial load
                              itemBuilder: (context, index) =>
                                  shimmerServiceCard(),
                            )
                          : (cubit.allServices.isEmpty && !cubit.isLoading)
                              ? Center(child: Text('No Services'.tr())) // Show "No Services" only if list is empty and not loading
                              : LoadMoreWrapper(
                                  onLoadMore: () =>
                                      cubit.getServices(isLoadMore: true),
                                  isLoading: cubit.isLoadMoreLoading, // Now correctly managed in cubit
                                  hasMore: cubit.hasMore, // Now correctly managed in cubit
                                  child: GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 20.h,
                                      crossAxisSpacing: 10.w,
                                    ),
                                    itemCount: cubit.allServices.length,
                                    itemBuilder: (context, index) {
                                      final service = cubit.allServices[index];
                                      return GestureDetector(
                                        onTap: () {
                                          RouteManager.navigateTo(
                                            // Corrected typo: ServiceProviders
                                            ServiceProviders(serviceId: service.id!),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Color(0xff4FB5FF),
                                                Color(0xffB8DCF5)
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8.r),
                                          ),
                                          child: Container(
                                            width: 80.w,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                              color: Colors.white,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                customImg(service.image,
                                                    height: 50.h),
                                                4.verticalSpace,
                                                Text(
                                                  service.name ?? '',
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        const Color(0xff3D3D3D),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
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

