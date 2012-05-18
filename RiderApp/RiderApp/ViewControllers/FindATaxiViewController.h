//
//  FindATaxiViewController.h
//  RiderApp
//
//  Created by Gursharan Singh on 30/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FindATaxiViewController : UIViewController {
    IBOutlet UIView *findingTaxiView;
    IBOutlet UIView *warningView;
}

- (IBAction)findATaxiClicked:(id)sender;
- (IBAction)cancelFindClicked:(id)sender;
- (void)showAlertWithMessage: (NSString *)message;
- (IBAction)doneClicked:(id)sender;

@end
