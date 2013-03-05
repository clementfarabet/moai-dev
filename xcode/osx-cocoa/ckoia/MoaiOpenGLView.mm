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

namespace MoaiInputDeviceID {
	enum {
		DEVICE,
		TOTAL,
	};
}

namespace MoaiInputDeviceSensorID {
	enum {
		KEYBOARD,
		POINTER,
		MOUSE_LEFT,
		MOUSE_MIDDLE,
		MOUSE_RIGHT,
		TOTAL,
	};
}

@implementation MoaiOpenGLView

- (void)mouseMoved:(NSEvent *)theEvent
{
    NSRect screenRect = [self bounds];
    CGFloat screenHeight = screenRect.size.height;
    NSPoint loc = [theEvent locationInWindow];
    NSRect pixelRect = [self convertRectToBacking:screenRect];
    CGFloat pixelHeight = pixelRect.size.height;
    CGFloat ratio = pixelHeight/screenHeight;
	AKUEnqueuePointerEvent( MoaiInputDeviceID::DEVICE, MoaiInputDeviceSensorID::POINTER, loc.x*ratio, pixelHeight-loc.y*ratio );
}

- (void)mouseDown:(NSEvent *)theEvent
{
    AKUEnqueueButtonEvent( MoaiInputDeviceID::DEVICE, MoaiInputDeviceSensorID::MOUSE_LEFT, true);
}

- (void)mouseUp:(NSEvent *)theEvent
{
    AKUEnqueueButtonEvent( MoaiInputDeviceID::DEVICE, MoaiInputDeviceSensorID::MOUSE_LEFT, false);
}

-(void)rightMouseDown:(NSEvent *)theEvent
{
    AKUEnqueueButtonEvent( MoaiInputDeviceID::DEVICE, MoaiInputDeviceSensorID::MOUSE_RIGHT, true);
}

-(void)rightMouseUp:(NSEvent *)theEvent
{
    AKUEnqueueButtonEvent( MoaiInputDeviceID::DEVICE, MoaiInputDeviceSensorID::MOUSE_RIGHT, false);
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSRect screenRect = [self bounds];
    CGFloat screenHeight = screenRect.size.height;
    NSPoint loc = [theEvent locationInWindow];
    NSRect pixelRect = [self convertRectToBacking:screenRect];
    CGFloat pixelHeight = pixelRect.size.height;
    CGFloat ratio = pixelHeight/screenHeight;
	AKUEnqueuePointerEvent( MoaiInputDeviceID::DEVICE, MoaiInputDeviceSensorID::POINTER, loc.x*ratio, pixelHeight-loc.y*ratio );
}

- (void)scrollWheel:(NSEvent *)theEvent
{
}

- (void)keyDown:(NSEvent *)theEvent
{
    unsigned short key = theEvent.keyCode;
	AKUEnqueueKeyboardEvent( MoaiInputDeviceID::DEVICE, MoaiInputDeviceSensorID::KEYBOARD, key, true );
}

- (void)keyUp:(NSEvent *)theEvent
{
    unsigned short key = theEvent.keyCode;
	AKUEnqueueKeyboardEvent( MoaiInputDeviceID::DEVICE, MoaiInputDeviceSensorID::KEYBOARD, key, false );
}

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

- (void)drawRect:(NSRect)dirtyRect
{
    // Clear background
    glClearColor(0,0,0,1);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Render
    AKURender();

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

-( int ) guessScreenDpi {
    float dpi = 110;
    NSRect screenRect = [self bounds];
    CGFloat screenHeight = screenRect.size.height;
    NSRect pixelRect = [self convertRectToBacking:screenRect];
    CGFloat pixelHeight = pixelRect.size.height;
    CGFloat ratio = pixelHeight/screenHeight;
    dpi *= ratio;
    return dpi;
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

    // Steal Focus.
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [[[self window] windowController] setShouldCascadeWindows:NO];
    [[self window] setFrameAutosaveName:@"WindowConfig"];
    
    // Detect window size
    NSRect screenRect = [self convertRectToBacking:[self bounds]];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    printf("screenRect: %f, %f", screenRect.size.width, screenRect.size.height);

    // Setup MOAI view:
    AKUSetScreenSize ( screenWidth, screenHeight );
    AKUSetScreenDpi([ self guessScreenDpi ]);
    AKUSetViewSize ( screenWidth, screenHeight );
    AKUDetectGfxContext ();

    // Register input devices
    AKUSetInputConfigurationName ( "AKUCocoa" );
	AKUReserveInputDevices			( MoaiInputDeviceID::TOTAL );
	AKUSetInputDevice				( MoaiInputDeviceID::DEVICE, "device" );
	AKUReserveInputDeviceSensors	( MoaiInputDeviceID::DEVICE, MoaiInputDeviceSensorID::TOTAL );
	AKUSetInputDeviceKeyboard		( MoaiInputDeviceID::DEVICE, MoaiInputDeviceSensorID::KEYBOARD,		"keyboard" );
	AKUSetInputDevicePointer		( MoaiInputDeviceID::DEVICE, MoaiInputDeviceSensorID::POINTER,		"pointer" );
	AKUSetInputDeviceButton			( MoaiInputDeviceID::DEVICE, MoaiInputDeviceSensorID::MOUSE_LEFT,	"mouseLeft" );
	AKUSetInputDeviceButton			( MoaiInputDeviceID::DEVICE, MoaiInputDeviceSensorID::MOUSE_MIDDLE,	"mouseMiddle" );
	AKUSetInputDeviceButton			( MoaiInputDeviceID::DEVICE, MoaiInputDeviceSensorID::MOUSE_RIGHT,	"mouseRight" );
    
    // Initialize MOAI env
	AKURunBytecode ( moai_lua, moai_lua_SIZE );

    // Set Lua Working Dir
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    [[NSFileManager defaultManager] changeCurrentDirectoryPath:resourcePath];
    NSString *luacmd = [NSString stringWithFormat:@"MOAIFileSystem.setWorkingDirectory('%@')",resourcePath];
    AKURunString([luacmd UTF8String]);

    // Run user script:
    NSString *cwd = [[NSBundle mainBundle] bundlePath];
    NSString *main = [cwd stringByAppendingPathComponent:@"/Contents/Resources/main.lua"];
    AKURunScript ( [main UTF8String] );

    // Setup timer for redraws
    NSTimer *timer = [NSTimer timerWithTimeInterval:AKUGetSimStep() target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSEventTrackingRunLoopMode]; // ensure timer fires during resize

    // Active mouse moved events:
    [[self window] setAcceptsMouseMovedEvents:YES];
    [[self window] makeFirstResponder:self];
    
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
    AKUSetScreenDpi([ self guessScreenDpi ]);
    AKUSetViewSize ( screenWidth, screenHeight );
}

@end
