import 'package:flutter/material.dart';

class RootDrawer {
  RootDrawer._();

  static DrawerControllerState of(BuildContext context) {
    return context.rootAncestorStateOfType(TypeMatcher<DrawerControllerState>()) as DrawerControllerState;
  }
}