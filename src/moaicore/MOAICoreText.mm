#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

#import <CoreFoundation/CFDictionary.h>
#import <CoreText/CoreText.h>


#include <moaicore/MOAICoreText.h>

void writeCoreTextOLD(MOAIImage &image)
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


void writeCoreTextOld2(MOAIImage &image)

{
	CFStringRef string = (CFStringRef) @"Long";
	CTFontRef font = CTFontCreateWithName(CFSTR("Helvetica"), 16, NULL);

	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//	CGContextRef context = CGBitmapContextCreate(image.GetBitmap(),
//												 image.GetWidth(),
//												 image.GetHeight(),
//												 8,
//												 image.GetWidth() * 4,
//												 colorSpace,
//												 kCGImageAlphaNoneSkipLast );

	CGContextRef context = CGBitmapContextCreate(image.GetBitmap(),
												 image.GetWidth(),
												 image.GetHeight(),
												 8,
												 image.GetWidth() * 4,
												 colorSpace,
												 kCGImageAlphaNoneSkipLast );
	
	
	
	// Initialize string, font, and context
	CFStringRef keys[] = { kCTFontAttributeName };
	CFTypeRef values[] = { font };
	
	CFDictionaryRef attributes =
    CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys,
					   (const void**)&values, sizeof(keys) / sizeof(keys[0]),
					   &kCFTypeDictionaryKeyCallBacks,
					   &kCFTypeDictionaryValueCallBacks);
	
	CFAttributedStringRef attrString =
    CFAttributedStringCreate(kCFAllocatorDefault, string, attributes);
	CFRelease(string);
	CFRelease(attributes);
	
	CTLineRef line = CTLineCreateWithAttributedString(attrString);
	
	// Set text position and draw the line into the graphics context
	CGContextSetTextPosition(context, 10.0, 10.0);
	CTLineDraw(line, context);
	CFRelease(line);
	CFRelease(context);
}


void writeCoreText(MOAIImage &image)
{
	int w = image.GetWidth(), h = image.GetHeight();
	
	memset(image.GetBitmap(), 255, image.GetWidth()*image.GetHeight()*3);
	
	CTFontRef font = CTFontCreateWithName(CFSTR("Helvetica"), 10, NULL);
	
	// Create an attributed string
	CFStringRef keys[] = { kCTFontAttributeName };
	CFTypeRef values[] = { font };
	CFDictionaryRef attr = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values,
											  sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	CFAttributedStringRef attrString = CFAttributedStringCreate(NULL, CFSTR("H"), attr);
	CFRelease(attr);

	CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	
    int bitmapBytesPerRow   = (w * 4);
    int bitmapByteCount     = (bitmapBytesPerRow * h);
	
    void *bitmapData = calloc( bitmapByteCount, 1 );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        return;
    }
    CGContextRef context = CGBitmapContextCreate (bitmapData,
												  w,
												  h,
												  8,
												  bitmapBytesPerRow,
												  colorSpace,
												  kCGImageAlphaNoneSkipLast);
	
	// Draw the string
	CTLineRef line = CTLineCreateWithAttributedString(attrString);
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);  //Use this one when using standard view coordinates
	//CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0)); //Use this one if the view's coordinates are flipped
	
	

	CGContextSetTextPosition(context, 100, 100);
	CTLineDraw(line, context);
	
	// Clean up
	CFRelease(line);
	CFRelease(attrString);
	CFRelease(font);
	CFRelease(context);

}