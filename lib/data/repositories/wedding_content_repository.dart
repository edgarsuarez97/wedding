import '../../domain/models/schedule_item.dart';
import '../../domain/models/wedding_content.dart';

class WeddingContentRepository {
  Future<WeddingContent> fetchContent() {
    return Future<WeddingContent>.value(
      WeddingContent(
        coupleNames: 'Gabriela & Edgar',
        weddingDate: DateTime(2027, 8, 28, 16),
        heroImageUrl: 'assets/images/portada-escritorio.jpg',
        heroMobileImageUrl: 'assets/images/portada-movil.jpg',
        story:
            'Desde nuestra primera conversación, en un lugar donde ninguno pensó que estaría ese día, a una promesa de una vida entera, hemos crecido juntos amándonos entre risas y aventura. Nos quedan muchísimas aventuras por vivir, y nos hace muy felices contar con ustedes en esta ocasión, la familia y los amigos que han sido parte del camino.',
        schedule: [
          ScheduleItem(
            timeLabel: '3:00 PM',
            title: 'Llegada de invitados',
            description:
                'Bebidas de bienvenida y acomodo de invitados.',
          ),
          ScheduleItem(
            timeLabel: '4:00 PM',
            title: 'Ceremonia',
            description: 'Votos e intercambio de anillos en la terraza.',
          ),
          ScheduleItem(
            timeLabel: '5:00 PM',
            title: 'Hora del cóctel',
            description: 'Abrebocas y fotos grupales.',
          ),
          ScheduleItem(
            timeLabel: '7:00 PM',
            title: 'Recepción y cena',
            description: 'Cena y brindis.',
          ),
          ScheduleItem(
            timeLabel: '8:15 PM',
            title: 'Primer baile y celebración',
            description: 'Bailaremos hasta que el cuerpo aguante.',
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
