import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SegmentedControl extends StatelessWidget {
  final String currentView;
  final ValueChanged<String?> onViewChanged;

  const SegmentedControl({
    super.key,
    required this.currentView,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            child: CupertinoSlidingSegmentedControl<String>(
              groupValue: currentView,
              children: const {
                'W': Text('日'),
                'M': Text('月'),
                'Y': Text('年'),
              },
              onValueChanged: onViewChanged,
              thumbColor: Colors.teal[300]!,
              backgroundColor: Colors.teal[100]!,
            ),
          ),
        ],
      ),
    );
  }
}
