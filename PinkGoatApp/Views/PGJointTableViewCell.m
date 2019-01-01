//
//  PGJointTableViewCell.m
//  PinkGoatApp
//
//  Created by Roy Li on 12/31/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import "PGJointTableViewCell.h"

@implementation PGJointTableViewCell

- (IBAction)sliderValueChanged:(id)sender {
    if (![sender isKindOfClass:[NSSlider class]]) {
        return;
    }
    NSSlider *slider = sender;
    if (self.sliderDidChangeValue != nil) {
        self.sliderDidChangeValue(slider.floatValue);
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
