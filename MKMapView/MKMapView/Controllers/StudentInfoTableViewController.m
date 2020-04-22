//
//  StudentInfoTableViewController.m
//  MKMapView
//
//  Created by kluv on 22/04/2020.
//  Copyright © 2020 com.kluv.hw24. All rights reserved.
//

#import "StudentInfoTableViewController.h"

@interface StudentInfoTableViewController ()

@end

@implementation StudentInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.firstNameLabel.text = self.student.firstName;
    self.lastNameLabel.text = self.student.lastName;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy"];
    
    self.birthDateLabel.text = [formatter stringFromDate:self.student.birthDate];
    
    self.sexLabel.text = self.student.sex == StudentMale ? @"Male" : @"Female";
    self.addressLabel.text = self.student.address;
    
}

- (IBAction)actionDone:(UIBarButtonItem *)sender {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}
@end
