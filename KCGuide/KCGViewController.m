//
//  KCGViewController.m
//  KCGuide
//
//  Created by JerryTaylorKendrick on 4/25/13.
//  Copyright (c) 2013 DeanAMH. All rights reserved.
//

#import "KCGViewController.h"
#import "ASIHTTPRequest.h"
#import "CurrentLocation.h"
#import "MBProgressHUD.h"

#define METERS_PER_MILE 1609.344


@interface KCGViewController ()

@end

@implementation KCGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    // 1
    CLLocationCoordinate2D zoomLocation;
    
    // Location of Cowork Waldo, Kansas City Missouri
    zoomLocation.latitude = 38.9929360;
    zoomLocation.longitude= -94.5942483;
    
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    
    // 3
    //[_mapView setRegion:viewRegion animated:YES];
    [_siteMap setRegion:viewRegion animated:YES];
}


// Add the following method
- (void)siteMap:(MKMapView *)siteMap annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    CurrentLocation *location = (CurrentLocation*)view.annotation;
    
    NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
    [location.mapItem openInMapsWithLaunchOptions:launchOptions];
}

- (void)plotSitePositions:(NSData *)responseData {
    for (id<MKAnnotation> annotation in _siteMap.annotations) {
        [_siteMap removeAnnotation:annotation];
    }
    
    NSDictionary *root = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
    NSArray *data = [root objectForKey:@"data"];
    
    for (NSArray *row in data) {
        NSNumber * latitude = [[row objectAtIndex:22]objectAtIndex:1];
        NSNumber * longitude = [[row objectAtIndex:22]objectAtIndex:2];
        NSString * crimeDescription = [row objectAtIndex:18];
        NSString * address = [row objectAtIndex:14];
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = latitude.doubleValue;
        coordinate.longitude = longitude.doubleValue;
        CurrentLocation *annotation = [[CurrentLocation alloc] initWithName:crimeDescription address:address coordinate:coordinate] ;
        [_siteMap addAnnotation:annotation];
	}
}



- (void)plotPoiPositions:(NSData *)responseData {
    for (id<MKAnnotation> annotation in _siteMap.annotations) {
        [_siteMap removeAnnotation:annotation];
    }
    
    NSDictionary *root = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
    NSArray *data = [root objectForKey:@"data"];
    
    for (NSArray *row in data) {
        NSNumber * latitude = [[row objectAtIndex:22]objectAtIndex:1];
        NSNumber * longitude = [[row objectAtIndex:22]objectAtIndex:2];
        NSString * crimeDescription = [row objectAtIndex:18];
        NSString * address = [row objectAtIndex:14];
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = latitude.doubleValue;
        coordinate.longitude = longitude.doubleValue;
        CurrentLocation *annotation = [[CurrentLocation alloc] initWithName:crimeDescription address:address coordinate:coordinate] ;
        [_siteMap addAnnotation:annotation];
	}
}



- (IBAction)updateButton:(id)sender {
    // 1
    //MKCoordinateRegion mapRegion = [_mapView region];
    MKCoordinateRegion siteRegion = [_siteMap region];
    //CLLocationCoordinate2D centerLocation = mapRegion.center;
    CLLocationCoordinate2D centerLocation = siteRegion.center;
    
    // 2
    NSString *jsonFile = [[NSBundle mainBundle] pathForResource:@"command" ofType:@"json"];
    NSString *formatString = [NSString stringWithContentsOfFile:jsonFile encoding:NSUTF8StringEncoding error:nil];
    NSString *json = [NSString stringWithFormat:formatString,
                      centerLocation.latitude, centerLocation.longitude, 0.5*METERS_PER_MILE];
    
    // 3
    
    NSURL *url = [NSURL URLWithString:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=38.9929360,-94.5942483&radius=500&sensor=false&key=AIzaSyATKtn7vfUPQ__vDMuSLaVhsBK7GR_hI64"];
    
    /*
     
     A Nearby Search request is an HTTP URL of the following form:
     
     https://maps.googleapis.com/maps/api/place/nearbysearch/json&parameters
     
     My key is: AIzaSyATKtn7vfUPQ__vDMuSLaVhsBK7GR_hI64 
     
     Example search:
     
     https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=38.9929360,-94.5942483&radius=500&sensor=false&key=AIzaSyATKtn7vfUPQ__vDMuSLaVhsBK7GR_hI64
     
     where may be either of the following values:-94.5954120     json (recommended) indicates output in JavaScript Object Notation (JSON)
     xml indicates output as XML
     Certain parameters are required to initiate a Nearby Search request. As is standard in URLs, all parameters are separated using the ampersand (&) character.
     
     Required parameters
     
     key — Your application's API key. This key identifies your application for purposes of quota management and so that Places added from your application are made immediately available to your app. Visit the APIs Console to create an API Project and obtain your key.
     location — The latitude/longitude around which to retrieve Place information. This must be specified as latitude,longitude.
     radius — Defines the distance (in meters) within which to return Place results. The maximum allowed radius is 50 000 meters. Note that radius must not be included if rankby=distance (described under Optional parameters below) is specified.
     sensor — Indicates whether or not the Place request came from a device using a location sensor (e.g. a GPS) to determine the location sent in this request. This value must be either true or false.
     
     Optional parameters
     
     keyword — A term to be matched against all content that Google has indexed for this Place, including but not limited to name, type, and address, as well as customer reviews and other third-party content.
     language — The language code, indicating in which language the results should be returned, if possible. See the list of supported languages and their codes. Note that we often update supported languages so this list may not be exhaustive.
     minprice and maxprice (optional) — Restricts results to only those places within the specified range. Valid values range between 0 (most affordable) to 4 (most expensive), inclusive. The exact amount indicated by a specific value will vary from region to region.
     name — A term to be matched against the names of Places. Results will be restricted to those containing the passed name value. Note that a Place may have additional names associated with it, beyond its listed name. The API will try to match the passed name value against all of these names; as a result, Places may be returned in the results whose listed names do not match the search term, but whose associated names do.
     opennow — Returns only those Places that are open for business at the time the query is sent. Places that do not specify opening hours in the Google Places database will not be returned if you include this parameter in your query.
     rankby — Specifies the order in which results are listed. Possible values are:
     prominence (default). This option sorts results based on their importance. Ranking will favor prominent places within the specified area. Prominence can be affected by a Place's ranking in Google's index, the number of check-ins from your application, global popularity, and other factors.
     distance. This option sorts results in ascending order by their distance from the specified location. Ranking results by distance will set a fixed search radius of 50km. One or more of keyword, name, or types is required.
     types — Restricts the results to Places matching at least one of the specified types. Types should be separated with a pipe symbol (type1|type2|etc). See the list of supported types.
     pagetoken — Returns the next 20 results from a previously run search. Setting a pagetoken parameter will execute a search with the same parameters used previously — all parameters other than pagetoken will be ignored.
     zagatselected — Restrict your search to only those locations that are Zagat selected businesses. This parameter does not require a true or false value, simply including the parameter in the request is sufficient to restrict your search. The zagatselected parameter is experimental, and only available to Places API enterprise customers.
    */
    
    
    // 4
    ASIHTTPRequest *_request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *request = _request;
    
    request.requestMethod = @"POST";
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request appendPostData:[json dataUsingEncoding:NSUTF8StringEncoding]];
    // 5
    [request setDelegate:self];
    
    [request setCompletionBlock:^{
        // Add at start of setCompletionBlock and setFailedBlock blocks
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSString *responseString = [request responseString];
        NSLog(@"Response: %@", responseString);
        [self plotPoiPositions:request.responseData];
    }];
    
    [request setFailedBlock:^{
        // Add at start of setCompletionBlock and setFailedBlock blocks
        [MBProgressHUD hideHUDForView:self.view animated:YES];        NSError *error = [request error];
        NSLog(@"Error: %@", error.localizedDescription);
    }];
    
    // 6
    [request startAsynchronous];
    // Add right after [request startAsynchronous] in refreshTapped action method
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading points of interest...";
    
}

@end

