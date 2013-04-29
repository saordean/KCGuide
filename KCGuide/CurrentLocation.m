//
//  CurrentLocation.m
//  KCGuide
//
//  Created by JerryTaylorKendrick on 4/25/13.
//  Copyright (c) 2013 DeanAMH. All rights reserved.
//

#import "CurrentLocation.h"
#import <AddressBook/AddressBook.h>


@interface CurrentLocation()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, assign) CLLocationCoordinate2D theCoordinate;
@end

/*
 
  Results from the Google Place "search nearby"  URL have the form:
 
 {
 "geometry" : {
 "location" : {
 "lat" : 38.99361860,
 "lng" : -94.60114209999999
 },
 "viewport" : {
 "northeast" : {
 "lat" : 39.00020490,
 "lng" : -94.59393399999999
 },
 "southwest" : {
 "lat" : 38.9850060,
 "lng" : -94.6083340
 }
 }
 },
 "icon" : "http://maps.gstatic.com/mapfiles/place_api/icons/geocode-71.png",
 "id" : "ff5819fecb085310cfa1e8ec10dce2a644adce8d",
 "name" : "Ward Parkway",
 "reference" : "CpQBiQAAALEi8lnxz6Qwgw-5YHWSqvAj3HODpWWszZrFo6zqc-x0bApji_qUJsyWT3Qplymu5t3SXJb8DDM-3NdAs0UAncEHvX9wWuL3vvvMIvZe3sj000Lvt56UUyP0fjP_iWPvn_7Gg5qM_rZyC2laFREuHdhzGbsWlwOBfOvZTM94TxTGDN9FEksrmv7feyLxDpbNhRIQRyFb9xll38aqab-OOUlcFhoUD4UdYCUaFlQ2XEcqiGVrJArgSo8",
 "types" : [ "neighborhood", "political" ],
 "vicinity" : "Kansas City"
 },

 */



@implementation CurrentLocation

- (id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        if ([name isKindOfClass:[NSString class]]) {
            self.name = name;
        } else {
            self.name = @"Unknown charge";
        }
        self.address = address;
        self.theCoordinate = coordinate;
    }
    return self;
}

// Returns the map item location name
- (NSString *)title {
    return _name;
}


// Returns the address of the map item
- (NSString *)subtitle {
    return _address;
}

// Returns the map item location as latitude and longitude
- (CLLocationCoordinate2D)coordinate {
    return _theCoordinate;
}

- (MKMapItem*)mapItem {
/*
    NSDictionary *addressDict = @{(NSString*)kABPersonAddressStreetKey : _address};
    MKPlacemark *placemark = [[MKPlacemark alloc]
                              initWithCoordinate:self.coordinate
                              addressDictionary:addressDict];
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = self.title;
 */
   MKMapItem *mapItem = [MKMapItem alloc];
   //MKPlacemark *placemark = [MKPlacemark alloc];
  

    return mapItem;
}

@end
