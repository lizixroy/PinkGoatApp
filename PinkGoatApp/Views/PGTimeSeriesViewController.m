//
//  PGTimeSeriesViewController.m
//  PinkGoatApp
//
//  Created by Roy Li on 12/31/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import "PGTimeSeriesViewController.h"
#import "PGTimeSeriesView.h"

@interface PGTimeSeriesViewController ()
@property (weak) IBOutlet PGTimeSeriesView *timeSeriesView;
@property (weak) IBOutlet NSTableView *variablesTableView;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *jointVariables;
@end

@implementation PGTimeSeriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.variablesTableView.delegate = self;
    self.variablesTableView.dataSource = self;
}

- (void)setupWithJointVariables:(NSMutableArray<NSNumber *> *)jointVariables
{
    self.jointVariables = jointVariables;
    [self.timeSeriesView setupWithAngles:self.jointVariables];
}

@end
