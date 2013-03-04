//
//  MoaiOpenGLView.h
//  ckoia
//
//  Created by Clement Farabet on 3/1/13.
//

#import <Cocoa/Cocoa.h>

@interface MoaiOpenGLView : NSOpenGLView
{
    GLuint framebuffer;
}

@property (assign) IBOutlet NSWindow *window;

@end
