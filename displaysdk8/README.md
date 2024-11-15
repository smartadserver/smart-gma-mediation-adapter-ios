Equativ - Google Mobile Ads SDK Adapter
==============================================

Introduction
------------
The _Equativ Display SDK_ can be used through _Google Mobile Ads SDK_ using the adapter provided in this repository for banner, interstitial and native ads. Those adapters are compatible with:

* _Equativ Display SDK_ v8.0+
* _Google Mobile Ads SDK_ v11.5.0

Setup
-----

1) Install the _Google Mobile Ads SDK_ according to the official documentation https://developers.google.com/admob/ios/download.

2) Install the _Equativ Display SDK_ by adding the _pod_ `Equativ-Display-SDK` to your app _Podfile_ (more info in [the documentation](https://documentation.smartadserver.com/displaySDK/ios/gettingstarted.html)).

3) Checkout this repository and copy the files you need into your Xcode Project:

* `SASGMAUtils` in any cases.
* `SASGMABannerAdapter` for banner ads.
* `SASGMAInterstitialAdapter` for interstitial ads.
* `SASGMANativeAdapter` for native ads.

4) You can now declare _SDK Mediation Creatives_ in the _Google Mobile Ads_ interface. To setup the _Custom Event_ (under _Ad networks_), you need to fill:

- the _Parameter_ field: set your _Smart AdServer_ IDs using slash separator `[siteID]/[pageID]/[formatID]`
- the _Class Name_ field: set `SASGMABannerAdapter` for banners, `SASGMAInterstitialAdapter` for interstitials or `SASGMANativeAdapter` for native ads.

5) If you intend to use keyword targeting in your Smart insertions, typically if you want it to match any custom targeting you have set-up on Google Ad Manager interface, you will need to set it on Google ad requests in your application.

For banner, interstitial and native ad, this is done by using `GADRequest`'s `keywords` attribut. For instance, for banner case, if your Equativ insertion uses "myCustomBannerTargeting" string on any Equativ programmed banner insertion:
```
let request = GADRequest()
request.keywords = ["myCustomBannerTargeting", "and", "additional", "keywords"]
bannerView.load(request)
```

As you can see, you can set-up multiples keywords, they will be concatenated before making the ad call via _Equativ Display SDK_.


More infos
----------
You can find more informations about the _Equativ Display SDK_ and the _Google Mobile Ads SDK_ in the official documentation:
https://documentation.smartadserver.com/displaySDK
