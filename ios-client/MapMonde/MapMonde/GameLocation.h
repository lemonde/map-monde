//
//  GameLocation.h
//  MapMonde
//
//  Created by Amadour Griffais (MIA) on 05/07/13.
//  Copyright (c) 2013 Le Monde Interactif. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface GameLocation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;

- (NSDictionary*) JSONSerialization;

+ (GameLocation*)gameLocationWithJSON:(id)json;
+ (GameLocation*)gameLocationWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
