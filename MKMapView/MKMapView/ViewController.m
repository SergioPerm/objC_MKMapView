//
//  ViewController.m
//  MKMapView
//
//  Created by kluv on 10/04/2020.
//  Copyright © 2020 com.kluv.hw24. All rights reserved.
//

#import "ViewController.h"
#import "UIView+MKAnnotationView.h"
#import "Student.h"
#import "StudentInfoTableViewController.h"
#import "MeetingPoint.h"
#import "MeetingRadarOverlay.h"

@interface ViewController () <MKMapViewDelegate>

@property (assign, nonatomic) BOOL setUserLocationOnStart;
@property (strong, nonnull) MKDirections* directions;

@property (strong, nonatomic) NSMutableArray* students;
@property (strong, nonatomic) NSMutableArray* studentsNames;

@property (strong, nonatomic) MeetingPoint* meetingPoint;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem* addRoutesButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionShowRoutesForStudents:)];
    UIBarButtonItem* addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionUpdateStudents:)];
    UIBarButtonItem* zoomButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(actionZoom:)];
    
    self.navigationItem.rightBarButtonItems = @[addRoutesButton, zoomButton, addButton];
      
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    self.mapView.showsUserLocation = YES;
    
    //show meeting point
    self.meetingPoint = [[MeetingPoint alloc] init];
    
    CLLocationCoordinate2D meetingCoordinate = CLLocationCoordinate2DMake(57.992049, 56.294794);
    self.meetingPoint.coordinate = meetingCoordinate;
    
    [self.mapView addAnnotation:self.meetingPoint];
        
    [self updateMeetingRadarOverlays];
    
    //generate names arr
    NSDictionary* dictNames = [self JSONFromFile];
    
    self.studentsNames = [[NSMutableArray alloc] init];
    self.students = [[NSMutableArray alloc] init];
    
    for (NSDictionary* studentName in dictNames) {
        
        NSString* fullName = [studentName objectForKey:@"name"];
        [self.studentsNames addObject:fullName];
        
    }
    
}

- (void)dealloc {
    
}

#pragma mark - Methods

- (UIColor*) generateColor {
    
    return [UIColor colorWithHue:drand48() saturation:1.0 brightness:1.0 alpha:1.0];
    
}

- (void)updateDistanceDataForStudents {
    
    int overDistance = 0;
    int within5distance = 0;
    int within3distance = 0;
    int within1distance = 0;
    
    for (Student* student in self.students) {
        
        CLLocationDistance distance = student.distanceToMeeting;
        
        if (distance > 5000) {
            student.distanceType = DistanceToMeetAbroad;
            overDistance++;
        } else if (distance > 3000 && distance <= 5000) {
            student.distanceType = DistanceToMeetFar;
            within5distance++;
        } else if (distance > 1000 && distance <= 3000) {
            student.distanceType = DistanceToMeetMiddle;
            within3distance++;
        } else {
            student.distanceType = DistanceToMeetNear;
            within1distance++;
        }
        
    }
    
    self.range5000Label.text = [NSString stringWithFormat:@"%@ %d",@"Range > 5000 m - ",overDistance];
    self.range3000Label.text = [NSString stringWithFormat:@"%@ %d",@"Range > 3000 m - ",within5distance];
    self.range1000Label.text = [NSString stringWithFormat:@"%@ %d",@"Range > 1000 m - ",within3distance];
    self.rangeMeetPointLabel.text = [NSString stringWithFormat:@"%@ %d",@"Range < 1000 m - ",within1distance];
    
}

- (void)updateMeetingRadarOverlays {
        
    NSMutableArray* overlaysForDelete = [NSMutableArray array];
    
    for (id<MKOverlay> overlay in self.mapView.overlays) {
        
        if ([overlay isKindOfClass:[MeetingRadarOverlay class]]) {
            [overlaysForDelete addObject:overlay];
        }
        
    }
    
    if ([overlaysForDelete count] > 0)
        [self.mapView removeOverlays:overlaysForDelete];
    
    NSMutableArray* overlays = [NSMutableArray array];
    
    [overlays addObject:[MeetingRadarOverlay circleWithCenterCoordinate:self.meetingPoint.coordinate radius:5000]];
    [overlays addObject:[MeetingRadarOverlay circleWithCenterCoordinate:self.meetingPoint.coordinate radius:3000]];
    [overlays addObject:[MeetingRadarOverlay circleWithCenterCoordinate:self.meetingPoint.coordinate radius:1000]];
    
    [self.mapView addOverlays:overlays level:MKOverlayLevelAboveRoads];
    
}

- (void)setLocationForStudent:(Student*) student {
    
    CLLocation* location = [[CLLocation alloc] initWithLatitude:student.coordinate.latitude longitude:student.coordinate.longitude];
    
    CLGeocoder* geoCoder = [[CLGeocoder alloc] init];
    
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        NSString* message = nil;
        
        if (error) {
            message = [error localizedDescription];
        } else {
            
            if ([placemarks count] > 0) {
                
                CLPlacemark* placeMark = [placemarks firstObject];
                
                NSString* address = [NSString stringWithFormat:@"%@, %@",
                                     placeMark.locality == nil ? @"" : placeMark.locality,
                                     placeMark.name == nil ? @"" : placeMark.name];
                
                
                student.address = address;
                
            } else {
                message = @"NO placeparks";
            }
        }
    }];
    
}

- (NSDictionary *)JSONFromFile
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"datanames" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

- (void)zoomToAllAnnotations {
    
   MKMapRect zoomRect = MKMapRectNull;
    
    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        
        CLLocationCoordinate2D location = annotation.coordinate;
        
        MKMapPoint center = MKMapPointForCoordinate(location);
        
        static double delta = 20000;
        
        MKMapRect rect = MKMapRectMake(center.x - delta, center.y - delta, delta * 2, delta * 2);
        
        zoomRect = MKMapRectUnion(zoomRect, rect);
        
    }
    
    zoomRect = [self.mapView mapRectThatFits:zoomRect];
    
    [self.mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsMake(50, 50, 50, 50) animated:YES];
    
}

- (void)showMapAlert:(NSString*) message {
    
    UIAlertAction* actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertController* alertCtrl = [UIAlertController alertControllerWithTitle:@"ATTENTION" message:message preferredStyle:UIAlertControllerStyleActionSheet];
    [alertCtrl addAction:actionCancel];
    
    [self presentViewController:alertCtrl animated:YES completion:nil];
    
}

- (NSString*)getRandomStudentName {
    
    int maxIndex = (int)self.studentsNames.count - 1;
    
    int randomIndex = arc4random() % maxIndex;
    
    return [self.studentsNames objectAtIndex:randomIndex];
    
}

- (void)addRouteToMeetOverlayForStudent:(Student*) student {
    
    MKDirections* directions;
    
    MKDirectionsRequest* request = [[MKDirectionsRequest alloc] init];
    
    MKPlacemark* placemarkSource = [[MKPlacemark alloc] initWithCoordinate:student.coordinate];
    request.source = [[MKMapItem alloc] initWithPlacemark:placemarkSource];
    
    MKPlacemark* placemarkDestination = [[MKPlacemark alloc] initWithCoordinate:self.meetingPoint.coordinate];
    
    request.destination = [[MKMapItem alloc] initWithPlacemark:placemarkDestination];
        
    request.transportType = MKDirectionsTransportTypeAutomobile;
    
    directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
                        
        } else if ([response.routes count] > 0) {
                        
            NSMutableArray* array = [NSMutableArray array];
            
            for (MKRoute* route in response.routes) {
                [array addObject:route.polyline];
            }
            
            [self.mapView addOverlays:array level:MKOverlayLevelAboveRoads];
            
        }
        
    }];
    
}

- (void)clearAllRoutes {
    
    NSMutableArray* routesForDelete = [NSMutableArray array];
    
    for (id<MKOverlay> overlay in self.mapView.overlays) {
        
        if ([overlay isKindOfClass:[MKPolyline class]]) {
            [routesForDelete addObject:overlay];
        }
        
    }
    
    if ([routesForDelete count] > 0)
        [self.mapView removeOverlays:routesForDelete];
    
}

- (void)updateRoutesForStudents {
    
    [self clearAllRoutes];
    
    for (Student* student in self.students) {
    
        int rndPercent = arc4random() % 100;
        
        if (student.distanceType == DistanceToMeetNear && rndPercent < 90) {
            [self addRouteToMeetOverlayForStudent:student];
        } else if (student.distanceType == DistanceToMeetMiddle && rndPercent < 70) {
            [self addRouteToMeetOverlayForStudent:student];
        } else if (student.distanceType == DistanceToMeetFar && rndPercent < 50) {
            [self addRouteToMeetOverlayForStudent:student];
        } else if (student.distanceType == DistanceToMeetAbroad && rndPercent < 20) {
            [self addRouteToMeetOverlayForStudent:student];
        }
        
    }
    
}

#pragma mark - Actions

- (void)actionShowRoutesForStudents:(UIBarButtonItem*) sender {
    
    [self clearAllRoutes];
    [self updateRoutesForStudents];
    
}

- (void)actionShowStudentInfo:(UIButton*) sender {
    
    StudentInfoTableViewController* studentInfoController = [self.storyboard instantiateViewControllerWithIdentifier:@"studentInfoTableViewController"];
    
    MKAnnotationView* annotationView = [sender superAnnotationView];
    studentInfoController.student = annotationView.annotation;
    
    UINavigationController* navCtrl = [[UINavigationController alloc] initWithRootViewController:studentInfoController];
    
    navCtrl.preferredContentSize = CGSizeMake(300, 300);
    navCtrl.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController* presentCtrl = navCtrl.popoverPresentationController;
    presentCtrl.permittedArrowDirections = UIPopoverArrowDirectionUp;
    presentCtrl.sourceRect = sender.frame;
    presentCtrl.sourceView = self.view;
    
    [self presentViewController:navCtrl animated:YES completion:nil];
        
}

- (void)actionUpdateStudents:(UIBarButtonItem*) sender {
    
    //delete all students
    [self clearAllRoutes];
    
    NSMutableArray* studentsForDelete = [NSMutableArray array];
    
    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        
        if ([annotation isKindOfClass:[Student class]]) {
            [studentsForDelete addObject:annotation];
        }
        
    }
    
    if ([studentsForDelete count] > 0) {
        [self.mapView removeAnnotations:[studentsForDelete copy]];
        [self.students removeAllObjects];
    }
        
    //create new students
    for (int i = 0; i < 15; i++) {
        
        NSString* fullStudentName = [self getRandomStudentName];
        
        Student* student = [[Student alloc] initWithName:fullStudentName andWithMeetingPoint:self.meetingPoint];
        [self setLocationForStudent:student];
        [self.students addObject:student];
        
    }
    
    [self.mapView showAnnotations:self.students animated:YES];
    
    [self updateDistanceDataForStudents];
    
}

- (void)actionAdd:(UIBarButtonItem*) sender {
    
    MyMapAnnotaion* annotaion = [[MyMapAnnotaion alloc] init];
    
    annotaion.title = @"Test title";
    annotaion.subtitle = @"Test subtitle";
    annotaion.coordinate = self.mapView.region.center;
    
    [self.mapView addAnnotation:annotaion];
    
}

- (void)actionZoom:(UIBarButtonItem*) sender {
 
    [self zoomToAllAnnotations];
    
}

- (void)actionDirection:(UIButton*) sender {
    
    MKAnnotationView* annotationView = [sender superAnnotationView];
    
    if (!annotationView) {
        return;
    }
    
    if ([self.directions isCalculating])
        [self.directions cancel];
    
    CLLocationCoordinate2D coordinate = annotationView.annotation.coordinate;
    
    MKDirectionsRequest* request = [[MKDirectionsRequest alloc] init];
    
    request.source = [MKMapItem mapItemForCurrentLocation];
    MKPlacemark* placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate];
    
    MKMapItem* destination = [[MKMapItem alloc] initWithPlacemark:placemark];
    
    request.destination = destination;
    
    request.transportType = MKDirectionsTransportTypeAutomobile;
    
    self.directions = [[MKDirections alloc] initWithRequest:request];
    
    [self.directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            
            [self showMapAlert:[error localizedDescription]];
            
        } else if ([response.routes count] == 0) {
            
            [self showMapAlert:@"No routes found"];
            
        } else {
            
            [self.mapView removeOverlays:[self.mapView overlays]];
            
            NSMutableArray* array = [NSMutableArray array];
            
            for (MKRoute* route in response.routes) {
                [array addObject:route.polyline];
            }
            
            [self.mapView addOverlays:array level:MKOverlayLevelAboveRoads];
                        
        }
        
    }];
}

- (void)actionDescription:(UIButton*) sender {
    
//    MKAnnotationView* annotationView = [sender superAnnotationView];
//
//    if (!annotationView) {
//        return;
//    }
//
//    CLLocationCoordinate2D coordinate = annotationView.annotation.coordinate;
//
//    CLLocation* location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
//
//    if ([self.geoCoder isGeocoding])
//        [self.geoCoder cancelGeocode];
//
//    [self.geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
//
//        NSString* message = nil;
//
//        if (error) {
//            message = [error localizedDescription];
//        } else {
//
//            if ([placemarks count] > 0) {
//
//                CLPlacemark* placeMark = [placemarks firstObject];
//                
//                NSString *address = [NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@",
//                                     placeMark.thoroughfare,
//                                     placeMark.locality,
//                                     placeMark.subLocality,
//                                     placeMark.administrativeArea,
//                                     placeMark.postalCode,
//                                     placeMark.country];
//
//                message = address;
//
//            } else {
//                message = @"NO placeparks";
//            }
//        }
//
//        [self showMapAlert:message];
//
//    }];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
        
    if ([view.annotation isKindOfClass:[MeetingPoint class]] && newState == MKAnnotationViewDragStateEnding) {
        
        [self updateMeetingRadarOverlays];
        [self updateDistanceDataForStudents];
        [self updateRoutesForStudents];
        
    }
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    if ([annotation isKindOfClass:[MeetingPoint class]]) {
        
        static NSString* identifier = @"meetingAnnotation";
        
        MKAnnotationView* annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        
        annotationView.image = [UIImage imageNamed:@"meetingPoint"];
        
        annotationView.draggable = YES;
        
        return annotationView;
        
    }

    static NSString* identifier = @"Annotation";

    MKAnnotationView* annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (!annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    }
    
    if ([annotation isKindOfClass:[Student class]]) {
        
        Student* student = (Student*)annotation;
        annotationView.image = student.image;
        annotationView.canShowCallout = YES;
        
        UIButton* infoBtn = [UIButton buttonWithType:UIButtonTypeInfoDark];
        [infoBtn addTarget:self action:@selector(actionShowStudentInfo:) forControlEvents:UIControlEventTouchUpInside];
        
        annotationView.rightCalloutAccessoryView = infoBtn;
        
    }

    return annotationView;

}


- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    
    if (!self.setUserLocationOnStart) {
        [self zoomToAllAnnotations];
        self.setUserLocationOnStart = YES;
    }
    
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    if ([overlay isKindOfClass:[MeetingRadarOverlay class]]) {
        
        MKCircleRenderer* circleRenderer = [[MKCircleRenderer alloc] initWithOverlay:overlay];
        circleRenderer.fillColor = [UIColor greenColor];
        
        MeetingRadarOverlay* meetingRadar = (MeetingRadarOverlay*)overlay;
        
        if (meetingRadar.radius == 5000) {
            circleRenderer.alpha = 0.25;
        } else if (meetingRadar.radius == 3000) {
            circleRenderer.alpha = 0.35;
        } else {
            circleRenderer.alpha = 0.5;
        }

        return circleRenderer;
        
    }
        
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        
        MKPolyline* routePolyline = (MKPolyline*)overlay;
        
        MKPolylineRenderer* renderer = [[MKPolylineRenderer alloc] initWithPolyline:routePolyline];
        
        renderer.lineWidth = 3;
        renderer.strokeColor = [self generateColor];
        
        return renderer;
            
    }
    
    return nil;
    
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    
    self.location = locations.lastObject;
    
}

//- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
//
//    NSLog(@"regionWillChangeAnimated");
//
//}
//
//- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
//
//    NSLog(@"regionWillCregionDidChangeAnimatedhangeAnimated");
//
//}
//
//- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
//
//    NSLog(@"mapViewWillStartLoadingMap");
//
//}
//
//- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
//
//    NSLog(@"mapViewDidFinishLoadingMap");
//
//}
//
//- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
//
//    NSLog(@"mapViewDidFailLoadingMap");
//
//}
//
//- (void)mapViewWillStartRenderingMap:(MKMapView *)mapView {
//
//    NSLog(@"mapViewWillStartRenderingMap");
//
//}
//
//- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
//
//    NSLog(@"mapViewDidFinishRenderingMap");
//
//}

@end
