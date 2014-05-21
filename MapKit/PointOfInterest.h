//
//  PointOfInterest.h
//  MapKit
//
//  Created by Cole Bratcher on 5/20/14.
//  Copyright (c) 2014 Cole Bratcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@import MapKit;

@interface PointOfInterest : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic) CLLocationCoordinate2D coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate andTitle:(NSString *)title;

@end
