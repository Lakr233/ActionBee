//
//  Communicator.m
//  
//
//  Created by Lakr Aream on 2022/8/14.
//

#import "Communicator.h"

NSData *argumentData;

__attribute__((constructor)) void communicator_constructor(void) {
    NSString *message = [NSProcessInfo.processInfo.environment valueForKey:@"Communicator_Message"];
    if (message.length <= 0) { return; }
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:message options:NULL];
    if (data == NULL || data.length <= 0) { return; }
    
    argumentData = data;
}

@implementation Communicator

+ (NSData*)retrieveParentData {
    return argumentData;
}

+ (void)sendRecipeDataAndExit:(NSString*)base64String {
    NSLog(@"\nActionBee-Result-Recipe://%@", base64String);
    exit(0);
}

@end
