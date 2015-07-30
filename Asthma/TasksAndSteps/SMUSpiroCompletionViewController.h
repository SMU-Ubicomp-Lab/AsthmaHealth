//
//  SMUSpiroCompletionViewController.h
//  Asthma
//
//  Created by Daniel Huang on 6/17/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <APCAppCore/APCAppCore.h>
#import "CorePlot-CocoaTouch.h"
#import "CPDConstants.h"
#import "CPDStockPriceStore.h"

@interface SMUSpiroCompletionViewController : APCStepViewController <CPTPlotDataSource, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) CPTGraphHostingView *hostView;

@end
