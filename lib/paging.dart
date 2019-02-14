import 'package:flutter/widgets.dart';

typedef PageBuilder<T> = Widget Function(BuildContext context, LoadMoreStatus status, PagedList<T> data);
typedef PageFuture<T> = Future<List<T>> Function(BuildContext context, int offset, int count);

enum LoadMoreStatus {
  Loading,
  Stable,
}

class Paging<T> extends StatefulWidget {
  final List<T> data;
  final int pageSize;
  final int distance;
  final PageBuilder<T> pageBuilder;
  final PageFuture<T> pageFuture;
  Paging({
    Key key,
    this.data,
    @required this.pageSize,
    int distance,
    @required this.pageBuilder,
    @required this.pageFuture,
  }) : assert(pageSize > 0),
       assert(distance > 0),
       assert(pageSize > distance),
       this.distance = distance ?? (pageSize / 2).floor(),
       super(key: key);

  @override
  _PagingState<T> createState() => _PagingState<T>();
}

class _PagingState<T> extends State<Paging<T>> implements PagedList<T> {
  List<T> _data;
  bool _hasMoreData = true;
  LoadMoreStatus _status = LoadMoreStatus.Stable;

  @override
  void initState() {
    super.initState();
    _data = widget.data ?? <T>[];
    if(_data.length < widget.distance) _load();
  }

  @override
  Widget build(BuildContext context) => widget.pageBuilder(context, _status, this);

  void _load() async {
    if(_status == LoadMoreStatus.Loading || !_hasMoreData) return;

    setState(() {
      _status = LoadMoreStatus.Loading;
    });

    List<T> items = await widget.pageFuture(context, _data.length, widget.pageSize);
    _hasMoreData = items != null && items.length >= widget.distance;

    setState(() {
      _status = LoadMoreStatus.Stable;
      _data.addAll(items);
    });
  }

  @override
  T operator [](int position) {
    if(_data.length - widget.distance == position) {
      _load();
    }
    return _data.elementAt(position);
  }

  @override
  int get length => _data.length;
}

abstract class PagedList<T> {
  int get length;
  T operator [](int index);
}
