import '../../domain/models/schedule_item.dart';
import '../../domain/models/wedding_content.dart';

class WeddingContentRepository {
  Future<WeddingContent> fetchContent() {
    return Future<WeddingContent>.value(
      WeddingContent(
        coupleNames: 'Gabriela & Edgar',
        weddingDate: DateTime(2027, 8, 28, 16),
        heroImageUrl:
            'https://images.unsplash.com/photo-1522673607200-164d1b6ce486?auto=format&fit=crop&w=1400&q=80',
        story:
            'Desde una conversación en una cafetería hasta una promesa para toda la vida, Edgar y Gabriela han construido un amor lleno de risas, fé y aventura. Esta celebración es nuestra carta de amor para la familia y los amigos que han sido parte del camino.',
        schedule: [
          ScheduleItem(
            timeLabel: '3:30 PM',
            title: 'Llegada de invitados y bienvenida en el jardín',
            description:
                'Limonada de la casa, cuerdas acústicas y acomodo de invitados.',
          ),
          ScheduleItem(
            timeLabel: '4:00 PM',
            title: 'Ceremonia',
            description: 'Votos e intercambio de anillos en la Terraza Rosa.',
          ),
          ScheduleItem(
            timeLabel: '5:00 PM',
            title: 'Hora del cóctel',
            description:
                'Botanas al centro y jazz en vivo bajo los árboles iluminados.',
          ),
          ScheduleItem(
            timeLabel: '6:30 PM',
            title: 'Recepción y cena',
            description:
                'Cena de tres tiempos y brindis emotivos en el Gran Salón.',
          ),
          ScheduleItem(
            timeLabel: '8:15 PM',
            title: 'Primer baile y celebración',
            description:
                'Baile, mesa de postres y carrito de café de medianoche.',
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
