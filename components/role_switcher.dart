import 'package:flutter/material.dart';

/// Simple role switcher widget (placeholder)
/// Can be extended to switch between user roles if needed
class RoleSwitcher extends StatelessWidget {
  final Color? iconColor;

  const RoleSwitcher({super.key, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.swap_horiz, color: iconColor ?? Colors.grey),
      onPressed: () {
        // TODO: Implement role switching if needed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Role switching not implemented')),
        );
      },
      tooltip: 'Switch Role',
    );
  }
}
