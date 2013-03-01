#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#include <CoreFoundation/CFDictionary.h>

#include <moaicore/MOAICoreText.h>

void writeCoreText(MOAIImage &image)
{
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(image.GetBitmap(),
											image.GetWidth(),
											image.GetHeight(),
											8,
											image.GetWidth() * 4,
											colorSpace,
											kCGImageAlphaNoneSkipLast );
	// kCGImageAlphaPremultipliedLast);
	// kCGImageAlphaLast
	
	CGColorSpaceRelease(colorSpace);

	
	CTFontRef font = CTFontCreateWithName(CFSTR("Helvetica"), 16, NULL);

	CFStringRef string = (CFStringRef) @"Long text.\nBlablabla";
	CFMutableAttributedStringRef attrStr = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
	CFAttributedStringReplaceString (attrStr, CFRangeMake(0, 0), string);
	
	//    create paragraph style and assign text alignment to it
	CTTextAlignment alignment = kCTJustifiedTextAlignment;
	CTParagraphStyleSetting _settings[] = { {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment} };
	CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(_settings, sizeof(_settings) / sizeof(_settings[0]));
	
	//    set paragraph style attribute
	CFAttributedStringSetAttribute(attrStr, CFRangeMake(0, CFAttributedStringGetLength(attrStr)), kCTParagraphStyleAttributeName, paragraphStyle);
	
	//    set font attribute
	CFAttributedStringSetAttribute(attrStr, CFRangeMake(0, CFAttributedStringGetLength(attrStr)), kCTFontAttributeName, font);
	
	CTLineRef line = CTLineCreateWithAttributedString(attrStr);
	
	// Set text position and draw the line into the graphics context
	CGContextSetTextPosition(context, 10.0, 10.0);
	CTLineDraw(line, context);
	CFRelease(line);

	
	//    release paragraph style and font
	CFRelease(string);
	CFRelease(paragraphStyle);
	CFRelease(font);
}
