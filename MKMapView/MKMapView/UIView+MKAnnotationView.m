//
//  MKAnnotationView.m
//  MKMapView
//
//  Created by kluv on 21/04/2020.
//  Copyright © 2020 com.kluv.hw24. All rights reserved.
//

#import "UIView+MKAnnotationView.h"

@implementation UIView (MKAnnotationView)

- (MKAnnotationView*) superAnnotationView {
    
    
    if ([self isKindOfClass:[MKAnnotationView class]]) {
        return (MKAnnotationView*)self;
    }
    
    if (!self.superview) {
        return nil;
    }
    
    return [self.superview superAnnotationView];
    
}

@end
