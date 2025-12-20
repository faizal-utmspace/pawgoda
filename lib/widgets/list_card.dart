import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:pawgoda/utils/styles.dart';

class ListCard extends StatelessWidget {
  final ListItem item;
  const ListCard(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color iconColor = item.color ?? Styles.blackColor;

    return InkWell(
      onTap: item.action,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Styles.bgColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              color: iconColor,
              size: 24,
            ),
            const Gap(15),
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 17,
                ),
              ),
            ),
            const Icon(
              CupertinoIcons.forward,
              color: Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class ListItem {
  final String name;
  final String description;
  final IconData icon;
  final VoidCallback action;
  final Color? color;

  ListItem({
    required this.name,
    required this.description,
    required this.icon,
    required this.action,
    this.color,
  });
}
