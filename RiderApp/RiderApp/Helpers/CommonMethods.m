//
//  CommonMethods.m
//  DriverApp
//
//  Created by Gursharan Singh on 09/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommonMethods.h"

@implementation CommonMethods

//To generate an unique ID for the device, we have to create our own now, because we don't get UDID of the device any more in IOS5
+ (NSString *)uniqueDeviceID {
    NSString *deviceID = nil;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"GeneratedDeviceID"]) {
        //Check if we already have our device ID saved.
        deviceID = [[NSUserDefaults standardUserDefaults] objectForKey:@"GeneratedDeviceID"];
    }
    else {
        //if not generate a new one
        deviceID = [self generatedeviceID];
        [[NSUserDefaults standardUserDefaults] setObject:deviceID forKey:@"GeneratedDeviceID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return deviceID;
}


+ (NSString *)generatedeviceID {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"9ddyyhhmmss9"];  
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    [formatter release];
    int random = (arc4random()%1111);
    return [dateString stringByAppendingFormat:@"%d", random];
}



@end
