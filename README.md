Smart AdServer - Google Mobile Ads SDK Adapter
==============================================

Introduction
------------
The _Smart Display SDK_ can be used through _Google Mobile Ads SDK_ using the adapter provided in this repository for banner, interstitial and rewarded video. Those adapters are compatible with the _Smart Display SDK_ v7.15.

Setup
-----

1) Install the _Google Mobile Ads SDK_ according to the official documentation https://developers.google.com/admob/ios/download.

2) Install the _Smart Display SDK_ by adding the _pod_ `Smart-Display-SDK` to your app _Podfile_ (more info in [the documentation](https://documentation.smartadserver.com/displaySDK/ios/gettingstarted.html)).

3) Checkout this repository and copy the files you need into your Xcode Project:

- `SASGMAUtils` in any cases.
- `SASGMABannerAdapter` for banner ads.
- `SASGMAInterstitialAdapter` for interstitial ads.
- `SASGMARewardedAdapter` for rewarded video ads.
- `SASGMANativeAdapter` for native ads ads.

4) You can now declare _SDK Mediation Creatives_ in the _Google Mobile Ads_ interface. To setup the _Custom Event_ (under _Ad networks_), you need to fill:

- the _Parameter_ field: set your _Smart AdServer_ IDs using slash separator `[siteID]/[pageID]/[formatID]`
- the _Class Name_ field: set `SASGMABannerAdapter` for banners, `SASGMAInterstitialAdapter` for interstitials or `SASGMARewardedAdapter` for rewarded videos.

5) If you intend to use keyword targeting in your Smart insertions, typically if you want it to match any custom targeting you have set-up on Google Ad Manager interface, you will need to set it on Google ad requests in your application.

For Banner, Interstitial and Native-Ad, this is done by using `GADRequest`'s `keywords` attribut. For instance, for banner case, if your smart insertion uses "myCustomBannerTargeting" string on any Smart programmed banner insertion:
```
let request = GADRequest()
request.keywords = ["myCustomBannerTargeting", "and", "additional", "keywords"]
bannerView.load(request)
```

For Rewarded Video, this is done by registering extra on `GADRequest` instance using our `SASGMAAdNetworkExtra` class. For instance, if your smart insertion uses "myCustomTargeting" string on any Smart programmed rewarded video insertion:
```
let request = GADRequest()
request.register(SASGMAAdNetworkExtra(keywords: ["myCustomTargeting", "and", "additional", "keywords"]))
GADRewardedAd.load(withAdUnitID: "yourAddUnitID", request: request)
```

As you can see, in both solution you can set-up multiples keywords, they will be concatenated before making the ad call via _Smart Display SDK_.


More infos
----------
You can find more informations about the _Smart Display SDK_ and the _Google Mobile Ads SDK_ in the official documentation:
https://documentation.smartadserver.com/displaySDK
