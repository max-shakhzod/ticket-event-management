import 'package:flutter/material.dart';

class TopCommonButtonsWidget extends StatefulWidget {
  final Function(int)? onPressed;
  final List<String> buttonLabels;
  final List<Color> buttonColors;

  const TopCommonButtonsWidget({
    super.key,
    required this.onPressed,
    required this.buttonLabels,
    required this.buttonColors,
  });

  @override
  // ignore: library_private_types_in_public_api
  _TopCommonButtonsWidgetState createState() => _TopCommonButtonsWidgetState();
}

class _TopCommonButtonsWidgetState extends State<TopCommonButtonsWidget> {
  int selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        itemCount: widget.buttonLabels.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: selectedIndex == index
                    ? widget.buttonColors[index]
                    : const Color.fromARGB(0, 255, 255, 255),
                side: BorderSide(color: widget.buttonColors[index]),
                fixedSize: const Size(113.0, 33.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0),
                ),
              ),
              onPressed: () {
                setState(() {
                  selectedIndex = index;
                });
                if (widget.onPressed != null) {
                  widget.onPressed!(index);
                }
                _scrollToSelectedButton(index);
              },
              child: Text(
                widget.buttonLabels[index],
                style: TextStyle(
                  fontSize: 14,
                  color: selectedIndex == index
                      ? Colors.white
                      : widget.buttonColors[index],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _scrollToSelectedButton(int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    const buttonWidth = 113.0;
    const buttonPadding = 8.0;
    final targetOffset =
        (index * (buttonWidth + buttonPadding)) -
        (screenWidth / 2) +
        (buttonWidth / 2);
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }
}
