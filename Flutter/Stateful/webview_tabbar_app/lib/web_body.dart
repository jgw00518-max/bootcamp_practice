import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebBody extends StatefulWidget {
  final String siteName;
  const WebBody({super.key, required this.siteName});

  @override
  State<WebBody> createState() => _WebBodyState();
}

class _WebBodyState extends State<WebBody> {
  late WebViewController controller;
  late bool isLoading;
  late String siteName;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    siteName = widget.siteName;
    controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (progress) {
              setState(() {
                isLoading = true;
              });
            },
            onPageStarted: (url) {
              setState(() {
                isLoading = true;
              });
            },
            onPageFinished: (url) {
              setState(() {
                isLoading = false;
              });
            },
            onWebResourceError: (error) {
              setState(() {
                isLoading = false;
              });
            },
          )
        )
        ..loadRequest(Uri.parse("https://$siteName"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          isLoading
          ? Center(child: CircularProgressIndicator(),)
          : WebViewWidget(controller: controller)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => backProcess(context),
        child: Icon(Icons.arrow_back),
      ),
    );
  } // build

  // --- Functions ---
  Future<void> backProcess(BuildContext context) async{
    if(await controller.canGoBack()){
      controller.goBack();
    }else{
      snackBarFunction();
    }
  }

  void snackBarFunction(){
    Get.snackbar("Warning", "No more to go!");
  }

} // class