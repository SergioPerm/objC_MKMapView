//
//  ViewController.m
//  MKMapView
//
//  Created by kluv on 10/04/2020.
//  Copyright © 2020 com.kluv.hw24. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <MKMapViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem* addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionAdd:)];
    UIBarButtonItem* zoomButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(actionZoom:)];
    
    self.navigationItem.rightBarButtonItems = @[zoomButton, addButton];
      
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    self.mapView.showsUserLocation = YES;
    
}

#pragma mark - Actions

- (void)actionAdd:(UIBarButtonItem*) sender {
    
    MyMapAnnotaion* annotaion = [[MyMapAnnotaion alloc] init];
    
    annotaion.title = @"Test title";
    annotaion.subtitle = @"Test subtitle";
    annotaion.coordinate = self.mapView.region.center;
    
    [self.mapView addAnnotation:annotaion];
    
}

- (void)actionZoom:(UIBarButtonItem*) sender {
 
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

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }

    static NSString* identifier = @"Annotation";

    MKPinAnnotationView* pin = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];

    if (!pin) {

        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];

        pin.pinTintColor = [UIColor purpleColor];
        pin.animatesDrop = YES;
        pin.canShowCallout = YES;
        pin.draggable = YES;
        //pin.image = [UIImage imageNamed:@"pin"];
        //pin.centerOffset = CGPointMake(0, -20);

    } else {

        pin.annotation = annotation;

    }

    pin.canShowCallout = YES;

    return pin;

}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    
    if (newState == MKAnnotationViewDragStateEnding) {
        
        CLLocationCoordinate2D location = view.annotation.coordinate;
        MKMapPoint point = MKMapPointForCoordinate(location);
        
       
        
    }
    
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
