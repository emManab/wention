import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showCustomSnackBar({
  required BuildContext context,
  required String message,
  required bool success,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      content: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: success ? Colors.green.shade100 : Colors.red.shade100,
          border: Border.all(
            color: success ? Colors.green : Colors.red,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.cancel,
              color: success ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    success ? "SUCCESS!" : "ERROR!",
                    style: TextStyle(
                      color: success ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
