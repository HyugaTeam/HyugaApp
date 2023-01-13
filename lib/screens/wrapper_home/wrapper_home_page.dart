import 'package:flutter/material.dart';
import 'package:hyuga_app/screens/wrapper_home/wrapper_home_provider.dart';
import 'package:hyuga_app/widgets/drawer.dart';

class WrapperHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var provider = context.watch<WrapperHomePageProvider>();
    var selectedScreenIndex = provider.selectedScreenIndex;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedScreenIndex,
        items: provider.screenLabels,
        // onTap: (index) => provider.updateSelectedScreenIndex(index),
        onTap: (index) =>
        provider.updateSelectedScreenIndex(index)
        //provider.pageController.animateToPage(index, duration: Duration(milliseconds: 200), curve: Curves.easeIn),

      ),
      drawer: ProfileDrawer(),
      body: IndexedStack(
        children: provider.screens,
        index: provider.selectedScreenIndex,
      )
    );
  }
}