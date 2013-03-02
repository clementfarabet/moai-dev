//
//  MoaiOpenGLView.m
//  ckoia
//
//  Created by Clement Farabet on 3/1/13.
//

#import "MoaiOpenGLView.h"

#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/glu.h>

#include <stdio.h>
#include <stdlib.h>
#include <lua-headers/moai_lua.h>
#include <aku/AKU.h>
#include <aku/AKU-luaext.h>
#include <aku/AKU-untz.h>

@implementation MoaiOpenGLView

- (id)initWithFrame:(NSRect)frame
{
    // Set up pixel config:
    NSOpenGLPixelFormatAttribute attributes [] = {
        NSOpenGLPFAWindow,
        NSOpenGLPFADoubleBuffer,	// double buffered
        NSOpenGLPFADepthSize, (NSOpenGLPixelFormatAttribute)16, // 16 bit depth buffer
        (NSOpenGLPixelFormatAttribute)nil
    };
    NSOpenGLPixelFormat * pf = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes] autorelease];

	self = [super initWithFrame:frame pixelFormat: pf];
    return self;
}

static void drawAnObject ()
{
    glColor3f(1.0f, 0.85f, 0.35f);
    glBegin(GL_TRIANGLES);
    {
        glVertex3f(  0.0,  0.6, 0.0);
        glVertex3f( -0.2, -0.3, 0.0);
        glVertex3f(  0.2, -0.3 ,0.0);
    }
    glEnd();
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Clear background
    glClearColor(0,0,0,1);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Render
    AKURender();
    //drawAnObject();
    
    // Done
    glFlush();
}

- (void)onTimer:(NSTimer *)timer
{
    // Update model
	AKUUpdate();
    
    // Redraw:
    [self drawRect:[self bounds]];
}

// set initial OpenGL state (current context is set)
// called after context is created
- (void) prepareOpenGL
{
    // Enable VSYNC:
    GLint swapInt = 1;
    [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
    
    // Go High Res
    [self  setWantsBestResolutionOpenGLSurface:YES];
    [self convertRectToBacking:[self bounds]];

    // AKU Context
    AKUCreateContext ();

    // Load Packages
    AKUExtLoadLuacrypto ();
    AKUExtLoadLuacurl ();
    AKUExtLoadLuafilesystem ();
    AKUExtLoadLuasocket ();
    AKUExtLoadLuasql ();
    AKUUntzInit ();

    // Detect window size (this doesnt work...)
    NSRect screenRect = [self convertRectToBacking:[self bounds]];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;

    // Setup MOAI view:
    AKUSetScreenSize ( screenWidth, screenHeight );
    AKUSetViewSize ( screenWidth, screenHeight );
    AKUDetectGfxContext ();

    // Initialize MOAI env
	AKURunBytecode ( moai_lua, moai_lua_SIZE );

    // Run user script:
    NSString *cwd = [[NSBundle mainBundle] bundlePath];
    NSString *main = [cwd stringByAppendingPathComponent:@"/Contents/Resources/main.lua"];
    AKURunScript ( [main UTF8String] );

    // Setup timer for redraws
    NSTimer *timer = [NSTimer timerWithTimeInterval:AKUGetSimStep() target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSEventTrackingRunLoopMode]; // ensure timer fires during resize
}

// window resizes, moves and display changes (resize, depth and display config change)
- (void) update
{
    // Super class
	[super update];
    
    // Detect window size
    NSRect screenRect = [self convertRectToBacking:[self bounds]];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    // Update
    AKUSetScreenSize ( screenWidth, screenHeight );
    AKUSetViewSize ( screenWidth, screenHeight );
}

@end
