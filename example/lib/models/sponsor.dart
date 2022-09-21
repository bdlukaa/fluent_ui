/// Current sponsors of the project <3
const sponsors = [
  Sponsor(
    username: 'bariccattion',
    imageUrl: 'https://avatars.githubusercontent.com/u/19714408?v=4',
    name: 'Rafael Gongora Bariccatti',
  ),
  Sponsor(
    username: 'h3x4d3c1m4l',
    imageUrl: 'https://avatars.githubusercontent.com/u/2611894?v=4',
    name: 'Sander in \'t Hout',
  ),
  Sponsor(
    username: 'phorcys420',
    imageUrl: 'https://avatars.githubusercontent.com/u/57866459?v=4',
    name: 'Phorcys',
  ),
  Sponsor(
    username: 'whiplashoo',
    imageUrl: 'https://avatars.githubusercontent.com/u/9117427?v=4',
    name: 'Minas Giannekas',
  ),
  Sponsor(
    username: 'TimeLord2010',
    imageUrl: 'https://avatars.githubusercontent.com/u/50129092?v=4',
    name: 'Vinícius Velloso',
  ),
  Sponsor(
    username: 'henry2man',
    imageUrl: 'https://avatars.githubusercontent.com/u/4610108?v=4',
    name: 'Enrique Cardona',
  ),
];

class Sponsor {
  final String? username;
  final String name;
  final String imageUrl;

  const Sponsor({
    required this.username,
    required this.name,
    required this.imageUrl,
  });

  Sponsor copyWith({
    String? username,
    String? name,
    String? imageUrl,
  }) {
    return Sponsor(
      username: username ?? this.username,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  String toString() =>
      'Sponsor(username: $username, name: $name, imageUrl: $imageUrl)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Sponsor &&
        other.username == username &&
        other.name == name &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode => username.hashCode ^ name.hashCode ^ imageUrl.hashCode;
}
