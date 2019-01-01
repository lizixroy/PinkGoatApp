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
@property (nonatomic, assign) NSUInteger jointCount;
@end

@implementation PGTimeSeriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.variablesTableView.delegate = self;
    self.variablesTableView.dataSource = self;
    [self.timeSeriesView setupWithJointCount:self.jointCount];
}

- (void)setupWithJointCount:(NSUInteger)jointCount
{
    self.jointCount = jointCount;
}

- (void)updateWithJointVariables:(NSArray<NSNumber *> *)jointVariables {
    [self.timeSeriesView updateWithJointVariables:jointVariables];
    [self.timeSeriesView setNeedsDisplay:YES];
}

@end
