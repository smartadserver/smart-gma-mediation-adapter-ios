Smart AdServer - Google Mobile Ads SDK Adapter
==============================================

Introduction
------------
The _Smart Display SDK_ can be used through _Google Mobile Ads SDK_ using the adapter provided in this repository for banner and interstitial. Those adapters are compatible with the _Smart Display SDK_ v6.10.

Setup
-----

1) Install the _Google Mobile Ads SDK_ according to the official documentation https://developers.google.com/admob/ios/download.

2) Install the _Smart Display SDK_ by adding the _pod_ `SmartAdServer-DisplaySDK` to your app _Podfile_ (more info in [the documentation](http://help.smartadserver.com/ios/V6.10/#IntegrationGuides/InstallationCocoapods.htm)).

3) Checkout this repository and copy the files you need into your Xcode Project:

- `SASGMACustomEventConstants.h` in any cases.
- `SASAdView+GMA` in any cases.
- `SASGMACustomEventBanner` for banner ads.
- `SASGMACustomEventInterstitial` for interstitial ads.

4) Edit the `SASGMACustomEventConstants.h` header and replace the default base URL with your dedicated base URL.

5) You can now declare _SDK Mediation Creatives_ in the _Google Mobile Ads_ interface. To setup the _Custom Event_ (under _Ad networks_), you need to fill:

- the _Parameter_ field: set your _Smart AdServer_ IDs using slash separator `[siteID]/[pageID]/[formatID]`
- the _Class Name_ field: set `SASGADCustomEventBanner` for banners or `SASGADCustomEventInterstitial` for interstitials.


More infos
----------
You can find more informations about the _Smart Display SDK_ and the _Google Mobile Ads SDK_ in the official documentation:
http://documentation.smartadserver.com/displaySDK
