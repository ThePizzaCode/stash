import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const WelcomeScreen({required this.onContinue, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(),
        // App Logo and Name
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          child: Column(
            children: [
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15,
                        spreadRadius: -7,
                        offset: Offset(0, 0),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(20),
                    image: const DecorationImage(
                        image: AssetImage(
                      'assets/logo.png', // Replace with your app's logo path
                    ))),
              ),

              const SizedBox(height: 30),
              // Headline
              Text(
                AppLocalizations.of(context)!.welcome_to_stash,
                style: const TextStyle(
                  fontFamily: "SFProDisplay",
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color.fromARGB(255, 3, 68, 230),
                ),
                textAlign: TextAlign.center,
              ),

              // Short Description
              Text(
                AppLocalizations.of(context)!
                    .your_loyalty_cards_all_in_one_place,
                style: const TextStyle(
                  fontFamily: "SFProDisplay",
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 3, 68, 230),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        // Continue Button
        GestureDetector(
          onTap: onContinue,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
            child: Padding(
              padding: EdgeInsets.only(bottom: Platform.isAndroid ? 15 : 0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 3, 68, 230),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.continue_button,
                        style: const TextStyle(
                          fontFamily: "SFProDisplay",
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Adjust height for padding at the bottom
      ],
    );
  }
}
