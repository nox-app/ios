//
//  CheckInViewController.m
//  nox
//
//  Created by Justine DiPrete on 7/6/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "CheckInViewController.h"

#import "Event.h"
#import "JSONKit.h"
#import "Venue.h"

@interface CheckInViewController ()

@end

static NSString * const kFourSquareRequestURL = @"https://api.foursquare.com/v2/venues/search?ll=%f,%f&client_id=Z4HWIUCCIRTBNVAZI4D3L0ESIKAVSBUW0P3OULS4Y45O5BDZ&client_secret=T1KVOWISOYXRIMEB3FPC2W5RIJ4ZJDXJPD2RDYZVCVRYX0W1&v=%@&query=%@";
static NSString * const kClientID = @"Z4HWIUCCIRTBNVAZI4D3L0ESIKAVSBUW0P3OULS4Y45O5BDZ";
static NSString * const kClientSecret = @"T1KVOWISOYXRIMEB3FPC2W5RIJ4ZJDXJPD2RDYZVCVRYX0W1";

@implementation CheckInViewController

- (id)initWithEvent:(Event *)a_event
{
    if(self = [super init])
    {
        m_venues = [[NSMutableArray alloc] init];
        m_event = a_event;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupMap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [m_mapView setShowsUserLocation:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [m_mapView setShowsUserLocation:NO];
    m_hasUpdatedVenues = NO;
}

- (void)setupMap
{
    [m_mapView setShowsUserLocation:YES];
    [self setMapRegion];
    
}

- (void)setMapRegion
{
    MKUserLocation * userLocation = [m_mapView userLocation];
    if(userLocation)
    {
        MKCoordinateSpan span = MKCoordinateSpanMake(0.005, 0.005);
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
        MKCoordinateRegion region = MKCoordinateRegionMake(location, span);
        [m_mapView setRegion:region animated:YES];
    }
}

- (void)updateVenueList
{
    MKUserLocation * userLocation = [m_mapView userLocation];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString * dateString = [formatter stringFromDate:[NSDate date]];
    
    NSURL * request = [NSURL URLWithString:[NSString stringWithFormat:kFourSquareRequestURL, userLocation.coordinate.latitude, userLocation.coordinate.longitude, dateString, @""]];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:request];
    NSURLConnection * urlConnection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    [urlConnection start];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [self setMapRegion];
    if(!m_hasUpdatedVenues)
    {
        [self updateVenueList];
        m_hasUpdatedVenues = YES;
    }
}

- (IBAction)cancelPressed
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)a_connection didReceiveResponse:(NSURLResponse *)a_response
{
    if([a_response expectedContentLength] == NSURLResponseUnknownLength)
    {
        m_downloadBuffer = [[NSMutableData alloc] init];
    }
    else
    {
        m_downloadBuffer = [[NSMutableData alloc] initWithCapacity:[a_response expectedContentLength]];
    }
}

- (void)connection:(NSURLConnection *)a_connection didReceiveData:(NSData *)a_data
{
    [m_downloadBuffer appendData:a_data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)a_connection
{
    JSONDecoder * decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
    
    NSDictionary * response = [[decoder objectWithData:m_downloadBuffer] objectForKey:@"response"];
    if(response)
    {
        NSDictionary * venues = [response objectForKey:@"venues"];
        if(venues)
        {
            [m_venues removeAllObjects];
            
            for(NSDictionary * venue in venues)
            {
                Venue * newVenue = [[Venue alloc] initWithDictionary:venue];
                [m_venues addObject:newVenue];
            }
        }
    }
    [m_tableView reloadData];
}

- (void)connection:(NSURLConnection *)a_connection didFailWithError:(NSError *)a_error
{
    m_downloadBuffer = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [m_venues count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"Identifier";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    Venue * venue = [m_venues objectAtIndex:indexPath.row];
    [cell.textLabel setText:venue.name];
    [cell.imageView setImage:venue.iconImage];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

@end
