//
//  GraphMaker.m
//  Asthma
//
//  Created by Daniel Huang on 8/14/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "GraphMaker.h"
NSString * const fontName = @"Helvetica Neue";

@interface GraphMaker ()

@end

float const kCellHeight = 300.0f;
NSString * const kFlowVsVolumeTitle = @"Flow Vs Volume";
NSString * const kFlowVsTimeTitle = @"Flow Vs Time";
NSString * const kVolumeVsTimeTitle = @"Volume Vs Time";

// Title Style
float const kTitleFontSize = 16.0f;
float const kTitleDisplacementX = 0.0f;
float const kTitleDisplacementY = 10.0f;

// Plot Area
// The part of the graph where the data is plotted
float const kPlotAreaPaddingLeft = 30.0f;
float const kPlotAreaPaddingBottom = 30.0f;

// Plot Space
// Mapping between the coordinate space (with a set of data) and the drawing space (inside plot area)
float const kXRangeExpansionFactor = 1.1f; // More of the x-axis is shown
float const kYRangeExpansionFactor = 1.2f; // More of the y-axis is shown

// Y-axis bounds for Flow Vs Volume and Flow Vs Time graphs
float const kYRangeLowerBound = 0.0f;
float const kYRangeUpperBound = 500.0f;

// Line style for the graph
float const kLineWidth = 2.5;

// Symbol (coordinate point) style for the graph
float const kSymbolSizeX = 6.0f;
float const kSymbolSizeY = 6.0f;

// Axis style
float const kAxisTitleFontSize = 12.0f; // Axis title
float const kAxisLineWidth = 2.0f;
float const kAxisTextFontSize = 11.0f; // Axis labels
float const kAxisTickWidth = 2.0f;
float const kAxisGridLineWidth = 1.0f;

// Axis titles
NSString * const kAxisTitleVolumeInLiters = @"Volume (L)";
NSString * const kAxisTitleTimeInSeconds = @"Time (s)";
NSString * const kAxisTitleFlowInLitersPerSeconds = @"Flow (L/s)";

// Y-axis positioning and labels
float const kYAxisTitleOffset = -45.0f;
float const kYAxisLabelOffset = 26.0f;
float const kYAxisMajorTickLength = 4.0f;
float const kYAxisMinorTickLength = 2.0f;
CGFloat const kYAxisMax = 1000.0f; // Maximum label value
NSInteger kYAxisMajorIncrement = 1; // ?
NSInteger kYAxisMinorIncrement = 100;


// X-axis positioning and labels
float const kXAxisTitleOffset = 15.0f;
float const kXAxisMajorTickLength = 4.0f;
int const kXAxisIncrement = 30; // Default scale increment for x-axis
int const kXAxisIncrementForFlowVsVolume = 1;
CGFloat const kXAxisMax = 500.0f;

@implementation GraphMaker

-(id) init {
    if(self = [super init])
    {
        
    }
    return self;
}

+(id)sharedInstance
{
    static GraphMaker *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+(CPTGraph *) getGraph:(CGRect)bounds withIdentifer:(NSString *)plotIdentifier withPlot:(CPTScatterPlot *)spiroPlot
{
    // Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    
    [graph applyTheme:[CPTTheme themeNamed:kCPTSlateTheme]];
    graph.plotAreaFrame.borderLineStyle = nil;
        
    // Set graph title
    if([plotIdentifier isEqualToString:FlowVsVolume])
    {
        graph.title = kFlowVsVolumeTitle;
    }
    else if([plotIdentifier isEqualToString:FlowVsTime])
    {
        graph.title = kFlowVsTimeTitle;
    }
    else if([plotIdentifier isEqualToString:VolumeVsTime])
    {
        graph.title = kVolumeVsTimeTitle;
    }
    
    // Create and set text style
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = fontName;
    titleStyle.fontSize = kTitleFontSize;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(kTitleDisplacementX, kTitleDisplacementY);
    
    // Set padding for plot area
    [graph.plotAreaFrame setPaddingLeft:kPlotAreaPaddingLeft];
    [graph.plotAreaFrame setPaddingBottom:kPlotAreaPaddingBottom];
    
    // Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    
    [[GraphMaker sharedInstance] configurePlots:plotIdentifier withGraph:graph withPlot:spiroPlot];
    
    
    return graph;
}

-(void)configurePlots:(NSString *)plotIdentifier withGraph:(CPTGraph *)graph withPlot:(CPTScatterPlot *) spiroPlot{
    // Get graph and plot space
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    
    [graph addPlot:spiroPlot toPlotSpace:plotSpace];
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:spiroPlot, nil]];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(kXRangeExpansionFactor)];
    plotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange;
    
    NSDecimalNumber *yRangeLowerBoundDecimalNumber = [[NSDecimalNumber alloc] initWithFloat:kYRangeLowerBound];
    NSDecimalNumber *yRangeUpperBoundDecimalNumber = [[NSDecimalNumber alloc] initWithFloat:kYRangeUpperBound];
    if([plotIdentifier isEqualToString:FlowVsVolume] || [plotIdentifier isEqualToString:FlowVsTime])
    {
        
        yRange = [[CPTMutablePlotRange alloc] initWithLocation:[yRangeLowerBoundDecimalNumber decimalValue] length:[yRangeUpperBoundDecimalNumber decimalValue]];
    }
    else if([plotIdentifier isEqualToString:VolumeVsTime])
    {
        yRange = [plotSpace.yRange mutableCopy];
        [yRange expandRangeByFactor:CPTDecimalFromCGFloat(kYRangeExpansionFactor)];
        
    }
    
    plotSpace.yRange = yRange;
    
    // Create styles and symbols
    CPTColor *spiroColor = [CPTColor redColor];
    
    CPTMutableLineStyle *spiroLineStyle = [spiroPlot.dataLineStyle mutableCopy];
    spiroLineStyle.lineWidth = kLineWidth;
    spiroLineStyle.lineColor = spiroColor;
    spiroPlot.dataLineStyle = spiroLineStyle;
    CPTMutableLineStyle *spiroSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    spiroSymbolLineStyle.lineColor = spiroColor;
    CPTPlotSymbol *spiroSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    spiroSymbol.fill = [CPTFill fillWithColor:spiroColor];
    spiroSymbol.lineStyle = spiroSymbolLineStyle;
    spiroSymbol.size = CGSizeMake(kSymbolSizeX, kSymbolSizeY);
    spiroPlot.plotSymbol = spiroSymbol;
    
    [self configureAxes:plotIdentifier withGraph:graph];
    
}

-(void)configureAxes:(NSString *)plotIdentifier withGraph:(CPTGraph *)graph {
    // Create style
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor whiteColor];
    axisTitleStyle.fontName = fontName;
    axisTitleStyle.fontSize = kAxisTitleFontSize;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = kAxisLineWidth;
    axisLineStyle.lineColor = [CPTColor whiteColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor whiteColor];
    axisTextStyle.fontName = fontName;
    axisTextStyle.fontSize = kAxisTextFontSize;
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor whiteColor];
    tickLineStyle.lineWidth = kAxisTickWidth;
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = kAxisGridLineWidth;
    // 2 - Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) graph.axisSet;
    // 3 - Configure x-axis
    CPTAxis *x = axisSet.xAxis;
    if([plotIdentifier isEqualToString:FlowVsVolume])
    {
        x.title = kAxisTitleVolumeInLiters;
    }
    else if([plotIdentifier isEqualToString:FlowVsTime] || [plotIdentifier isEqualToString:VolumeVsTime])
    {
        x.title = kAxisTitleTimeInSeconds;
    }
    
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = kXAxisTitleOffset;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = kXAxisMajorTickLength;
    x.tickDirection = CPTSignNegative;
    CGFloat dateCount = [[[CPDStockPriceStore sharedInstance] datesInMonth] count];
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
    NSInteger i = 0;
    int increment = kXAxisIncrement;
    if([plotIdentifier isEqualToString:FlowVsVolume])
        increment = kXAxisIncrementForFlowVsVolume;
    for (i=0; i<kXAxisMax; i+=increment) {
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
    if([plotIdentifier isEqualToString:FlowVsVolume] || [plotIdentifier isEqualToString:FlowVsTime])
    {
        y.title = kAxisTitleFlowInLitersPerSeconds;
    }
    else if([plotIdentifier isEqualToString:VolumeVsTime])
    {
        y.title = kAxisTitleVolumeInLiters;
    }
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = kYAxisTitleOffset;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = kYAxisLabelOffset;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = kYAxisMajorTickLength;
    y.minorTickLength = kYAxisMinorTickLength;
    y.tickDirection = CPTSignPositive;
    NSInteger majorIncrement = kYAxisMajorIncrement;
    NSInteger minorIncrement = kYAxisMinorIncrement;
    CGFloat yMax = kYAxisMax;  // should determine dynamically based on maximum value
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
            label.offset = -y.majorTickLength - y.labelOffset;
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

@end
