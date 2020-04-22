//
//  StudentInfoTableViewController.h
//  MKMapView
//
//  Created by kluv on 22/04/2020.
//  Copyright © 2020 com.kluv.hw24. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Student.h"

NS_ASSUME_NONNULL_BEGIN

@interface StudentInfoTableViewController : UITableViewController

- (IBAction)actionDone:(UIBarButtonItem *)sender;

@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *birthDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *sexLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (strong, nonatomic) Student* student;

@end

NS_ASSUME_NONNULL_END
