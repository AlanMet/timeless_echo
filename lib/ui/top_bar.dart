import 'package:flutter/widgets.dart';

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
          const Expanded(flex: 3, child: Placeholder()),
          if (screenWidth > 900) const Expanded(flex: 3, child: Placeholder()),
          const Expanded(flex: 3, child: Placeholder()),
        ],
      ),
    );
  }
}
