/// Where an image can be loaded from.
///
/// [asset] is always bundled with the app (seed images), so the UI can show
/// something on a first launch without network. [url] is optional and, when
/// set, is loaded through the disk cache.
final class ImageRef {
  const ImageRef({required this.asset, this.url});

  final String asset;
  final String? url;

  @override
  bool operator ==(Object other) =>
      other is ImageRef && other.asset == asset && other.url == url;

  @override
  int get hashCode => Object.hash(asset, url);
}
