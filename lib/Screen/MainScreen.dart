import 'package:chatapp/Providers/HomeProvider.dart';
import 'package:chatapp/Providers/NotifiationProvider.dart';
import 'package:chatapp/Providers/SearchProvider.dart';
import 'package:chatapp/Screen/AddFriends.dart';
import 'package:chatapp/Screen/HomeScreen.dart';
import 'package:chatapp/Screen/LoginScreen.dart';
import 'package:chatapp/Screen/NotificationScreen.dart';
import 'package:chatapp/Screen/ProfileScreen.dart';
import 'package:chatapp/Screen/SearchScreen.dart';
import 'package:chatapp/constant/AppColors.dart';
import 'package:chatapp/model/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';

import '../Firebase/firebaseInstance.dart';
import '../Firebase/notification/NotificationService.dart';
import '../Providers/AddFriendsProvider.dart';
import '../Providers/ProfileProvider.dart';
import '../Providers/ThemeProvider.dart';
import '../function/MyFunction.dart';
import '../util/Shared_Preference.dart';

class MainScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() =>MainScreenState();
  }

class MainScreenState extends State<MainScreen> {
  PersistentTabController? _controller;

  int index=0;

  List<Widget> _buildScreens() {
    return [
      HomeScreen(),
      SearchScreen(),
      AddFriends(),
      NotifiationScreen(),
      ProfileScreen(this)
    ];
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      _controller = PersistentTabController(initialIndex: 0);


      Future.delayed(Duration(seconds: 5),(){
        assignData(context);
      });

    });
  }

  @override
  Widget build(BuildContext context) {
    //logout();
    var themeBlack=context.read<ThemeProvider>().darkTheme;
    return FirebaseAuth.instance.currentUser==null?LoginScreen():Scaffold(
      body: PersistentTabView(
        context,
        onItemSelected: (value){
          setState(() {
            index=value;
          });
        },
        controller: _controller,
        screens: _buildScreens(),
        items: [
          PersistentBottomNavBarItem(
            icon: FaIcon(index==0?Icons.home:Icons.home_outlined),
            title: ("Home".tr),
            activeColorPrimary: AppColors.primary,
            inactiveColorPrimary: themeBlack?Colors.white:Colors.black,
          ),
          PersistentBottomNavBarItem(
            icon: Icon(index==1?Icons.search:Icons.search_outlined),
            title: ("Search".tr),
            activeColorPrimary: AppColors.primary,
            inactiveColorPrimary: themeBlack?Colors.white:Colors.black,
          ),
          PersistentBottomNavBarItem(
            icon: Icon(Icons.add,color: Colors.white,),
            title: ("Add".tr),
            activeColorPrimary: AppColors.primary,
            inactiveColorPrimary: themeBlack?Colors.white:Colors.black,
          ),
          PersistentBottomNavBarItem(
            icon: Icon(index==3?Icons.notifications:Icons.notifications_none_outlined),
            title: ("Notifications".tr),
            activeColorPrimary: AppColors.primary,
            inactiveColorPrimary: themeBlack?Colors.white:Colors.black,
          ),
          PersistentBottomNavBarItem(
            icon: Icon(index==4?Icons.person:Icons.person_outline),
            title: ("Profile".tr),
            activeColorPrimary: AppColors.primary,
            inactiveColorPrimary: themeBlack?Colors.white:Colors.black,
          ),
        ],
        confineInSafeArea: true,
        backgroundColor: themeBlack?AppColors.blackboxbg:Colors.white, // Default is Colors.white.
        handleAndroidBackButtonPress: true, // Default is true.
        resizeToAvoidBottomInset: true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
        stateManagement: true, // Default is true.
        hideNavigationBarWhenKeyboardShows: true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
          colorBehindNavBar: Colors.grey,
        ),
        popAllScreensOnTapOfSelectedTab: true,
        popActionScreens: PopActionScreensType.all,
        itemAnimationProperties: ItemAnimationProperties( // Navigation Bar's items animation properties.
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimation( // Screen transition animation on change of selected tab.
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),
        navBarStyle: NavBarStyle.style15, // Choose the nav bar style with this property.
      ),
    );
  }

  void assignData(context) {
    Provider.of<HomeProvider>(context,listen: false).assignData();
    Provider.of<NotificationProvider>(context,listen: false).findData();
    Provider.of<ProfileProvider>(context,listen: false).assignData();
    Provider.of<AddFriendsProvider>(context,listen: false).assignData();
  }


}

