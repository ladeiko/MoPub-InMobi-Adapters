//
//  InMobyAdapterUtils.h
//  MoPub-InMobi-Adapters
//
//  Created by Sergey Ladeiko on May/15/20.
//

#import <Foundation/Foundation.h>

NS_INLINE id caseInSensitiveGet(NSDictionary* dict, NSString* key) {
    NSString* const lowercasedKey = [key lowercaseString];
    NSString* const found = [[[dict allKeys] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [[evaluatedObject lowercaseString] isEqualToString:lowercasedKey];
    }]] firstObject];
    return found ? [dict objectForKey: found] : nil;
}
