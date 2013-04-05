// Copyright (c) 2010-2011 Zipline Games, Inc. All Rights Reserved.
// http://getmoai.com

#include "pch.h"

#include <moaicore/MOAIDataBuffer.h>
#include <moaicore/MOAIGfxDevice.h>
#include <moaicore/MOAILogMessages.h>
#include <moaicore/MOAIPvrHeader.h>
#include <moaicore/MOAIStream.h>
#include <moaicore/MOAIAsyncTexture.h>
#include <moaicore/MOAIMultiTexture.h>

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <GLKit/GLKTextureLoader.h>


//================================================================//
// local
//================================================================//

//----------------------------------------------------------------//
/**	@name	load
	@text	Loads a texture from a data buffer or a file. Optionally pass
			in an image transform (not applicable to PVR textures).
	
	@overload
		@in		MOAIAsyncTexture self
		@in		string filename
		@opt	number transform		Any bitwise combination of MOAIImage.QUANTIZE, MOAIImage.TRUECOLOR, MOAIImage.PREMULTIPLY_ALPHA
		@opt	string debugname		Name used when reporting texture debug information
		@out	nil
	
	@overload
		@in		MOAIAsyncTexture self
		@in		MOAIImage image
		@opt	string debugname		Name used when reporting texture debug information
		@out	nil
	
	@overload
		@in		MOAIAsyncTexture self
		@in		MOAIDataBuffer buffer
		@opt	number transform		Any bitwise combination of MOAIImage.QUANTIZE, MOAIImage.TRUECOLOR, MOAIImage.PREMULTIPLY_ALPHA
		@opt	string debugname		Name used when reporting texture debug information
		@out	nil
	
	@overload
		@in		MOAIAsyncTexture self
		@in		MOAIStream buffer
		@opt	number transform		Any bitwise combination of MOAIImage.QUANTIZE, MOAIImage.TRUECOLOR, MOAIImage.PREMULTIPLY_ALPHA
		@opt	string debugname		Name used when reporting texture debug information
		@out	nil
*/
int MOAIAsyncTexture::_load ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAIAsyncTexture, "U" )

	self->Init ( state, 2 );
	return 0;
}

//================================================================//
// MOAIAsyncTexture
//================================================================//

//----------------------------------------------------------------//
MOAIGfxState* MOAIAsyncTexture::AffirmTexture ( MOAILuaState& state, int idx ) {

	MOAIGfxState* gfxState = 0;
	
	gfxState = state.GetLuaObject < MOAITextureBase >( idx, false );
	if ( gfxState ) return gfxState;
	
	gfxState = state.GetLuaObject < MOAIMultiTexture >( idx, false );
	if ( gfxState ) return gfxState;
	
	MOAIAsyncTexture* texture = new MOAIAsyncTexture ();
	if ( !texture->Init ( state, idx )) {
		// TODO: report error
		delete texture;
		texture = 0;
	}
	return texture;
}

//----------------------------------------------------------------//
bool MOAIAsyncTexture::Init ( MOAILuaState& state, int idx ) {

	u32 transform = state.GetValue < u32 >( idx + 1, MOAIAsyncTexture::DEFAULT_TRANSFORM );
	cc8* debugName = state.GetValue < cc8* >( idx + 2, 0 );

	if ( state.IsType ( idx, LUA_TUSERDATA )) {
		
		bool done = false;
		
		MOAIImage* image = state.GetLuaObject < MOAIImage >( idx, false );
		if ( image ) {
			this->Init ( *image, debugName ? debugName : "(texture from MOAIImage)" );
			done = true;
		}
		
		if ( !done ) {
			MOAIDataBuffer* data = state.GetLuaObject < MOAIDataBuffer >( idx, false );
			if ( data ) {
				this->Init ( *data, transform, debugName ? debugName : "(texture from MOAIDataBuffer)" );
				done = true;
			}
		}
		
		if ( !done ) {
			MOAIStream* stream = state.GetLuaObject < MOAIStream >( idx, false );
			if ( stream && stream->GetUSStream ()) {
				this->Init ( *stream->GetUSStream (), transform, debugName ? debugName : "(texture from MOAIStream)" );
				done = true;
			}
		}
		
		return done;
	}
	else if ( state.IsType ( idx, LUA_TSTRING )) {
		
		cc8* filename = lua_tostring ( state, idx );
		this->Init ( filename, transform );
		return true;
	}
	return false;
}

//----------------------------------------------------------------//
void MOAIAsyncTexture::Init ( MOAIImage& image, cc8* debugname ) {

	this->Clear ();
	
	if ( image.IsOK ()) {
		this->mImage.Copy ( image );
		this->mDebugName = debugname;
		this->Load ();
	}
}

//----------------------------------------------------------------//
void MOAIAsyncTexture::Init ( MOAIImage& image, int srcX, int srcY, int width, int height, cc8* debugname ) {

	this->Clear ();
	if ( image.IsOK ()) {

		this->mImage.Init ( width, height, image.GetColorFormat (), image.GetPixelFormat ());
		this->mImage.CopyBits ( image, srcX, srcY, 0, 0, width, height );
		
		this->mDebugName = debugname;
		this->Load ();
	}
}

//----------------------------------------------------------------//
void MOAIAsyncTexture::Init ( cc8* filename, u32 transform, cc8* debugname ) {

	this->Clear ();
	if ( MOAILogMessages::CheckFileExists ( filename )) {
		
		this->mFilename = USFileSys::GetAbsoluteFilePath ( filename );
		if ( debugname ) {
			this->mDebugName = debugname;
		}
		else {
			this->mDebugName = this->mFilename;
		}		
		this->mTransform = transform;
		this->Load ();
	} else {
			
		STLString expand = USFileSys::GetAbsoluteFilePath ( filename );
		MOAILog ( NULL, MOAILogMessages::MOAI_FileNotFound_S, expand.str ());
			
	}
}

//----------------------------------------------------------------//
void MOAIAsyncTexture::Init ( USStream& stream, u32 transform, cc8* debugname ) {

	this->Clear ();
	
	this->mImage.Load ( stream, transform );
	
	// if no image, check to see if the file is a PVR
	if ( !this->mImage.IsOK ()) {
		
		MOAIPvrHeader header;
		header.Load ( stream );
		
		// get file data, check if PVR		
		if ( header.IsValid ()) {
			
			u32 size = header.GetTotalSize ();
			
			this->mData = malloc ( size );
			this->mDataSize = size;		
			
			size = stream.ReadBytes ( this->mData, size );
			
			if ( size != this->mDataSize ) {
				free ( this->mData );
				this->mData = 0;
				this->mDataSize = 0;
			}
		}
	}
	
	// if we're OK, store the debugname and load
	if ( this->mImage.IsOK () || this->mData ) {
		this->mDebugName = debugname;
		this->Load ();
	}
}

//----------------------------------------------------------------//
void MOAIAsyncTexture::AsyncInit ( MOAIDataBuffer& data, u32, cc8* debugname ) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
	void* bytes;
	size_t size;
	data.Lock ( &bytes, &size );

	this->mData = malloc ( size );
	this->mDataSize = size;
	memcpy( this->mData, bytes, this->mDataSize );
	
	this->mDebugName = debugname;
	this->Load();
	
	data.Unlock ();
#endif
}

void MOAIAsyncTexture::Init ( MOAIDataBuffer& data, u32 transform, cc8* debugname ) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
	AsyncInit(data, transform, debugname); return;
#endif
	
	void* bytes;
	size_t size;
	data.Lock ( &bytes, &size );
	
	USByteStream stream;
	stream.SetBuffer ( bytes, size, size );
	
	this->Init ( stream, transform, debugname );
	
	data.Unlock ();
}


//----------------------------------------------------------------//
bool MOAIAsyncTexture::IsRenewable () {

	if ( this->mFilename.size ()) return true;
	if ( this->mImage.IsOK ()) return true;
	if ( this->mData ) return true;
	
	return false;
}

//----------------------------------------------------------------//
MOAIAsyncTexture::MOAIAsyncTexture () :
	mTransform ( DEFAULT_TRANSFORM ),
	mData ( 0 ),
	mDataSize ( 0 ) {
	
	RTTI_BEGIN
		RTTI_EXTEND ( MOAITextureBase )
	RTTI_END
}

//----------------------------------------------------------------//
MOAIAsyncTexture::~MOAIAsyncTexture () {
}

//----------------------------------------------------------------//
void MOAIAsyncTexture::OnClear () {

	MOAITextureBase::OnClear ();

	this->mFilename.clear ();
	this->mDebugName.clear ();
	this->mImage.Clear ();
	
	if ( this->mData ) {
		free ( this->mData );
		this->mData = NULL;
	}
	this->mDataSize = 0;
}

//----------------------------------------------------------------//
void MOAIAsyncTexture::AsyncOnCreate () {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
	if ( this->mData ) {
		
		NSLog(@"A!");
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
		GLKTextureLoader *textureLoader = [[GLKTextureLoader alloc] initWithSharegroup:[EAGLContext currentContext].sharegroup];
		
		this->mGLTexID = 0;
		this->mIsLoading = true;
		
		[textureLoader textureWithContentsOfData:[NSData dataWithBytes:this->mData length:this->mDataSize] options:nil queue:queue completionHandler: ^(GLKTextureInfo *name, NSError *err) {
			if (err!=nil)
			{
				NSLog(@"Error loading texture!");
			} else {
				this->mGLTexID = name.name;
				this->mIsLoading = false;
				NSLog(@"loaded %@", [NSNumber numberWithInt:this->mGLTexID]);
				
				MOAIGfxDevice::Get ().ReportTextureAlloc ( this->mDebugName, this->mTextureSize );
				this->mIsDirty = true;
			}

			[textureLoader release];
		}];
		
		NSLog(@"B!");

		if ( this->mData ) {
			free ( this->mData );
			this->mData = NULL;
		}
		this->mDataSize = 0;
	}

	if ( this->mFilename.size ()) {

		NSLog(@"A!");
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
		GLKTextureLoader *textureLoader = [[GLKTextureLoader alloc] initWithSharegroup:[EAGLContext currentContext].sharegroup];
		
		this->mGLTexID = 0;
		this->mIsLoading = true;
		
		NSString *filename = [NSString stringWithCString:this->mFilename.c_str() encoding:NSASCIIStringEncoding];
		
		[textureLoader textureWithContentsOfFile:filename options:nil queue:queue completionHandler: ^(GLKTextureInfo *name, NSError *err) {
			if (err!=nil)
			{
				NSLog(@"Error loading texture!");
			} else {
				this->mGLTexID = name.name;
				this->mIsLoading = false;
				NSLog(@"loaded %@", [NSNumber numberWithInt:this->mGLTexID]);
				
				MOAIGfxDevice::Get ().ReportTextureAlloc ( this->mDebugName, this->mTextureSize );
				this->mIsDirty = true;
			}
			
			[textureLoader release];
		}];
		
		NSLog(@"B!");
	}
#endif
}

//----------------------------------------------------------------//
void MOAIAsyncTexture::OnCreate () {

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
	AsyncOnCreate(); return;
#endif
	
	if ( this->mImage.IsOK ()) {
		this->CreateTextureFromImage ( this->mImage );
	}
	else if ( this->mData ) {
		this->CreateTextureFromPVR ( this->mData, this->mDataSize );
	}
	
	if ( this->mFilename.size ()) {
		
		this->mImage.Clear ();
		
		if ( this->mData ) {
			free ( this->mData );
			this->mData = NULL;
		}
		this->mDataSize = 0;
	}
}


//----------------------------------------------------------------//
void MOAIAsyncTexture::OnLoad () {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
	return;
#endif

	if ( this->mFilename.size ()) {
	
		this->mImage.Load ( this->mFilename, this->mTransform );
		
		if ( !this->mImage.IsOK ()) {
			
			// if no image, check to see if the file is a PVR
			USFileStream stream;
			stream.OpenRead ( this->mFilename );
			
			size_t size = stream.GetLength ();
			void* data = malloc ( size );
			stream.ReadBytes ( data, size );

			stream.Close ();
			
			if ( MOAIPvrHeader::GetHeader ( data, size )) {
				this->mData = data;
				this->mDataSize = size;		
			}
			else {
				free ( data );
			}
		}
	}
	
	if ( this->mImage.IsOK ()) {
		
		this->mWidth = this->mImage.GetWidth ();
		this->mHeight = this->mImage.GetHeight ();
	}
	else if ( this->mData ) {
	
		MOAIPvrHeader* header = MOAIPvrHeader::GetHeader ( this->mData, this->mDataSize );
		if ( header ) {
			this->mWidth = header->mWidth;
			this->mHeight = header->mHeight;
		}
	}

}

//----------------------------------------------------------------//
void MOAIAsyncTexture::RegisterLuaClass ( MOAILuaState& state ) {
	
	MOAITextureBase::RegisterLuaClass ( state );
}

//----------------------------------------------------------------//
void MOAIAsyncTexture::RegisterLuaFuncs ( MOAILuaState& state ) {

	MOAITextureBase::RegisterLuaFuncs ( state );
	
	luaL_Reg regTable [] = {
		{ "load",					_load },
		{ NULL, NULL }
	};

	luaL_register ( state, 0, regTable );
}

//----------------------------------------------------------------//
void MOAIAsyncTexture::SerializeIn ( MOAILuaState& state, MOAIDeserializer& serializer ) {
	MOAITextureBase::SerializeIn ( state, serializer );
	
	STLString path = state.GetField ( -1, "mPath", "" );
	
	if ( path.size ()) {
		this->Init ( path, DEFAULT_TRANSFORM ); // TODO: serialization
	}
}

//----------------------------------------------------------------//
void MOAIAsyncTexture::SerializeOut ( MOAILuaState& state, MOAISerializer& serializer ) {
	MOAITextureBase::SerializeOut ( state, serializer );
	
	STLString path = USFileSys::GetRelativePath ( this->mFilename );
	state.SetField ( -1, "mPath", path.str ());
}

