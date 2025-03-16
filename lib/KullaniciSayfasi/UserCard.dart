import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class UserCard extends StatelessWidget {
  final String email;
  final String name;
  final String phone;
  final String status;

  const UserCard({super.key, 
    required this.email,
    required this.name,
    required this.phone,
    required this.status,
  });

  void deleteUser(BuildContext context) {
    // Add your delete logic here
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(email),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.17,
        children: [
          SlidableAction(
            onPressed: (context) => deleteUser(context),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Sil',
            borderRadius: BorderRadius.circular(12.0),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
      child: Stack(
        children: [
          Card(
            color: Colors.white,
            elevation: 4,
            shadowColor: Colors.cyan,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    email,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(email),
                  Text(name),
                  Text(phone),
                  Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      status,
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            top: 9,
            right: 16,
            child: Icon(
              Icons.swipe_left,
              size: 20,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
