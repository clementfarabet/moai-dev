#include <moaicore/MOAICoreText.h>

void writeCoreText(MOAIImage *image)
{
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef gc = CGBitmapContextCreate(image.GetBitmap(),
											image.GetWidth(),
											image.GetHeight(),
											8,
											image.GetWidth() * 4,
											colorSpace,
											kCGImageAlphaLast);
	
	CGColorSpaceRelease(colorSpace);

	CFStringRef string = (CFStringRef) @"Long text.\nBlablabla";
	
	CTFontRef font = CTFontCreateWithName(CFSTR("Times New Roman"), 16, NULL);
	
	//    create paragraph style and assign text alignment to it
	CTTextAlignment alignment = kCTJustifiedTextAlignment;
	CTParagraphStyleSetting _settings[] = { {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment} };
	CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(_settings, sizeof(_settings) / sizeof(_settings[0]));
	
	//    set paragraph style attribute
	CFAttributedStringSetAttribute(attrStr, CFRangeMake(0, CFAttributedStringGetLength(attrStr)), kCTParagraphStyleAttributeName, paragraphStyle);
	
	//    set font attribute
	CFAttributedStringSetAttribute(attrStr, CFRangeMake(0, CFAttributedStringGetLength(attrStr)), kCTFontAttributeName, font);
	
	
	CGContextRef context;
	
	
	// Initialize string, font, and context
	CFStringRef keys[] = { kCTFontAttributeName };
	CFTypeRef values[] = { font };
	
	CFDictionaryRef attributes =
    CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys,
					   (const void**)&values, sizeof(keys) / sizeof(keys[0]),
					   &kCFTypeDictionaryCallBacks,
					   &kCFTypeDictionaryValueCallbacks);
	
	CFAttributedStringRef attrString =
    CFAttributedStringCreate(kCFAllocatorDefault, string, attributes);
	
	CFRelease(string);
	CFRelease(attributes);
	
	CTLineRef line = CTLineCreateWithAttributedString(attrString);
	
	// Set text position and draw the line into the graphics context
	CGContextSetTextPosition(context, 10.0, 10.0);
	CTLineDraw(line, context);
	CFRelease(line);

	
	//    release paragraph style and font
	CFRelease(paragraphStyle);
	CFRelease(font);
}
