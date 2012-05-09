//
//  TaxiFoundViewController.h
//  RiderApp
//
//  Created by Gursharan Singh on 30/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaxiFoundViewController : UIViewController {
    IBOutlet UILabel *taxiNameLabel;
    IBOutlet UILabel *timeLabel;
}

- (IBAction)cancelButtonClicked:(id)sender;

@end
