
//
//  TestScene.m
//  Cetris
//
//  Created by Bob  on 14-6-29.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import "TestScene.h"
#import "PhysicsHelper.h"
#import "FireControl.h"

@implementation TestScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [UIColor grayColor];
        FireControl *fc = [FireControl controlWithRadius:200 FireBlock:^(id object) {
            NSLog(@"fire block");
        } VectorChangeBlock:^(id object) {
            FireControl *fc = (FireControl *)object;
            NSLog(@"vector change block: %f/%f", fc.controlVector.dx, fc.controlVector.dy);
        }];
        fc.position = CGPointMake(size.width/2, size.height/2);
        [self addChild:fc];
        [fc setControlVector:CGVectorMake(-0.5, -0.5)];
    }
    
    return self;
}





@end





