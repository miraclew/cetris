
//
//  TestScene.m
//  Cetris
//
//  Created by Bob  on 14-6-29.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import "TestScene.h"
#import "PhysicsHelper.h"

@implementation TestScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        SKShapeNode *node = [SKShapeNode node];
        node.position = CGPointMake(100, 100);
        //node.path = [self createMovingPath:node.position velocity:CGPointMake(20, 20) acceleration:CGPointMake(0, -10)];
        node.path = [PhysicsHelper createMovingPath:node.position velocity:CGPointMake(20, 20) acceleration:CGPointMake(0, -10) steps:100 deltaTime:0.1];
        node.strokeColor = [UIColor redColor];
        [self addChild:node];
    }
    
    return self;
}





@end





