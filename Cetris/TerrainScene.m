//
//  TerrainScene.m
//  Cetris
//
//  Created by Wan Wei on 14/6/28.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import "TerrainScene.h"
#import "Terrain.h"

#define kMaxHillKeyPoints 8
#define kHillSegmentWidth 5
#define kMaxHillVertices 4000
#define kMaxBorderVertices 800

typedef enum : NSUInteger {
    NONE,
    DIRECTION,
    LUANCH,
} ControlMode;

@interface TerrainScene() {
    CGPoint _hillKeyPoints[kMaxHillKeyPoints];
    CGPoint _controlOrigin;
    ControlMode _mode;
}

@property SKNode *draggedNode;
@property SKShapeNode *terrianNode;
@property SKNode *hero;
@property SKSpriteNode *control;
@property SKSpriteNode *pointer;
@end

@implementation TerrainScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
//        [self generateHills];
//        [self addTerrian];
        _terrianNode = [[Terrain alloc] initWithSize:size];
        [self addChild:_terrianNode];
        _mode = NONE;
        
        _hero = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(20, 10)];
        _hero.position = CGPointMake(100, self.size.height - 20);
        _hero.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(20, 10)];
        _hero.physicsBody.friction = 1.0f;
        [self addChild:_hero];
        
        // joy sticks
        _controlOrigin = CGPointMake(60, 60);
        _control = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:CGSizeMake(20, 20)];
        _control.name = @"Stick";
        _control.position = _controlOrigin;
        [self addChild:_control];
        
        _pointer = [SKSpriteNode spriteNodeWithColor:[UIColor purpleColor] size:CGSizeMake(10, 10)];
        [_pointer setHidden:YES];
        [self addChild:_pointer];
    }
    
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    SKNode *node = [self nodeAtPoint:[[touches anyObject] locationInNode:self]];
    
    if ([node.name isEqualToString:@"Stick"]) {
        self.draggedNode = node;
    }
    
    NSLog(@"touchesBegan");
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint location = [[touches anyObject] locationInNode:self];
    
    // Control dragged
    if (self.draggedNode != nil) {
        
        // determine control mode
        int xOffset = location.x - _controlOrigin.x;
        int yOffset = location.y - _controlOrigin.y;
        
        if (abs(xOffset) > abs(yOffset)) {
            _mode = DIRECTION;
        } else {
            if (yOffset < _control.size.height/2) {
                _mode = LUANCH;
            }

        }
        
        NSLog(@"xOffset=%d, yOffset=%d", xOffset, yOffset);
        NSLog(@"mode=%lu", _mode);
        if (_mode == DIRECTION) {
            if (abs(xOffset) < 30) {
                self.draggedNode.position = CGPointMake(location.x, self.draggedNode.position.y);
            }
            
            int xDelta = 100;
            if (self.draggedNode.position.x < _controlOrigin.x) {
                xDelta = -100;
            }
            [_hero runAction:[SKAction moveByX:xDelta y:0 duration:50]];
        }
        
        if (_mode == LUANCH) {
            _pointer.position = location;
            [_pointer setHidden:NO];
        }
        
    }
    
//    NSLog(@"touchesMoved");
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesEnded");
    [self.draggedNode runAction:[SKAction moveTo:CGPointMake(60, 60) duration:0.5]];
    
    if (self.draggedNode != nil) {
        //[self.draggedNode removeAllActions];
        [_hero removeAllActions];
        self.draggedNode = nil;
        _mode = NONE;
        
        [_pointer setHidden:YES];
    }
}

-(void)applyConstraints {
    if (_hero.position.x < 0) {
        _hero.position = CGPointMake(0, _hero.position.y);
    }
    if (_hero.position.x > self.size.width) {
        _hero.position = CGPointMake(self.size.width, _hero.position.y);
    }

}

-(void)didSimulatePhysics {
    [self applyConstraints];
}

-(void)didFinishUpdate {
    
}

@end
