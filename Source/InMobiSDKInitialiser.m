//
//  InMobiSDKInitialiser.m
//  MoPub-InMobi-Adapters
//
//  Created by Ankit Pandey on 05/06/19.
//  Updated by Siarhei Ladzeika on 18/May/2020
//

#import "InMobiSDKInitialiser.h"
#import "InMobiGDPR.h"
#import <InMobiSDK/IMSdk.h>
#import "InMobyAdapterUtils.h"

NSString * const kIMErrorDomain = @"com.inmobi.mopubcustomevent.iossdk";
NSString * const kIMPlacementID = @"placementid";
NSString * const kIMAccountID = @"accountid";

@implementation InMobiSDKInitialiser

static BOOL isAccountInitialised = false;
static NSMutableArray* completions = nil;

+ (void)initialiseSdkWithInfo:(NSDictionary*)info withCompletion:(void (^)(NSError* error))completion {

    dispatch_async(dispatch_get_main_queue(), ^(void) {

        if (isAccountInitialised) {
            completion(nil);
            return;
        }

        if (!completions) {
            completions = [NSMutableArray new];
        }

        [completions addObject:[completion copy]];

        if ([completions count] > 1) {
            return;
        }

        void (^complete)(NSError*) = ^(NSError* error) {

            NSArray* callbacks = [completions copy];
            [completions removeAllObjects];

            [callbacks enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                void (^completion)(NSError* error) = obj;
                completion(error);
            }];
        };

        if (![[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(window)]) {
            NSError* error = [NSError errorWithDomain:kIMErrorDomain code:kIMIncorrectAccountID userInfo:@{ NSLocalizedDescriptionKey: @"Inmobi requires AppDelegate to implement window property"}];
            complete(error);
            return;
        }

        NSString* const accountId = [caseInSensitiveGet(info, kIMAccountID) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(accountId == nil || ![InMobiSDKInitialiser isValidAccountID:accountId]) {
            NSError* error = [NSError errorWithDomain:kIMErrorDomain code:kIMIncorrectAccountID userInfo:@{ NSLocalizedDescriptionKey: @"Inmobi's adapter failed to initialize because of invalid or empty accountId.."}];
            complete(error);
            return;
        }

        NSDictionary *gdprConsentObject = [InMobiGDPR getGDPRConsentDictionary];
        //InMobi SDK initialization with the account id setup @Mopub dashboard

        [IMSdk initWithAccountID:accountId consentDictionary:gdprConsentObject andCompletionHandler:^(NSError * _Nullable error) {
            isAccountInitialised = !error;
            RUN_SYNC_ON_MAIN_THREAD(complete(error);)
        }];
    });

}

+ (BOOL)isValidAccountID:(NSString *)accountID {
    if ([accountID isKindOfClass:[NSString class]] && ([accountID length] == 32 || [accountID length] == 36)) {
        return YES;
    }
    return NO;
}

+ (BOOL)isSDKInitialised {
    return isAccountInitialised;
}

+ (void)updateGDPRConsent {
    [IMSdk updateGDPRConsent:[InMobiGDPR getGDPRConsentDictionary]];
}

@end
