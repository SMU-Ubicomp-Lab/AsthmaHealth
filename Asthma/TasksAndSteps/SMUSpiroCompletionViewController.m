//
//  SMUSpiroCompletionViewController.m
//  Asthma
//
//  Created by Daniel Huang on 6/17/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "SMUSpiroCompletionViewController.h"
#include <stdlib.h>
@import HealthKit;

@interface SMUSpiroCompletionViewController ()
@property (strong, nonatomic) HKHealthStore *healthStore;
@end

float const kCellHeight = 300.0;
NSString * const fontName = @"Helvetica Neue";

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
    [self configurePlots:plotIdentifier];
    [self configureAxes:plotIdentifier];
}

-(void)configureHost {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    [cell setBounds:CGRectMake(0, 0, [cell width], kCellHeight)];
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:[cell bounds]];
    self.hostView.allowPinchScaling = YES;
}

-(void)configureGraph:(NSString *)plotIdentifier {
    // Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    [graph applyTheme:[CPTTheme themeNamed:kCPTSlateTheme]];
    graph.plotAreaFrame.borderLineStyle = nil;
    self.hostView.hostedGraph = graph;
    
    // Set graph title
    if([plotIdentifier isEqualToString:FlowVsVolume])
    {
        graph.title = @"Flow Vs Volume";
    }
    else if([plotIdentifier isEqualToString:FlowVsTime])
    {
        graph.title = @"Flow Vs Time";
    }
    else if([plotIdentifier isEqualToString:VolumeVsTime])
    {
        graph.title = @"Volume Vs Time";
    }
    else
    {
        graph.title = @"Graph Title";
    }
    
    // Create and set text style
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = fontName;
    titleStyle.fontSize = 16.0f;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    
    // Set padding for plot area
    [graph.plotAreaFrame setPaddingLeft:30.0f];
    [graph.plotAreaFrame setPaddingBottom:30.0f];
    
    // Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
}

-(void)configurePlots:(NSString *)plotIdentifier {
    // Get graph and plot space
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    // Create the ploy
    CPTScatterPlot *spiroPlot = [[CPTScatterPlot alloc] init];
    spiroPlot.dataSource = self;
    spiroPlot.identifier = plotIdentifier;
    CPTColor *spiroColor = [CPTColor redColor];
    [graph addPlot:spiroPlot toPlotSpace:plotSpace];
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:spiroPlot, nil]];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    plotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange;
    if([plotIdentifier isEqualToString:FlowVsVolume])
    {
        yRange = [[CPTMutablePlotRange alloc] initWithLocation:[[NSDecimalNumber
                                                                                      decimalNumberWithString:@"0.0"] decimalValue] length:[[NSDecimalNumber
                                                                                                                                             decimalNumberWithString:@"500.0"] decimalValue]];
    }
    else if([plotIdentifier isEqualToString:FlowVsTime])
    {
        yRange = [[CPTMutablePlotRange alloc] initWithLocation:[[NSDecimalNumber
                                                                                      decimalNumberWithString:@"0.0"] decimalValue] length:[[NSDecimalNumber
                                                                                                                                             decimalNumberWithString:@"500.0"] decimalValue]];
    }
    else if([plotIdentifier isEqualToString:VolumeVsTime])
    {
        yRange = [plotSpace.yRange mutableCopy];
        [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];

    }
    
    plotSpace.yRange = yRange;
    
    // Create styles and symbols
    CPTMutableLineStyle *spiroLineStyle = [spiroPlot.dataLineStyle mutableCopy];
    spiroLineStyle.lineWidth = 2.5;
    spiroLineStyle.lineColor = spiroColor;
    spiroPlot.dataLineStyle = spiroLineStyle;
    CPTMutableLineStyle *spiroSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    spiroSymbolLineStyle.lineColor = spiroColor;
    CPTPlotSymbol *spiroSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    spiroSymbol.fill = [CPTFill fillWithColor:spiroColor];
    spiroSymbol.lineStyle = spiroSymbolLineStyle;
    spiroSymbol.size = CGSizeMake(6.0f, 6.0f);
    spiroPlot.plotSymbol = spiroSymbol;
}

-(void)configureAxes:(NSString *)plotIdentifier {
    // Create style
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor whiteColor];
    axisTitleStyle.fontName = fontName;
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor whiteColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor whiteColor];
    axisTextStyle.fontName = fontName;
    axisTextStyle.fontSize = 11.0f;
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor whiteColor];
    tickLineStyle.lineWidth = 2.0f;
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 1.0f;
    // 2 - Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    // 3 - Configure x-axis
    CPTAxis *x = axisSet.xAxis;
    if([plotIdentifier isEqualToString:FlowVsVolume])
    {
        x.title = @"Volume (L)";
    }
    else if([plotIdentifier isEqualToString:FlowVsTime])
    {
        x.title = @"Time (s)";
    }
    else if([plotIdentifier isEqualToString:VolumeVsTime])
    {
        x.title = @"Time (s)";
    }
    else
    {
        x.title = @"x-axis";
    }
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = 15.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = 4.0f;
    x.tickDirection = CPTSignNegative;
    CGFloat dateCount = [[[CPDStockPriceStore sharedInstance] datesInMonth] count];
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
    NSInteger i = 0;
    int increment = 30;
    if([plotIdentifier isEqualToString:FlowVsVolume])
        increment =1;
    for (i=0; i<500; i+=increment) {
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%li",(long)i]  textStyle:x.labelTextStyle];
        CGFloat location = i;
        label.tickLocation = CPTDecimalFromCGFloat(location);
        label.offset = x.majorTickLength;
        if (label) {
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithFloat:location]];
        }
    }
    x.axisLabels = xLabels;
    x.majorTickLocations = xLocations;
    // 4 - Configure y-axis
    CPTAxis *y = axisSet.yAxis;
    if([plotIdentifier isEqualToString:FlowVsVolume])
    {
        y.title = @"Flow (L/s)";
    }
    else if([plotIdentifier isEqualToString:FlowVsTime])
    {
        y.title = @"Flow (L/s)";
    }
    else if([plotIdentifier isEqualToString:VolumeVsTime])
    {
        y.title = @"Volume (L)";
    }
    else
    {
        y.title = @"y-axis";
    }
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = -45.0f;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 16.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    NSInteger majorIncrement = 1;
    NSInteger minorIncrement = 100;
    CGFloat yMax = 1000.0f;  // should determine dynamically based on maximum value
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    for (NSInteger j = minorIncrement; j <= yMax; j += minorIncrement) {
        NSUInteger mod = j % majorIncrement;
        if (mod == 0) {
            // j is the original spirometry measure multiplied by 100 (so the graph would display integer values)
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%.2f", (j/100.0)] textStyle:y.labelTextStyle];
            NSDecimal location = CPTDecimalFromInteger(j);
            label.tickLocation = location;
            label.offset = -y.majorTickLength - y.labelOffset-10; // -10 for extra cushion room between label and y-axis
            if (label) {
                [yLabels addObject:label];

            }
            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        } else {
            [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
        }
    }
    
    
    y.axisLabels = yLabels;
    y.majorTickLocations = yMajorLocations;
    y.minorTickLocations = yMinorLocations;
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return [[[[CPDStockPriceStore sharedInstance] storedResults] valueForKey:@"VolumeCurveInLiters"] count];
    //return 40;
    
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            if([plot.identifier isEqual:FlowVsVolume])
            {
                return [[[[CPDStockPriceStore sharedInstance] storedResults] valueForKey:@"VolumeCurveInLiters"] objectAtIndex:index];
            }
            return [NSNumber numberWithUnsignedInteger:index];
            break;
            
        case CPTScatterPlotFieldY:
            if ([plot.identifier isEqual:FlowVsTime] == YES || [plot.identifier isEqual:FlowVsVolume] == YES) {
                
                NSArray *curve = [[[CPDStockPriceStore sharedInstance] storedResults] valueForKey:FlowVsTime];
                
                // NSString to NSDecimalNumber
                float valueForGraph = [[curve objectAtIndex:index] floatValue];
                
                NSDecimalNumber *dec = [NSDecimalNumber numberWithFloat:valueForGraph*100.0];
                NSLog(@"%@",dec);
                return dec;

            } else if ([plot.identifier isEqual:VolumeVsTime] == YES) {
                NSArray *curve = [[[CPDStockPriceStore sharedInstance] storedResults] valueForKey:VolumeVsTime];
                
                // NSString -> NSDecimalNumber
                float valueForGraph = [[curve objectAtIndex:index] floatValue];
                
                NSDecimalNumber *dec = [NSDecimalNumber numberWithFloat:valueForGraph*100.0];
                NSLog(@"%@",dec);
                return dec;
            }
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
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        CGRect frame = CGRectMake(0, 0, 160, 50);
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        UIView *graphView = [[UIView alloc] initWithFrame:frame];
        int r = arc4random_uniform(100);
        if(r%2==0)
        {
            [graphView setBackgroundColor:[UIColor redColor]];
        }
        else
        {
            [graphView setBackgroundColor:[UIColor blackColor]];
        }
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


- (IBAction)SaveButtonPressed:(id)sender {
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
                                                    float fvc = [[[[CPDStockPriceStore sharedInstance] storedResults] valueForKey:@"FVCInLiters"] floatValue];
                                                    float fev1 = [[[[CPDStockPriceStore sharedInstance] storedResults] valueForKey:@"FEVOneInLiters"] floatValue];
                                                    float pef = [[[[CPDStockPriceStore sharedInstance] storedResults] valueForKey:@"PeakFlowInLitersPerSecond"] floatValue];
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
                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Test Finished"
                                                                                                    message:@"The data has been stored and this test is now over. You will now be redirected back to the dashboard."
                                                                                                   delegate:self
                                                                                          cancelButtonTitle:@"OK"
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
    
    if([title isEqualToString:@"OK"])
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
