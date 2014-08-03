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
@property (nonatomic)  int timeOut;
@end

@implementation Car {
    SKLabelNode* _countDown;
    SKShapeNode* _arrowLine;
    NSTimer* _countDownTimer;
}

+(instancetype) carWithId:(int64_t) carId IsLeft:(BOOL)isLeft IsMe:(BOOL)isMe {
    Car *car = [[Car alloc] initWithColor:nil size:CGSizeMake(0, 0) IsLeft:isLeft IsMe:isMe];
    return car;
}

-(instancetype)initWithColor:(UIColor *)color size:(CGSize)size IsLeft:(BOOL)isLeft IsMe:(BOOL)isMe {
    CGSize _size = CGSizeMake(15, 10);
    UIColor* _color = isLeft?[UIColor redColor]:[UIColor greenColor];
    if (self = [super initWithColor:_color size:_size]) {
        _timeOut = 5;
        
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_size];
        self.physicsBody.friction = 0.1f;
        self.physicsBody.usesPreciseCollisionDetection = YES;
        self.isSelected = NO;
        self.isLeft = isLeft;
        if (isLeft) {
            _towerRotation = M_PI_4;
        } else {
            _towerRotation = 3* M_PI_4;
        }
        [self setUserInteractionEnabled:YES];
        
        _countDown = [SKLabelNode labelNodeWithFontNamed:@"System"];
        _countDown.position = CGPointMake(0, 30);
        _countDown.hidden = YES;
        [self addChild:_countDown];
        
        if (isMe) {
            _arrowLine = [SKShapeNode node];
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, NULL, 0,0);
            CGPathAddLineToPoint(pathRef, NULL, 20, 0);
            _arrowLine.strokeColor = [UIColor yellowColor];
            _arrowLine.lineWidth = 1;
            _arrowLine.path = pathRef;
            _arrowLine.zPosition = 1;
            _arrowLine.zRotation = _towerRotation;
            
            [self addChild:_arrowLine];
        }
    }
    
    return self;
}

-(void)setTowerRotation:(CGFloat)towerRotation {
    _towerRotation = towerRotation;
    _arrowLine.zRotation = towerRotation;
}

-(void)takeTurn:(BOOL)take {
//    [self removeAllActions];
    [_countDownTimer invalidate];
    _countDown.hidden = YES;
    self.timeOut = 5;
    
    self.alpha = 1.0;
    if (take) {
        _countDown.hidden = NO;
        _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
//        SKAction* fadeOut = [SKAction fadeOutWithDuration:1];
//        SKAction* fadeIn = [SKAction fadeInWithDuration:1];
//        [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[fadeOut, fadeIn]]]];
    }
}

-(void)countDown {
    self.timeOut--;

    if (self.timeOut == 0) {
        [_countDownTimer invalidate];
        _countDown.hidden = YES;
    } else {
        
    }
}

-(void)setTimeOut:(int)timeOut{
    _timeOut = timeOut;
    _countDown.text = [NSString stringWithFormat:@"%d", _timeOut];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _isSelected = YES;
    NSLog(@"touchesBegan");
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
