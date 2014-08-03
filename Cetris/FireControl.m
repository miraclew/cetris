//
//  FireControl.m
//  Cetris
//
//  Created by Wan Wei on 14/7/5.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import "FireControl.h"

@interface FireControl()

@property SKShapeNode *back;
@property SKShapeNode *fireButton;
@property SKShapeNode *handle;
@property SKShapeNode *arrow;
@property SKShapeNode *arrowLine;
@property (nonatomic, copy) FireBlock fireBlock;
@property (nonatomic, copy) VectorChangeBlock vectorChangeBlock;
@end

@implementation FireControl

+(instancetype) controlWithRadius:(CGFloat)radius FireBlock:(FireBlock) block1 VectorChangeBlock:(VectorChangeBlock)block2{
    FireControl *control = [[FireControl alloc] initWithRadius:radius FireBlock:block1 VectorChangeBlock:block2];
    return control;
}

-(instancetype)initWithRadius:(CGFloat) radius FireBlock:(FireBlock) block1 VectorChangeBlock:(VectorChangeBlock)block2{
    if (self = [super init]) {
        _radius = radius;
        _fireBlock = block1;
        _vectorChangeBlock = block2;
        _controlVector = CGVectorMake(0.5, 0.5);
        [self setUserInteractionEnabled:YES];
        
        _fireButton = [SKShapeNode node];
        [_fireButton setUserInteractionEnabled:YES];
        CGMutablePathRef path1 = CGPathCreateMutable();
        CGPathAddArc(path1, NULL, 0, 0, 0.2*radius, 0, M_PI*2, YES);
        _fireButton.path = path1;
        _fireButton.lineWidth = 1.0;
        _fireButton.fillColor = [SKColor redColor];
        _fireButton.strokeColor = [SKColor whiteColor];
        _fireButton.glowWidth = 0.5;
        _fireButton.name = @"FireButton";
        _fireButton.zPosition = 2;
        [self addChild:_fireButton];
       
        self.zPosition = 200;
        [self drawHandle];
        [self drawArrow];
    }
    
    return self;
}

-(void)drawHandle{
    if (_handle) {
        [_handle removeFromParent];
    }
    _handle = [SKShapeNode node];
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddArc(pathRef, NULL, 0, 0, 0.1*_radius, 0, M_PI*2, YES);
    _handle.path = pathRef;
    _handle.lineWidth = 1.0;
    _handle.fillColor = [SKColor blueColor];
    _handle.strokeColor = [SKColor whiteColor];
    _handle.glowWidth = 0.5;
    _handle.name = @"Handle";
    _handle.position = CGPointMake(-_radius * _controlVector.dx, -_radius*_controlVector.dy);
    _handle.zPosition = 2;
    [self addChild:_handle];
}

-(void)drawArrow{
    if (_arrow) {
        [_arrow removeFromParent];
    }
    if (_arrowLine) {
        [_arrowLine removeFromParent];
    }
    
    CGFloat angle = atan2f(-_handle.position.y, -_handle.position.x);
    NSLog(@"angle= %f", angle * 180 / M_PI);
    
    CGFloat triangleLength = 0.04*_radius;
    _arrow = [SKShapeNode node];
    CGMutablePathRef path1 = CGPathCreateMutable();
    CGPathMoveToPoint(path1, NULL, 0, triangleLength);
    CGPathAddLineToPoint(path1, NULL, 0, -triangleLength);
    CGPathAddLineToPoint(path1, NULL, sqrtf(2*triangleLength*triangleLength) , 0);
    CGPathCloseSubpath(path1);
    _arrow.strokeColor = [UIColor yellowColor];
    _arrow.lineWidth = 1;
    _arrow.fillColor = [UIColor yellowColor];
    _arrow.path = path1;
    _arrow.zPosition = 2;
    _arrow.zRotation = angle;
    _arrow.position = CGPointMake(-_handle.position.x, -_handle.position.y);
    [self addChild:_arrow];
    
    
    _arrowLine = [SKShapeNode node];
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathMoveToPoint(pathRef, NULL, _handle.position.x, _handle.position.y);
    CGPathAddLineToPoint(pathRef, NULL, -_handle.position.x, -_handle.position.y);
    _arrowLine.strokeColor = [UIColor yellowColor];
    _arrowLine.glowWidth = 5;
    _arrowLine.lineWidth = 1;
    _arrowLine.path = pathRef;
    _arrowLine.zPosition = 1;
    [self addChild:_arrowLine];
}

-(void)setControlVector:(CGVector)controlVector{
    _controlVector = controlVector;
    
    [self drawHandle];
    [self drawArrow];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"FireButton"]) {
        SKAction *scaleDown = [SKAction scaleTo:0.8 duration:0.2];
        SKAction *scaleUp = [SKAction scaleTo:1 duration:0.2];
        SKAction *sequence = [SKAction sequence:@[scaleDown, scaleUp]];
        [node runAction:sequence];
        if (_fireBlock) {
            _fireBlock(self);
        }
    } else if ([node.name isEqualToString:@"Handle"]) {
        
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"Handle"]) {
        node.position = location;
        [self drawArrow];
        
        _controlVector = CGVectorMake(-_handle.position.x/_radius, -_handle.position.y/_radius);
        if (_vectorChangeBlock) {
            _vectorChangeBlock(self);
        }
    }
    
}

@end
