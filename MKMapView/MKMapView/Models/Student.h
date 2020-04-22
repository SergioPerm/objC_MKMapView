//
//  Student.h
//  MKMapView
//
//  Created by kluv on 22/04/2020.
//  Copyright © 2020 com.kluv.hw24. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    StudentMale,
    StudentFemale
} StudentSex;

@interface Student : NSObject <MKAnnotation>

@property (strong, nonatomic) NSString* firstName;
@property (strong, nonatomic) NSString* lastName;

@property (strong, nonatomic) UIImage* image;
@property (assign, nonatomic) StudentSex sex;
@property (strong, nonatomic) NSDate* birthDate;
@property (strong, nonatomic) NSString* address;

@property (nonatomic, readonly, copy, nullable) NSString *title;
@property (nonatomic, readonly, copy, nullable) NSString *subtitle;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithName:(NSString*)fullName andWithCenterCoordinate:(CLLocationCoordinate2D)coordinate;

@end

NS_ASSUME_NONNULL_END
