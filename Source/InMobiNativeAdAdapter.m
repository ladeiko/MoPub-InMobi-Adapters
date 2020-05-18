//
//  InMobiNativeAdapter.m
//  MoPub-InMobi-Adapters
//
//  Created by Niranjan Agrawal on 28/10/15.
//
//
#import "InMobiNativeAdAdapter.h"

#import <InMobiSDK/IMSdk.h>

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MPNativeAdError.h"
    #import "MPNativeAdConstants.h"
    #import "MPAdDestinationDisplayAgent.h"
    #import "MPCoreInstanceProvider.h"
    #import "MPLogging.h"
#endif

//Default keys for InMobi Native Ads
//These values must correspond to the strings configured with InMobi.

static NSString *gInMobiTitleKey = @"title";
static NSString *gInMobiDescriptionKey = @"description";
static NSString *gInMobiCallToActionKey = @"cta";
static NSString *gInMobiPrimaryAdViewKey = @"primaryAdView";
static NSString *gInMobiRatingKey = @"rating";
static NSString *gInMobiScreenshotKey = @"screenshots";
static NSString *gInMobiIconKey = @"icon";
// As of 6-25-2014 this key is editable on InMobi's site
static NSString *gInMobiLandingURLKey = @"landingURL";

//InMobi Key - Do Not Change.
static NSString *const kInMobiImageURL = @"url";

@implementation InMobiNativeAdAdapter

@synthesize properties = _properties;
@synthesize defaultActionURL = _defaultActionURL;

+ (void)setCustomKeyForTitle:(NSString *)key {
    gInMobiTitleKey = [key copy];
}

+ (void)setCustomKeyForDescription:(NSString *)key {
    gInMobiDescriptionKey = [key copy];
}

+ (void)setCustomKeyForCallToAction:(NSString *)key {
    gInMobiCallToActionKey = [key copy];
}

+ (void)setCustomKeyForPrimaryAdView:(NSString *)key {
    gInMobiPrimaryAdViewKey = [key copy];
}

+ (void)setCustomKeyForRating:(NSString *)key {
    gInMobiRatingKey = [key copy];
}

+ (void)setCustomKeyForScreenshot:(NSString *)key {
    gInMobiScreenshotKey = [key copy];
}

+ (void)setCustomKeyForIcon:(NSString *)key {
    gInMobiIconKey = [key copy];
}

+ (void)setCustomKeyForLandingURL:(NSString *)key {
    gInMobiLandingURLKey = [key copy];
}

- (instancetype)initWithInMobiNativeAd:(IMNative *)nativeAd {
    self = [super init];
    if (self) {
        self.nativeAd = nativeAd;
        self.nativeAd.delegate = self;
        
        NSDictionary *inMobiProperties = [self inMobiProperties];
        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
        
        if ([self.nativeAd adRating]) {
            [properties setObject:[self.nativeAd adRating] forKey:kAdStarRatingKey];
        }
        
        if ([[self.nativeAd adTitle] length]) {
            [properties setObject:[self.nativeAd adTitle] forKey:kAdTitleKey];
        }
        
        if ([[self.nativeAd adDescription] length]) {
            [properties setObject:[self.nativeAd adDescription] forKey:kAdTextKey];
        }

        if ([[self.nativeAd adCtaText] length]) {
            [properties setObject:[self.nativeAd adCtaText] forKey:kAdCTATextKey];
        }

        NSDictionary *iconDictionary = [inMobiProperties objectForKey:gInMobiIconKey];

        if ([[iconDictionary objectForKey:kInMobiImageURL] length]) {
            [properties setObject:[iconDictionary objectForKey:kInMobiImageURL] forKey:kAdIconImageKey];
        }

        _properties = properties;

        if ([self.nativeAd adLandingPageUrl]) {
            _defaultActionURL = [self.nativeAd adLandingPageUrl];
        } else {
            // Log a warning if we can't find the landing URL since the key can either be "landing_url", "landingURL", or a custom key depending on the date the property was created.
            MPLogWarn(@"WARNING: Couldn't find landing url with key: %@ for InMobi network.  Double check your ad property and call setCustomKeyForLandingURL: with the correct key if necessary.", gInMobiLandingURLKey);
        }
    }
    return self;
}

- (NSDictionary *)inMobiProperties {
    NSData *data = [self.nativeAd.customAdContent dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error = nil;
    NSDictionary *propertyDictionary = nil;
    if (data) {
        propertyDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    }
    if (propertyDictionary && !error) {
        return propertyDictionary;
    }
    else {
        return nil;
    }
}

#pragma mark - <MPStaticNativeAdImpressionTimerDelegate>

- (void)trackImpression {
    [self.delegate nativeAdWillLogImpression:self];
}

#pragma mark - <MPNativeAdAdapter>

- (void)trackClick {
    [self.nativeAd reportAdClickAndOpenLandingPage];
}

- (void)displayContentForURL:(NSURL *)URL rootViewController:(UIViewController *)controller {
    if (!controller) {
        return;
    }
    
    if (!URL || ![URL isKindOfClass:[NSURL class]] || ![URL.absoluteString length]) {
        return;
    }
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self) strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if ([strongSelf.delegate respondsToSelector:@selector(nativeAdDidClick:)]) {
                MPLogEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)]);
                [strongSelf.delegate nativeAdDidClick:strongSelf];
            }
            
            [strongSelf.delegate nativeAdWillPresentModalForAdapter:self];
        }
    });
}

- (void)willAttachToView:(UIView *)view
{
    MPLogEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)]);
    MPLogEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)]);
    MPLogEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)]);
    MPLogEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)]);
    
    [self.delegate nativeAdWillLogImpression:self];
    self.adView = view;
}

- (UIView *)mainMediaView {
    return [self.nativeAd primaryViewOfWidth:[self viewControllerForPresentingModalView].view.frame.size.width];
}


#pragma mark - <MPAdDestinationDisplayAgentDelegate>

- (UIViewController *)viewControllerForPresentingModalView {
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)displayAgentWillPresentModal {
    [self.delegate nativeAdWillPresentModalForAdapter:self];
}

- (void)displayAgentWillLeaveApplication {
    [self.delegate nativeAdWillLeaveApplicationFromAdapter:self];
}

- (void)displayAgentDidDismissModal {
    [self.delegate nativeAdDidDismissModalForAdapter:self];
}

#pragma mark - <IMNativeDelegate>

- (void)nativeDidFinishLoading:(IMNative*)native{
    MPLogEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)]);
}

- (void)native:(IMNative*)native didFailToLoadWithError:(IMRequestStatus*)error{
    MPLogEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error]);
}

- (void)nativeWillPresentScreen:(IMNative*)native{
    MPLogEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)]);
    [self.delegate nativeAdWillPresentModalForAdapter:self];
}

- (void)nativeDidPresentScreen:(IMNative*)native{
    MPLogEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)]);
}

- (void)nativeWillDismissScreen:(IMNative*)native{
    MPLogEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)]);
}

- (void)nativeDidDismissScreen:(IMNative*)native{
    MPLogEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)]);
    [self.delegate nativeAdDidDismissModalForAdapter:self];
}

- (void)userWillLeaveApplicationFromNative:(IMNative*)native{
    MPLogEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)]);
    [self.delegate nativeAdWillLeaveApplicationFromAdapter:self];
}

- (void)native:(IMNative *)native didInteractWithParams:(NSDictionary *)params{
    MPLogEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)]);
}

- (void)nativeAdImpressed:(IMNative *)native{
    MPLogInfo(@"InMobi impression tracked successfully");
    [self.delegate nativeAdWillLogImpression:self];
}

- (void)nativeDidFinishPlayingMedia:(IMNative*)native{
    MPLogInfo(@"[InMobi]Native video did finish playing media");
}

- (void)userDidSkipPlayingMediaFromNative:(IMNative *)native { 
    MPLogInfo(@"[InMobi]User did skip the media from Native AD");
}

- (void)native:(IMNative *)native rewardActionCompletedWithRewards:(NSDictionary *)rewards{
    MPLogInfo(@"[InMobi]Native reward action completed with rewards: %@", [rewards description]);
}

@end
