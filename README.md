Smart AdServer - Google Ads Mobile SDK Adapter for iOS
==============================================

Introduction
------------
The _Smart AdServer iOS SDK_ can be used through _Google Ads Mobile SDK (DFP)_ using the adapter provided in this repository for both _SASBannerView_ and _SASInterstitialView_.

Setup
-----

To start using the _Smart AdServer iOS SDK_ through DFP, simply add all the classes included in this repository in your project (**the Xcode projects needs to contain a correctly installed _Smart AdServer SDK_**).

You can declares _SDK Mediation Creatives_ in the _DFP_ interface. To setup the _Custom Event_ (under _Ad networks_), you need to fill:

* the _Parameter_ field: set your _Smart AdServer_ IDs using slash separator `[siteID]/[pageID]/[formatID]`
* the _Class Name_ field: set `SASGADCustomEventBanner` for banners and `SASGADCustomEventInterstitial` for interstitials

More infos
----------
You can find more informations about the _Smart AdServer iOS SDK_ and the _Google Ads Mobile Mediation Adapters_ in the official documentation:
http://help.smartadserver.com/en/
