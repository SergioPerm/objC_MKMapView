//
//  MeetingPoint.h
//  MKMapView
//
//  Created by kluv on 23/04/2020.
//  Copyright © 2020 com.kluv.hw24. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MeetingPoint : NSObject <MKAnnotation>

@property (nonatomic, readonly, copy, nullable) NSString *title;
@property (nonatomic, readonly, copy, nullable) NSString *subtitle;

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;

@end

NS_ASSUME_NONNULL_END
