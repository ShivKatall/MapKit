//
//  PointOfInterest.m
//  MapKit
//
//  Created by Cole Bratcher on 5/20/14.
//  Copyright (c) 2014 Cole Bratcher. All rights reserved.
//

#import "PointOfInterest.h"

@implementation PointOfInterest

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate andTitle:(NSString *)title
{
    if (self = [super init]) {
        self.coordinate = coordinate;
        self.title      = title;
    }
    return self;
}

@end
