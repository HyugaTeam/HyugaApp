import 'package:flutter/material.dart';
import 'package:hyuga_app/config/config.dart';
import 'package:hyuga_app/screens/ticket/ticket_provider.dart';

class TicketPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var provider = context.watch<TicketPageProvider>();
    var ticket = provider.ticket;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: CircleAvatar(
            backgroundColor: Theme.of(context).highlightColor,
            radius: 40,
            child: IconButton(
              // alignment: Alignment.centerRight,
              color: Theme.of(context).colorScheme.secondary,
              //padding: EdgeInsets.symmetric(horizontal: 20),
              onPressed: () => Navigator.pop(context),
              icon: Image.asset(localAsset("left-arrow"), width: 18, color: Theme.of(context).primaryColor,)
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).highlightColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade600,
              spreadRadius: 1,
              blurRadius: 15,
              offset: const Offset(0, 15)
            )
          ],
          borderRadius: BorderRadius.circular(20),
        ),
        height: MediaQuery.of(context).size.height*0.8,
        child: Column(
          
        ),
      ),
    );
  }
}