import 'package:equatable/equatable.dart';

import 'schedule_item.dart';

class WeddingContent extends Equatable {
  const WeddingContent({
    required this.coupleNames,
    required this.weddingDate,
    required this.heroImageUrl,
    required this.story,
    required this.schedule,
    required this.galleryImageUrls,
    required this.videoUrl,
  });

  final String coupleNames;
  final DateTime weddingDate;
  final String heroImageUrl;
  final String story;
  final List<ScheduleItem> schedule;
  final List<String> galleryImageUrls;
  final String videoUrl;

  @override
  List<Object> get props => [
    coupleNames,
    weddingDate,
    heroImageUrl,
    story,
    schedule,
    galleryImageUrls,
    videoUrl,
  ];
}
