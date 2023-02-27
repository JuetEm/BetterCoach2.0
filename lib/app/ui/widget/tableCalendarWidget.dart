import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:web_project/app/data/model/color.dart';
import 'package:web_project/app/data/provider/calendar_service.dart';

class TableCalendarWidget extends StatefulWidget {
  TableCalendarWidget(
      {Key? key,
      required this.selectedDate,
      required this.customFunctionOnDaySelected})
      : super(key: key);

  final String selectedDate;
  final Function customFunctionOnDaySelected;
  @override
  State<TableCalendarWidget> createState() => _TableCalendarWidgetState();
}

class _TableCalendarWidgetState extends State<TableCalendarWidget> {
  Map<DateTime, List<Event>> events = {
    DateTime.utc(2022, 7, 13): [Event('title'), Event('title2')],
    DateTime.utc(2022, 7, 14): [Event('title3')],
  };

  List<Event> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  // 달력 보여주는 형식
  CalendarFormat calendarFormat = CalendarFormat.month;
  // 선택된 날짜
  DateTime selectedDateIn = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  DateTime focusedDate = DateTime.now();

  @override
  void initState() {
    if (widget.selectedDate == "") {
      selectedDateIn = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
    } else {
      // DateTime selectedDateIn;
      selectedDateIn = new DateFormat('yyyy-MM-dd').parse(widget.selectedDate);
    }

    print(
        "[GF] getDateFromCalendar - selectedDateIn 선택날짜 / ${selectedDateIn.toString()}");
    focusedDate = selectedDateIn;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarService>(
        builder: (context, calendarService, child) {
      return TableCalendar(
        rowHeight: 44,
        focusedDay: focusedDate,
        firstDay: DateTime.now().subtract(Duration(days: 365 * 10 + 2)),
        lastDay: DateTime.now().add(Duration(days: 365 * 10 + 2)),
        calendarFormat: calendarFormat,
        calendarStyle: CalendarStyle(
          todayDecoration:
              BoxDecoration(color: Palette.titleOrange, shape: BoxShape.circle),
          selectedDecoration: BoxDecoration(
              color: Palette.buttonOrange, shape: BoxShape.circle),
          rangeHighlightColor: Palette.buttonOrange,
          markerSize: 10.0,
          markerDecoration: BoxDecoration(
              color: Palette.buttonOrange, shape: BoxShape.circle),
        ),
        eventLoader: _getEventsForDay,
        onFormatChanged: ((format) {
          setState(() {
            calendarFormat = format;
          });
        }),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            selectedDateIn = selectedDay;
            focusedDate = focusedDay;
            widget.customFunctionOnDaySelected;
          });
          calendarService.setDate(
            DateTime(
              focusedDate.year,
              focusedDate.month,
              focusedDate.day,
            ),
          );
          // 저장하기 성공시 MemberAdd로 이동
          //  calendarService.currentSelectedDate());
        },
        selectedDayPredicate: (day) {
          return isSameDay(selectedDateIn, day);
        },
        // calendarIsOffStaged = true;
      );
    });
  }
}

class Event {
  String title;

  Event(this.title);
}
