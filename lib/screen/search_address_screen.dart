import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:food_pick/widget/appbars.dart';
import 'package:daum_postcode_search/daum_postcode_search.dart';

class SearchAddressScreen extends StatelessWidget {
  const SearchAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: '주소 검색',
        isLeading: true,
      ),
      body: DaumPostcodeSearch(
        webPageTitle: '주소 검색',
        initialOption: InAppWebViewGroupOptions(),
        onConsoleMessage: (controller, consoleMessage) {},
        onLoadError: (controller, url, code, message) {},
        onLoadHttpError: (controller, url, statusCode, description) {},
        androidOnPermissionRequest: (controller, origin, resources) async {
          return PermissionRequestResponse(
            resources: resources,
            action: PermissionRequestResponseAction.GRANT,
          );
        },
      ),
    );
  }
}
