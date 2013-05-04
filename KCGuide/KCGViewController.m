//
//  KCGViewController.m
//  KCGuide
//
//  Created by JerryTaylorKendrick on 4/25/13.
//  Copyright (c) 2013 DeanAMH. All rights reserved.:
//

#import "KCGViewController.h"

// Preferred networking framework for URL processing
#import "AFNetworking.h"

// Networking framework used by Ray Wenderlich for URL processing
//#import "ASIHTTPRequest.h"

#import "SiteLocation.h"
#import "MBProgressHUD.h"
#import <CoreLocation/Corelocation.h>


#define METERS_PER_MILE 1609.344


@interface KCGViewController ()

@property (strong, nonatomic) NSData *response;
@property (strong, nonatomic) NSURLRequest *theRequest;
@property (strong, nonatomic) NSURLRequest *request;
@property (strong, nonatomic) NSURL *url;


@end

@implementation KCGViewController 


@synthesize fliteController;
@synthesize slt;



// This method of the MKMapView class is called when an annotation view (pin) is clicked
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)annotationView
{
/*
   Parameters
     mapView
         The map view containing the annotation view.
      view
         The annotation view that was selected.
     Discussion
        You can use this method to track changes in the selection state of annotation views.
 */
    if ([annotationView.annotation isKindOfClass:[MKUserLocation class]]) {
        return;
    }
    
    //NSLog(@"Title: %@", annotationView.annotation.title);
    //NSLog(@"Subitle: %@", annotationView.annotation.subtitle);}

    // Say the name of the point of interest and its address
    NSString *phrase = [NSString stringWithFormat:@"%@ at %@",annotationView.annotation.title, annotationView.annotation.subtitle];
    [self.fliteController say:phrase  withVoice:self.slt];}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];
    
    
    [self.fliteController say:@"Welcome to the Kansas City guide! Please press the Update Sites button for points of interest near you" withVoice:self.slt];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    
    CLLocationCoordinate2D zoomLocation;
    
    //Don't Forget To Adopt CLLocationManagerDelegate  protocol
    //set up the Location manager
    CLLocationManager *lm;
    lm = [[CLLocationManager alloc] init];
    lm.desiredAccuracy = kCLLocationAccuracyBest;
    //lm.distanceFilter = DISTANCE_FILTER_VALUE;
    //lm.delegate = self;
    [lm startUpdatingLocation];
    
    CLLocation *youAreHere = [lm location];
    
    CLLocationCoordinate2D coord;
    // Put LocationManager latitude and longitude info into CLLocationCoordinate2D
    // for a one shot fill:
    coord = [youAreHere coordinate];
    
    // Zoom to the current location
    zoomLocation.latitude = coord.latitude;
    zoomLocation.longitude = coord.longitude;
    //NSLog(@"Current Latitude: %f, Current Longitude: %f", zoomLocation.latitude, zoomLocation.longitude);
    
    
    // Zoom to the Location of Cowork Waldo, Kansas City Missouri
    zoomLocation.latitude = 38.9929360;
    zoomLocation.longitude= -94.5942483;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    
    [_mapView setRegion:viewRegion animated:YES];
}


// This method is used to create an annotation view for a point of interest on the site map used in this application
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"SiteLocation";
    //NSLog(@"siteMap viewForAnnotation called");
    if ([annotation isKindOfClass:[SiteLocation class]]) {
        
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier: identifier];
        
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            annotationView.image = [UIImage imageNamed:@"arrest.png"];//here we use a nice image instead of the default pins
            // Add to siteMap:viewForAnnotation: after setting the image on the annotation view
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        } else {
            annotationView.annotation = annotation;
        }
        return annotationView;
    }
    return nil;
}


// This method is used to annotate the map view with pins for each point of interest site found using
// Google Place "nearby search" URL
- (void)siteMap:(MKMapView *)siteMap annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    SiteLocation *location = (SiteLocation*)view.annotation;
    
    NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
   [location.mapItem openInMapsWithLaunchOptions:launchOptions];
}


- (void)plotSitePositions:(NSData *)responseData {
    for (id<MKAnnotation> annotation in _mapView.annotations) {
        [_mapView removeAnnotation:annotation];
    }
    
    NSError *err = nil;
    NSDictionary *jsonArray=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&err];
    if (!jsonArray) {
        NSLog(@"Error parsing JSON: %@", err);
    } else {
        for(NSDictionary *results in [jsonArray objectForKey:@"results"]) {
            //NSLog(@"%@",results);
            for (NSDictionary *geometry in [results objectForKey:@"geometry"]){
                //NSString *iconURL = [results objectForKey:@"icon"];
                NSString *name = [results objectForKey:@"name"];
                //NSLog(@"Name: %@", name );
                NSNumber *latitude = [results valueForKeyPath:@"geometry.location.lat"];
                //NSLog(@"Latitude %@",latitude);
                NSNumber *longitude = [results valueForKeyPath:@"geometry.location.lng"];
                //NSLog(@"Longitude %@",longitude);
                
                NSString *address = [NSString alloc];
                address =  [results objectForKey:@"vicinity"];
                
                CLLocationCoordinate2D coordinate;
                coordinate.latitude = latitude.doubleValue;
                coordinate.longitude = longitude.doubleValue;
                SiteLocation *annotation = [[SiteLocation alloc] initWithName:name address:address coordinate:coordinate] ;
                [_mapView addAnnotation:annotation];
            }
        }
    }
}


- (IBAction)updateButton:(id)sender {
    // Setting the site map region
    MKCoordinateRegion siteRegion = [_mapView region];
    CLLocationCoordinate2D centerLocation = siteRegion.center;
    
    // Getting the center location coordinates
    NSString *location = [NSString stringWithFormat:@"%f,%f", centerLocation.latitude, centerLocation.longitude];
    //NSLog(@"The center location coordinates are: %@",location);
    
   /**********************************************************************************
    *  Description fo the Google Place Nearby Search request and JSON format results *
    **********************************************************************************
    
    A Nearby Search request is an HTTP URL of the following form:
     
               https://maps.googleapis.com/maps/api/place/nearbysearch/json&parameters
     
    (Note: A registered usage key is required to use Google Place.  My key is: AIzaSyATKtn7vfUPQ__vDMuSLaVhsBK7GR_hI64  )
     
    Example search:
     
    https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=38.9929360,-94.5942483&radius=500&sensor=false&key=AIzaSyATKtn7vfUPQ__vDMuSLaVhsBK7GR_hI64
     
    The json parameter (recommended) indicates output in JavaScript Object Notation (JSON), xml indicates output as XML
    Certain parameters are required to initiate a Nearby Search request. As is standard in URLs, all parameters are separated
    using the ampersand (&) character.
     
    Required parameters
     
    key — Your application's API key. This key identifies your application for purposes of quota management and so that Places 
          added from your application are made immediately available to your app. Visit the APIs Console to create an API Project
          and obtain your key.
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
  
    Search results have the form (in JSON):
     
     "html_attributions" : [],
     "next_page_token" : "ClRGAAAADBjoE5AUNvzKEJVCY_kIRi0rnvgC7bL9HRFmSdUSErK3jS70PelvwcI5_-lrvSArkoFI5d-ZYMs5wyNl90dQfgorxTmO5KOHWFmy6wMU_FQSEKSOYMIzGjomO40wCz6WRZ0aFINVsYja6iR06DKpmdyNOrYBZEJk",
     "results" : [     {
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
     "status" : "OK"
    ************************************************************************************************************
    */
    
    // Google Place registered key
    NSString *key = @"AIzaSyATKtn7vfUPQ__vDMuSLaVhsBK7GR_hI64";
    
    // URL string with variables for the "location" and "key" values
    NSString *searchString = [NSString stringWithFormat: @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%@&radius=500&sensor=false&key=%@",location,key];
    
    // URL string in encoded format
    NSString *encodedString = [searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    // All variable required for the AFSJSONRequestOperation method
    _url = [NSURL URLWithString:encodedString];
    _request = [NSURLRequest requestWithURL:_url];
    //NSURLRequest *theRequest = [NSURLRequest requestWithURL:url];
    _theRequest = [NSURLRequest requestWithURL:_url];
    NSURLResponse *resp = nil;
    NSError *err = nil;
    
    //NSData *response = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &resp error: &err];
    _response = [NSURLConnection sendSynchronousRequest: _theRequest returningResponse: &resp error: &err];
    if (_response == nil) {
        NSLog(@"The was problem accessing the Google Place data, try again");
        return;
    }
    

    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:self.request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        // Success Block code.  This code is executed when a web service call is successful
        //NSLog(@"Successful AFSONRequestOperation call");
        //NSLog(@"%@", JSON);
        // Turn progress indicator off
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        //[self plotSitePositions:_response];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        // Failure Block code.  This code is executed when a web service call doesn't work.
        NSLog(@"An AFJSON request error occurred: %@", error);
        // Turn progress indicator off
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    [operation start];
    // Start progress indicator running
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading points of interest.";
    
    [self plotSitePositions:_response];
    
    
   /****************************************
    *  Code to test the Web URL and access *
    ****************************************
    NSDictionary *jsonArray=[NSJSONSerialization JSONObjectWithData:_response options:NSJSONReadingMutableContainers error:&err];
    if (!jsonArray) {
        NSLog(@"Error parsing JSON: %@", err);
    } else {
        for(NSDictionary *results in [jsonArray objectForKey:@"results"]) {
            NSLog(@"----------------------------------- item beginning ----------------------------------------------------");
            //NSLog(@"%@",results);
            for (NSDictionary *geometry in [results objectForKey:@"geometry"]){
                 //NSString *iconURL = [results objectForKey:@"icon"];
                 NSString *name = [results objectForKey:@"name"];
                 NSLog(@"Name: %@", name);
                 NSNumber *latitude = [results valueForKeyPath:@"geometry.location.lat"];
                 NSLog(@"Latitude %@",latitude);
                 NSNumber *longitude = [results valueForKeyPath:@"geometry.location.lng"];
                 NSLog(@"Longitude %@",longitude);
            }
            NSLog(@"----------------------------------- item end ----------------------------------------------------------");
        }
    }
    **************************************
    */
}


- (FliteController *)fliteController {
	if (fliteController == nil) {
		fliteController = [[FliteController alloc] init];
	}
	return fliteController;
}


- (Slt *)slt {
	if (slt == nil) {
		slt = [[Slt alloc] init];
	}
	return slt;
}
    


@end

