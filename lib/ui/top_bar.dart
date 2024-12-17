import 'package:flutter/widgets.dart';
import 'health_bar.dart';
import 'theme_toggle.dart';

class TopBar extends StatefulWidget {
  const TopBar({super.key});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      child: Row(
        children: [
          const Expanded(flex: 3, child: HealthWidget()),
          if (screenWidth > 900) Expanded(flex: 3, child: Container()),
          const Expanded(flex: 3, child: ThemeToggleWidget()),
        ],
      ),
    );
  }
}
