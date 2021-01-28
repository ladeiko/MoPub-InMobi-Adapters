//
//  InMobiBannerCustomEvent.h
//  MoPub-InMobi-Adapters
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MPInlineAdAdapter.h"
#endif

@interface InMobiBannerCustomEvent : MPInlineAdAdapter <MPThirdPartyInlineAdAdapter>

@end
