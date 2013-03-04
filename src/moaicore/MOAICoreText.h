#ifndef	MOAICORETEXT_H
#define	MOAICORETEXT_H

#include "pch.h"
#include <moaicore/MOAIImage.h>

#define DPI 72
#define POINTS_TO_PIXELS(points,dpi) (( points * dpi ) / DPI )
#define PIXELS_TO_POINTS(pixels,dpi) (( pixels * DPI ) / dpi )

//================================================================//
// MOAICoreFont
//================================================================//
class MOAICoreFont :
public MOAILuaObject {
protected:
	
	STLString mFontName;
	u32 mFlags;
	
//	MOAILuaSharedPtr < MOAIFontReader > mReader;
//	MOAILuaSharedPtr < MOAIGlyphCacheBase > mCache;
	
	float mDefaultSize;
	
	//----------------------------------------------------------------//
	static int			_getFontName			( lua_State* L );
	static int			_load					( lua_State* L );
	static int			_setDefaultSize			( lua_State* L );
	
public:
	
	DECL_LUA_FACTORY ( MOAICoreFont )
	
	GET ( cc8*, FontName, mFontName );
	
	void				Init					( cc8* fontname );
	MOAICoreFont			();
	~MOAICoreFont			();
	void				RegisterLuaClass		( MOAILuaState& state );
	void				RegisterLuaFuncs		( MOAILuaState& state );
	void				SerializeIn				( MOAILuaState& state, MOAIDeserializer& serializer );
	void				SerializeOut			( MOAILuaState& state, MOAISerializer& serializer );
};


//================================================================//
// MOAICoreTextState
//================================================================//
class MOAICoreTextState {
protected:
	
	MOAICoreFont*	mFont;
	float			mSize;
	float			mScale;
	u32				mColor;
	STLString		mText;
	u32				mHAlign;
	u32				mVAlign;
	
public:
	enum {
		LEFT_JUSTIFY = 0,
		CENTER_JUSTIFY = 1,
		RIGHT_JUSTIFY = 2,
	};
	
	//----------------------------------------------------------------//
	MOAICoreTextState		();
	~MOAICoreTextState		();
};

//================================================================//
// MOAICoreText
//================================================================//
/**	@name	MOAICoreText
 @text	Represents a style that may be applied to a text box or a
 secion of text in a text box using a style escape.
 */
class MOAICoreText:
public MOAILuaObject,
public MOAICoreTextState {
private:
	static int		_setAlignment			( lua_State* L );
	static int		_getColor				( lua_State* L );
	static int		_getFont				( lua_State* L );
	static int		_getScale				( lua_State* L );
	static int		_getSize				( lua_State* L );
	static int		_setColor				( lua_State* L );
	static int		_setFont				( lua_State* L );
	static int		_setScale				( lua_State* L );
	static int		_setSize				( lua_State* L );
	static int		_setString				( lua_State* L );
	static int		_renderToImage			( lua_State* L );
	static int		_premultiplyAlpha		( lua_State* L );
	
public:
	
	DECL_LUA_FACTORY ( MOAICoreText )
	
	GET ( MOAICoreFont*, Font, mFont );
	GET ( float, Size, mSize );
	GET_SET ( u32, Color, mColor );
	
	//----------------------------------------------------------------//
	void			Init					( MOAICoreText& style );
	MOAICoreText							();
	~MOAICoreText							();
	void			Render					( MOAILuaState& state );
	void			RegisterLuaClass		( MOAILuaState& state );
	void			RegisterLuaFuncs		( MOAILuaState& state );
	void			SerializeIn				( MOAILuaState& state, MOAIDeserializer& serializer );
	void			SerializeOut			( MOAILuaState& state, MOAISerializer& serializer );
	void			SetFont					( MOAICoreFont* font );
	void			SetText					( cc8* text );
	void            ValidFont               ();
	void			SetSize					( float size );
	void            RenderToImage           ( MOAIImage &img );
	void            PremultiplyAlpha        ( MOAIImage &img );
	void			RenderCoreText			( MOAIImage &img );
};





#endif
