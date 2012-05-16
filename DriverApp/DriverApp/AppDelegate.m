//
//  AppDelegate.m
//  DriverApp
//
//  Created by Gursharan Singh on 30/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "SignUpViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "HomeViewController.h"
#import "ASIFormDataRequest.h"
#import "CommonMethods.h"
#import "NSString+SBJSON.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize navigationController;
@synthesize latitudeVal;
@synthesize longitudeVal;
@synthesize mLocationManager;

- (void)dealloc
{
    [navigationController release];
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    UIViewController *viewController = nil;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"registeredOnServer"]) {
        viewController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    }
    else {
        viewController = [[SignUpViewController alloc] initWithNibName:@"SignUpViewController" bundle:nil];
    }
    
    self.navigationController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
    self.navigationController.navigationBarHidden = YES;
    [viewController release];
    
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];
    
    // Register for notifications
    [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound| UIRemoteNotificationTypeBadge)];  

    // Handle the notification at launch
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo != nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"To Test Notification: %@", userInfo] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    
    
    [self updateTheLocation];
    return YES;
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // UALOG(@"APN device token: %@", deviceToken);
    // Updates the device token and registers the token with UA
    NSString* newToken = [deviceToken description];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[NSUserDefaults standardUserDefaults] setObject:newToken forKey:@"APNS_Token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// Copy and paste this method into your AppDelegate to recieve push
// notifications for your application while the app is running.
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"To Test Notification: %@", userInfo] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark - Loader Methods

//Create Loading Indicator object to be shown, when web-service calls etc are made.
-(void) showLoadingIndicator
{
	if(loadingView == nil)
	{
		loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 120)];
        loadingView.center = self.window.center;
        
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, loadingView.frame.size.width, 35)];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:18.6];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"Driver App";
        [loadingView addSubview:label];
        [label release];
        
        loadingView.layer.cornerRadius = 10;
        loadingView.layer.borderColor = [[UIColor whiteColor] CGColor];
        loadingView.layer.borderWidth = 3;
		loadingView.backgroundColor = [UIColor blackColor];
		loadingView.alpha = 0.81;	
		loader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		loader.center = CGPointMake(loadingView.frame.size.width/2, loadingView.frame.size.height/2);
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, loader.center.y+15, loadingView.frame.size.width, 30)];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:15];
        label.text = @"Please Wait..";
        label.backgroundColor = [UIColor clearColor];
        [loadingView addSubview:label];
        [label release];
        
		[loader startAnimating];
		[loadingView addSubview:loader];
		[self.window addSubview:loadingView];
	}
}

//Hide the loading indicator
-(void) hideLoadingIndicator {
	if(loadingView !=nil) {
		[loader stopAnimating];
		[loader release];
		loader = nil;	
		[loadingView removeFromSuperview];
		[loadingView release];
		loadingView = nil;
	}
}

#pragma mark - Location Related

- (void)updateTheLocation {
    if (!mLocationManager) {
        self.mLocationManager.delegate = nil;
        self.mLocationManager = nil;
        CLLocationManager *locMngr = [[CLLocationManager alloc] init];
        self.mLocationManager = locMngr;
        self.mLocationManager.delegate = self;
        self.mLocationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
        self.mLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.mLocationManager.delegate = self;
        [locMngr release];
    }
    else {
        self.mLocationManager.delegate = self;
    }
    [self.mLocationManager startUpdatingLocation];
}

#pragma mark locationManager delegate
-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
    NSDate *eventDate = newLocation.timestamp; 
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow]; 
    if (abs(howRecent) < 5.0) { 
        self.latitudeVal = newLocation.coordinate.latitude;
        self.longitudeVal = newLocation.coordinate.longitude;
    }
}

-(void) locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error
{
    [self showAlertWithMessage:[error localizedDescription]];
    [self.mLocationManager stopUpdatingLocation];
    self.mLocationManager.delegate = nil;
    self.mLocationManager = nil;
}

- (void)showAlertWithMessage: (NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"TaxiRider App" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}


#pragma mark - Update Location On server periodically

- (void)locationUpdatingTimer {
    locUpdatingTimer = [[NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(sendCurrentLocationToServer) userInfo:nil repeats:YES] retain];
}

- (void)stopTimers {
    if (locUpdatingTimer && [locUpdatingTimer isValid]) {
        [locUpdatingTimer invalidate];
        [locUpdatingTimer release];
        locUpdatingTimer = nil;
    }
}

- (void)sendCurrentLocationToServer {
    NSString *requestUrlString = hostURL;
    //Creating the HTTP Request and setting the required post values
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestUrlString]];
    [request setPostValue:@"driver" forKey:@"axn"];
    [request setPostValue:@"newlocation" forKey:@"code"];
    [request setPostValue:[CommonMethods uniqueDeviceID] forKey:@"deviceid"];
    NSString *locString = [NSString stringWithFormat:@"%f,%f", self.latitudeVal, self.longitudeVal];
    
    [request setPostValue:locString forKey:@"location"];
    [request setTimeOutSeconds:200];
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(uploadReportFinished:)];
    [request setDidFailSelector:@selector(uploadReportFailed:)];
    [request startAsynchronous];
    
}

//If request fails, show an alert to the user and hide the indicator view
- (void)uploadReportFailed:(ASIHTTPRequest *)request {
    NSLog(@"uploadReportFailed: %@", [request responseString]);
    [self showAlertWithMessage:@"Sending Location to Server failed, Please try again later."];
}

//If request finishes, hide the loading indicator and pass him to the next view
- (void)uploadReportFinished: (ASIHTTPRequest *)request {
    NSLog(@"Response: %@", [request responseString]);
    NSDictionary *dict = [[request responseString] JSONValue];
    if ([[dict valueForKey:@"returnCode"] intValue] == 0) { //Everything was fine on server.
       
    }
    else {
        [self showAlertWithMessage:[NSString stringWithFormat:@"Error from Server: %@", [dict valueForKey:@"error"]]];
    }
}



@end
