//
//  AppDelegate.h
//  DriverApp
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
    
    NSTimer *locUpdatingTimer;
    BOOL isTimerOn;
    BOOL isAppRunning;
}

@property (retain, nonatomic) UIWindow *window;
@property (retain, nonatomic) UINavigationController *navigationController;

@property (nonatomic, retain) CLLocationManager *mLocationManager;
@property (nonatomic, assign) float latitudeVal;
@property (nonatomic, assign) float longitudeVal;

-(void) showLoadingIndicator;
-(void) hideLoadingIndicator;
- (void)showAlertWithMessage: (NSString *)message;

- (void)updateTheLocation;
- (void)locationUpdatingTimer;
- (void)stopTimers;
- (void)handleNotification: (NSDictionary *)userInfo;
- (BOOL)isInternetAvailable;

@end
