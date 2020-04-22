//
//  MKAnnotationView.h
//  MKMapView
//
//  Created by kluv on 21/04/2020.
//  Copyright © 2020 com.kluv.hw24. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotationView.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (MKAnnotationView)

- (MKAnnotationView*) superAnnotationView;

@end

NS_ASSUME_NONNULL_END
