import 'package:communal/models/book.dart';
import 'package:communal/presentation/common/common_book_cover.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CommonVerticalBookCard extends StatelessWidget {
  CommonVerticalBookCard({
    super.key,
    required this.book,
    this.clickable = true,
    this.axis = Axis.vertical,
  });

  final Book book;
  final bool clickable;
  final Axis axis;
  final GlobalKey _imageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    print('Rendered: ${book.title}');
    return InkWell(
      onTap: clickable
          ? () {
              context.push(
                book.owner.isCurrentUser
                    ? '${RouteNames.myBooks}/${book.id}'
                    : RouteNames.foreignBooksPage.replaceFirst(':bookId', book.id),
              );
            }
          : null,
      hoverColor: Colors.transparent,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.hardEdge,
        margin: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              Expanded(
                flex: axis == Axis.vertical ? 0 : 1,
                child: CommonBookCover(
                  book,
                  key: _imageKey,
                ),
              ),
              const Divider(height: 10),
              AdjustableWidthText(
                card: this,
                imageKey: _imageKey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdjustableWidthText extends StatefulWidget {
  const AdjustableWidthText({
    super.key,
    required this.card,
    required this.imageKey,
  });

  final CommonVerticalBookCard card;
  final GlobalKey imageKey;

  @override
  State<AdjustableWidthText> createState() => _AdjustableWidthTextState();
}

class _AdjustableWidthTextState extends State<AdjustableWidthText> {
  double imageWidth = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getImageWidth());
  }

  void getImageWidth() {
    if (widget.imageKey.currentContext != null) {
      final RenderBox renderBox = widget.imageKey.currentContext!.findRenderObject() as RenderBox;
      if (renderBox.hasSize) {
        final width = renderBox.size.width;
        if (width != imageWidth) {
          setState(() {
            imageWidth = width;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.card.axis == Axis.vertical ? null : (imageWidth > 0 ? imageWidth : null),
      padding: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
      child: Column(
        children: [
          Text(
            widget.card.book.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Divider(height: 5),
          Text(
            widget.card.book.author,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
