import 'package:flutter/material.dart';

class PlacePicker {
  static void show(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PlacePickerScreen(),
    ));
  }
}

class PlacePickerScreen extends StatelessWidget {
  final TextEditingController _textController = TextEditingController();
  // GoogleMapsPlaces _places = GoogleMapsPlaces(
  //     apiKey: widget.apiKey,
  //     baseUrl: widget.proxyBaseUrl,
  //     httpClient: widget.httpClient,
  //     apiHeaders: await GoogleApiHeaders().getHeaders(),
  //   );

  @override
  Widget build(BuildContext context) {
    _textController.addListener(_serachListener);
    return WillPopScope(
      onWillPop: () async {
        try {
          _textController.dispose();
        } catch (e) {}
        print('WillPopScope');
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _textController,
            decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.black,
                )),
          ),
        ),
        body: ListView.separated(
            itemBuilder: (context, index) => ListTile(
                  leading: Icon(Icons.location_on),
                  title: Text('prediction.description'),
                  onTap: () {},
                ),
            separatorBuilder: (context, index) => Divider(height: 1),
            itemCount: 5),
      ),
    );
  }

  void _serachListener() {
    print('Second text field: ${_textController.text}');
  }

  void searchApi(args) {
    // final res = await _places!.autocomplete(
    //     value,
    //     offset: widget.offset,
    //     location: widget.location,
    //     radius: widget.radius,
    //     language: widget.language,
    //     sessionToken: widget.sessionToken,
    //     types: widget.types!,
    //     components: widget.components!,
    //     strictbounds: widget.strictbounds!,
    //     region: widget.region,
    //   );
  }
}
