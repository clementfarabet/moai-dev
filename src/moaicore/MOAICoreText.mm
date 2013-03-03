#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

#import <CoreFoundation/CFDictionary.h>
#import <CoreText/CoreText.h>


#include <moaicore/MOAICoreText.h>


void writeCoreText(MOAIImage &image)
{
	int w = image.GetWidth(), h = image.GetHeight();
	
	CTFontRef font = CTFontCreateWithName(CFSTR("Times"), 16.0, NULL);
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);



	
	
	
	CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
	CFAttributedStringReplaceString (attrString, CFRangeMake(0, 0), CFSTR("Because the world is round it turns me on."));
	
	//    create paragraph style and assign text alignment to it
	CTTextAlignment alignment = kCTRightTextAlignment;
//	CTTextAlignment alignment = kCTJustifiedTextAlignment;
//	CTTextAlignment alignment = kCTJustifiedTextAlignment;
	CTParagraphStyleSetting _settings[] = {    {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment} };
	CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(_settings, sizeof(_settings) / sizeof(_settings[0]));
	
	//    set paragraph style attribute
	CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTParagraphStyleAttributeName, paragraphStyle);
	
	//    set font attribute
	CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTFontAttributeName, font);
	
	//    set colod attribute
	//	CGFloat components[] = { 1.0, 1.0, 1.0, 1.0 };
	CGFloat components[] = { 0.0, 0.0, 0.0, 1.0 };
	CGColorRef col = CGColorCreate(colorSpace, components);
	CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTForegroundColorAttributeName, col);


	
	
    int bitmapBytesPerRow   = (w * 4);
    int bitmapByteCount     = (bitmapBytesPerRow * h);

    CGContextRef context = CGBitmapContextCreate (image.GetBitmap(),
												  w,
												  h,
												  8,
												  bitmapBytesPerRow,
												  colorSpace,
												  kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host);

	CGMutablePathRef path = CGPathCreateMutable();
	CGRect bounds = CGRectMake(0.0, 0.0, w, h);
	CGPathAddRect(path, NULL, bounds);
	
//	CGContextSetFillColorWithColor(context, CGColorGetConstantColor(kCGColorBlack));
//	CGRect rectangle = CGRectMake(0, 0, w,h);
//	CGContextAddRect(context, rectangle);
//	CGContextFillPath(context);
	
	
	// Draw the string
//	CTLineRef line = CTLineCreateWithAttributedString(attrString);

	
	
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);  //Use this one when using standard view coordinates
	
	CGContextSetShouldAntialias(context, YES);
	CGContextSetAllowsFontSmoothing(context, NO);
	CGContextSetShouldSmoothFonts(context, NO);
	CGContextSetAllowsFontSubpixelPositioning(context, YES);
	CGContextSetShouldSubpixelPositionFonts(context, YES);
	CGContextSetAllowsFontSubpixelQuantization(context, YES);
	CGContextSetShouldSubpixelQuantizeFonts(context, YES);
//	CGContextSetTextPosition(context, 20, 5);
//	CTLineDraw(line, context);
//	CGContextSetTextPosition(context, 20, 100);
//	CTLineDraw(line, context);
//	CFRelease(line);
	
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
	CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
												CFRangeMake(0, 0), path, NULL);
	CFRelease(framesetter);
	CTFrameDraw(frame, context);
	CFRelease(frame);
	
	// Clean up
	CFRelease(paragraphStyle);
	CFRelease(attrString);
	CFRelease(font);
	CFRelease(context);

}



void writeCoreTextGrey(MOAIImage &image)
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
	CGContextSetAllowsFontSmoothing(context, NO);
	CGContextSetShouldSmoothFonts(context, NO);
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