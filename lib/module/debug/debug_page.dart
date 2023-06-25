import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:top_one/module/debug/debug_page_notifier.dart';
import 'package:top_one/view/app_nav_bar.dart';

class DebugPage extends ConsumerStatefulWidget {
  const DebugPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DebugPageState();
}

class _DebugPageState extends ConsumerState<DebugPage> {
  final provider = ChangeNotifierProvider<DebugPageNotifier>((ref) => DebugPageNotifier());

  final scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    ref.read(provider).load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppNavbar(const Text("DEBUG")),
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: <Widget>[
          _buildListView(),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildListView() {
    var items = ref.watch(provider).items;
    return ListView.builder(
      controller: scrollController,
      itemCount: items.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        var item = items[index];
        return Padding(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
          child: SizedBox(
            height: 40,
            child: generateActionButton(item.title, Colors.grey.shade500, Colors.black, () {
              if (item.action != null) item.action!(context);
            }),
          ),
        );
        // return buildTaskItem(context, item);
      },
    );
  }

  Widget generateActionButton(String title, Color backgroundColor, Color textColor, void Function() onTap) {
    return Center(
      child: Material(
        borderRadius: BorderRadius.circular(8.0),
        // 设置背景颜色 默认矩形
        color: backgroundColor,
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          //点击事件回调
          onTap: onTap,
          //不要在这里设置背景色，for则会遮挡水波纹效果,如果设置的话尽量设置Material下面的color来实现背景色
          child: Container(
            //设置child 居中
            alignment: const Alignment(0, 0),
            child: Text(
              title,
              style: TextStyle(color: textColor, fontSize: 16.0),
            ),
          ),
        ),
      ),
    );
  }
}
