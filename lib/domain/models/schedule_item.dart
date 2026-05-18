import 'package:equatable/equatable.dart';

class ScheduleItem extends Equatable {
  const ScheduleItem({
    required this.timeLabel,
    required this.title,
    required this.description,
  });

  final String timeLabel;
  final String title;
  final String description;

  @override
  List<Object> get props => [timeLabel, title, description];
}
