// Optional mock server for the J'Donuts app.
//
//   cd mock_server && dart pub get && dart run bin/server.dart [--port 8080] [--price-bump 100]
//
// Serves the public catalog from ../assets/seed/seed.json under /v1 with a
// {data, error, meta} envelope, plus /images/<file> from ../assets/images.
// --price-bump adds kyats to every price so a refresh is easy to see.
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

const _apiVersion = 'v1';

Future<void> main(List<String> args) async {
  final port = int.parse(_option(args, '--port') ?? '8080');
  final priceBump = int.parse(_option(args, '--price-bump') ?? '0');
  // Run from the mock_server folder; the app's assets are one level up.
  final root = Directory.current.parent;
  final seedFile = File('${root.path}/assets/seed/seed.json');
  if (!seedFile.existsSync()) {
    stderr.writeln('Run me from jdonuts_app/mock_server (no ${seedFile.path}).');
    exit(64);
  }
  final imagesDir = Directory('${root.path}/assets/images');

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler((request) => _route(request, seedFile, imagesDir, priceBump));
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  stdout.writeln('J\'Donuts mock server on http://${server.address.host}:${server.port}/$_apiVersion');
}

String? _option(List<String> args, String name) {
  final i = args.indexOf(name);
  return i >= 0 && i + 1 < args.length ? args[i + 1] : null;
}

Future<Response> _route(Request request, File seed, Directory images, int priceBump) async {
  final segments = request.url.pathSegments;
  if (request.method != 'GET') return _error(405, 'method_not_allowed', 'Only GET is supported');
  if (segments.length == 2 && segments.first == 'images') {
    return _image(images, segments[1]);
  }
  if (segments.length != 2 || segments.first != _apiVersion) {
    return _error(404, 'not_found', 'Unknown path /${request.url.path}');
  }
  final json = jsonDecode(await seed.readAsString()) as Map<String, dynamic>;
  return switch (segments[1]) {
    'health' => _ok({'status': 'ok'}),
    'products' => _ok(_bumpPrices(json['products'] as List<dynamic>, priceBump)),
    'banners' => _ok(json['banners']),
    'sections' => _ok(json['sections']),
    'shops' => _ok(json['shops']),
    _ => _error(404, 'not_found', 'Unknown resource ${segments[1]}'),
  };
}

List<dynamic> _bumpPrices(List<dynamic> products, int bump) => [
      for (final p in products.cast<Map<String, dynamic>>())
        {...p, 'priceMmk': (p['priceMmk'] as int) + bump},
    ];

Response _ok(Object? data) => Response.ok(
      jsonEncode({
        'data': data,
        'error': null,
        'meta': {'version': 1, 'generatedAt': DateTime.now().toUtc().toIso8601String()},
      }),
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

Response _error(int status, String code, String message) => Response(
      status,
      body: jsonEncode({
        'data': null,
        'error': {'code': code, 'message': message},
        'meta': null,
      }),
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

Future<Response> _image(Directory images, String name) async {
  final file = File('${images.path}/$name');
  if (name.contains('..') || !await file.exists()) {
    return _error(404, 'not_found', 'No image $name');
  }
  return Response.ok(file.openRead(), headers: {'content-type': 'image/png'});
}
