import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Card anim')),
        body: CardStack(),
      ),
    );
  }
}

class CardStack extends StatefulWidget {
  const CardStack({super.key});

  @override
  State<CardStack> createState() => _CardStackState();
}

class _CardStackState extends State<CardStack> {
  List<bool> _cardSelected = [false, false, false, false, false];
  bool _isSplit = false;
  int? _activeCardIndex;

  final List<String> _imagePaths = [
    'assets/note.png',
    'assets/note1.png',
    'assets/note2.png',
    'assets/note3.png',
    'assets/bgNote.png',
  ];

  void _handleTopCardTap() {
    setState(() {
      _isSplit = !_isSplit;
      for (int i = 0; i < 5; i++) {
        _cardSelected[i] = false;
      }
      _activeCardIndex = null;
    });
  }

  void _handleCardTap(int index) {
    if (_isSplit && index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NewScreen(
                  imagePaths: _imagePaths,
                )),
      );
    } else {
      setState(() {
        if (_activeCardIndex == index) {
          _activeCardIndex = null;
          _cardSelected[index] = false;
        } else {
          _activeCardIndex = index;
          for (int i = 0; i < 5; i++) {
            _cardSelected[i] = false;
          }
          _cardSelected[index] = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: List.generate(5, (index) {
          return AnimatedPositioned(
            duration: Duration(milliseconds: 500),
            top: _cardSelected[index] ? 20.0 : 100.0,
            left: _isSplit ? 50.0 + (index * 40.0) : 50.0,
            width: _isSplit ? 100.0 : 70,
            child: GestureDetector(
              onTap: () {
                if (_isSplit) {
                  _handleCardTap(index);
                } else {
                  _handleTopCardTap();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(_imagePaths[index]),
                    fit: BoxFit.cover,
                  ),
                ),
                height: 100,
                width: 200,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class NewScreen extends StatelessWidget {
  final List<String> imagePaths;

  NewScreen({required this.imagePaths});

  @override
  Widget build(BuildContext context) {
    final List<String> _imagePaths = [
      'assets/note.png',
      'assets/note1.png',
      'assets/note2.png',
      'assets/note3.png',
      'assets/note4.png',
      'assets/note5.png',
    ];
    return Scaffold(
      appBar: AppBar(title: Text('All Notes')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: _imagePaths.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_imagePaths[index]),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
