import 'package:flutter/cupertino.dart';

class ImagesUtil {

  getThumb(String url) {
    List<String> urlList =List<String>();

    var cut = url.lastIndexOf('&');
    url = url.substring(0, cut);
    url = url.replaceAll('Profile%2F', 'Profile%2Fprofile%2Fthumbs%2F');
    var index = url.lastIndexOf('.');
    urlList.add( url.substring(0,index));
    urlList.add('_400x400');
    urlList.add( url.substring(index, url.length));
    Uri.decodeFull('${urlList}');

    return urlList.join();
  }
}
