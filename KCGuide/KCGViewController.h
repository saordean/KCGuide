//
//  KCGViewController.h
//  KCGuide
//
//  Created by JerryTaylorKendrick on 4/25/13.
//  Copyright (c) 2013 DeanAMH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>



@interface KCGViewController : UIViewController<MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *siteMap;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
- (IBAction)updateButton:(id)sender;

@end
