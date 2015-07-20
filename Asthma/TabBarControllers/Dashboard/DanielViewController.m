//
//  DanielViewController.m
//  Asthma
//
//  Created by Daniel Huang on 7/7/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "DanielViewController.h"
#import "APHDashboardEditViewController.h"
#import "APHDashboardAirQualityTableViewCell.h"
#import "APHAirQualityCollectionViewCell.h"
#import "APHTableViewDashboardAQAlertItem.h"
#import "APHAsthmaBadgesObject.h"
#import "APHDashboardBadgesTableViewCell.h"
#import "APHBadgesCollectionViewCell.h"
#import "APHCalendarCollectionViewController.h"
#import "APHAirQualitySectionHeaderView.h"
#import "APHCalendarDataModel.h"
#import "APHAirQualityDataModel.h"
#import "APHConstants.h"

@interface DanielViewController ()<UIViewControllerTransitioningDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, APCPieGraphViewDatasource, APCConcentricProgressViewDataSource>

@property (nonatomic, strong) NSMutableArray *rowItemsOrder;

@property (nonatomic, strong) APCScoring *stepScore;
@property (nonatomic, strong) APCScoring *peakScore;

@property (nonatomic, assign) BOOL shouldAnimateObjects;


@end

@implementation DanielViewController
#pragma mark - Init

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _rowItemsOrder = [NSMutableArray arrayWithArray:[defaults objectForKey:kAPCDashboardRowItemsOrder]];
        
        if (!_rowItemsOrder.count) {
            _rowItemsOrder = [[NSMutableArray alloc] initWithArray:@[
                                                                     @(kAPHDashboardItemTypePeakFlow)
                                                                     ]];
            
            [defaults setObject:[NSArray arrayWithArray:_rowItemsOrder] forKey:kAPCDashboardRowItemsOrder];
            [defaults synchronize];
            
        }
        
        self.title = NSLocalizedString(@"Dashboard", @"Dashboard");
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //self.rowItemsOrder = [NSMutableArray arrayWithArray:[defaults objectForKey:kAPCDashboardRowItemsOrder]];
    [self prepareScoringObjects];
    [self prepareData];
}

- (void)prepareScoringObjects
{
    {
        HKQuantityType *hkQuantity = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
        self.stepScore = [[APCScoring alloc] initWithHealthKitQuantityType:hkQuantity
                                                                      unit:[HKUnit countUnit]
                                                              numberOfDays:-1];
    }
    
    {
        HKHealthStore *healthStore = [[HKHealthStore alloc] init];
        // "Share" (read/write) spirometry measurements (FVC, FEV1, PEF)
        NSSet *spirometryObjectTypes = [NSSet setWithObjects:
                                        [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierForcedVitalCapacity],
                                        [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierForcedExpiratoryVolume1],
                                        [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierPeakExpiratoryFlowRate],
                                        nil];
        
        
        
        // Request access
        [healthStore requestAuthorizationToShareTypes:spirometryObjectTypes
                                            readTypes:spirometryObjectTypes
                                           completion:^(BOOL success, NSError *error) {
                                               
                                               if(success == YES)
                                               {
                                                   // ...
                                                   NSLog(@"Authorization success");
                                               }
                                               else
                                               {
                                                   NSLog(@"Problem with authorization: %@", error);
                                               }
                                               
                                           }];
        
        HKQuantityType *hkQuantity = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierForcedVitalCapacity];
        //self.peakScore = [[APCScoring alloc] initWithHealthKitQuantityType:hkQuantity unit:[HKUnit literUnit] numberOfDays:-kNumberOfDaysToDisplay];
        NSLog(@"starting initwithdata");
        self.peakScore = [[APCScoring alloc] initWithData:hkQuantity unit:[HKUnit literUnit] numberOfDays:-kNumberOfDaysToDisplay];
        
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data

- (void)prepareData
{
    
    [self.items removeAllObjects];
    
    {
        NSMutableArray *rowItems = [NSMutableArray new];
        
        for (NSNumber *typeNumber in self.rowItemsOrder) {
            
            APHDashboardItemType rowType = typeNumber.integerValue;
            
            
                    
                    APCTableViewDashboardGraphItem *item = [APCTableViewDashboardGraphItem new];
                    item.caption = NSLocalizedString(@"Peak Flow", @"");
                    if (self.peakScore.averageDataPoint.doubleValue > 0 && self.peakScore.averageDataPoint.doubleValue != self.peakScore.maximumDataPoint.doubleValue) {
                        item.detailText = [NSString stringWithFormat:NSLocalizedString(@"Average : %0.0f", @"Average: {value} ft"), [[self.peakScore averageDataPoint] doubleValue]];
                    }
                    item.graphData = self.peakScore;
                    item.identifier = kAPCDashboardGraphTableViewCellIdentifier;
                    item.editable = YES;
                    item.tintColor = [UIColor appTertiaryYellowColor];
                    //item.info = NSLocalizedString(kTooltipPeakFlowContent, @"");
                    item.info = @"hola";
                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = item;
                    row.itemType = rowType;
                    [rowItems addObject:row];
            
            
            
        }
        
        APCTableViewSection *section = [APCTableViewSection new];
        section.rows = [NSArray arrayWithArray:rowItems];
        section.sectionTitle = NSLocalizedString(@"Recent Activity", @"");
        [self.items addObject:section];
    }
    
    [self.tableView reloadData];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    APCTableViewDashboardItem *dashboardItem = (APCTableViewDashboardItem *)[self itemForIndexPath:indexPath];
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    APCTableViewItem *dashboardItem = [self itemForIndexPath:indexPath];
    
    
    
    return height;
}

/*********************************************************************************/
#pragma mark - Overriding APHDashboardVC
/*********************************************************************************/
- (void)updateVisibleRowsInTableView:(NSNotification *)notification
{
    [super updateVisibleRowsInTableView:notification];
    [self prepareData];
    self.shouldAnimateObjects = YES;
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
