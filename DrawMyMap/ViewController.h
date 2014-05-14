//
//  ViewController.h
//  DrawMap
//
//  Created by Allan.Chan on 5/14/14.
//  Copyright (c) 2014 Allan. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
@interface ViewController : UIViewController<CLLocationManagerDelegate,MKMapViewDelegate>
{
    UIImageView *drawImageView;
    CGMutablePathRef pathRef;
    UIImage *redPoint;
    UIImage *greenPoint;
    MKPolygon *overflowParkingPolygon;
}
@property(nonatomic,retain) IBOutlet UIView *touchView;
@property(nonatomic,retain)IBOutlet MKMapView *mapView;
@property(nonatomic,retain)CLLocationManager *locationManager;
@property(nonatomic,retain) NSString *maplatitude;
@property(nonatomic,retain) NSString *maplongitude;
@property(nonatomic,retain) UIView  *loadingView;
@property(nonatomic,retain) NSMutableArray *mapArrayLatitude;
@property(nonatomic,retain) NSMutableArray *mapArrayLongitude;
@property(nonatomic,retain) NSString *errorNum;
@end
