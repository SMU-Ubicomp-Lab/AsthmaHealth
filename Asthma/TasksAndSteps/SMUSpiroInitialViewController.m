//
//  SMUSpiroInitialViewController.m
//  Asthma
//
//  Created by Eric Larson on 5/27/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "SMUSpiroInitialViewController.h"
#import "CPDConstants.h"
#import "CPDStockPriceStore.h"


@interface SMUSpiroInitialViewController ()
{
    BOOL testStarted;
}
// our model of the spirometry analysis for one effort
@property (strong, nonatomic) SpirometerEffortAnalyzer* spiro;

// Used to stored the flow data, and send it via email.
@property (strong, nonatomic) NSDictionary *buffer;

// UI
@property (weak, nonatomic) IBOutlet UILabel *feedbackLabel;
@property (weak, nonatomic) IBOutlet UIButton *testControlButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end

@implementation SMUSpiroInitialViewController
- (IBAction)nextPressed:(id)sender {
    [self.delegate stepViewController:self didFinishWithNavigationDirection:ORKStepViewControllerNavigationDirectionForward];
    
}
- (IBAction)testControlButtonPressed:(id)sender {
    if(testStarted == YES)
    {
        // cancel effort
        [self endTest];
        [self.spiro requestThatCurrentEffortShouldCancel];
        
        
    }
    else // start effort
    {
        self.feedbackLabel.text = @"Calibrating sound, please remain silent...";
        [self startTest];
        [self.spiro beginListeningForEffort];
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    testStarted = NO;
    
    self.feedbackLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.feedbackLabel.numberOfLines = 0;
    
    
    self.spiro = [[SpirometerEffortAnalyzer alloc] init];
    self.spiro.delegate = self;
    self.spiro.prefferredAudioMaxUpdateIntervalInSeconds = 1.0/24.0; // the default is 30FPS, so setting lower
    // the FPS possible on this depends on the audio buffer size and sampling rate, which is different for different phones
    // most likely this has a maximum update rate of about 100 FPS
    
    self.buffer = @{};
    
    
    // uncomment when done debugging
    //[self.spiro askPermissionToUseAudioIfNotDone];
    
    [self.spiro activateDebugAudioModeWithWAVFile:nil];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Methods to update UI
- (void)endTest {
    testStarted = NO;
    [self.testControlButton setTitle:@"Start" forState:UIControlStateNormal];
}

- (void)startTest {
    testStarted = YES;
    [self.testControlButton setTitle:@"Cancel" forState:UIControlStateNormal];
}

#pragma mark SpirometerDelegate Methods
// all delegate methods are called from the main queue for UI updates
// as such, you should add the operation to another queue if it is not UI related
-(void)didFinishCalibratingSilence{
    self.feedbackLabel.text = @"Inhale deeply ...and blast out air when ready!";
}

-(void)didTimeoutWaitingForTestToStart{
    self.feedbackLabel.text = @"No exhale heard, effort canceled";
    [self endTest];
}

-(void)didStartExhaling{
    self.feedbackLabel.text = @"Keep blasting!!";
}

-(void)willEndTestSoon{
    self.feedbackLabel.text = @"Try to push last air out!! Go, Go, Go!";
}

-(void)didCancelEffort{
    self.feedbackLabel.text = @"Effort Cancelled";
    [self endTest];
    
}


-(void)didEndEffortWithResults:(NSDictionary*)results{
    // right now results are an empty dictionary
    // in the future the results of the effort will all be stored as key/value pairs
    NSLog(@"%@",results);
    self.feedbackLabel.text = @"Effort Complete. Thanks!";
    
    self.buffer = results; // save data for sensing to the user
    
    NSLog(@"%@", results);
    
    [self endTest];
    self.nextButton.enabled = YES;
    
    [[CPDStockPriceStore sharedInstance] storeSpiroData:results]; // in order to pass results to the next view controller
    
    
}

-(void)didUpdateFlow:(float)flow andVolume:(float)volume{
    // A calibrated flow measurement that will come back dynamically and some time after the flow is detected
    // flow and volume are just placeholders right now
    // the value of "flow" will change, but it is not converted to an actual flow rate yet
    // volume is always zero right now
    
    //self.flowSlider.value = flow; // watch it jump around when updated
    NSLog(@"%@",[NSString stringWithFormat:@"Flow: %.2f",flow]);
    
}

-(void)didUpdateAudioBufferWithMaximum:(float)maxAudioValue{
    // once silence has been calibrated, you will start getting this message
    // This happens many times per second, depending on the preferred time interval (default is 30 times per scond)
    // for updating a game UI quickly, this is the better option but does not give you a valid flow rate
    NSLog(@"Audio Max: %.4f", maxAudioValue);
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
