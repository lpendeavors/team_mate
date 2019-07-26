import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TeamMateDateTimeDropdown extends StatefulWidget {
  const TeamMateDateTimeDropdown({
    Key key,
    this.labelText,
    this.selectedDate,
    this.selectDate,
  }) : super(key: key);

  final String labelText;
  final DateTime selectedDate;
  final ValueChanged<DateTime> selectDate;

  @override
  _TeamMateDateTimeDropdownState createState() => _TeamMateDateTimeDropdownState();
}

class _TeamMateDateTimeDropdownState extends State<TeamMateDateTimeDropdown> {
  DateTime _shownDate = DateTime.now();
  TimeOfDay _shownTime = TimeOfDay.fromDateTime(DateTime.now());

  Future<void> _selectDate(BuildContext context) async {
    final DateTime date = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate,
      firstDate: DateTime(2019),
      lastDate: DateTime(2100),
    );
    if (date != null && date != widget.selectedDate) {
      setState(() {
        _shownDate = date;
      });
      final TimeOfDay time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(date),
      );
      if (time != null) {
        setState(() {
          _shownTime = time;
        });
        var due = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        widget.selectDate(due);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle = Theme.of(context).textTheme.title;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          flex: 4,
          child: _InputDropdown(
            labelText: widget.labelText,
            valueText: DateFormat.yMMMd().format(_shownDate),
            valueStyle: valueStyle,
            onPressed: () { _selectDate(context); },
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          flex: 3,
          child: _InputDropdown(
            valueText: _shownTime.format(context),
            valueStyle: valueStyle,
          ),
        ),
      ],
    );
  }
}

class _InputDropdown extends StatelessWidget {
  const _InputDropdown({
    Key key,
    this.child,
    this.labelText,
    this.valueText,
    this.valueStyle,
    this.onPressed,
  }) : super(key: key);

  final String labelText;
  final String valueText;
  final TextStyle valueStyle;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          border: InputBorder.none,
        ),
        baseStyle: valueStyle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(valueText, style: valueStyle),
            Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}