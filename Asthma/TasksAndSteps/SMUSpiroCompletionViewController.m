//
//  SMUSpiroCompletionViewController.m
//  Asthma
//
//  Created by Daniel Huang on 6/17/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "SMUSpiroCompletionViewController.h"
#include <stdlib.h>

@interface SMUSpiroCompletionViewController ()

@end

@implementation SMUSpiroCompletionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
-(void)initPlot:(NSString *)plotIdentifier {
    [self configureHost];
    [self configureGraph];
    [self configurePlots:plotIdentifier];
    [self configureAxes];
}

-(void)configureHost {
    //self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:self.view.bounds];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    [cell setBounds:CGRectMake(0, 0, [cell width], 200)];
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:[cell bounds]];
    self.hostView.allowPinchScaling = YES;
    //[self.view addSubview:self.hostView];
}

-(void)configureGraph {
    // 1 - Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    [graph applyTheme:[CPTTheme themeNamed:kCPTSlateTheme]];
    self.hostView.hostedGraph = graph;
    // 2 - Set graph title
    NSString *title = @"Volume vs Time";
    graph.title = title;
    // 3 - Create and set text style
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = @"Helvetica-Bold";
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

-(void)configurePlots:(NSString *)plotIdentifier {
    // 1 - Get graph and plot space
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    // 2 - Create the three plots
    CPTScatterPlot *aaplPlot = [[CPTScatterPlot alloc] init];
    aaplPlot.dataSource = self;
    aaplPlot.identifier = plotIdentifier;
    CPTColor *aaplColor = [CPTColor redColor];
    [graph addPlot:aaplPlot toPlotSpace:plotSpace];
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:aaplPlot, nil]];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    plotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
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

-(void)configureAxes {
    // 1 - Create styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor whiteColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor whiteColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor whiteColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
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
    x.title = @"Time";
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
    for (i=0; i<500; i+=30) {
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
    y.title = @"Volume";
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = -40.0f;
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
    NSInteger minorIncrement = 10;
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
    return [[[[CPDStockPriceStore sharedInstance] storedResults] valueForKey:@"VolumeCurveInLiters"] count];
    //return 40;

}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    //NSInteger valueCount = [[[CPDStockPriceStore sharedInstance] datesInMonth] count];
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
                
                // NSString -> NSDecimalNumber
                float valueForGraph = [[curve objectAtIndex:index] floatValue];
                
                NSDecimalNumber *dec = [NSDecimalNumber numberWithFloat:valueForGraph*100.0];
                NSLog(@"%@",dec);
                return dec;
                //return [[[CPDStockPriceStore sharedInstance] monthlyPrices:CPDTickerSymbolAAPL] objectAtIndex:index];
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
    [tableView setRowHeight:200.0]; // this is not the best place to put this
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
            [self initPlot:FlowVsTime];
        }
        else if(indexPath.row == 1)
        {
            [self initPlot:VolumeVsTime];
        }
        else if(indexPath.row == 2)
        {
            [self initPlot:FlowVsVolume];
        }
        
        [cell.contentView addSubview:self.hostView];
        
    }
    
    return cell;
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
