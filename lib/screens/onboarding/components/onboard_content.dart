import 'package:flutter/material.dart';
import 'package:hyuga_app/config/config.dart';

class OnboardContent extends StatelessWidget {
  final String image;
  final String title;
  final String content;

  OnboardContent(this.image, this.title, this.content);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Spacer(),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 30),
            child: Image.asset(
              localAsset(image), 
              width: MediaQuery.of(context).size.width*0.75,
              height: MediaQuery.of(context).size.height*0.5,
            ),
          ),
        ),
        Spacer(),
        Text(title, style: Theme.of(context).textTheme.headline5!.copyWith(color: Theme.of(context).colorScheme.tertiary, fontStyle: FontStyle.normal, fontSize: 22)),
        SizedBox(height: 25),
        Text(content, style: Theme.of(context).textTheme.headline3!.copyWith(color: Theme.of(context).primaryColor, fontSize: 26, fontWeight: FontWeight.normal)),
        Spacer()
      ],
    );
  }
}