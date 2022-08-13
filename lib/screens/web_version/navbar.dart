
import 'package:flutter/material.dart';
import 'package:hyuga_app/screens/web_version/navigation_menu/become_partner_page.dart';
import 'package:hyuga_app/screens/web_version/navigation_menu/contact_page.dart';
import 'package:hyuga_app/screens/web_version/navigation_menu/log_in_page.dart';
import 'package:hyuga_app/screens/web_version/navigation_menu/partners_page.dart';
import 'package:hyuga_app/screens/web_version/navigation_menu/profile_page.dart';
import 'package:hyuga_app/screens/web_version/web_landing_page.dart';
import 'package:hyuga_app/services/auth_service.dart';
import 'package:provider/provider.dart';

class Navbar extends StatefulWidget  implements PreferredSizeWidget{
  @override
  _NavbarState createState() => _NavbarState();
  @override
  Size get preferredSize => const Size.fromHeight(150);
}

class _NavbarState extends State<Navbar> {
  
  late Map<String, String> _navMenuButtons;
  
  @override
  void initState() {
    super.initState();
    _navMenuButtons =  {
      "Acasă": 'wrapper/',
      "Devino partener": BecomePartnerWebPage.route,
      "Parteneri": PartnersWebPage.route,
      "Contact": ContactWebPage.route,
    };
    authService.currentUser != null 
      ? _navMenuButtons.addAll({"Profil": ProfileWebPage.route})
      : _navMenuButtons.addAll({"Log In": LogInWebPage.route});
  }

  Widget _buildNavMenuButton(BuildContext context, String text, String route){
      return TextButton(
        onPressed: (){
          Navigator.pushNamed(context, route);
        },
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'Lato'
          ),
        ),
        style: ButtonStyle(
          textStyle: MaterialStateProperty.resolveWith(
            (states){
              return TextStyle(
                color: Theme.of(context).primaryColor
              );
            }
          )
        ),
      );
    }

    /// Builds the website's Navigation Menu (right side)
    Widget _buildNavMenu(BuildContext context){
      return Container(
        width: MediaQuery.of(context).size.width*0.3,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _navMenuButtons.keys.map<Widget>((text) => _buildNavMenuButton(context, text, _navMenuButtons[text]!))
          .toList()
        ),
      );
    }

    /// Builds the website's app title (left side)
    Widget _buildAppTitle(){
      return Row(
        children: [
          Image.asset(
            'assets/images/wine-street-logo.png',
            width: 80,
          ),
          SizedBox(width: 30,),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Wine Street",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30
                ),
              ),
              SizedBox(
                height: 15
              ),
              Text(
                "Wine & Dine la superlativ",
                style: TextStyle(
                  fontSize: 14,
                ),
              )
            ],
          )
        ],
      );
    }

    AppBar _buildNavBar(BuildContext context){
      return AppBar( /// Page Navbar
        elevation: 0,
        toolbarHeight: 140,
        leading: Container(),
        title: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width*0.1,
            vertical: 10
          ),
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAppTitle(), // The website's title (with image and title)
              Spacer(),
              _buildNavMenu(context) // The website's Navigation Menu
            ],
          ),
        ),
      );
    }

  @override
  Widget build(BuildContext context) {
    return StreamProvider.value(
      initialData: null,
      value: authService.user,
      builder: (context, snapshot) {
        return _buildNavBar(context);
      }
    );
  }
}


