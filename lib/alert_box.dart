import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:glass/glass.dart';

class AlertBox {
  static void show(
    BuildContext context, {
    required String title,
    required String content,
    required String accept,
    required String decline,
    required Color acceptColor,
    required Future<void> Function() acceptCallback,
    required Future<void> Function() declineCallback,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool loading = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: Colors.white.withOpacity(0),
          insetPadding: EdgeInsets.zero,
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          children: [
            Center(
              child: Container(
                width: screenWidth * 0.7,
                decoration: BoxDecoration(
                  // color: Colors.white.withOpacity(.8),
                  color: Theme.of(context).shadowColor.withOpacity(.7),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Icon(
                        CupertinoIcons.exclamationmark_triangle_fill,
                        color: Colors.amber,
                        size: 40,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: "SFProRounded",
                          fontWeight: FontWeight.w600,
                          fontSize: 19,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          content,
                          style: const TextStyle(
                            fontFamily: "SFProRounded",
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Color.fromARGB(255, 91, 91, 91),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Divider(
                        color: Color.fromARGB(255, 120, 120, 120),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Column(
                          children: !loading
                              ? [
                                  SizedBox(height: 15),
                                  Center(
                                    child: GestureDetector(
                                      onTap: declineCallback,
                                      child: Text(
                                        decline,
                                        style: const TextStyle(
                                          fontFamily: "SFProRounded",
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ]
                              : [
                                  const Expanded(
                                    // padding: EdgeInsets,
                                    child: Center(
                                        child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Color.fromARGB(255, 91, 91, 91),
                                        strokeWidth: 2,
                                      ),
                                    )),
                                  ),
                                ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).asGlass(
                clipBorderRadius: BorderRadius.circular(40.0),
                enabled: true,
                frosted: true,
              ),
            ),
          ],
        );
      },
    );
  }
}
