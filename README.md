Smart AdServer - Google Mobile Ads SDK Adapter
==============================================

Introduction
------------
The _Smart Display SDK_ can be used through _Google Mobile Ads SDK_ using the adapter provided in this repository for banner, interstitial and rewarded video. Those adapters are compatible with the _Smart Display SDK_ v7.0.

Setup
-----

1) Install the _Google Mobile Ads SDK_ according to the official documentation https://developers.google.com/admob/ios/download.

2) Install the _Smart Display SDK_ by adding the _pod_ `Smart-Display-SDK` to your app _Podfile_ (more info in [the documentation](http://documentation.smartadserver.com/displaySDK/ios/gettingstarted.html)).

3) Checkout this repository and copy the files you need into your Xcode Project:

- `SASGMACustomEventConstants.h` in any cases.
- `SASGMAUtils` in any cases.
- `SASGMACustomEventBanner` for banner ads.
- `SASGMACustomEventInterstitial` for interstitial ads.
- `SASGMARewardedAdapter` for rewarded video ads.

4) Edit the `SASGMACustomEventConstants.h` header and replace the default base URL with your dedicated base URL.

5) You can now declare _SDK Mediation Creatives_ in the _Google Mobile Ads_ interface. To setup the _Custom Event_ (under _Ad networks_), you need to fill:

- the _Parameter_ field: set your _Smart AdServer_ IDs using slash separator `[siteID]/[pageID]/[formatID]`
- the _Class Name_ field: set `SASGMACustomEventBanner` for banners, `SASGMACustomEventInterstitial` for interstitials or `SASGMARewardedAdapter` for rewarded videos.


More infos
----------
You can find more informations about the _Smart Display SDK_ and the _Google Mobile Ads SDK_ in the official documentation:
http://documentation.smartadserver.com/displaySDK
