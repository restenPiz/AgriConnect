import 'package:flutter/material.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: Center(
        child: Column(
          children: [
            Text('AgriConnect'),
            Text(
              'Conectando agricultores diretamente aos mercados urbanos. Elimine intermediários e maximize seus lucros.',
            ),
            ElevatedButton(onPressed: () {}, child: Text('Comecar')),
            ElevatedButton(onPressed: () {}, child: Text('Saiba Mais')),
          ],
        ),
      ),
    );
  }
}
