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
            SizedBox(height: 300),
            Center(
              child: Text(
                'AgriConnect',
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Conectando agricultores diretamente aos mercados urbanos. Elimine intermediários e maximize seus lucros.',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: Text('Comecar')),
            SizedBox(height: 10),
            ElevatedButton(onPressed: () {}, child: Text('Saiba Mais')),
          ],
        ),
      ),
    );
  }
}
