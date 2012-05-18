//
//  TaxiFoundViewController.m
//  RiderApp
//
//  Created by Gursharan Singh on 30/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TaxiFoundViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation TaxiFoundViewController

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
    bgImageView.layer.cornerRadius = 8;
    bgImageView.backgroundColor = [UIColor blackColor];
    
    taxiNameLabel.text = [NSString stringWithFormat:@"Company: %@", [[[NSUserDefaults standardUserDefaults] valueForKey:@"request"] valueForKey:@"company"]];
    taxiNumberLabel.text = [NSString stringWithFormat:@"Cab #: %@", [[[NSUserDefaults standardUserDefaults] valueForKey:@"request"] valueForKey:@"cab_id"]];
    
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

- (IBAction)cancelButtonClicked:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
