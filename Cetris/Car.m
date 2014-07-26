//
//  Car.m
//  Cetris
//
//  Created by Wan Wei on 14/6/29.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import "Car.h"

@interface Car()
@property BOOL isSelected;
@end

@implementation Car

+(instancetype) carWithId:(int64_t) carId IsLeft:(BOOL)isLeft {
    CGSize size = CGSizeMake(15, 10);
    Car *car = [Car spriteNodeWithColor:isLeft?[UIColor redColor]:[UIColor greenColor] size:size];
    car.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
    car.physicsBody.friction = 1.0f;
    car.physicsBody.usesPreciseCollisionDetection = YES;
    car.isSelected = NO;
    car.isLeft = isLeft;
    [car setUserInteractionEnabled:YES];
    return car;
}

-(void)takeTurn:(BOOL)take {
    [self removeAllActions];
    self.alpha = 1.0;
    if (take) {
        SKAction* fadeOut = [SKAction fadeOutWithDuration:1];
        SKAction* fadeIn = [SKAction fadeInWithDuration:1];
        [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[fadeOut, fadeIn]]]];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _isSelected = YES;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_isSelected) {
        CGPoint location = [[touches anyObject] locationInNode:self.parent];
        self.position = CGPointMake(location.x, self.position.y);
        if ([_delegate respondsToSelector:@selector(didPositionChanged:Position:)]) {
            [_delegate didPositionChanged:self Position:self.position];
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    _isSelected = NO;
}

@end
