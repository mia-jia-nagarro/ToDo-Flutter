import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo/Todo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isShowTodoList = false;
  bool isShowLoadingView = false;

  final dio = Dio();
  List<Todo> todoList = [];

  @override
  void initState() {
    super.initState();
    // getTodoList();
  }

  void showLoading() {
    setState(() {
      isShowLoadingView = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      getTodoList();
    });
  }

  void getTodoList() async {
    final future = await dio
        .get<List<dynamic>>("http://jsonplaceholder.typicode.com/todos");
    isShowLoadingView = false;
    var list = future.data ?? [];
    if (future.statusCode == 200 && list.isNotEmpty) {
      isShowTodoList = true;
    } else {
      isShowTodoList = false;
    }

    for (var data in list) {
      var todo = Todo.fromJson(data);
      todoList.add(todo);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (isShowLoadingView) {
      return _loadingPage();
    } else {
      Widget widget;
      if (isShowTodoList) {
        widget = _todoListPage();
      } else {
        widget = _emptyPage();
      }
      return _homePage(widget);
    }
  }

  Widget _homePage(Widget widget) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Todo List",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Fluttertoast.showToast(
                  msg: "clicked action.", toastLength: Toast.LENGTH_SHORT);
            },
            icon: const Icon(Icons.more_vert),
            color: Colors.black,
          )
        ],
      ),
      body: widget,
    );
  }

  Widget _loadingPage() {
    return Container(
      color: Colors.white,
      width: double.maxFinite,
      height: double.maxFinite,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
        ),
      ),
    );
  }

  Widget _emptyPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text("Give it another try", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: showLoading,
            child: const Text(
              "RELOAD",
              style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
          )
        ],
      ),
    );
  }

  Widget _todoListPage() {
    return ListView.separated(
        itemBuilder: _listItems,
        padding: const EdgeInsets.only(top: 10),
        itemCount: todoList.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(
              color: Colors.black,
            )
    );
  }

  Widget _listItems(BuildContext context, int index) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Fluttertoast.showToast(msg: "clicked : $index item");
        },
        child: Row(
          children: [
            const Padding(padding: EdgeInsets.symmetric(vertical: 20)),
            const Expanded(
                flex: 2,
                child: Center(
                  child: Icon(Icons.circle, color: Colors.grey),
                )),
            Expanded(
                flex: 8,
                child: Container(
                    margin: const EdgeInsets.only(right: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(todoList[index].title ?? "",
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 3)),
                        Text(
                            "completed : ${todoList[index].completed!.toString()}")
                      ],
                    ))),

            // const SizedBox(width: 15),
            // const Icon(Icons.circle, color: Colors.grey),
            // const SizedBox(width: 20),
            // Column(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     const SizedBox(height: 15),
            //     Container(
            //       width: MediaQuery.of(context).size.width / 3 * 2,
            //       child: Text(todoList[index].title ?? "",
            //           maxLines: 1, overflow: TextOverflow.ellipsis),
            //     ),
            //     const SizedBox(height: 8),
            //     Text("completed : ${todoList[index].completed!.toString()}"),
            //     const SizedBox(height: 15),
            //   ],
            // )
          ],
        ));
  }
}
