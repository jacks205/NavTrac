//
//  Direction.m
//  NavigationTracker
//
//  Created by Mark Jackson on 1/14/14.
//  Copyright (c) 2014 Mark Jackson. All rights reserved.
//

#import "Direction.h"
#import <Parse/PFObject+Subclass.h>

@implementation Direction

@dynamic address;
@dynamic city;
@dynamic zipcode;
@dynamic state;

@dynamic distance;
@dynamic baseTime;
@dynamic trafficTime;
@dynamic travelTime;

@dynamic latitude;
@dynamic longitude;

@dynamic userId;
@dynamic username;

+(NSString *)parseClassName{
    return @"Directions";
}



-(id)initWithAddress:(NSString*)address city:(NSString*)city state:(NSString*)state zipcode:(NSString*)zipcode{
    self = [super init];
    if (self) {
        self.address = address;
        self.city = city;
        self.state = state;
        self.zipcode = zipcode;
    }
    
    return self;
}

+ (id)directionWithAddress:(NSString*)address city:(NSString*)city state:(NSString*)state zipcode:(NSString*)zipcode direction:(Direction *) direction user:(PFUser *)user{
    direction.address = address;
    direction.city = city;
    direction.state = state;
    direction.zipcode = zipcode;
    direction.username = [user username];
    direction.userId = [user objectId];
    return direction;
    
}


// Build url each time to go with users current location
-(NSURL *)buildUrl: (CLLocationCoordinate2D) currentCoords{
    
    NSString *formattedString = [NSString stringWithFormat:@"%@app_id=%@&app_code=%@&waypoint0=geo!%f,%f&waypoint1=geo!%@,%@&%@", URL_1, APP_ID, APP_CODE, currentCoords.latitude, currentCoords.longitude, [self latitude], [self longitude] , URL_2];

    NSURL *routesUrl = [NSURL URLWithString:formattedString];
    
    return routesUrl;
    
}





@end