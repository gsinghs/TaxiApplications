//
//  AppDelegate.m
//  RiderApp
//
//  Created by Gursharan Singh on 30/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "SignUpViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation AppDelegate

@synthesize window = _window;
@synthesize navigationController;

- (void)dealloc
{
    [navigationController release];
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    SignUpViewController *viewController = [[SignUpViewController alloc] initWithNibName:@"SignUpViewController" bundle:nil];
    self.navigationController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
    self.navigationController.navigationBarHidden = YES;
    [viewController release];
    
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];
    return YES;
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
        label.text = @"Rider App";
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


@end
