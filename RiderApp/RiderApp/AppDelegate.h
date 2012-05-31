//
//  AppDelegate.h
//  RiderApp
//
//  Created by Gursharan Singh on 30/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate> {
    UINavigationController *navigationController;
    UIView *loadingView;
    UIActivityIndicatorView *loader;
    CLLocationManager *mLocationManager;
    float latitudeVal;
    float longitudeVal;
    int locationManagerCount;

}

@property (retain, nonatomic) UIWindow *window;
@property (retain, nonatomic) UINavigationController *navigationController;

@property (nonatomic, retain) CLLocationManager *mLocationManager;
@property (nonatomic, assign) float latitudeVal;
@property (nonatomic, assign) float longitudeVal;

- (void)showAlertWithMessage: (NSString *)message;
-(void) showLoadingIndicator;
-(void) hideLoadingIndicator;
- (BOOL)isInternetAvailable;
- (void)handleNotification: (NSDictionary *)userInfo;
- (void)updateTheLocation;

@end
