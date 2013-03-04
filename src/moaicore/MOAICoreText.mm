#import <Foundation/Foundation.h>
//#import <ApplicationServices/ApplicationServices.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreFoundation/CFDictionary.h>
#import <CoreText/CoreText.h>


#include <moaicore/MOAICoreText.h>


// Copyright (c) 2010-2011 Zipline Games, Inc. All Rights Reserved.
// http://getmoai.com

#include "pch.h"
#include <contrib/utf8.h>
#include <moaicore/MOAIImage.h>
#include <moaicore/MOAIImageTexture.h>
#include <moaicore/MOAILogMessages.h>
#include <moaicore/MOAITextureBase.h>

//================================================================//
// local
//================================================================//

//----------------------------------------------------------------//
/**	@name	getFontName
 @text	Returns the filename of the font.
 
 @in		MOAICoreFont self
 @out	name
 */
int MOAICoreFont::_getFontName ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAICoreFont, "U" )
	state.Push ( self->mFontName );
	return 1;
}

//----------------------------------------------------------------//
/**	@name	load
 @text	Sets the filename of the font for use when loading glyphs.
 
 @in		MOAICoreFont self
 @in		string fontname			The name of the font to load.
 @out	nil
 */
int MOAICoreFont::_load ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAICoreFont, "US" )
	
	cc8* fontname	= state.GetValue < cc8* >( 2, "" );
	self->Init ( fontname );
	
	return 0;
}


//----------------------------------------------------------------//
/**	@name	setDefaultSize
 @text	Selects a glyph set size to use as the default size when no
 other size is specified by objects wishing to use MOAICoreFont to
 render text.
 
 @in		MOAICoreFont self
 @in		number points			The point size to be rendered onto the internal texture.
 @opt		number dpi				The device DPI (dots per inch of device screen). Default value is 72 (points same as pixels).
 @out		nil
 */
int MOAICoreFont::_setDefaultSize ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAICoreFont, "U" )
	
	float points	= state.GetValue < float >( 2, 0 );
	float dpi		= state.GetValue < float >( 3, DPI );
	
	self->mDefaultSize = POINTS_TO_PIXELS ( points, dpi );
	
	return 0;
}

//----------------------------------------------------------------//
void MOAICoreFont::Init ( cc8* filename ) {
	
	this->mFontName = STLString(filename);

}

//----------------------------------------------------------------//
MOAICoreFont::MOAICoreFont () :
mDefaultSize ( 0.0f ) {
	
	RTTI_BEGIN
	RTTI_EXTEND ( MOAILuaObject )
	RTTI_END
}

//----------------------------------------------------------------//
MOAICoreFont::~MOAICoreFont () {
	
//	this->mReader.Set ( *this, 0 );
//	this->mCache.Set ( *this, 0 );
}


//----------------------------------------------------------------//
void MOAICoreFont::RegisterLuaClass ( MOAILuaState& state ) {
}

//----------------------------------------------------------------//
void MOAICoreFont::RegisterLuaFuncs ( MOAILuaState& state ) {
	
	luaL_Reg regTable [] = {
		{ "getFontName",				_getFontName },
		{ "load",						_load },
		{ "setDefaultSize",				_setDefaultSize },
		{ NULL, NULL }
	};
	
	luaL_register ( state, 0, regTable );
}

//----------------------------------------------------------------//
void MOAICoreFont::SerializeIn ( MOAILuaState& state, MOAIDeserializer& serializer ) {
	UNUSED ( serializer );
	
	this->mFontName = state.GetField ( -1, "mFontName", this->mFontName );
	this->mDefaultSize = state.GetField ( -1, "mDefaultSize", this->mDefaultSize );
}

//----------------------------------------------------------------//
void MOAICoreFont::SerializeOut ( MOAILuaState& state, MOAISerializer& serializer ) {
	UNUSED ( serializer );
	
	state.SetField ( -1, "mFontName", this->mFontName );
	state.SetField ( -1, "mDefaultSize", this->mDefaultSize );
}















//================================================================//
// MOAICoreTextState
//================================================================//

//----------------------------------------------------------------//
MOAICoreTextState::MOAICoreTextState () :
mText ( "" ),
mFont ( 0 ),
mSize ( 0.0f ),
mScale ( 1.0f ),
mColor ( 0xffffffff ),
mHAlign(RIGHT_JUSTIFY),
mVAlign(LEFT_JUSTIFY)
{
}

//----------------------------------------------------------------//
MOAICoreTextState::~MOAICoreTextState () {
}


//================================================================//
// local
//================================================================//

//----------------------------------------------------------------//
/**	@name	getColor
 @text	Gets the color of the style.
 
 @in		MOAICoreText self
 @out	number r
 @out	number g
 @out	number b
 @out	number a
 */
int MOAICoreText::_getColor ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAICoreText, "U" )
	
	USColorVec color = USColor::Set ( self->mColor );
	
	lua_pushnumber ( state, color.mR );
	lua_pushnumber ( state, color.mG );
	lua_pushnumber ( state, color.mB );
	lua_pushnumber ( state, color.mA );
	
	return 4;
}

//----------------------------------------------------------------//
/**	@name	getFont
 @text	Gets the font of the style.
 
 @in		MOAICoreText self
 @out	MOAICoreFont font
 */
int MOAICoreText::_getFont ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAICoreText, "U" )
	
	MOAICoreFont* font = self->GetFont ();
	if ( font ) {
		font->PushLuaUserdata ( state );
		return 1;
	}
	
	return 0;
}

//----------------------------------------------------------------//
/**	@name	getScale
 @text	Gets the scale of the style.
 
 @in		MOAICoreText self
 @out	number scale
 */
int MOAICoreText::_getScale ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAICoreText, "U" )
	state.Push ( self->mScale );
	return 1;
}

//----------------------------------------------------------------//
/**	@name	getSize
 @text	Gets the size of the style.
 
 @in		MOAICoreText self
 @out	number size
 */
int MOAICoreText::_getSize ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAICoreText, "U" )
	lua_pushnumber ( state, self->mSize );
	return 1;
}

//----------------------------------------------------------------//
/**	@name	setAlignment
 @text	Sets the horizontal and/or vertical alignment of the text in the text box.
 
 @in		MOAITextBox self
 @in		enum hAlignment				Can be one of LEFT_JUSTIFY, CENTER_JUSTIFY or RIGHT_JUSTIFY.
 @in		enum vAlignment				Can be one of LEFT_JUSTIFY, CENTER_JUSTIFY or RIGHT_JUSTIFY.
 @out	nil
 */
int MOAICoreText::_setAlignment ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAICoreText, "UN" )
	
	self->mHAlign = state.GetValue < u32 >( 2, MOAICoreText::LEFT_JUSTIFY );
	self->mVAlign = state.GetValue < u32 >( 3, MOAICoreText::LEFT_JUSTIFY );
	
	return 0;
}

//----------------------------------------------------------------//
/**	@name	setColor
 @text	Initialize the style's color.
 
 @in		MOAICoreText self
 @in		number r	Default value is 0.
 @in		number g	Default value is 0.
 @in		number b	Default value is 0.
 @opt	number a	Default value is 1.
 @out	nil
 */
int MOAICoreText::_setColor ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAICoreText, "UNNN" )
	self->mColor = state.GetColor32 ( 2, 0.0f, 0.0f, 0.0f, 1.0f );
	return 0;
}

//----------------------------------------------------------------//
/**	@name	setFont
 @text	Sets or clears the style's font.
 
 @in		MOAICoreText self
 @opt	MOAICoreFont font		Default value is nil.
 @out	nil
 */
int MOAICoreText::_setFont ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAICoreText, "U" )
	MOAICoreFont* font = state.GetLuaObject < MOAICoreFont >( 2, true );
	self->SetFont ( font );
	return 0;
}

//----------------------------------------------------------------//
/**	@name	setScale
 @text	Sets the scale of the style. The scale is applied to
 any glyphs drawn using the style after the glyph set
 has been selected by size.
 
 @in		MOAICoreText self
 @opt	number scale		Default value is 1.
 @out	nil
 */
int MOAICoreText::_setScale ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAICoreText, "U" )
	self->mScale = state.GetValue < float >( 2, 1.0f );
	return 0;
}

//----------------------------------------------------------------//
/**	@name	setSize
 @text	Sets or clears the style's size.
 
 @in		MOAICoreText self
 @in		number points			The point size to be used by the style.
 @opt	number dpi				The device DPI (dots per inch of device screen). Default value is 72 (points same as pixels).
 @out	nil
 */
int MOAICoreText::_setSize ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAICoreText, "UN" )
	
	float points	= state.GetValue < float >( 2, 0.0f );
	float dpi		= state.GetValue < float >( 3, DPI );
	
	self->SetSize ( POINTS_TO_PIXELS ( points, dpi ));
	
	return 0;
}

//----------------------------------------------------------------//
/**	@name	setString
 @text	Sets the text string to be displayed by this textbox.
 
 @in		MOAITextBox self
 @in		string newStr				The new text string to be displayed.
 @out	nil
 */
int MOAICoreText::_setString ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAICoreText, "US" )
	
	cc8* text = state.GetValue < cc8* >( 2, "" );
	self->SetText ( text );
	
	return 0;
}

//================================================================//
// MOAICoreText
//================================================================//

//----------------------------------------------------------------//
void MOAICoreText::Init ( MOAICoreText& style ) {
	
	this->SetFont ( style.mFont );
	this->mSize = style.mSize;
	this->mColor = style.mColor;
}

//----------------------------------------------------------------//
MOAICoreText::MOAICoreText () {
	
	RTTI_BEGIN
	RTTI_EXTEND ( MOAILuaObject )
	RTTI_END
}

//----------------------------------------------------------------//
MOAICoreText::~MOAICoreText () {
	
	this->SetFont ( 0 );
}

//----------------------------------------------------------------//
void MOAICoreText::RegisterLuaClass ( MOAILuaState& state ) {
	UNUSED ( state );

	state.SetField ( -1, "LEFT_JUSTIFY", ( u32 )LEFT_JUSTIFY );
	state.SetField ( -1, "CENTER_JUSTIFY", ( u32 )CENTER_JUSTIFY );
	state.SetField ( -1, "RIGHT_JUSTIFY", ( u32 )RIGHT_JUSTIFY );
}

//----------------------------------------------------------------//
void MOAICoreText::RegisterLuaFuncs ( MOAILuaState& state ) {
	UNUSED ( state );
	
	luaL_Reg regTable [] = {
		{ "setAlignment",			_setAlignment },
		{ "getColor",				_getColor },
		{ "getFont",				_getFont },
		{ "getScale",				_getScale },
		{ "getSize",				_getSize },
		{ "setColor",				_setColor },
		{ "setFont",				_setFont },
		{ "setScale",				_setScale },
		{ "setSize",				_setSize },
		{ "setString",				_setString },
		{ "renderToImage",			_renderToImage },
		{ "premultiplyAlpha",		_premultiplyAlpha },
		{ NULL, NULL }
	};
	
	luaL_register ( state, 0, regTable );
}

//----------------------------------------------------------------//
void MOAICoreText::SerializeIn ( MOAILuaState& state, MOAIDeserializer& serializer ) {
	UNUSED ( state );
	UNUSED ( serializer );
}

//----------------------------------------------------------------//
void MOAICoreText::SerializeOut ( MOAILuaState& state, MOAISerializer& serializer ) {
	UNUSED ( state );
	UNUSED ( serializer );
}

//----------------------------------------------------------------//
void MOAICoreText::SetFont ( MOAICoreFont* font ) {
	
	if ( this->mFont != font ) {
		
		this->LuaRetain ( font );
		this->LuaRelease ( this->mFont );
		this->mFont = font;
	}
}

//----------------------------------------------------------------//
void MOAICoreText::SetSize ( float size ) {
	
	if ( this->mSize != size ) {
		this->mSize = size;
	}
}

//----------------------------------------------------------------//
void MOAICoreText::SetText ( cc8* text ) {

	this->mText = text;
}














//----------------------------------------------------------------//
/**	@name	renderToImage
 @text	Renders text into image using CoreText
 
 @in		MOAICoreText self
 @opt	MOAIImage img		Default value is nil.
 @out	nil
 */
int MOAICoreText::_renderToImage ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAICoreText, "U" )
	MOAIImage* img = state.GetLuaObject < MOAIImage >( 2, true );
	self->RenderToImage ( *img );
	return 0;
}

//----------------------------------------------------------------//
void MOAICoreText::RenderToImage( MOAIImage& img ) {
	this->RenderCoreText(img);
}


//----------------------------------------------------------------//
/**	@name	premultiplyAlpha
 @text	Premultiplies alpha into RGB values
 
 @in		MOAICoreText self
 @opt	MOAIImage	img		Default value is nil.
 @out	nil
 */
int MOAICoreText::_premultiplyAlpha ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAICoreText, "U" )
	MOAIImage* img = state.GetLuaObject < MOAIImage >( 2, true );
	self->PremultiplyAlpha ( *img );
	return 0;
}

//----------------------------------------------------------------//
void MOAICoreText::PremultiplyAlpha( MOAIImage &img ) {
	
	if (img.GetColorFormat() != USColor::RGBA_8888) {
		MOAILog ( NULL, MOAILogMessages::MOAI_ParamTypeMismatch, "Image not 32-bit RGBA. ");
		return;
	}
	
	u32 nPixels = img.GetWidth() * img.GetHeight();
	unsigned char *bm = (unsigned char *)img.GetBitmap();
	for (u32 k=0; k<nPixels; k++)
	{
		bm[4*k+0] = (bm[4*k+0]*bm[4*k+3])/255;
		bm[4*k+1] = (bm[4*k+1]*bm[4*k+3])/255;
		bm[4*k+2] = (bm[4*k+2]*bm[4*k+3])/255;
	}
}












void MOAICoreText::RenderCoreText(MOAIImage &image)
{
	MOAICoreFont *cfont = this->GetFont();
	if (!cfont)
	{
		MOAILog ( NULL, MOAILogMessages::MOAI_IndexOutOfRange_DDD, "No font set.");
		return;
	}
	
	int w = image.GetWidth(), h = image.GetHeight();
	
	CFStringRef fontName = CFStringCreateWithCStringNoCopy ( NULL,cfont->GetFontName(), kCFStringEncodingMacRoman, kCFAllocatorNull);
	CTFontRef font = CTFontCreateWithName(fontName, this->GetSize(), NULL);
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	//CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	
	CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
	CFStringRef cstring = CFStringCreateWithCStringNoCopy ( NULL,this->mText, kCFStringEncodingMacRoman, kCFAllocatorNull);
	CFAttributedStringReplaceString (attrString, CFRangeMake(0, 0), cstring);
	
	//    create paragraph style and assign text alignment to it
	CTTextAlignment alignment = kCTLeftTextAlignment;
	printf("%d", this-mHAlign);
	switch(this->mHAlign)
	{
		case LEFT_JUSTIFY:
			alignment = kCTLeftTextAlignment; break;
		case CENTER_JUSTIFY:
			alignment = kCTJustifiedTextAlignment; break;
		case RIGHT_JUSTIFY:
			alignment = kCTRightTextAlignment; break;
	}
	CTParagraphStyleSetting _settings[] = {    {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment} };
	CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(_settings, sizeof(_settings) / sizeof(_settings[0]));
	
	//    set paragraph style attribute
	CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTParagraphStyleAttributeName, paragraphStyle);
	
	//    set font attribute
	CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTFontAttributeName, font);
	
	USColorVec color = USColor::Set ( this->mColor );
	CGFloat components[] = { color.mR, color.mG, color.mB, color.mA };
	
	CGColorRef col = CGColorCreate(colorSpace, components);
	CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTForegroundColorAttributeName, col);

    CGContextRef context = CGBitmapContextCreate (image.GetBitmap(),
												  w,
												  h,
												  8,
												  w * 4,
												  colorSpace,
												  kCGImageAlphaPremultipliedLast);

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