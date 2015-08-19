//
//  GraphMaker.h
//  Asthma
//
//  Created by Daniel Huang on 8/14/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"
#import "CPDConstants.h"
#import "CPDStockPriceStore.h"

@interface GraphMaker : NSObject
+(id)sharedInstance;
+(CPTGraph *) getGraph:(CGRect)bounds withIdentifer:(NSString *)plotIdentifier withPlot:(CPTScatterPlot *)spiroPlot;
@end
