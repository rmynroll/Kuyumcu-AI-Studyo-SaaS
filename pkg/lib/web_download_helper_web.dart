import 'dart:js' as js;

/// Web platformunda resmi indirmek için JavaScript eval fonksiyonunu çağırır.
void downloadImageWeb(String url) {
  js.context.callMethod('eval', [
    "var a = document.createElement('a'); a.href = '$url'; a.download = 'kuyumcu-ai-studyo.jpg'; document.body.appendChild(a); a.click(); document.body.removeChild(a);"
  ]);
}
