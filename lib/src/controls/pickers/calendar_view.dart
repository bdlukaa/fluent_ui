import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';

enum CalendarViewDisplayMode { month, year, decade }

class CalendarView extends StatelessWidget {
  const CalendarView({
    Key? key,
    this.onChanged,
    this.currentDate,
    this.displayMode = CalendarViewDisplayMode.month,
    this.min,
    this.max,
  }) : super(key: key);

  final CalendarViewDisplayMode displayMode;

  final DateTime? currentDate;
  final DateTime? min;
  final DateTime? max;

  final ValueChanged<DateTime>? onChanged;

  @override
  Widget build(BuildContext context) {
    // return m.CalendarDatePicker(
    //   firstDate: DateTime(2000),
    //   initialDate: DateTime.now(),
    //   lastDate: DateTime.now().add(Duration(days: 1000)),
    //   onDateChanged: (v) {
    //     print(v);
    //   },
    // );
    debugCheckHasFluentTheme(context);
    final currentDate = this.currentDate ?? DateTime.now();
    final style = context.theme;
    return Container(
      width: 300,
      decoration: BoxDecoration(
        border: Border.all(
          color: style.disabledColor ?? Colors.transparent,
        ),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Theme(
            data: style.copyWith(Style(
              iconButtonStyle: style.iconButtonStyle?.copyWith(IconButtonStyle(
                margin: EdgeInsets.zero,
                decoration: (_) =>
                    BoxDecoration(borderRadius: BorderRadius.zero),
              )),
            )),
            child: Row(children: [
              Expanded(
                child: Text(
                  DateFormat.yMMMM().format(currentDate),
                  style: style.typography?.subtitle,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_up),
                onPressed: () {
                  onChanged?.call(currentDate.add(Duration(days: 30)));
                },
              ),
              IconButton(
                icon: Icon(Icons.chevron_down),
                onPressed: () {
                  onChanged?.call(currentDate.subtract(Duration(days: 30)));
                },
              ),
            ]),
          ),
        ),
        Row(
          children: () {
            final days = List.generate(7, (index) {
              return DateFormat('EEEE').format(DateTime(2021, 03, index + 1));
            });
            return List.generate(days.length, (index) {
              return Expanded(
                child: Text(
                  days[index].substring(0, 2),
                  textAlign: TextAlign.center,
                  style: style.typography?.caption,
                ),
              );
            });
          }(),
        ),
      ]),
    );
  }
}
