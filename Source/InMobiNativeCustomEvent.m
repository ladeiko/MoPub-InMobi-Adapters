//
//  InMobiNativeCustomEvent.m
//  MoPub-InMobi-Adapters
//
//  Created by Niranjan Agrawal on 28/10/15.
//  Updated by Siarhei Ladzeika on 18/May/2020
//

#import <Foundation/Foundation.h>
#import "InMobiNativeCustomEvent.h"
#import "InMobiNativeAdAdapter.h"
#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MPNativeAd.h"
    #import "MPLogging.h"
    #import "MPNativeAdError.h"
    #import "MPNativeAdConstants.h"
    #import "MPNativeAdUtils.h"
    #import "MPConstants.h"
#endif

#import <InMobiSDK/IMSdk.h>

#import "InMobiGDPR.h"
#import "InMobiSDKInitialiser.h"
#import "InMobyAdapterUtils.h"

static NSString *gAppId = nil;

@interface InMobiNativeCustomEvent ()

@property (nonatomic, strong) IMNative *nativeAd;
@property (nonatomic, strong) InMobiNativeAdAdapter *adAdapter;

@end

@implementation InMobiNativeCustomEvent

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {

    void (^action)(void) = [^{
        long long placementId = [caseInSensitiveGet(info, kIMPlacementID) longLongValue];
        if(placementId <= 0) {
            NSError* error = [NSError errorWithDomain:kIMErrorDomain code:kIMIncorrectPlacemetID userInfo:@{NSLocalizedDescriptionKey: @"Native ad initialization skipped. The placementID is incorrect." }];
            [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
            return;
        }
        self.nativeAd = [[IMNative alloc] initWithPlacementId:placementId];

        // Mandatory params to be set by the publisher to identify the supply source type
        NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
        [paramsDict setObject:@"c_mopub" forKey:@"tp"];
        [paramsDict setObject:MP_SDK_VERSION forKey:@"tp-ver"];

        //Make sure to have the below line commented before the app is released.
        /*
         Sample for setting up the InMobi SDK Demographic params.
         Publisher need to set the values of params as they want.

         [IMSdk setAreaCode:@"1223"];
         [IMSdk setEducation:kIMSDKEducationHighSchoolOrLess];
         [IMSdk setGender:kIMSDKGenderMale];
         [IMSdk setAge:12];
         [IMSdk setPostalCode:@"234"];
         [IMSdk setLogLevel:kIMSDKLogLevelDebug];
         [IMSdk setLocationWithCity:@"BAN" state:@"KAN" country:@"IND"];
         [IMSdk setLanguage:@"ENG"];
         */

        self.nativeAd.extras = paramsDict; // For supply source identification
        self.nativeAd.delegate = self;
        RUN_SYNC_ON_MAIN_THREAD([self.nativeAd load];)
    } copy];

    if(![InMobiSDKInitialiser isSDKInitialised]){
        [InMobiSDKInitialiser initialiseSdkWithInfo:info withCompletion:^(NSError *error) {
            if(error) {
                MPLogInfo(@"Inmobi's adapter failed to initialise with error:%@. kindly pass correct accountID",error);
                [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
                return;
            }
            action();
        }];
    }
    else {
        [InMobiSDKInitialiser updateGDPRConsent];
        action();
    }
}

#pragma mark - IMNativeDelegate

- (void)nativeDidFinishLoading:(IMNative *)imnative {
    MPLogEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)]);
    MPLogInfo(@"[InMobi] custom ad content:%@",[imnative customAdContent]);
    
    self.adAdapter = [[InMobiNativeAdAdapter alloc] initWithInMobiNativeAd:imnative];
    MPNativeAd *interfaceAd = [[MPNativeAd alloc] initWithAdAdapter:self.adAdapter];
    [self.delegate nativeCustomEvent:self didLoadAd:interfaceAd];
}

- (void)native:(IMNative*)native didFailToLoadWithError:(IMRequestStatus*)error {
    MPLogEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error]);
    [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:MPNativeAdNSErrorForInvalidAdServerResponse(error.description)];
}

- (void)nativeAdImpressed:(IMNative *)native{
    MPLogInfo(@"InMobi impression tracked successfully");
    [self.adAdapter.delegate nativeAdWillLogImpression:self.adAdapter];
}

- (void)nativeWillPresentScreen:(IMNative*)native{
    MPLogEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)]);
}

- (void)nativeDidPresentScreen:(IMNative*)native{
    MPLogEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)]);
}

- (void)nativeWillDismissScreen:(IMNative*)native{
    MPLogEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)]);
}

- (void)nativeDidDismissScreen:(IMNative*)native{
    MPLogEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)]);
}

- (void)userWillLeaveApplicationFromNative:(IMNative*)native{
    MPLogEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)]);
}

- (void)native:(IMNative *)native didInteractWithParams:(NSDictionary *)params{
    MPLogEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)]);
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

- (void)native:(IMNative*)native adAudioStateChanged:(BOOL)audioStateMuted {
    MPLogInfo(@"[InMobi]Native audio state of ad, audioStateMuted:%d",audioStateMuted);
}

@end
