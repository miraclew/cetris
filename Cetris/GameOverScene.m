//
//  GameOverScene.m
//  Cetris
//
//  Created by Wan Wei on 14/6/28.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import "GameOverScene.h"
#import "MyScene.h"

@implementation GameOverScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        SKLabelNode *titleNode = [SKLabelNode labelNodeWithFontNamed:@"System"];
        titleNode.text = @"炮弹对轰";
        titleNode.position = CGPointMake(size.width/2, size.height/2);
        [self addChild:titleNode];
        
        SKLabelNode *startNode = [SKLabelNode labelNodeWithFontNamed:@"System"];
        startNode.name = @"StartButton";
        startNode.text = @"开始";
        startNode.position = CGPointMake(size.width/2, size.height/2 - 80);
        [self addChild:startNode];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    //if fire button touched, bring the rain
    if ([node.name isEqualToString:@"StartButton"]) {
        SKAction *buttonClick = [SKAction playSoundFileNamed:@"pushbtn.wav" waitForCompletion:NO];
        [self runAction:buttonClick];
        SKScene *gameScene = [[MyScene alloc] initWithSize:self.size];
        SKTransition *transition = [SKTransition flipHorizontalWithDuration:0.5];
        [self.view presentScene:gameScene transition:transition];
    }
}

@end
