//
//  ViewController.h
//  MKMapView
//
//  Created by kluv on 10/04/2020.
//  Copyright © 2020 com.kluv.hw24. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MyMapAnnotaion.h"

@interface ViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) CLLocation* location;

@property (weak, nonatomic) IBOutlet UILabel *range5000Label;
@property (weak, nonatomic) IBOutlet UILabel *range3000Label;
@property (weak, nonatomic) IBOutlet UILabel *range1000Label;
@property (weak, nonatomic) IBOutlet UILabel *rangeMeetPointLabel;

@end

