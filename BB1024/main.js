 (function() {
  document.getElementById("header").remove();
  document.getElementsByClassName("t")[0].remove();
  var link = document.body.textContent.match(/(http:\/\/www\.rmdown\.com\/link\.php\?hash=\w+)/g);
  if (link != null) {
  var url = link[0].split("=")[1].slice(3).substring(0, 40);
  window.webkit.messageHandlers.NativeInterface.postMessage({url: url});
  } else {
  window.webkit.messageHandlers.NativeInterface.postMessage({url: ""});
  }
  })()
