//
//  MapViewController.m
//  Photobook
//
//  Created by seta cheam on 7/8/16.
//  Copyright © 2016 seta cheam. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "Services.h"
#import "Tags.h"
#import "SoundDetailViewController.h"
#import "CCHMapClusterController.h"
#import "CCHMapClusterAnnotation.h"

@interface MapViewController ()<MKMapViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *photoMap;
@property (strong, nonatomic) MKPointAnnotation * selectedPoint;
@property (nonatomic) NSInteger selectedTag;
@property (nonatomic) NSInteger counter;

@property (strong, nonatomic) CCHMapClusterController *mapClusterController;
@property (strong, nonatomic) NSMutableArray * notationArray;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self defaultSetupView];
}

- (void)defaultSetupView {
    
    self.photoMap.delegate = self;
    self.counter = 0;
    
    self.currentLatitude = [Services storeGetFloatDefaultSettingByKey:@"lngKey"];
    self.currentLongitude = [Services storeGetFloatDefaultSettingByKey:@"latKey"];
    
    if (self.locationArray.count > 0){
        
        Tags * tag = self.locationArray[0];
        PhotoSound * photo = tag.photoSound;
        
        CLLocationCoordinate2D coor = CLLocationCoordinate2DMake([photo.latitude floatValue],
                                                                 [photo.longitude floatValue]);
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coor, self.photoMap.frame.size.width,
                                                                       self.photoMap.frame.size.height);
        [self.photoMap setRegion:[self.photoMap regionThatFits:region] animated:YES];
        
        self.notationArray = [NSMutableArray new];
        for (Tags * tag in self.locationArray){
            
            PhotoSound * photo = tag.photoSound;
            
            CLLocationCoordinate2D coorPhoto = CLLocationCoordinate2DMake([photo.latitude floatValue],
                                                                          [photo.longitude floatValue]);
            
            MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
            point.coordinate = coorPhoto;
            point.title = tag.name;
            [self.notationArray addObject:point];
            
        }
        
    }
    
    self.mapClusterController = [[CCHMapClusterController alloc] initWithMapView:self.photoMap];
    [self.mapClusterController addAnnotations:self.notationArray withCompletionHandler:NULL];
    [self.mapClusterController selectAnnotation:self.notationArray[0] andZoomToRegionWithLatitudinalMeters:1000 longitudinalMeters:1000];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    static NSString* AnnotationIdentifier = @"AnnotationIdentifier";
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
    if(annotationView)
        return annotationView;
    else
    {
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                        reuseIdentifier:AnnotationIdentifier];

        Tags * tag = [self.locationArray objectAtIndex:self.counter];
        PhotoSound * photo = tag.photoSound;
        
        NSData *imgData = [NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:photo.thumbnail]];
        
        annotationView.image = [Services imageWithImage:[UIImage imageWithData:imgData] scaledToWidth:50];
        annotationView.canShowCallout = NO;
        
        annotationView.layer.cornerRadius = 2;
        annotationView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        annotationView.layer.shadowOffset = CGSizeMake(0.5, 4.0);
        annotationView.layer.shadowOpacity = 0.5;
        annotationView.layer.shadowRadius = 5.0;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(calloutTapped:)];
        [annotationView setTag:self.counter];
        [annotationView addGestureRecognizer:tapGesture];
        
        self.counter ++;
        
        return annotationView;
    }
    return nil;
}

-(void) calloutTapped:(UITapGestureRecognizer *) sender {
    
    UIView * view = sender.view;
    id<MKAnnotation> annotation = ((MKAnnotationView*)view).annotation;
    MKPointAnnotation * point = (MKPointAnnotation *)annotation;
    
    self.selectedPoint = point;
    self.selectedTag = view.tag;
    
    [self.photoMap deselectAnnotation:point animated:NO];
    UIActionSheet * actionsheet = [[UIActionSheet alloc] initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View Photos", @"Show route", nil];
    [actionsheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 1:
        {
            if ([[UIApplication sharedApplication] canOpenURL:
                 [NSURL URLWithString:@"comgooglemaps://"]]) {
                [[UIApplication sharedApplication] openURL:
                 [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?saddr=%f,%f&daddr=%f,%f",self.currentLatitude, self.currentLongitude, self.selectedPoint.coordinate.latitude, self.selectedPoint.coordinate.longitude]]];
            } else {
                [[UIApplication sharedApplication] openURL:
                 [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f",self.currentLatitude, self.currentLongitude, self.selectedPoint.coordinate.latitude, self.selectedPoint.coordinate.longitude]]];
                
            }
        }
            break;
            
        case 0:
        {
            
            Tags * tag = [self.locationArray objectAtIndex:self.selectedTag];

            SoundDetailViewController * sound = [[SoundDetailViewController alloc] init];
            [sound setCurrentTag:tag];
            UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:sound];
            [self presentViewController:nav animated:YES completion:nil];
        }
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
