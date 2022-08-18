//
//  Communicator.h
//  
//
//  Created by Lakr Aream on 2022/8/14.
//

#import <Foundation/Foundation.h>

@interface Communicator : NSObject

+ (NSData* _Nullable )retrieveParentData;
+ (void)sendRecipeDataAndExit:(NSString* _Nonnull)base64String;

@end

