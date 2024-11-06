import 'package:flutter/material.dart';

class ShoppingCartBtn extends StatefulWidget {
  const ShoppingCartBtn({super.key});

  @override
  State<ShoppingCartBtn> createState() => _ShoppingCartBtnState();
}

class _ShoppingCartBtnState extends State<ShoppingCartBtn> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: AnimatedContainer(
            duration: Duration(seconds: 1),
            width: isExpanded ? 150 : 80,
            height: 60,
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(10)),
            child: Icon(
              Icons.shopping_cart,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
