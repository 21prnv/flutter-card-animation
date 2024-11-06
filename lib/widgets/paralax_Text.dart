import 'package:flutter/material.dart';

class TextRevealOnScroll extends StatefulWidget {
  final String text;

  const TextRevealOnScroll({Key? key, required this.text}) : super(key: key);

  @override
  _TextRevealOnScrollState createState() => _TextRevealOnScrollState();
}

class _TextRevealOnScrollState extends State<TextRevealOnScroll> {
  late ScrollController _scrollController;
  List<String> _words = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _words = widget.text.split(' ');
    _scrollController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Container(
                height: constraints.maxHeight * 3, // Total scrollable height
                color: Colors.transparent,
              ),
            ),
            Positioned.fill(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: _words.asMap().entries.map((entry) {
                    int index = entry.key;
                    String word = entry.value;
                    double progress = (_scrollController.hasClients
                        ? _scrollController.offset / (constraints.maxHeight * 2)
                        : 0.0);
                    double wordProgress =
                        (progress - index / _words.length) * _words.length;
                    double opacity = wordProgress.clamp(0.0, 1.0);

                    return Stack(
                      children: [
                        Text(
                          word,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        Opacity(
                          opacity: opacity,
                          child: Text(
                            word,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
