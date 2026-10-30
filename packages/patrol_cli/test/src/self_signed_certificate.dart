import 'dart:convert';
import 'dart:io';

/// A [SecurityContext] for a local https server in tests, with a self-signed
/// certificate for localhost and 127.0.0.1 that nothing trusts.
///
/// Test-only; the key is public. Listed in `false_secrets` in pubspec.yaml;
/// update that entry if this file moves, or `dart pub publish` fails on the
/// key. Regenerate with:
///
/// ```sh
/// openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -nodes \
///   -days 36500 -subj /CN=localhost \
///   -addext subjectAltName=DNS:localhost,IP:127.0.0.1 \
///   -keyout key.pem -out cert.pem
/// ```
SecurityContext selfSignedSecurityContext() => SecurityContext()
  ..useCertificateChainBytes(utf8.encode(_certificate))
  ..usePrivateKeyBytes(utf8.encode(_privateKey));

const _certificate = '''
-----BEGIN CERTIFICATE-----
MIIBmjCCAUGgAwIBAgIUbGDOP2RkXqRH6M29TTlVOaUIhNowCgYIKoZIzj0EAwIw
FDESMBAGA1UEAwwJbG9jYWxob3N0MCAXDTI2MTAyNzE2NDkzNVoYDzIxMjYxMDAz
MTY0OTM1WjAUMRIwEAYDVQQDDAlsb2NhbGhvc3QwWTATBgcqhkjOPQIBBggqhkjO
PQMBBwNCAATo182uQrdKIR44V6GtasQucUfScY3LYXF55WpboPtSRsPrOmuRatGa
gaBICNyHsGabApUgrBJhot4gm5BG4ZX0o28wbTAdBgNVHQ4EFgQUUglMXj0NRK0s
4X8kLDsFWwYUmAIwHwYDVR0jBBgwFoAUUglMXj0NRK0s4X8kLDsFWwYUmAIwDwYD
VR0TAQH/BAUwAwEB/zAaBgNVHREEEzARgglsb2NhbGhvc3SHBH8AAAEwCgYIKoZI
zj0EAwIDRwAwRAIgecrwh5qje9JXeAMcPnZGLi0qbwW7QuNoRtAR7TiFeBUCIHF5
VJP9sTbKceOyx6ke+9Lm5YAfNwb7XKukxhxzzkGY
-----END CERTIFICATE-----
''';

const _privateKey = '''
-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQggfDB7ztN7uBqaesi
HOx3OY+uiPG6YNohBBWSN2Pf2MyhRANCAATo182uQrdKIR44V6GtasQucUfScY3L
YXF55WpboPtSRsPrOmuRatGagaBICNyHsGabApUgrBJhot4gm5BG4ZX0
-----END PRIVATE KEY-----
''';
