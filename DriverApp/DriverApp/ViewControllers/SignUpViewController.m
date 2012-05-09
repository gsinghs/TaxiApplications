//
//  SignUpViewController.m
//  DriverApp
//
//  Created by Gursharan Singh on 30/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SignUpViewController.h"
#import "HomeViewController.h"
#import "ASIFormDataRequest.h"
#import "CommonMethods.h"
#import "AppDelegate.h"
#import "NSString+SBJSON.h"

@implementation SignUpViewController

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    nameTxtField.verticalPadding = 0; 
    nameTxtField.horizontalPadding = 15;
    companyTxtField.verticalPadding = 0; 
    companyTxtField.horizontalPadding = 15;
    cabNumberTxtField.verticalPadding = 0; 
    cabNumberTxtField.horizontalPadding = 15;
    
}


#pragma TextField delegates
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {        // return NO to disallow editing.
    if (textField == cabNumberTxtField) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.3];
        CGRect frame = self.view.frame;
        frame.origin.y = -40;
        self.view.frame = frame;
        [UIView commitAnimations];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == cabNumberTxtField) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.3];
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        self.view.frame = frame;
        [UIView commitAnimations];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {              // called when 'return' key pressed. return NO to ignore.
    [textField resignFirstResponder];
    return YES;
}

#pragma - Button Actions
- (IBAction)signUpClicked:(id)sender {
    if ([self validateTextOfTextFieldForNull:nameTxtField] == NO) {
        [self showAlertWithMessage:@"Please enter your name."];
        return;
    }
    if ([self validateTextOfTextFieldForNull:companyTxtField]  == NO) {
        [self showAlertWithMessage:@"Please enter your Company."];
        return;
    }
    if ([self validateTextOfTextFieldForNull:cabNumberTxtField]  == NO) {
        [self showAlertWithMessage:@"Please enter your Cab Number."];
        return;
    }
    [self performSelector:@selector(createAccountOnServer)];
}


//Check for valid value of text field
- (BOOL)validateTextOfTextFieldForNull: (UITextField *)textField {
    if (textField.text && ![[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        return YES;
    }
    return NO;
}

//Validate the string so that it is not nil, and not having spaces in end/begining
- (NSString *)validatedTextOfTextFieldForNull: (UITextField *)textField {
    if (textField.text) {
        return [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    return @"";
}

- (void)showAlertWithMessage: (NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"TaxiRider App" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

#pragma mark- Server Posting Methods

//Make a server call to create an account on server
- (void)createAccountOnServer {
    NSString *requestUrlString = hostURL;
    
    //Show loading view while server call is in place
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showLoadingIndicator];
    
    //Creating the HTTP Request and setting the required post values
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestUrlString]];

    [request setPostValue:@"signup" forKey:@"axn"];
    [request setPostValue:@"driver" forKey:@"code"];
    [request setPostValue:[CommonMethods generatedeviceID] forKey:@"deviceid"];

    [request setPostValue:[self validatedTextOfTextFieldForNull:nameTxtField] forKey:@"name"];
    [request setPostValue:[self validatedTextOfTextFieldForNull:companyTxtField] forKey:@"company"];
    [request setPostValue:[self validatedTextOfTextFieldForNull:cabNumberTxtField] forKey:@"cab"];
    [request setTimeOutSeconds:200];
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(uploadReportFinished:)];
    [request setDidFailSelector:@selector(uploadReportFailed:)];
    [request startAsynchronous];
    
}

//If request fails, show an alert to the user and hide the indicator view
- (void)uploadReportFailed:(ASIHTTPRequest *)request {
    NSLog(@"uploadReportFailed: %@", [request responseString]);
    [self showAlertWithMessage:@"Uploading to Server failed, Please try again later."];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate hideLoadingIndicator];
    
}

//If request finishes, check for the response string, hide the loading indicator and pass him to the next view if response OK
- (void)uploadReportFinished: (ASIHTTPRequest *)request {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate hideLoadingIndicator];

    NSDictionary *dict = [[request responseString] JSONValue];
    //NSLog(@"uploadReportFinished: %@", dict);
    
    if ([[dict valueForKey:@"returnCode"] intValue] == 0) { //Everything was fine on server.
        HomeViewController *viewController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
        [self.navigationController pushViewController:viewController animated:YES];
        [viewController release];
    }
    else {
        [self showAlertWithMessage:[NSString stringWithFormat:@"Error from Server: %@", [dict valueForKey:@"error"]]];
    }
    
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

@end
