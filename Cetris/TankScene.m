//
//  TankScene.m
//  Cetris
//
//  Created by Wan Wei on 14/8/9.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import "TankScene.h"
#import "Tank.h"
#import "Vehicle.h"

@implementation TankScene {
    Tank* _tank;
    Vehicle* _car;
    BOOL _right;
    BOOL _anglePlus;
}
-(instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsBody.restitution = 0;
        _right = YES;
        _anglePlus = YES;

        _tank = [[Tank alloc] initWithPosition:CGPointMake(size.width/2, 200)];
        [self addChild:_tank];
//        self.backgroundColor = [SKColor whiteColor];
        
        for (SKPhysicsJoint* joint in _tank.joints) {
            [self.physicsWorld addJoint:joint];
        }
    }
    
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        
        CGPoint location = [touch locationInNode:self];       
        
    }
    
}

-(void)update:(NSTimeInterval)currentTime{
    if (_tank.position.x > 450) {
        _right = NO;
    }
    if (_tank.position.x < 100) {
        _right = YES;
    }

    
    if (_tank.stick.zRotation >= M_PI-0.01) {
        _anglePlus = NO;
    }
    if (_tank.stick.zRotation <= 0.01) {
        _anglePlus = YES;
    }

//    _tank.stick.zRotation += (_anglePlus?1:-1) * M_PI_4/100;

    [_tank move:_right];
    NSLog(@"Tank: %f/%f", _tank.position.x, _tank.position.y);
}

@end
