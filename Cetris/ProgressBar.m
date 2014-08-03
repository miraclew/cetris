//
//  ProgressBar.m
//  Cetris
//
//  Created by Wan Wei on 14/8/2.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import "ProgressBar.h"

@implementation ProgressBar {
//    SKSpriteNode* _board;
    SKSpriteNode* _stick;
}

-(id)initWithColor:(UIColor *)color size:(CGSize)size {
    if (self = [super initWithColor:color size:size]) {
        _stick = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(0, size.height)];
        [self addChild:_stick];
    }
    
    return self;
}

-(void)setPercent:(CGFloat)percent{
    _stick.size = CGSizeMake(self.size.width*percent, self.size.height);
}

@end
