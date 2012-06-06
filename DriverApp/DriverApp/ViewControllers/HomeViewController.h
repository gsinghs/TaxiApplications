//
//  HomeViewController.h
//  DriverApp
//
//  Created by Gursharan Singh on 30/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface HomeViewController : UIViewController <MKMapViewDelegate>{
    IBOutlet UIButton *availableButton;
    IBOutlet UIButton *occupyButton;
    IBOutlet MKMapView *mapView;
}

- (IBAction)availableORHireClicked:(UIButton *)sender;
- (void)postStatusOnServer:(int)status;
- (void)showAlertWithMessage: (NSString *)message;
- (void)changeButtonStatesForButtons: (UIButton *)sender;

@end
