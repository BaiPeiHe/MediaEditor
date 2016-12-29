//
//  ViewController.m
//  Hello_Triangle
//
//  Created by 白鹤 on 2016/12/29.
//  Copyright © 2016年 白鹤. All rights reserved.
//

#import "RootViewController.h"
#import "esUtil.h"

extern void esMain(ESContext *esContext );

@interface RootViewController ()
{
    ESContext _esContext;
}

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
    if(!self.context){
        
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self setupGL];
    
}

- (void)dealloc
{
    [self tearDownGL];
    
    if([EAGLContext currentContext] == self.context){
        [EAGLContext setCurrentContext:nil];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    if([self isViewLoaded] && ([[self view] window] == nil)){
        self.view = nil;
        
        [self tearDownGL];
        
        if([EAGLContext currentContext] == self.context){
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
    // Dispose of any resources that can be recreated.
}

- (void)setupGL{
    
    [EAGLContext setCurrentContext:self.context];
    
    // 在一段内存块中填充某个给定的值，是对较大的结构体或数组进行清零操作的一种最快方法
    memset( &_esContext, 0, sizeof( _esContext ) );
    
    esMain( &_esContext );
}

- (void)tearDownGL{
    
    [EAGLContext setCurrentContext:self.context];
    
    if( _esContext.shutdownFunc ){
        
        _esContext.shutdownFunc( &_esContext );
    }
}

- (void)update{
    
    if( _esContext.updateFunc ){
        
        _esContext.updateFunc( &_esContext, self.timeSinceLastUpdate);
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    _esContext.width = view.drawableWidth;
    _esContext.height = view.drawableHeight;
    
    if( _esContext.drawFunc ){
        
        _esContext.drawFunc( &_esContext );
    }
}

@end
