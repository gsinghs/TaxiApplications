//
//  AddressAnnotation.h
//  DriverApp
//
//  Created by Gursharan Singh on 29/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddressAnnotation.h"
#import<MapKit/MapKit.h>


@implementation AddressAnnotation
@synthesize coordinate;
@synthesize title , subtitle ;



#pragma mark -coordinate

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
    if (self = [super init]) {
        coordinate=c;
    }
    return self;
}

- (void)dealloc {
	
	 [super dealloc];
}


@end
