//
//  InMobiRewardedCustomEvent.m
//  MoPub-InMobi-Adapters
//
//  Updated by Siarhei Ladzeika on 18/May/2020
//

#import <Foundation/Foundation.h>
#import "InMobiRewardedCustomEvent.h"
#import "InMobiGDPR.h"
#import "InMobiSDKInitialiser.h"
#import "InMobyAdapterUtils.h"

@import MoPubSDK;
@import InMobiSDK;

@interface InMobiRewardedCustomEvent ()<IMInterstitialDelegate>

@property (nonatomic, strong) IMInterstitial *interstitialAd;

@end


@implementation InMobiRewardedCustomEvent

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    MPLogInfo(@"Requesting InMobi Rewarded interstitial");

    void (^action)(void) = [^{
        long long placementId = [caseInSensitiveGet(info, kIMPlacementID) longLongValue];
        if(placementId <= 0) {
            NSError* error = [NSError errorWithDomain:kIMErrorDomain code:kIMIncorrectPlacemetID userInfo:@{NSLocalizedDescriptionKey: @"Rewarded Intestitial initialization skipped. The placementID is incorrect." }];
            [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
            //[self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
            return;
        }
        self.interstitialAd = [[IMInterstitial alloc] initWithPlacementId:placementId];
        self.interstitialAd.delegate = self;

        //Mandatory params to be set by the publisher to identify the supply source type
        NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
        [paramsDict setObject:@"c_mopub" forKey:@"tp"];
        [paramsDict setObject:MP_SDK_VERSION forKey:@"tp-ver"];

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

        self.interstitialAd.extras = paramsDict; // For supply source identification
        RUN_SYNC_ON_MAIN_THREAD([self.interstitialAd load];)
    } copy];

    if(![InMobiSDKInitialiser isSDKInitialised]) {
        [InMobiSDKInitialiser initialiseSdkWithInfo:info withCompletion:^(NSError *error) {
            if(error) {
                MPLogInfo(@"Inmobi's adapter failed to initialise with error:%@. kindly pass correct accountID",error);
                [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
                //[self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
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

- (BOOL)isRewardExpected {
    return YES;
}

- (BOOL)hasAdAvailable {
    if (self.interstitialAd!=NULL && [self.interstitialAd isReady]) {
        return true;
    }
    return false;
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController {

    if([self hasAdAvailable]) {
        [self.interstitialAd showFromViewController:viewController withAnimation:kIMInterstitialAnimationTypeCoverVertical];
    }
    else {
         NSError *error = [NSError errorWithDomain:MoPubRewardedAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
//         [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
    }
}

- (BOOL)enableAutomaticImpressionAndClickTracking{
    return YES;
}

- (void)handleCustomEventInvalidated{
    //Do nothing
}

#pragma mark - IMInterstitialDelegate

-(void)interstitialDidFinishLoading:(IMInterstitial*)interstitial {
    MPLogEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)]);
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
//    [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
}

- (void)interstitial:(IMInterstitial *)interstitial didReceiveWithMetaInfo:(IMAdMetaInfo *)metaInfo {
    MPLogInfo(@"[InMobi] InMobi Ad Server responded with an Rewarded Interstitial ad");
}

-(void)interstitial:(IMInterstitial*)interstitial didFailToLoadWithError:(IMRequestStatus*)error {
    MPLogEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error]);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
    //[self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:(NSError*)error];
}

-(void)interstitialWillPresent:(IMInterstitial*)interstitial {
    MPLogEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)]);
    [self.delegate fullscreenAdAdapterAdWillAppear:self];
//    [self.delegate rewardedVideoWillAppearForCustomEvent:self];
}

-(void)interstitialDidPresent:(IMInterstitial *)interstitial {
    MPLogEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)]);
    [self.delegate fullscreenAdAdapterAdDidAppear:self];
//    [self.delegate rewardedVideoDidAppearForCustomEvent:self];
}

-(void)interstitial:(IMInterstitial*)interstitial didFailToPresentWithError:(IMRequestStatus*)error {
    MPLogEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error]);
    [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
//    [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:(NSError *)error];
}

-(void)interstitialWillDismiss:(IMInterstitial*)interstitial {
    MPLogEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)]);
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
//    [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
}

-(void)interstitialDidDismiss:(IMInterstitial*)interstitial {
    MPLogEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)]);
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
//    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
}

-(void)interstitial:(IMInterstitial*)interstitial didInteractWithParams:(NSDictionary*)params {
    MPLogEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)]);
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
//    [self.delegate rewardedVideoDidReceiveTapEventForCustomEvent:self];
}

-(void)interstitial:(IMInterstitial*)interstitial rewardActionCompletedWithRewards:(NSDictionary*)rewards {
    if(rewards!=nil){
        MPLogInfo(@"InMobi reward action completed with rewards: %@", [rewards description]);
        MPReward *reward = [[MPReward alloc] initWithCurrencyType:kMPRewardCurrencyTypeUnspecified amount:[rewards allValues][0]];
        [self.delegate fullscreenAdAdapter:self willRewardUser:reward];
//        [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:(MPRewardedVideoReward*)reward];
    }
}

-(void)userWillLeaveApplicationFromInterstitial:(IMInterstitial*)interstitial {
    MPLogEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)]);
    [self.delegate fullscreenAdAdapterWillLeaveApplication:self];
//    [self.delegate rewardedVideoWillLeaveApplicationForCustomEvent:self];
}

@end
