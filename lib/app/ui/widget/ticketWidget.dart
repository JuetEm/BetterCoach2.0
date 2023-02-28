import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../data/model/color.dart';

/// 티켓 위젯
class TicketWidget extends StatefulWidget {
  final int ticketCountLeft;
  final int ticketCountAll;
  final String ticketTitle;
  final String ticketDescription;
  final String ticketStartDate;
  final String ticketEndDate;
  final bool isAlive;

  bool? selected;

  final Function customFunctionOnTap;
  final Function? customFunctionOnLongPress;

  TicketWidget({
    Key? key,
    required this.ticketCountLeft,
    required this.ticketCountAll,
    required this.ticketTitle,
    required this.ticketDescription,
    required this.ticketStartDate,
    required this.ticketEndDate,
    this.selected = false,
    required this.customFunctionOnTap,
    this.customFunctionOnLongPress,
    required this.isAlive,
  }) : super(key: key);

  @override
  State<TicketWidget> createState() => _TicketWidgetState();
}

class _TicketWidgetState extends State<TicketWidget> {
  bool _toggle = false;
  @override
  Widget build(BuildContext context) {
    int ticketDateLeft = int.parse(DateTime.now()
        .difference(DateTime.parse(widget.ticketEndDate))
        .inDays
        .toString());

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
            width: 2,
            color: widget.selected!
                ? Palette.textBlue
                : widget.isAlive
                    ? Palette.backgroundOrange
                    : Palette.grayEE),
      ),
      child: InkWell(
        onLongPress: () {
          widget.customFunctionOnLongPress!();
        },
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTapDown: (details) {
          setState(() {
            _toggle = true;
          });
        },
        onTapUp: (details) {
          setState(() {
            _toggle = false;
          });
        },
        onTap: () {
          widget.customFunctionOnTap;
        },
        child: Container(
          width: 280,
          height: 140,
          padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 100,
                width: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 6),
                    Text("남은 횟수",
                        style: TextStyle(color: Palette.gray66, fontSize: 12)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "${widget.ticketCountLeft}",
                          style: TextStyle(
                              color: widget.ticketCountLeft == 0
                                  ? Palette.gray99
                                  : Palette.textOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: widget.ticketCountAll >= 100 ? 20 : 28),
                        ),
                        Text(
                          "/",
                          style: TextStyle(
                              color: widget.ticketCountLeft == 0
                                  ? Palette.gray99
                                  : Palette.textOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: widget.ticketCountAll >= 100 ? 20 : 28),
                        ),
                        Text(
                          "${widget.ticketCountAll}",
                          style: TextStyle(
                              color: Palette.gray99,
                              fontSize: widget.ticketCountAll >= 100 ? 20 : 28),
                        )
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      ticketDateLeft > 0
                          ? "(D+${ticketDateLeft})"
                          : "(D-${ticketDateLeft.abs()})",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: ticketDateLeft <= 14
                              ? Palette.textRed
                              : Palette.gray66),
                    ),
                  ],
                ),
              ),
              Container(
                  width: 1, color: Palette.grayEE, height: double.infinity),
              Container(
                  width: 160,
                  padding: EdgeInsets.only(left: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${widget.ticketTitle}",
                          style: TextStyle(
                              color: Palette.gray00,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      SizedBox(height: 5),
                      Text(
                        "${widget.ticketDescription}",
                        style: TextStyle(fontSize: 12, color: Palette.gray66),
                      ),
                      SizedBox(height: 10),
                      Text("시작일: ${widget.ticketStartDate}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          )),
                      Row(
                        children: [
                          Text("종료일: ${widget.ticketEndDate}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              )),
                        ],
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    ).animate(target: _toggle ? 1 : 0).scaleXY(end: 0.95, duration: 100.ms);
  }
}

/// 티켓 추가하기 버튼 위젯
class AddTicketWidget extends StatefulWidget {
  final String label;
  final Function customFunctionOnTap;
  final bool addIcon;

  const AddTicketWidget({
    Key? key,
    required this.customFunctionOnTap,
    required this.label,
    required this.addIcon,
  }) : super(key: key);

  @override
  State<AddTicketWidget> createState() => _AddTicketWidgetState();
}

class _AddTicketWidgetState extends State<AddTicketWidget> {
  bool _toggle = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(width: 2, color: Palette.grayEE)),
        child: InkWell(
          onTapDown: (details) {
            setState(() {
              _toggle = true;
            });
          },
          onTapUp: (details) {
            setState(() {
              _toggle = false;
            });
          },
          onTap: () {
            widget.customFunctionOnTap();
          },
          child: Container(
            width: 280,
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${widget.label}",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Palette.gray99),
                ),
                if (widget.addIcon)
                  Icon(
                    Icons.add_circle_outline,
                    color: Palette.gray99,
                  )
                else
                  SizedBox()
              ],
            ),
          ),
        ),
      ).animate(target: _toggle ? 1 : 0).scaleXY(end: 0.95, duration: 100.ms),
    );
  }
}
