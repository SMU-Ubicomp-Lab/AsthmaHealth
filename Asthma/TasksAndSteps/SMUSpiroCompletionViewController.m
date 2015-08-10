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
    // Do any additional setup after loading the view.
    self.healthStore = [[HKHealthStore alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIViewController lifecycle methods
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[self initPlot:FlowVsTime];
}

#pragma mark - Chart behavior
-(void)initPlot:(int)plotIdentifier {
    [self configureHost];
    [self configureGraph:plotIdentifier];
    [self configurePlots:plotIdentifier];
    [self configureAxes:plotIdentifier];
}

-(void)configureHost {
    //self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:self.view.bounds];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    [cell setBounds:CGRectMake(0, 0, [cell width], kCellHeight)];
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:[cell bounds]];
    self.hostView.allowPinchScaling = YES;
    //[self.view addSubview:self.hostView];
}

-(void)configureGraph:(int)plotIdentifier {
    // 1 - Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    [graph applyTheme:[CPTTheme themeNamed:kCPTSlateTheme]];
    graph.plotAreaFrame.borderLineStyle = nil;
    self.hostView.hostedGraph = graph;
    // 2 - Set graph title
    if(plotIdentifier == 0)
    {
        graph.title = @"Flow vs Volume";
    }
    else if(plotIdentifier == 1)
    {
        graph.title = @"Flow vs Time";
    }
    else if (plotIdentifier == 2)
    {
        graph.title = @"Volume vs Time";
    }
    else // should not reach here
    {
        graph.title = @"Spirometry Results";
    }
    
    // 3 - Create and set text style
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = fontName;
    titleStyle.fontSize = 16.0f;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    // 4 - Set padding for plot area
    [graph.plotAreaFrame setPaddingLeft:30.0f];
    [graph.plotAreaFrame setPaddingBottom:30.0f];
    // 5 - Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    
}

-(void)configurePlots:(int)plotIdentifier {
    // 1 - Get graph and plot space
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    // 2 - Create the three plots
    CPTScatterPlot *aaplPlot = [[CPTScatterPlot alloc] init];
    aaplPlot.dataSource = self;
    if(plotIdentifier == 0)
    {
        aaplPlot.identifier = @"FlowVsVolume";
    }
    else if(plotIdentifier == 1)
    {
        aaplPlot.identifier = @"FlowVsTime";
    }
    else if(plotIdentifier == 2)
    {
        aaplPlot.identifier = @"VolumeVsTime";
    }
    CPTColor *aaplColor = [CPTColor redColor];
    [graph addPlot:aaplPlot toPlotSpace:plotSpace];
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:aaplPlot, nil]];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    plotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
    if(plotIdentifier == 0 || plotIdentifier == 1) // so the x axis will always be displayed
    {
        yRange = [[CPTMutablePlotRange alloc] initWithLocation:[[NSDecimalNumber
                                                                 decimalNumberWithString:@"0.0"] decimalValue] length:[[NSDecimalNumber
                                                                                                                        decimalNumberWithString:@"500.0"] decimalValue]];
    }
    
    plotSpace.yRange = yRange;
    // 4 - Create styles and symbols
    CPTMutableLineStyle *aaplLineStyle = [aaplPlot.dataLineStyle mutableCopy];
    aaplLineStyle.lineWidth = 2.5;
    aaplLineStyle.lineColor = aaplColor;
    aaplPlot.dataLineStyle = aaplLineStyle;
    CPTMutableLineStyle *aaplSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    aaplSymbolLineStyle.lineColor = aaplColor;
    CPTPlotSymbol *aaplSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    aaplSymbol.fill = [CPTFill fillWithColor:aaplColor];
    aaplSymbol.lineStyle = aaplSymbolLineStyle;
    aaplSymbol.size = CGSizeMake(6.0f, 6.0f);
    aaplPlot.plotSymbol = aaplSymbol;
}

-(void)configureAxes:(int)plotIdentifier {
    // 1 - Create styles
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
    
    if(plotIdentifier == 0) // =0Flow vs Volume
    {
        x.title = @"Volume (L)";
    }
    else if(plotIdentifier == 1 || plotIdentifier == 2) // 1=Flow vs Time; 2=Volume vs Time
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
    int increment = 1; // fix later..
    if(plotIdentifier == 0)
    {
        increment = 1;
    }
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
    
    
    if(plotIdentifier == 0 || plotIdentifier == 1) // 0=Flow vs Volume; 1=Flow vs Time
    {
        y.title = @"Flow (L/s)";
    }
    else if(plotIdentifier == 2) // 2=Volume vs Time
    {
        y.title = @"Volume (L)";
    }
    else
    {
        y.title = @"y-axis";
    }
    
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = -45.0f; // used to be 40
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 16.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    
    
    //constrain axis
    //axisSet.axes = [NSArray arrayWithObjects:x,y, nil];
    //self.hostView.hostedGraph.axisSet = axisSet;
    //axisSet.yAxis.axisConstraints = [CPTConstraints constraintWithUpperOffset:0];
    
    
    NSInteger majorIncrement = 1;
    NSInteger minorIncrement = 50;
    CGFloat yMax = 1000.0f;  // should determine dynamically based on max price
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
                NSLog(@"added label at %f with offset %d", j, label.offset);
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
    if([(NSString *)plot.identifier isEqualToString:@"FlowVsVolume"] || [(NSString *)plot.identifier isEqualToString:@"FlowVsTime"])
    {
        return [[[[CPDStockPriceStore sharedInstance] storedResults] valueForKey:@"FlowCurveInLitersPerSecond"] count];
    }
    else if([(NSString *)plot.identifier isEqualToString:@"VolumeVsTime"])
    {
        return [[[[CPDStockPriceStore sharedInstance] storedResults] valueForKey:@"VolumeCurveInLiters"] count];
    }
    
    return 10; // this should not be called

}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    //NSInteger valueCount = [[[CPDStockPriceStore sharedInstance] datesInMonth] count];
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            if([(NSString *)plot.identifier isEqualToString:@"FlowVsVolume"])
            {
                return [[[[CPDStockPriceStore sharedInstance] storedResults] valueForKey:@"VolumeCurveInLiters"] objectAtIndex:index];
            }
            
            return [[[[CPDStockPriceStore sharedInstance] storedResults] valueForKey:@"TimeStampsForFlowAndVolume"] objectAtIndex:index];
            break;
            
        case CPTScatterPlotFieldY:
            if ([(NSString *)plot.identifier isEqualToString:@"FlowVsVolume"] || [(NSString *)plot.identifier isEqualToString:@"FlowVsTime"]) {
                
                NSArray *curve = [[[CPDStockPriceStore sharedInstance] storedResults] valueForKey:@"FlowCurveInLitersPerSecond"];
                
                // NSString -> NSDecimalNumber
                float valueForGraph = [[curve objectAtIndex:index] floatValue];
                
                NSDecimalNumber *dec = [NSDecimalNumber numberWithFloat:valueForGraph*100.0];
                NSLog(@"%@",dec);
                return dec;
            } else if ([(NSString *)plot.identifier isEqualToString:@"VolumeVsTime"]) {
                NSArray *curve = [[[CPDStockPriceStore sharedInstance] storedResults] valueForKey:@"VolumeCurveInLiters"];
                
                // NSString -> NSDecimalNumber
                float valueForGraph = [[curve objectAtIndex:index] floatValue];
                
                NSDecimalNumber *dec = [NSDecimalNumber numberWithFloat:valueForGraph*100.0];
                //NSLog(@"%@",dec);
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
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 3;
    }
    else if(section == 1)
    {
        return 4;
    }
    return 4; // should not reach here
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(indexPath.section == 0)
    {
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            CGRect frame = CGRectMake(0, 0, 160, 50);
            UILabel *label = [[UILabel alloc] initWithFrame:frame];
            [cell.contentView addSubview:self.hostView];
            
        }
    }
    else
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"DataCell"];
        cell.textLabel.text = @"ghway";
        cell.detailTextLabel.text = @"detail text";
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
