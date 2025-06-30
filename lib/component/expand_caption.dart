import 'package:flutter/material.dart';

class ExpandCaption extends StatefulWidget {
  final String text;
  final int limitWord;
  const ExpandCaption({super.key, required this.text, this.limitWord = 3});

  @override
  State<ExpandCaption> createState() => _ExpandCaptionState();
}

class _ExpandCaptionState extends State<ExpandCaption> {
  bool readMore = false;

  @override
  Widget build(BuildContext context) {
    //final textTheme = Theme.of(context).textTheme;
    List<String> words = widget.text.split(' ');

    bool shouldTrim = words.length > widget.limitWord;
    String textDisplay;
    if (!readMore && shouldTrim) {
      textDisplay = '${words.sublist(0, widget.limitWord).join(' ')}...';
    } else {
      textDisplay = widget.text;
    }

    // return Row(
    //   children: [
    //     Text(
    //       textDisplay,
    //       softWrap: true,
    //       overflow: TextOverflow.visible,
    //       style: const TextStyle(
    //         fontSize: 16,
    //         height: 1.5,
    //       ),
    //     ),
    //     const SizedBox(height: 4),
    //     if (shouldTrim)
    //       GestureDetector(
    //         onTap: () {
    //           setState(() {
    //             readMore = !readMore;
    //           });
    //         },
    //         child: Text(
    //           readMore ? 'Sembunyikan' : 'Lihat Selengkapnya',
    //           style: const TextStyle(
    //             color: Colors.blue,
    //             fontWeight: FontWeight.bold,
    //           ),
    //         ),
    //       ),
    //   ],
    // );
    return Column( 
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText( 
          text: TextSpan(
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.black,
            ),
            children: [
              TextSpan(text: textDisplay),
              if (shouldTrim) ...[
                const TextSpan(text: ' '),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        readMore = !readMore;
                      });
                    },
                    child: Text(
                      readMore ? 'Sembunyikan' : 'Lihat Selengkapnya',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
