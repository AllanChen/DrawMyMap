//
//  ViewController.m
//  DrawMap
//
//  Created by Allan.Chan on 5/14/14.
//  Copyright (c) 2014 Allan. All rights reserved.
//

#import "AFNetworking.h"
#import "ViewController.h"

@interface ViewController ()

@property(nonatomic,retain) NSMutableArray *jueweiShopDataArray;
@property(nonatomic) BOOL loadDataTure;
@end

@implementation ViewController
@synthesize mapView;
@synthesize locationManager;
@synthesize touchView;
@synthesize jueweiShopDataArray;
@synthesize errorNum;
@synthesize loadDataTure;
- (void)viewDidLoad
{
    [self initWithMap];
    loadDataTure = FALSE;
    [super viewDidLoad];

}

-(void)initWithMap
{
    redPoint = [UIImage imageNamed:@"blue_point.png"];
    greenPoint = [UIImage imageNamed:@"prue_point.png"];
    locationManager = [[CLLocationManager alloc]init];
    [self.locationManager setDelegate:self];
  
    locationManager.distanceFilter=1000.0f;
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager startUpdatingLocation];
    
    MKCoordinateRegion theRegion = { {0.0, 0.0 }, { 0.0, 0.0 } };
    theRegion.span.longitudeDelta = 0.01f;
    theRegion.span.latitudeDelta = 0.01f;
    MKCoordinateSpan theSpan;
    theSpan.latitudeDelta=0.05;
    theSpan.longitudeDelta=0.05;
    theRegion.center=[locationManager.location coordinate];
    theRegion.span=theSpan;
    [mapView setRegion:[mapView regionThatFits:theRegion] animated:TRUE];
    [mapView setDelegate:self];
    [mapView setShowsUserLocation:YES];
    
    [self.mapView setRegion:theRegion animated:YES];
    [self.mapView setCenterCoordinate:locationManager.location.coordinate animated:YES];
    touchView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"touch_view_bg.png"]];
    [self.view addSubview:touchView];
    [self loadDataFromServer];
    
}

-(IBAction)drawFunction:(id)sender
{
    drawImageView = [[UIImageView alloc] initWithFrame:self.mapView.frame];
    drawImageView.image = [UIImage imageNamed:@"edit_bg.png"];
    drawImageView.userInteractionEnabled = YES;
    [self.view addSubview:drawImageView];
    
    /*
     |  Set the draw size
     |  设置画布大小
     */
    UIGraphicsBeginImageContext(drawImageView.frame.size);
    [drawImageView.image drawInRect:CGRectMake(0, 0, drawImageView.frame.size.width, drawImageView.frame.size.height)];
    
    /*
     |  Init line
     |  初始化线条；
     */
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 53.0/255, 177.0/255, 20.0/255, 1.0);
    CGContextSetLineCap(context,kCGLineCapRound);
    CGContextSetLineWidth(context, 7.0);
    
    [self removeAnnotationsOnTheMap];
    [touchView setUserInteractionEnabled:NO];
    [touchView setAlpha:0.5];
}

-(IBAction)clearFunction:(id)sender
{
    [drawImageView removeFromSuperview];
    [self removeAnnotationsOnTheMap];
    UIGraphicsEndImageContext();
}

/*
 |  Clean Annotation
 |  清除大头针
 */
-(void)removeAnnotationsOnTheMap
{
    NSMutableArray *toRemove = [NSMutableArray arrayWithCapacity:10];
    for (id annotation in mapView.annotations)
    {
        if (annotation != mapView.userLocation)
        {
            [toRemove addObject:annotation];
        }
    }
    [mapView removeAnnotations:toRemove];
}

-(IBAction)resetUserLocaltion:(id)sender
{
    MKCoordinateSpan theSpan;
    theSpan.latitudeDelta=0.05;
    theSpan.longitudeDelta=0.05;
    MKCoordinateRegion theRegion;
    theRegion.center=[locationManager.location coordinate];
    theRegion.span=theSpan;
    [mapView setRegion:[mapView regionThatFits:theRegion] animated:TRUE];
    [self.mapView setCenterCoordinate:locationManager.location.coordinate animated:YES];
    [self.mapView setShowsUserLocation:YES];
}

-(MKPointAnnotation *)addPoint:(double)latitude andLongitude:(double)longitude andtitle:(NSString *)title
{
    MKCoordinateRegion anotherRegin2 = {{latitude,longitude},{0.0,0.0}};
    MKPointAnnotation *pointAnnotation2 = nil;
    pointAnnotation2 = [[MKPointAnnotation alloc] init];
    pointAnnotation2.coordinate = anotherRegin2.center;
    pointAnnotation2.title=title;
    pointAnnotation2.subtitle=@"AllanChan";
    return pointAnnotation2;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch.view == drawImageView)
    {
        CGPoint location = [touch locationInView:drawImageView];
        pathRef = CGPathCreateMutable();
        CGPathMoveToPoint(pathRef, NULL, location.x, location.y);
    }
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch.view == drawImageView)
    {
        /*
         |  Start draw point
         |  开始画线的第一个点
         */
        
        CGPoint location = [touch locationInView:drawImageView];
        
        /*
         |  draw line
         |  开始画线的路线
         */
        CGPoint pastLocation = [touch previousLocationInView:drawImageView];
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextMoveToPoint(context, pastLocation.x, pastLocation.y);
        CGContextAddLineToPoint(context, location.x, location.y);
        CGContextDrawPath(UIGraphicsGetCurrentContext(), kCGPathFillStroke);
        drawImageView.image = UIGraphicsGetImageFromCurrentImageContext();
        CGPathAddLineToPoint(pathRef, NULL, location.x, location.y);
        
    }
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    /*
     |  End draw
     |  结束绘画
     */
    UITouch *touch = [touches anyObject];
    if (touch.view == drawImageView)
    {
        /*
         |  Get Data and add point
         */

        CGPathCloseSubpath(pathRef);
        CLLocationCoordinate2D temLocation;
        CGPoint locationConverToImage;
        if ([self.jueweiShopDataArray count]>0)
        {
            for (int i=0; i<[self.jueweiShopDataArray count]; i++)
            {
                temLocation.latitude = [[[[[self.jueweiShopDataArray objectAtIndex:i] objectForKey:@"businesses"] objectAtIndex:i] objectForKey:@"latitude"] doubleValue];
                temLocation.longitude = [[[[[self.jueweiShopDataArray objectAtIndex:i] objectForKey:@"businesses"] objectAtIndex:i] objectForKey:@"longitude"] doubleValue];
                NSLog(@"%f",temLocation.longitude);
                locationConverToImage = [mapView convertCoordinate:temLocation toPointToView:drawImageView];
                if (CGPathContainsPoint(pathRef, NULL, locationConverToImage, NO))
                {
                [mapView addAnnotation:[self addPoint:[[[[[self.jueweiShopDataArray objectAtIndex:i] objectForKey:@"businesses"] objectAtIndex:i] objectForKey:@"latitude"] doubleValue] andLongitude:[[[[[self.jueweiShopDataArray objectAtIndex:i] objectForKey:@"businesses"] objectAtIndex:i] objectForKey:@"longitude"] doubleValue] andtitle:[[[[self.jueweiShopDataArray objectAtIndex:i] objectForKey:@"businesses"] objectAtIndex:i] objectForKey:@"name"]]];
                }
            }
        }
        [self.touchView setUserInteractionEnabled:YES];
        [self.touchView setAlpha:1.0];
        [self.view insertSubview:self.mapView aboveSubview:drawImageView];
        [self.view insertSubview:self.touchView aboveSubview:self.mapView];
    }
}

-(void)loadDataFromServer
{
    if (locationManager.location.coordinate.latitude > 1)
    {
        
        /*
         | coordinate
         | 坐标
         */
        
        NSString *dataURLString = [[NSString alloc] initWithFormat:@"%@",@"http://your website address/api.php"];
        NSURLRequest *urlRequest = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:dataURLString]];
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                             {
                                                 self.jueweiShopDataArray = [JSON objectForKey:@"deals"];
                                                 //[self showDataToInterface:self.jueweiShopDataArray];
                                             } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                             {
                                                 NSLog(@"%@",error);
                                             }];
        [operation start];
    }
    
    else
    {
        NSLog(@"please let me know where you are");
    }
  
}


-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay{
	if([overlay isKindOfClass:[MKPolygon class]]){
		MKPolygonView *view = [[MKPolygonView alloc] initWithOverlay:overlay];
		view.lineWidth=5;
		view.strokeColor=[UIColor blueColor];
		view.fillColor=[[UIColor blueColor] colorWithAlphaComponent:0.5];
		return view;
	}
	return nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/*
 |   AddAnnotation;
 |   添加大头针动画;
 */

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    MKAnnotationView *annotationView;
    for (annotationView in views)
    {
        if ([annotationView isKindOfClass:[MKPinAnnotationView class]])
        {
            CGRect endFrame = annotationView.frame;
            annotationView.frame = CGRectMake(endFrame.origin.x, endFrame.origin.y - 230.0, endFrame.size.width, endFrame.size.height);
            annotationView.image = redPoint;
            [UIView beginAnimations:@"drop" context:NULL];
            [UIView setAnimationDuration:0.45];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [annotationView setFrame:CGRectMake(endFrame.origin.x, endFrame.origin.y, 16, 25)];
            [UIView commitAnimations];
        }
    }
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([[view.annotation title] isEqualToString:@"Current Location"] )
    {
        return;
    }
    else
    {
        view.image = greenPoint;
    }
}
-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if ([[view.annotation title] isEqualToString:@"Current Location"] )
    {
        return;
    }
    else
    {
        view.image = redPoint;
    }
}


-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    /*
     |  Get UserLocation (animation);
     |  获取用户的地理位置，然后定位到当前位置（有动画）;
     */
    [self.mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];

}

/*
 |  Location Fail ;
 |  定位失败 ;
 */
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"失败");
}

@end
