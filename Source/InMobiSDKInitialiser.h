//
//  InMobiSDKInitialiser.h
//  MoPub-InMobi-Adapters
//
//  Created by Ankit Pandey on 05/06/19.
//  Updated by Siarhei Ladzeika on 18/May/2020
//

#import <Foundation/Foundation.h>

#define RUN_SYNC_ON_MAIN_THREAD(Stuff) \
if ([NSThread currentThread].isMainThread) { \
do { \
Stuff; \
} while (0); \
} \
else { \
dispatch_sync(dispatch_get_main_queue(), ^(void) { \
do { \
Stuff; \
} while (0); \
}); \
}

typedef enum {
    kIMIncorrectAccountID,
    kIMIncorrectPlacemetID
} IMErrorCode;

extern NSString * const kIMErrorDomain;
extern NSString * const kIMPlacementID;
extern NSString * const kIMAccountID;

@interface InMobiSDKInitialiser : NSObject

/**
* Initialises the InMobi SDK with InMobi's Account ID extracted from info dictionary
*/
+ (void)initialiseSdkWithInfo:(NSDictionary*)info withCompletion:(void (^)(NSError* error))completion;

/**
 * Checks if the InMobi SDK is already initialised or not
 */
+ (BOOL)isSDKInitialised;

/**
 * @discussion Update the consent Dictionary in the SDK
 */
+ (void)updateGDPRConsent;

@end
