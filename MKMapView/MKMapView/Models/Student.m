//
//  Student.m
//  MKMapView
//
//  Created by kluv on 22/04/2020.
//  Copyright © 2020 com.kluv.hw24. All rights reserved.
//

#import "Student.h"

@interface Student()

@property (strong, nonatomic) NSString* fullName;
@property (assign, nonatomic) CLLocationCoordinate2D centerCoordinate;

@end

@implementation Student

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupStudentSettings];
    }
    return self;
}

- (instancetype)initWithName:(NSString*) fullName andWithMeetingPoint:(MeetingPoint*)meetingPoint
{
    self = [super init];
    if (self) {
        
        self.fullName = fullName;
        self.meetingPoint = meetingPoint;
        
        [self setupStudentSettings];
        
    }
    return self;
}

- (CLLocationDistance)distanceToMeeting {
    
    CLLocation* locationStudent = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
    CLLocation* meetingLocation = [[CLLocation alloc] initWithLatitude:self.meetingPoint.coordinate.latitude longitude:self.meetingPoint.coordinate.longitude];
    
    CLLocationDistance distanceToMeetPoint = [locationStudent distanceFromLocation:meetingLocation];
    
    return distanceToMeetPoint;
    
}

- (void)setupStudentSettings {
    
    NSArray* fullNameArr = [self.fullName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    self.firstName = fullNameArr[0];
    self.lastName = fullNameArr[1];
    
    double rndLatitudeDelta = (arc4random() % 11) / 100.0 * (arc4random() % 2 == 0 ? -1 : 1);
    double rndLongitudeDelta = (arc4random() % 11) / 100.0 * (arc4random() % 2 == 0 ? -1 : 1);
    
    double latitude = self.meetingPoint.coordinate.latitude + rndLatitudeDelta;
    double longitude = self.meetingPoint.coordinate.longitude + rndLongitudeDelta;
    
    _coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    self.sex = arc4random() % 2 == 1 ? StudentMale : StudentFemale;
    
    if (self.sex == StudentMale) {
        self.image = [UIImage imageNamed:@"male"];
    } else {
        self.image = [UIImage imageNamed:@"female"];
    }
    
    NSUInteger rndValue = 5 + arc4random() % ((365*25) - 5);
    self.birthDate = [self generateRandomDateWithinDaysBeforeSpecDay:rndValue];
    
    _title = self.fullName;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy"];
    
    _subtitle = [formatter stringFromDate:self.birthDate];
    
}

- (NSDate *)generateRandomDateWithinDaysBeforeSpecDay:(NSUInteger)daysBack {
    
    NSUInteger day = arc4random_uniform((u_int32_t)daysBack);  // explisit cast
    NSUInteger hour = arc4random_uniform(23);
    NSUInteger minute = arc4random_uniform(59);
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:31];
    [comps setMonth:12];
    [comps setYear:2010];
    NSDate *dateTo = [[NSCalendar currentCalendar] dateFromComponents:comps];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *offsetComponents = [NSDateComponents new];
    [offsetComponents setDay:(day * -1)];
    [offsetComponents setHour:hour];
    [offsetComponents setMinute:minute];
    
    NSDate *randomDate = [gregorian dateByAddingComponents:offsetComponents
                                                    toDate:dateTo
                                                   options:0];
    
    return randomDate;
    
}


@end
