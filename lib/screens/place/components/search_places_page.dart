import 'package:flutter/material.dart';
import 'package:hyuga_app/config/config.dart';
import 'package:hyuga_app/screens/places/places_provider.dart';

class SearchPlacesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var provider = context.watch<PlacesPageProvider>();
    return WillPopScope(
      onWillPop: () async{
        provider.pageController.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
        provider.updateNextPageIndex(0);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text('Căutare "${provider.searchKeyword}"',),
          ),
          leadingWidth: 80,
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.4),
              radius: 40,
              child: IconButton(
                // alignment: Alignment.centerRight,
                color: Theme.of(context).colorScheme.secondary,
                //padding: EdgeInsets.symmetric(horizontal: 20),
                onPressed: () => provider.pageController.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.easeOut),
                icon: Image.asset(localAsset("left-arrow"), width: 18, color: Theme.of(context).primaryColor,)
              ),
            ),
          ),
        )
      ),
    );
  }
}