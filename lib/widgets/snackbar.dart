import 'package:flutter/material.dart';

void showCustomSnackBar(
    BuildContext context, {
      required String title,
      required String message,
      required bool isSuccess,
    }) {
  final backgroundColor = isSuccess ? const Color(0xFFDFF5E3) : const Color(0xFFFFE0E0);
  final borderColor = isSuccess ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
  final icon = isSuccess ? Icons.check_circle : Icons.error;

  final snackBar = SnackBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 4),
    content: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: borderColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: borderColor)),
                const SizedBox(height: 4),
                Text(message,
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey.shade800)),
              ],
            ),
          ),
          InkWell(
            onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            child: Icon(Icons.close, color: borderColor),
          )
        ],
      ),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
