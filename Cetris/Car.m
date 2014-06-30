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

+(instancetype) carWithId:(int) carId {
    CGSize size = CGSizeMake(15, 10);
    Car *car = [Car spriteNodeWithColor:[UIColor redColor] size:size];
    car.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
    car.physicsBody.friction = 1.0f;
    car.isSelected = NO;
    [car setUserInteractionEnabled:YES];
    return car;
}

+(instancetype) leftCarWithId:(int) carId {
    Car *car = [Car carWithId:carId];
    car.isLeft = YES;
    return car;
}

+(instancetype) rightCarWithId:(int) carId {
    Car *car = [Car carWithId:carId];
    car.color = [UIColor greenColor];
    car.isLeft = NO;
    return car;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _isSelected = YES;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_isSelected) {
        CGPoint location = [[touches anyObject] locationInNode:self.parent];
        self.position = CGPointMake(location.x, self.position.y);
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    _isSelected = NO;
}

@end
