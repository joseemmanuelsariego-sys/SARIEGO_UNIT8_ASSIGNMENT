// STARTER FILE: given to students as-is. Read it, then run with your CMS:
//
//   Strapi:     flutter run --dart-define=CMS=strapi
//                           --dart-define=CMS_URL=http://localhost:1337
//                           (add --dart-define=CMS_TOKEN=... if Public can't read)
//   Contentful: flutter run --dart-define=CMS=contentful
//                           --dart-define=CMS_SPACE=your-space-id
//                           --dart-define=CMS_TOKEN=your-delivery-token
//   Sanity:     flutter run --dart-define=CMS=sanity
//                           --dart-define=CMS_PROJECT=your-project-id
//                           (add --dart-define=CMS_DATASET=... if not production)
//
// Tip: put the values in a file such as cms.json (and add it to .gitignore):
//   { "CMS": "strapi", "CMS_URL": "http://localhost:1337" }
// then run: flutter run --dart-define-from-file=cms.json
import 'package:http/http.dart' as http;

import 'data/cms/contentful_source.dart';
import 'data/cms/sanity_source.dart';
import 'data/cms/strapi_source.dart';
import 'data/event_source.dart';
import 'data/sample_events.dart';

// EXPLAIN E2: These values are put into the app when it is built. Is
// CMS_TOKEN a secret once the app is on someone's phone or on the web?
// What kind of token is safe to put here, and what kind never is?
const cmsName = String.fromEnvironment('CMS');
const cmsUrl = String.fromEnvironment('CMS_URL');
const cmsSpace = String.fromEnvironment('CMS_SPACE');
const cmsProject = String.fromEnvironment('CMS_PROJECT');
const cmsDataset = String.fromEnvironment(
  'CMS_DATASET',
  defaultValue: 'production',
);
const cmsToken = String.fromEnvironment('CMS_TOKEN');

/// Picks the event source from the --dart-define values.
/// Without CMS=..., the app uses the built-in sample events.
EventSource createEventSource(http.Client client) {
  return switch (cmsName) {
    'strapi' => StrapiEventSource(client, baseUrl: cmsUrl, token: cmsToken),
    'contentful' => ContentfulEventSource(
      client,
      spaceId: cmsSpace,
      token: cmsToken,
    ),
    'sanity' => SanityEventSource(
      client,
      projectId: cmsProject,
      dataset: cmsDataset,
      token: cmsToken,
    ),
    _ => SampleEventSource(),
  };
}
