//
//  FindATaxiViewController.m
//  RiderApp
//
//  Created by Gursharan Singh on 30/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FindATaxiViewController.h"
#import "ASIFormDataRequest.h"
#import "CommonMethods.h"
#import "NSString+SBJSON.h"
#import "TaxiFoundViewController.h"

@implementation FindATaxiViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taxiFound:) name:@"TAXI_FOUND" object:nil];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [findingTaxiView removeFromSuperview];
    [warningView removeFromSuperview];
}

#pragma - Notification

- (void)taxiFound: (NSNotification *)notification {
    //  NSDictionary *requestDict = [notification object];
    TaxiFoundViewController *viewController = [[TaxiFoundViewController alloc] initWithNibName:@"TaxiFoundViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

- (IBAction)doneClicked:(id)sender {
    [findingTaxiView removeFromSuperview];
    [warningView removeFromSuperview];
}


#pragma - Button Clicks

- (IBAction)findATaxiClicked:(id)sender {
    [self.view addSubview:findingTaxiView];
    [self performSelector:@selector(makeRequestOnServer)];
}

- (IBAction)cancelFindClicked:(id)sender {
    [findingTaxiView removeFromSuperview];
    [warningView removeFromSuperview];
}

#pragma mark- Server Posting Methods

//Make a server call to create an account on server
- (void)makeRequestOnServer {
    NSString *requestUrlString = hostURL;
    
    //Creating the HTTP Request and setting the required post values
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestUrlString]];
    [request setPostValue:@"request" forKey:@"axn"];
    [request setPostValue:@"create" forKey:@"code"];
    [request setPostValue:[CommonMethods uniqueDeviceID] forKey:@"deviceid"];
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"APNS_Token"]) {
        [request setPostValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"APNS_Token"] forKey:@"token"];
    }
    [request setTimeOutSeconds:200];
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(uploadReportFinished:)];
    [request setDidFailSelector:@selector(uploadReportFailed:)];
    [request startAsynchronous];
    
}

//If request fails, show an alert to the user and hide the indicator view
- (void)uploadReportFailed:(ASIHTTPRequest *)request {
    NSLog(@"uploadReportFailed: %@", [request responseString]);
    [self showAlertWithMessage:@"Server failed, Please try again later."];
    
}

//If request finishes, hide the loading indicator and pass him to the next view
- (void)uploadReportFinished: (ASIHTTPRequest *)request {
  
    NSDictionary *dict = [[request responseString] JSONValue];
    NSLog(@"uploadReportFinished: %@", dict);
    
    if ([[dict valueForKey:@"returnCode"] intValue] == 0) { //Everything was fine on server.
       
    }
    else if ([[dict valueForKey:@"returnCode"] intValue] == 1 && [[dict valueForKey:@"error"] isEqualToString:@"No Taxis Found"]) {
        [self.view addSubview:warningView];
    }
    else {
        [self showAlertWithMessage:[NSString stringWithFormat:@"Error from Server: %@", [dict valueForKey:@"error"]]];
    }
}


#pragma - Other Helpers

- (void)showAlertWithMessage: (NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"TaxiRider App" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

@end
