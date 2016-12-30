//
//  6_3.c
//  6_3_顶点数组
//
//  Created by 白鹤 on 2016/12/30.
//  Copyright © 2016年 白鹤. All rights reserved.
//

#include "esUtil.h"

typedef struct {
    // Handle to a program object
    GLuint programObject;
    
}UserData;

///
// Initialize the program object
//

int Init ( ESContext *esContext){
    
    UserData *userData = esContext->userData;
    const char vShaderStr[] =
    "#version 300 es                            \n"
    "layout(location = 0) in vec4 a_position;   \n"
    "layout(location = 1) in vec4 a_color;      \n"
    "out vec4 v_color;                          \n"
    "void main()                                \n"
    "{                                          \n"
    "   v_color = a_color;                      \n"
    "   gl_Position = a_position;               \n"
    "}";
    
    const char fShaderStr[] =
    "#version 300 es                            \n"
    "precision mediump float;                   \n"
    "in vec4 v_color;                           \n"
    "out vec4 o_fragColor;                      \n"
    "void main()                                \n"
    "{                                          \n"
    "   o_fragColor = v_color;                  \n"
    "}";
    
    
    GLuint programObject;
    
    // Create the program object
    programObject = esLoadProgram( vShaderStr, fShaderStr );
    if( programObject == 0){
        
        return GL_FALSE;
    }
    
    // Store the program object
    userData->programObject = programObject;
    
    glClearColor( 1.0f, 1.0f, 1.0f, 0.0f);
    
    return GL_TRUE;
}

///
// Draw a triangle using the program object created in Init()
//

void Draw ( ESContext *esContext){
    
    UserData *userData = esContext->userData;
    GLfloat color[4] = { 1.0f, 0.0f, 0.0f, 1.0f};
    // 3 vertices , with (x,y,z) per-vertex
    GLfloat vertexPos[3 * 3] = {
        
         0.0f,  0.5f,  0.0f, // v0
        -0.5f, -0.5f,  0.0f, // v1
         0.5f, -0.5f,  0.0f  // v2
    };
    
    glViewport( 0, 0, esContext->width, esContext->height);
    
    glClear( GL_COLOR_BUFFER_BIT );
    
    glUseProgram( userData->programObject );
    
    // 指定了渲染时索引值为 index 的顶点属性数组的数据格式和位置
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, vertexPos );
    // 启用通用顶点属性数组
    glEnableVertexAttribArray( 0 );
    // 加载 index 指定的通用顶点属性
    glVertexAttrib4fv( 1, color );
    
    glDrawArrays( GL_TRIANGLES, 0, 3 );
    // 禁用通用顶点属性数组
    glDisableVertexAttribArray( 0 );
    
}

void Shutdown ( ESContext *esContext){
    
    UserData *userData = esContext->userData;
    
    glDeleteProgram( userData->programObject );
}

int esMain ( ESContext *esContext){
    
    esContext->userData = malloc( sizeof(UserData ) );
    
    esCreateWindow( esContext, "Example 6-3", 320, 240, ES_WINDOW_RGB );
    
    if( !Init( esContext ) ){
        
        return GL_FALSE;
    }
    
    esRegisterShutdownFunc( esContext, Shutdown );
    esRegisterDrawFunc( esContext,  Draw );
    
    return GL_TRUE;
}
