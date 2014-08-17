//
//  ViewController.m
//  Cetris
//
//  Created by Wan Wei on 14-6-15.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import "ViewController.h"
#import "TerrainScene.h"
#import "TestScene.h"
#import "StartScene.h"
#import "TankScene.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
//    skView.showsPhysics = YES;
    
    self.game = [[Game alloc] init];
    self.game.view = skView;    
    [self.game start];
//    [self presentTestScene:skView];
}

-(void)presentTestScene:(SKView *)view {
    SKScene *scene = [[TankScene alloc] initWithSize:self.view.bounds.size];
    [view presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

@end
