//
//  TaxiRequestViewController.h
//  DriverApp
//
//  Created by Gursharan Singh on 30/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface TaxiRequestViewController : UIViewController <MKMapViewDelegate>{
    IBOutlet UILabel *descriptionLabel;
    IBOutlet UILabel *proceedToDescriptionLabel;
    IBOutlet UILabel *distanceLabel;
    IBOutlet UIView *requestAcceptedView;
    IBOutlet MKMapView *mapView;
    IBOutlet MKMapView *proceedMapView;

}

- (IBAction)acceptRequestClicked:(id)sender;
- (IBAction)rejectRequestClicked:(id)sender;
- (IBAction)callcustomerClicked:(id)sender;
- (void)showAlertWithMessage: (NSString *)message;
- (IBAction)doneClicked:(id)sender;
- (void)geocodeLocationForCoordinate:(NSString *)coordinatesString;
- (void)setLabelTexts: (NSString *)string;

@end
