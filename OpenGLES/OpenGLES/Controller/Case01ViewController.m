//
//  Case01ViewController.m
//  OpenGLES
//
//  Created by 白鹤 on 2016/12/26.
//  Copyright © 2016年 白鹤. All rights reserved.
//

#import "Case01ViewController.h"

typedef struct {
    GLKVector3 positionCoords;
    GLKVector2 textureCoords;
}SceneVertex;

static const SceneVertex vertices[] =
{
    {{-0.5f, -0.5f,0.0}},  // lower left corner
    {{ 0.5f, -0.5f,0.0}},  // lower right corner
    {{-0.5f,  0.5f,0.0}},  // upper left corner
};

@interface Case01ViewController ()

@end

@implementation Case01ViewController

@synthesize baseEffect;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    GLKView *view = (GLKView *)self.view;
    
    NSAssert([view isKindOfClass:[GLKView class]], @"View COntroller's view is not a GLKView");
    
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    [EAGLContext setCurrentContext:view.context];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;
    
    // 图形的颜色
    self.baseEffect.constantColor = GLKVector4Make(1.0f,  // red
                                                   1.0f,  // green
                                                   1.0f,  // blue
                                                   1.0f); // alpha
    
    // 背景色
    glClearColor(0.0f,
                 0.0f,
                 0.0f,
                 1.0f);
    // 1.为缓存生成唯一的标示
    glGenBuffers(1,
                 &vertexBufferID);
    // 2.为接下来的运算绑定缓存
    glBindBuffer(GL_ARRAY_BUFFER,
                 vertexBufferID);
    // 3.复制数据到缓存中
    glBufferData(GL_ARRAY_BUFFER,  // 当前上下文所绑定的是哪一个缓存
                 sizeof(vertices), // 指定复制进这个缓存的字节的数量
                 vertices,         // 要复制的字节的地址
                 GL_STATIC_DRAW);  // 缓存在未来的运算中可能将会被怎么使用
    
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [self.baseEffect prepareToDraw];
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 4.启动
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    // 5.设置指针
    glVertexAttribPointer(// 当前的缓存包含每个顶点的位置信息
                          GLKVertexAttribPosition,
                          3,                   // 每个位置由三个部分
                          GL_FLOAT,            // 每部分都保存为一个浮点类型的值
                          GL_FALSE,            // 小数点固定数据是否可以被改变
                          sizeof(SceneVertex), // 步幅:每个顶点保存多少字节
                          NULL);      // 从当前绑定的顶点缓存开始位置访问顶点数据
    
    // 6.绘图
    glDrawArrays(GL_TRIANGLES,
                 0,
                 3);
}

-(void)viewDidUnload{
    [super viewDidUnload];
    
    GLKView *view = (GLKView *)self.view;
    
    [EAGLContext setCurrentContext:view.context];
    
    if(0 != vertexBufferID){
        glDeleteBuffers(1,
                        &vertexBufferID);
        vertexBufferID = 0;
    }
    
    ((GLKView *)self.view).context = nil;
    
    [EAGLContext setCurrentContext:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
