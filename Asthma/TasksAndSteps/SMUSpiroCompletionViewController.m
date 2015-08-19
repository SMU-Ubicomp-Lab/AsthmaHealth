//
//  SMUSpiroCompletionViewController.m
//  Asthma
//
//  Created by Daniel Huang on 6/17/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "SMUSpiroCompletionViewController.h"
#include <stdlib.h>
#import "GraphMaker.h"
@import HealthKit;

@interface SMUSpiroCompletionViewController ()
@property (strong, nonatomic) HKHealthStore *healthStore;
@end

// Table View Cell
float const kCellHeight = 300.0f;
NSString * const kHostCellIdentifier = @"";
NSString * const kDefaultCellIdentifier = @"Cell";

// Keys for values in spiro analysis results array
NSString * const kVolumeCurveKey = @"VolumeCurveInLiters";
NSString * const kFVCKey = @"FVCInLiters";
NSString * const kFEVOneKey = @"FEVOneInLiters";
NSString * const kPkFlowKey = @"PeakFlowInLitersPerSecond";

// Test Finished Alert
NSString * const kFinishedAlertTitle = @"Test Finished";
NSString * const kFinishedAlertMessage = @"The data has been stored and this test is now over. You will now be redirected back to the dashboard.";
NSString * const kButtonTitle = @"OK";


//float const kGraphFrameWidth = 160.0f;
//float const kGraphFrameHeight = 50.0f;


@implementation SMUSpiroCompletionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.healthStore = [[HKHealthStore alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIViewController lifecycle methods
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Chart behavior
-(void)initPlot:(NSString *)plotIdentifier {
    [self configureHost];
    [self configureGraph:plotIdentifier];
    
}

-(void)configureHost {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kHostCellIdentifier];
    [cell setBounds:CGRectMake(0, 0, [cell width], kCellHeight)];
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:[cell bounds]];
    self.hostView.allowPinchScaling = YES;
}

-(void)configureGraph:(NSString *)plotIdentifier {
    // Create the plot
    CPTScatterPlot *spiroPlot = [[CPTScatterPlot alloc] init];
    spiroPlot.dataSource = self;
    spiroPlot.identifier = plotIdentifier;
    
    self.hostView.hostedGraph = [GraphMaker getGraph:self.hostView.bounds withIdentifer:plotIdentifier withPlot:spiroPlot];

}


#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *) __unused plot {
    return [[[[CPDStockPriceStore sharedInstance] storedResults] valueForKey:kVolumeCurveKey] count];
    
    
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    float valueForGraph = 0.0f;
    NSArray *curve;
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            if([plot.identifier isEqual:FlowVsVolume])
            {
                return [[[[CPDStockPriceStore sharedInstance] storedResults] valueForKey:kVolumeCurveKey] objectAtIndex:index];
            }
            return [NSNumber numberWithUnsignedInteger:index];
            break;
            
        case CPTScatterPlotFieldY:
            
            if ([plot.identifier isEqual:FlowVsTime] == YES || [plot.identifier isEqual:FlowVsVolume] == YES) {
                curve = [[[CPDStockPriceStore sharedInstance] storedResults] valueForKey:FlowVsTime];
            } else if ([plot.identifier isEqual:VolumeVsTime] == YES) {
                curve = [[[CPDStockPriceStore sharedInstance] storedResults] valueForKey:VolumeVsTime];
            }

            valueForGraph = [[curve objectAtIndex:index] floatValue];
            
            NSDecimalNumber *dec = [[NSDecimalNumber alloc] initWithFloat:valueForGraph*100.0]; // Multiplied by 100 so a whole number will be displayed on the graph
            return dec;
            break;
    }
    return [NSDecimalNumber zero];
}

# pragma mark - UITableView methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [tableView setRowHeight:kCellHeight]; // this is not the best place to put this
    return 1;
}
-(NSInteger)tableView:(UITableView *) __unused tableView numberOfRowsInSection:(NSInteger) __unused section
{
    return 3;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDefaultCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDefaultCellIdentifier];
        
        //CGRect frame = CGRectMake(0, 0, kGraphFrameWidth, kGraphFrameHeight);
        //UIView *graphView = [[UIView alloc] initWithFrame:frame];
        
        if(indexPath.row == 0)
        {
            [self initPlot:FlowVsVolume];
        }
        else if(indexPath.row == 1)
        {
            [self initPlot:FlowVsTime];
        }
        else if(indexPath.row == 2)
        {
            [self initPlot:VolumeVsTime];
        }
        
        [cell.contentView addSubview:self.hostView];
        
    }
    
    return cell;
}

# pragma mark - Save to Healthkit


- (IBAction)SaveButtonPressed:(id) __unused sender {
    // "Share" (read/write) spirometry measurements (FVC, FEV1, PEF)
    NSLog(@" Save Button pressed");
    NSSet *spirometryObjectTypes = [NSSet setWithObjects:
                                    [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierForcedVitalCapacity],
                                    [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierForcedExpiratoryVolume1],
                                    [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierPeakExpiratoryFlowRate],
                                    nil];
    
    NSLog(@"Going to request access");
    
    // Request access
    [self.healthStore requestAuthorizationToShareTypes:spirometryObjectTypes
                                             readTypes:spirometryObjectTypes
                                            completion:^(BOOL success, NSError *error) {
                                                
                                                if(success == YES)
                                                {
                                                    NSLog(@"Authorization success");
                                                    
                                                    NSLog(@"Access requested");
                                                    
                                                    // prepare values to store (FVC, FEV1, PEF)
                                                    float fvc = [[[[CPDStockPriceStore sharedInstance] storedResults] valueForKey:kFVCKey] floatValue];
                                                    float fev1 = [[[[CPDStockPriceStore sharedInstance] storedResults] valueForKey:kFEVOneKey] floatValue];
                                                    float pef = [[[[CPDStockPriceStore sharedInstance] storedResults] valueForKey:kPkFlowKey] floatValue];
                                                    NSDate *now = [NSDate date];
                                                    
                                                    HKUnit *literUnit = [HKUnit literUnit];
                                                    HKUnit *literPerSecondUnit = [HKUnit unitFromString:@"L/s"];
                                                    
                                                    HKQuantity *fvcQuantity = [HKQuantity quantityWithUnit:literUnit doubleValue:fvc];
                                                    HKQuantity *fev1Quantity = [HKQuantity quantityWithUnit:literUnit doubleValue:fev1];
                                                    HKQuantity *pefQuantity = [HKQuantity quantityWithUnit:literPerSecondUnit doubleValue:pef];
                                                    
                                                    HKQuantityType *fvcType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierForcedVitalCapacity];
                                                    HKQuantityType *fev1Type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierForcedExpiratoryVolume1];
                                                    HKQuantityType *pefType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierPeakExpiratoryFlowRate];
                                                    
                                                    HKQuantitySample *fvcSample = [HKQuantitySample quantitySampleWithType:fvcType quantity:fvcQuantity startDate:now endDate:now];
                                                    HKQuantitySample *fev1Sample = [HKQuantitySample quantitySampleWithType:fev1Type quantity:fev1Quantity startDate:now endDate:now];
                                                    HKQuantitySample *pefSample = [HKQuantitySample quantitySampleWithType:pefType quantity:pefQuantity startDate:now endDate:now];
                                                    
                                                    NSLog(@"Will attempt to store");
                                                    
                                                    [self.healthStore saveObject:fvcSample withCompletion:^(BOOL success, NSError *error) {
                                                        if(success == YES)
                                                            NSLog(@"FVC stored");
                                                        else
                                                            NSLog(@"Error storing FVC: %@", error);
                                                    }];
                                                    [self.healthStore saveObject:fev1Sample withCompletion:^(BOOL success, NSError *error) {
                                                        if(success == YES)
                                                            NSLog(@"FEV1 stored");
                                                        else
                                                            NSLog(@"Error storing FEV1: %@", error);
                                                    }];
                                                    [self.healthStore saveObject:pefSample withCompletion:^(BOOL success, NSError *error) {
                                                        if(success == YES)
                                                            NSLog(@"PEF stored");
                                                        else
                                                            NSLog(@"Error storing PEF: %@", error);
                                                    }];
                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kFinishedAlertTitle                                                                                                    message:kFinishedAlertMessage
                                                                                                   delegate:self
                                                                                          cancelButtonTitle:kButtonTitle
                                                                                          otherButtonTitles:nil];
                                                    [alert show];
                                                }
                                                else
                                                {
                                                    NSLog(@"Authorization failed");
                                                    NSLog(@"%@",error);
                                                }
                                                
                                            }];
    
    
    
    
    
}

# pragma mark - UIAlertView Delegate Methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:kButtonTitle])
    {
        NSLog(@"OK Button Pressed");
        [self.delegate stepViewController:self didFinishWithNavigationDirection:ORKStepViewControllerNavigationDirectionForward]; // go back to dashboard
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
