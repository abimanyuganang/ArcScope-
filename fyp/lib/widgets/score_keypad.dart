import 'package:flutter/material.dart';

class ScoreKeypad extends StatelessWidget {
  final void Function(int) onTap;
  final VoidCallback onDelete;
  const ScoreKeypad({super.key, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final caps = [11,10,9,8,7,6, 5,4,3,2,1,-1]; // 11=X, -1=M
    String txt(int v) => v == 11 ? 'X' : (v == -1 ? 'M' : '$v');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 10)],
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Column(
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final v in caps)
                SizedBox(
                  width: 46,
                  height: 46,
                  child: OutlinedButton(
                    onPressed: () => onTap(v),
                    style: OutlinedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(txt(v), style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: onDelete, child: const Text('Delete')),
          ),
        ],
      ),
    );
  }
}
