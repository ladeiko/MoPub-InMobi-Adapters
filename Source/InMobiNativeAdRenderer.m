//
//  InMobiNativeAdRenderer.m
//  MoPub-InMobi-Adapters
//
//  Created by Iti Agrawal on 13/09/19.
//

#import "InMobiNativeAdRenderer.h"

#import <InMobiSDK/IMSdk.h>
#if __has_include("MoPub.h")
#import "MPLogging.h"
#import "MPNativeAdAdapter.h"
#import "MPNativeAdConstants.h"
#import "MPNativeAdError.h"
#import "MPNativeAdRendererConfiguration.h"
#import "MPNativeAdRendering.h"
#import "MPNativeAdRenderingImageLoader.h"
#import "MPNativeView.h"
#import "MPStaticNativeAdRendererSettings.h"
#import "MPURLRequest.h"
#import "MPHTTPNetworkSession.h"
#import "MPMemoryCache.h"
#endif
#import "InMobiNativeAdAdapter.h"


@interface InMobiNativeAdRenderer ()

@property (nonatomic, strong) UIView<MPNativeAdRendering> *adView;
@property (nonatomic) BOOL adViewInViewHierarchy;
@property (nonatomic, strong) InMobiNativeAdAdapter *adapter;
@property (nonatomic, strong) Class renderingViewClass;

@end

@implementation InMobiNativeAdRenderer
//@synthesize viewSizeHandler = _viewSizeHandler;

- (instancetype)initWithRendererSettings:(id<MPNativeAdRendererSettings>)rendererSettings {
    if(self = [super init]) {
        MPStaticNativeAdRendererSettings *settings = (MPStaticNativeAdRendererSettings *)rendererSettings;
        _renderingViewClass = settings.renderingViewClass;
        _viewSizeHandler = [settings.viewSizeHandler copy];
    }
    return self;
}

+ (MPNativeAdRendererConfiguration *)rendererConfigurationWithRendererSettings:(id<MPNativeAdRendererSettings>)rendererSettings {
    MPNativeAdRendererConfiguration* config = [[MPNativeAdRendererConfiguration alloc] init];
    config.rendererClass = [self class];
    config.rendererSettings = rendererSettings;
    config.supportedCustomEvents = @[@"InMobiNativeCustomEvent"];
    return config;
}

- (UIView *)retrieveViewWithAdapter:(id<MPNativeAdAdapter>)adapter error:(NSError *__autoreleasing *)error {
    if (!adapter || ![adapter isKindOfClass:[InMobiNativeAdAdapter class]]) {
        if (error) {
            *error = MPNativeAdNSErrorForRenderValueTypeError();
        }
        return nil;
    }
    
    self.adapter = (InMobiNativeAdAdapter *)adapter;
    
    if ([self.renderingViewClass respondsToSelector:@selector(nibForAd)]) {
       self.adView = (UIView<MPNativeAdRendering> *)[[[self.renderingViewClass nibForAd]
           instantiateWithOwner:nil
                        options:nil] firstObject];
     } else {
         self.adView = [[self.renderingViewClass alloc] init];
     }

     self.adView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
     MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], nil);
     MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], nil);
     [self renderUnifiedAdViewWithAdapter:self.adapter];
    return self.adView;
}

// Creates Unified Native AdView with adapter.
- (void)renderUnifiedAdViewWithAdapter:(id<MPNativeAdAdapter>)adapter {
   if ([self.adView respondsToSelector:@selector(nativeTitleTextLabel)]) {
       self.adView.nativeTitleTextLabel.text = [adapter.properties objectForKey:kAdTitleKey];
   }
   
   if ([self.adView respondsToSelector:@selector(nativeMainTextLabel)]) {
       self.adView.nativeMainTextLabel.text = [adapter.properties objectForKey:kAdTextKey];
   }
   
   if ([self.adView respondsToSelector:@selector(nativeCallToActionTextLabel)]) {
       self.adView.nativeCallToActionTextLabel.text = [adapter.properties objectForKey:kAdCTATextKey];
   }
   
   if ([self.adView respondsToSelector:@selector(nativeCallToActionTextLabel)]) {
       self.adView.nativeCallToActionTextLabel.text = [adapter.properties objectForKey:kAdCTATextKey];
   }
   
   if ([self.adView respondsToSelector:@selector(layoutStarRating:)]) {
       NSNumber *starRatingNum = [adapter.properties objectForKey:kAdStarRatingKey];
       
       if ([starRatingNum isKindOfClass:[NSNumber class]] && starRatingNum.floatValue >= kStarRatingMinValue && starRatingNum.floatValue <= kStarRatingMaxValue) {
           [self.adView layoutStarRating:starRatingNum];
       }
   }
   
   if ([self.adView respondsToSelector:@selector(nativeMainImageView)]) {
       UIView *mediaView = [adapter.properties objectForKey:kAdMainMediaViewKey];
       UIView *mainImageView = [self.adView nativeMainImageView];
       
       mediaView.frame = mainImageView.bounds;
       mediaView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
       mediaView.userInteractionEnabled = YES;
       mainImageView.userInteractionEnabled = YES;
       
       [mainImageView addSubview:mediaView];
   }
   
   if ([self.adView respondsToSelector:@selector(nativeIconImageView)]) {
       UIView *iconImageView = [self.adView nativeIconImageView];
       iconImageView.userInteractionEnabled = YES;
   }
   
   if ([self.adView respondsToSelector:@selector(nativeVideoView)]) {
       UIView *mediaView = [adapter.properties objectForKey:kVASTVideoKey];
       UIView *videoView = [self.adView nativeVideoView];
       
       mediaView.frame = videoView.bounds;
       mediaView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
       mediaView.userInteractionEnabled = YES;
       videoView.userInteractionEnabled = YES;
       
       [videoView addSubview:mediaView];
   }
}

- (void)adViewWillMoveToSuperview:(UIView *)superview
{
    self.adViewInViewHierarchy = (superview != nil);
    
    if (superview) {
        if ([self.adView respondsToSelector:@selector(layoutCustomAssetsWithProperties:imageLoader:)]) {
            [self.adView layoutCustomAssetsWithProperties:self.adapter.properties imageLoader:nil];
        }
    }
}


@end
