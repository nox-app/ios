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
#import "Location.h"
#import "PlacePost.h"
#import "Profile.h"
#import "RoundedView.h"
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iconDidDownload:) name:kVenueIconDidDownloadNotification object:nil];
    
    m_confirmView.layer.cornerRadius = 8.0;
    m_confirmView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    m_confirmView.layer.borderWidth = 1.0;
}

- (void)iconDidDownload:(NSNotification *)a_notification
{
    Venue * venue = [a_notification object];
    
    //todo(jdiprete): Is this better than just reloading every time?
    NSUInteger index = [m_venues indexOfObject:venue];
    if(index != NSNotFound)
    {
        [m_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kVenueIconDidDownloadNotification object:nil];
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
    Venue * venue = [m_venues objectAtIndex:indexPath.row];
    [m_confirmPlaceName setText:[venue name]];
    [m_confirmIconView setImage:[venue iconImage]];
    [m_confirmAddressLabel setText:[[venue location] address]];
    [m_confirmCityStateLabel setText:[NSString stringWithFormat:@"%@, %@", [[venue location] city], [[venue location] state]]];
    
    [m_confirmView setCenter:self.view.center];
    [m_confirmView setHidden:YES];
    [self.view addSubview:m_confirmView];
    [m_confirmView attachPopUpAnimation];
    [m_confirmView setHidden:NO];
    
    m_currentVenue = venue;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)confirmPressed:(id)sender
{
    PlacePost * post = [[PlacePost alloc] init];
    [post setVenue:m_currentVenue];
    [post setTime:[NSDate date]];
    [post setLocation:[[Profile sharedProfile] lastLocation]];
    [post setUser:[[Profile sharedProfile] user]];
    [post setEvent:[m_event resourceURI]];
    [post setType:kPlaceType];
    [m_event addPost:post];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelConfirmPressed:(id)sender
{
    [m_confirmView removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
