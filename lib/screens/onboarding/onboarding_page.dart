import 'package:flutter/material.dart';
import 'package:hyuga_app/screens/wrapper/wrapper_provider.dart';

import 'components/dot_indicator.dart';
import 'components/onboard_content.dart';
import 'onboarding_provider.dart';

class OnboardingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var provider = context.watch<OnboardingPageProvider>();
    var wrapperProvider = context.watch<WrapperProvider>();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: provider.pageController,
                itemCount: provider.pages.length,
                onPageChanged: provider.updateSelectedPageIndex,
                itemBuilder: (context, index) => OnboardContent(
                  provider.pages[index]['image']!,
                  provider.pages[index]['title']!,
                  provider.pages[index]['content']!,
                )
              ),
            ),
            Row(
              children: [
                ...List.generate(provider.pages.length, (index) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: DotIndicator(index == provider.pageIndex),
                )),
                Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 30.0),
                  child: SizedBox(
                    height: 60, 
                    width: 60,
                    child: FloatingActionButton(
                      onPressed: () { 
                        provider.pageIndex < provider.pages.length - 1
                        ? provider.pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn)
                        : wrapperProvider.finishOnboardingScreen();
                      },
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      elevation: 0,
                      child: Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}