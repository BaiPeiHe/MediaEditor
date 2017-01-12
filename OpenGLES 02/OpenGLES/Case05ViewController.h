//
//  Case05ViewController.h
//  OpenGLES
//
//  Created by 白鹤 on 2016/12/28.
//  Copyright © 2016年 白鹤. All rights reserved.
//

#import <GLKit/GLKit.h>

@class AGLKVertexAttribArrayBuffer;

@interface Case05ViewController : GLKViewController
{
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    GLfloat _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    GLuint _texture0ID;
    GLuint _texture1ID;
}
@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexBuffer;


@end
