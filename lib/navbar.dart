import 'package:Stash/homepage.dart';
import 'package:Stash/providers/account_provider.dart';
import 'package:Stash/providers/fidelity_cards_provider.dart';
import 'package:Stash/providers/stores_provider.dart';
import 'package:Stash/rewards.dart';
import 'package:Stash/scan_modal.dart';
import 'package:Stash/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';

import 'package:provider/provider.dart';

class NavBar extends StatefulWidget {
  final int pageIndex;
  const NavBar({
    required this.pageIndex,
    super.key,
  });

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final stores = Provider.of<StoresProvider>(context, listen: false);
      final auth = Provider.of<AccountProvider>(context, listen: false);
      final cards = Provider.of<FidelityCardsProvider>(context, listen: false);

      await stores.fetchStores();
      await cards.loadCards();
      await cards.sweepAll(auth.token);
    });

    _selectedIndex = widget.pageIndex;
  }

  final List<Widget> _screens = [
    const Homepage(),
    const Rewards(),
    const Settings(),
  ];

  void _onItemTapped(int index) {
    if (index == 1) {
      FlutterStatusbarcolor.setNavigationBarColor(
        Theme.of(context).primaryColorDark,
      );
      FlutterStatusbarcolor.setStatusBarColor(
        Colors.transparent,
      );
    } else {
      FlutterStatusbarcolor.setStatusBarColor(
          Theme.of(context).primaryColorDark);
      FlutterStatusbarcolor.setNavigationBarColor(
          Theme.of(context).primaryColorDark);
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(children: [
            _screens[_selectedIndex],
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).disabledColor,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15,
                          spreadRadius: -7,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(),
                        GestureDetector(
                          onTap: () {
                            _onItemTapped(0);
                          },
                          child: SvgPicture.asset(
                            "assets/icons/home.svg",
                            height: 30,
                            color: _selectedIndex == 0
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _onItemTapped(1);
                          },
                          child: SvgPicture.asset(
                            "assets/icons/percent.svg",
                            height: 30,
                            color: _selectedIndex == 1
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _onItemTapped(2);
                          },
                          child: SvgPicture.asset(
                            "assets/icons/settings.svg",
                            height: 30,
                            color: _selectedIndex == 2
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            ScanModal.show(context);
                          },
                          child: const Icon(
                            CupertinoIcons.add_circled_solid,
                            color: Color.fromARGB(255, 24, 104, 242),
                            size: 30,
                          ),
                        ),
                        const SizedBox(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ])),
    );
  }
}
