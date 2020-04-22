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

@interface ViewController () <MKMapViewDelegate>

@property (assign, nonatomic) BOOL setUserLocationOnStart;
@property (strong, nonnull) MKDirections* directions;

@property (strong, nonatomic) NSMutableArray* students;
@property (strong, nonatomic) NSMutableArray* studentsNames;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem* addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionUpdateStudents:)];
    UIBarButtonItem* zoomButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(actionZoom:)];
    
    self.navigationItem.rightBarButtonItems = @[zoomButton, addButton];
      
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    self.mapView.showsUserLocation = YES;
    
    
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
                
                NSString *address = [NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@",
                                     placeMark.thoroughfare,
                                     placeMark.locality,
                                     placeMark.subLocality,
                                     placeMark.administrativeArea,
                                     placeMark.postalCode,
                                     placeMark.country];
                
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

#pragma mark - Actions

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
    
    NSMutableArray* studentsForDelete = [NSMutableArray array];
    
    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        
        if ([annotation isKindOfClass:[Student class]]) {
            [studentsForDelete addObject:annotation];
        }
        
    }
    
    if ([studentsForDelete count] > 0)
        [self.mapView removeAnnotations:[studentsForDelete copy]];
        
    //create new students
    for (int i = 0; i < 15; i++) {
        
        NSString* fullStudentName = [self getRandomStudentName];
        
        Student* student = [[Student alloc] initWithName:fullStudentName andWithCenterCoordinate:self.mapView.userLocation.location.coordinate];
        [self setLocationForStudent:student];
        [self.students addObject:student];
        
    }
    
    [self.mapView showAnnotations:self.students animated:YES];
    
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

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
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
    
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        
        MKPolyline* routePolyline = (MKPolyline*)overlay;
        
        MKPolylineRenderer* renderer = [[MKPolylineRenderer alloc] initWithPolyline:routePolyline];
        
        renderer.lineWidth = 2;
        renderer.strokeColor = [UIColor greenColor];
        
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
