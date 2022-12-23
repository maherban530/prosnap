import 'package:chat_app/Provider/auth_provider.dart';
import 'package:chat_app/Provider/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> providersCollection = [
  ChangeNotifierProvider(create: (_) => AuthProvider()),
  ChangeNotifierProvider(create: (_) => ThemeChanger()),
];
