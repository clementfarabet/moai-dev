#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

#import <CoreFoundation/CFDictionary.h>
#import <CoreText/CoreText.h>


#include <moaicore/MOAICoreText.h>


void writeCoreTextRGBA(MOAIImage &image)
{
	int w = image.GetWidth(), h = image.GetHeight();
	
	CTFontRef font = CTFontCreateWithName(CFSTR("Helvetica"), 10.0, NULL);
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);

	CGFloat components[] = { 1.0, 1.0, 1.0, 1.0 };
	CGColorRef red = CGColorCreate(colorSpace, components);

	// Create an attributed string
	CFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName };
	CFTypeRef values[] = { font, red };
	CFDictionaryRef attr = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values,
											  sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	CFAttributedStringRef attrString = CFAttributedStringCreate(NULL, CFSTR("Hello World"), attr);
	CFRelease(attr);

	
    int bitmapBytesPerRow   = (w * 4);
    int bitmapByteCount     = (bitmapBytesPerRow * h);

    CGContextRef context = CGBitmapContextCreate (image.GetBitmap(),
												  w,
												  h,
												  8,
												  bitmapBytesPerRow,
												  colorSpace,
												  kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host);

	
//	CGContextSetFillColorWithColor(context, CGColorGetConstantColor(kCGColorBlack));
//	CGRect rectangle = CGRectMake(0, 0, w,h);
//	CGContextAddRect(context, rectangle);
//	CGContextFillPath(context);
	
	// Draw the string
	CTLineRef line = CTLineCreateWithAttributedString(attrString);
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);  //Use this one when using standard view coordinates
	
	CGContextSetShouldAntialias(context, YES);
	CGContextSetAllowsFontSmoothing(context, NO);
	CGContextSetShouldSmoothFonts(context, NO);
	CGContextSetAllowsFontSubpixelPositioning(context, NO);
	CGContextSetShouldSubpixelPositionFonts(context, NO);
	CGContextSetAllowsFontSubpixelQuantization(context, NO);
	CGContextSetShouldSubpixelQuantizeFonts(context, NO);
	CGContextSetTextPosition(context, 10, 5);
	CTLineDraw(line, context);
	
	// Clean up
	CFRelease(line);
	CFRelease(attrString);
	CFRelease(font);
	CFRelease(context);

}



void writeCoreText(MOAIImage &image)
{
	int w = image.GetWidth(), h = image.GetHeight();
	
	CTFontRef font = CTFontCreateWithName(CFSTR("Helvetica"), 10.0, NULL);
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	
	CGFloat components[] = { 1.0, 1.0, 1.0, 1.0 };
	CGColorRef red = CGColorCreate(colorSpace, components);
	
	// Create an attributed string
	CFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName };
	CFTypeRef values[] = { font, red };
	CFDictionaryRef attr = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values,
											  sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	CFAttributedStringRef attrString = CFAttributedStringCreate(NULL, CFSTR("Hello World"), attr);
	CFRelease(attr);
	
	
    int bitmapBytesPerRow   = (w * 1);
    int bitmapByteCount     = (bitmapBytesPerRow * h);
	
    CGContextRef context = CGBitmapContextCreate (image.GetBitmap(),
												  w,
												  h,
												  8,
												  bitmapBytesPerRow,
												  colorSpace,
												  kCGImageAlphaOnly);
	

	// Draw the string
	CTLineRef line = CTLineCreateWithAttributedString(attrString);
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);  //Use this one when using standard view coordinates
	
	CGContextSetShouldAntialias(context, YES);
	CGContextSetAllowsFontSmoothing(context, YES);
	CGContextSetShouldSmoothFonts(context, YES);
	CGContextSetAllowsFontSubpixelPositioning(context, YES);
	CGContextSetShouldSubpixelPositionFonts(context, YES);
	CGContextSetAllowsFontSubpixelQuantization(context, NO);
	CGContextSetShouldSubpixelQuantizeFonts(context, NO);
	CGContextSetTextPosition(context, 10, 5);
	CTLineDraw(line, context);
	
	// Clean up
	CFRelease(line);
	CFRelease(attrString);
	CFRelease(font);
	CFRelease(context);
	
}