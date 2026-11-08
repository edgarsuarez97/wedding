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
            description: 'Bebidas de bienvenida y acomodo de invitados.',
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
          'assets/images/galeria/foto-01.webp',
          'assets/images/galeria/foto-02.webp',
          'assets/images/galeria/foto-03.webp',
          'assets/images/galeria/foto-04.webp',
          'assets/images/galeria/foto-05.webp',
          'assets/images/galeria/foto-06.webp',
          'assets/images/galeria/foto-07.webp',
          'assets/images/galeria/foto-08.webp',
          'assets/images/galeria/foto-09.webp',
          'assets/images/galeria/foto-10.webp',
          'assets/images/galeria/foto-11.webp',
          'assets/images/galeria/foto-12.webp',
          'assets/images/galeria/foto-13.webp',
          'assets/images/galeria/foto-14.webp',
          'assets/images/galeria/foto-15.webp',
          'assets/images/galeria/foto-16.webp',
        ],
        videoUrl: 'https://samplelib.com/lib/preview/mp4/sample-10s.mp4',
      ),
    );
  }
}
