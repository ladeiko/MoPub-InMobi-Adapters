//
//  InMobiRewardedCustomEvent.h
//  MoPub-InMobi-Adapters
//
//  Created by Niranjan Agrawal on 28/10/15.
//
//

#ifndef InMobiRewardedCustomEvent_h
#define InMobiRewardedCustomEvent_h


#endif /* InMobiRewardedCustomEvent_h */

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MPFullscreenAdAdapter.h"
#endif

@interface InMobiRewardedCustomEvent : MPFullscreenAdAdapter <MPThirdPartyFullscreenAdAdapter>

@end
