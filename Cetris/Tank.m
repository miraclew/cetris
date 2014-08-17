//
//  Tank.m
//  Cetris
//
//  Created by Wan Wei on 14/8/9.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import "Tank.h"

@implementation Tank {
    NSMutableArray* _wheels;
}

-(id)initWithPosition:(CGPoint)pos {
    if (self = [super initWithColor:nil size:CGSizeMake(100, 40)]) {
        _joints = [[NSMutableArray alloc] init];
        _wheels = [[NSMutableArray alloc] init];
        self.alpha = 0.5;
        
        _chassis = [SKSpriteNode spriteNodeWithImageNamed:@"tank"];
        _chassis.name = @"Tank.chassis";
        _chassis.position = pos;
        _chassis.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(_chassis.size.width-20, _chassis.size.height-20)];
        _chassis.physicsBody.mass = 0.8;
        [self addChild:_chassis];
        
        int STICK_LEN = 40;
        _stick = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(STICK_LEN, 5)];
        _stick.position = CGPointMake(pos.x+STICK_LEN/2, pos.y+15);
        _stick.anchorPoint = CGPointMake(0, 0.5);
        _stick.zPosition = -1;
//        _stick.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_stick.size];
//        _stick.physicsBody.dynamic = NO;
        [self addChild:_stick];
        
//        CGPoint p = CGPointMake(_stick.position.x-_stick.size.width/2, _stick.position.y);
//        SKPhysicsJointPin* pin = [SKPhysicsJointPin jointWithBodyA:_chassis.physicsBody bodyB:_stick.physicsBody anchor:p];
//        pin.frictionTorque = 1.0;
//        pin.shouldEnableLimits = YES;
//        pin.lowerAngleLimit = 0;
//        pin.upperAngleLimit = M_PI;
//        
//        [_joints addObject:pin];

        [self creatWheels];
    }
    
    return self;
}

-(void)setCollisionBitmask:(uint32_t)collisionBitmask {
    _chassis.physicsBody.categoryBitMask = collisionBitmask;
    _stick.physicsBody.categoryBitMask = collisionBitmask;
    
    for (SKSpriteNode* w in _wheels) {
        w.physicsBody.categoryBitMask = collisionBitmask;
    }
}

-(void)setZRotation:(CGFloat)zRotation {
    _chassis.zRotation = zRotation;
}

-(void)setTowerRotation:(CGFloat)towerRotation {
    _stick.zRotation = towerRotation;
    _towerRotation = towerRotation;
}

-(void)changeTowerRotaion:(CGFloat)rotationDelta {
    if (_stick.zRotation < 0) {
        if (_stick.zRotation >= -M_PI_2) {
            _stick.zRotation = 0;
        } else {
            _stick.zRotation = M_PI;
        }
    }
    CGFloat newRotaion = _stick.zRotation + rotationDelta;
    if (newRotaion < 1/20*M_PI) {
        return;
    }
    NSLog(@"zRotaion=%f", newRotaion);
    _stick.zRotation = newRotaion;
    _towerRotation = newRotaion;
}

-(CGFloat)zRotation {
    return _chassis.zRotation;
}

-(CGPoint)position {
    return _chassis.position;
}

-(void)takeTurn:(BOOL)take {
    if (take) {
        self.alpha = 1.0;
    } else {
        self.alpha = 0.5;
    }
}

-(void)creatWheels {
    for (int i=0; i<3; i++) {
        SKSpriteNode* w = [SKSpriteNode spriteNodeWithImageNamed:@"wheel"];
        w.name = @"Tank.wheel";
        w.position = CGPointMake(28*i+_chassis.position.x - 28, _chassis.position.y-8);
        w.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:w.size.width/2];
        [self addChild:w];
        w.physicsBody.friction = 0.5;
        w.physicsBody.mass = 2.0f;
        
        SKPhysicsJointPin* pin = [SKPhysicsJointPin jointWithBodyA:_chassis.physicsBody bodyB:w.physicsBody anchor:w.position];
        pin.frictionTorque = 0.05;
        [_joints addObject:pin];
        
        _leftWheel = w;
        [_wheels addObject:w];
    }
}

-(void)move:(BOOL)left {
//    NSLog(@"tank velocity: %f", _chassis.physicsBody.velocity.dx);
    if (fabs(_chassis.physicsBody.velocity.dx) > 100.0f) {
        return;
    }
    for (SKSpriteNode* w in _wheels) {
        [w.physicsBody applyTorque:left? -10:10];
    }
}

@end
