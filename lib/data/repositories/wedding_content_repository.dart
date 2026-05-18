import '../../domain/models/schedule_item.dart';
import '../../domain/models/wedding_content.dart';

class WeddingContentRepository {
  Future<WeddingContent> fetchContent() {
    return Future<WeddingContent>.value(
      WeddingContent(
        coupleNames: 'Edgar & Gabriela',
        weddingDate: DateTime(2027, 8, 28, 16),
        heroImageUrl:
            'https://images.unsplash.com/photo-1522673607200-164d1b6ce486?auto=format&fit=crop&w=1400&q=80',
        story:
            'From a coffee shop conversation to a lifetime promise, Edgar and Gabriela have built a love rooted in laughter, faith, and adventure. This celebration is our love letter to family and friends who have been part of the journey.',
        schedule: [
          ScheduleItem(
            timeLabel: '3:30 PM',
            title: 'Guest Arrival & Garden Welcome',
            description:
                'Signature lemonade, acoustic strings, and guest seating.',
          ),
          ScheduleItem(
            timeLabel: '4:00 PM',
            title: 'Ceremony',
            description: 'Vows and ring exchange at the Rose Terrace.',
          ),
          ScheduleItem(
            timeLabel: '5:00 PM',
            title: 'Cocktail Hour',
            description:
                'Passed appetizers with live jazz under the lantern trees.',
          ),
          ScheduleItem(
            timeLabel: '6:30 PM',
            title: 'Dinner Reception',
            description:
                'Three-course dinner and heartfelt toasts in the Grand Hall.',
          ),
          ScheduleItem(
            timeLabel: '8:15 PM',
            title: 'First Dance & Celebration',
            description: 'Dancing, dessert bar, and midnight espresso cart.',
          ),
        ],
        galleryImageUrls: [
          'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1522673607200-164d1b6ce486?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1529636798458-92182e662485?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1473177104440-ffee2f376098?auto=format&fit=crop&w=900&q=80',
        ],
        videoUrl: 'https://samplelib.com/lib/preview/mp4/sample-10s.mp4',
      ),
    );
  }
}
