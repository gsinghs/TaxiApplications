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
#import "AppDelegate.h"

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusChange:) name:@"STATUS_REQUEST" object:nil];


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

- (void)statusChange: (NSNotification *)notification {
    NSDictionary *requestDict = [notification object];
    NSLog(@"%@", requestDict);
    [warningView removeFromSuperview];
    [findingTaxiView removeFromSuperview];

    switch ([[requestDict valueForKey:@"status"] intValue]) {
        case 0: {
            //        Status = 0:   The request was created but no drivers have accepted it yet.  In this case, show the Finding Taxis screen.
            [self.view addSubview:findingTaxiView];
            break;
        }
        case 1: {
            //        Status = 1:  The driver has accepted.  In this case, I will also send the company and cab_id.  Show, the Taxi Found page.
            //        Here is what I will return: {"returnCode":0, "status":1,"company":"Metro Taxi", "cab_id":"230"}
            TaxiFoundViewController *viewController = [[TaxiFoundViewController alloc] initWithNibName:@"TaxiFoundViewController" bundle:nil];
            [self.navigationController pushViewController:viewController animated:YES];
            [viewController release];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"madeRequestID"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            break;
        }
        case 2: {
            //        Status = 2:  The request has expired.  In this case, show the No Taxi's found page
            [self.view addSubview:warningView];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"madeRequestID"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            break;
        }
        case 3: {
            //        Status = 3:  The request is completed or request was not found.  In this case, show the first screen with the Request Taxi button.
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"madeRequestID"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            break;
        }
        default:
            break;
    }

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
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"madeRequestID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *locString = [NSString stringWithFormat:@"%f,%f", appDelegate.latitudeVal, appDelegate.longitudeVal];
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
    [self showAlertWithMessage:@"Server failed, Please try again later."];
    
}

//If request finishes, hide the loading indicator and pass him to the next view
- (void)uploadReportFinished: (ASIHTTPRequest *)request {
  
    NSDictionary *dict = [[request responseString] JSONValue];
    NSLog(@"uploadReportFinished: %@", dict);
    
    if ([[dict valueForKey:@"returnCode"] intValue] == 0) { //Everything was fine on server.
        [[NSUserDefaults standardUserDefaults] setObject:[dict valueForKey:@"requestid"] forKey:@"madeRequestID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
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
