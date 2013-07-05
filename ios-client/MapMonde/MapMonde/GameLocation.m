//
//  GameLocation.m
//  MapMonde
//
//  Created by Amadour Griffais (MIA) on 05/07/13.
//  Copyright (c) 2013 Le Monde Interactif. All rights reserved.
//

#import "GameLocation.h"

@implementation GameLocation

//**************************************************************************
#pragma mark - Factories

+ (GameLocation*)gameLocationWithJSON:(id)json
{
    if ([json isKindOfClass:[NSDictionary class]] && [json[@"lat"] isKindOfClass:[NSNumber class]] && [json[@"long"] isKindOfClass:[NSNumber class]]) {
        GameLocation* location = [GameLocation new];
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [json[@"lat"] doubleValue];
        coordinate.longitude = [json[@"long"] doubleValue];
        location.coordinate = coordinate;
        return location;
    }
    
    return nil;
}

+ (GameLocation*)gameLocationWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    GameLocation* location = [GameLocation new];
    location.coordinate = coordinate;
    return location;
}

//**************************************************************************
#pragma mark - JSON serialization

- (NSDictionary*) JSONSerialization
{
    return @{@"lat": @(self.coordinate.latitude), @"long": @(self.coordinate.longitude)};
}

@end
