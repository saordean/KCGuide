//
//  KCGViewController.h
//  KCGuide
//
//  Created by JerryTaylorKendrick on 4/25/13.
//  Copyright (c) 2013 DeanAMH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Slt/Slt.h>
#import <OpenEars/FliteController.h>

FliteController *fliteController;
Slt *slt;


@interface KCGViewController : UIViewController<MKMapViewDelegate>

@property (strong, nonatomic) FliteController *fliteController;
@property (strong, nonatomic) Slt *slt;
@property (weak, nonatomic) IBOutlet MKMapView *siteMap;
- (IBAction)updateButton:(id)sender;

@end
