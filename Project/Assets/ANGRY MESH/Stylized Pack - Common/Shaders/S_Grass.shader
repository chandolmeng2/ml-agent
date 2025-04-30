// Made with Amplify Shader Editor v1.9.8.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ANGRYMESH/Stylized Pack/Grass"
{
	Properties
	{
		[Header(Base)][Toggle(_ENABLESMOOTHNESSWAVES_ON)] _EnableSmoothnessWaves("Enable Smoothness Waves", Float) = 1
		_BaseOpacityCutoff("Base Opacity Cutoff", Range( 0 , 1)) = 0.3
		[HDR]_BaseAlbedoColor("Base Albedo Color", Color) = (0.5019608,0.5019608,0.5019608,0)
		_BaseAlbedoBrightness("Base Albedo Brightness", Range( 0 , 5)) = 1
		_BaseAlbedoDesaturation("Base Albedo Desaturation", Range( 0 , 1)) = 0
		_BaseSmoothnessIntensity("Base Smoothness Intensity", Range( 0 , 1)) = 0.5
		_BaseSmoothnessWaves("Base Smoothness Waves", Range( 0 , 1)) = 0.5
		_BaseNormalIntensity("Base Normal Intensity", Range( 0 , 5)) = 0
		[NoScaleOffset]_BaseAlbedo("Base Albedo", 2D) = "gray" {}
		[NoScaleOffset]_BaseNormal("Base Normal", 2D) = "bump" {}
		[Header(Bottom Color)][Toggle(_ENABLEBOTTOMCOLOR_ON)] _EnableBottomColor("Enable Bottom Color", Float) = 1
		[Toggle(_ENABLEBOTTOMDITHER_ON)] _EnableBottomDither("Enable Bottom Dither", Float) = 0
		[HDR]_BottomColor("Bottom Color", Color) = (0.5019608,0.5019608,0.5019608,0)
		_BottomColorOffset("Bottom Color Offset", Range( 0 , 5)) = 1
		_BottomColorContrast("Bottom Color Contrast", Range( 0 , 5)) = 1
		_BottomDitherOffset("Bottom Dither Offset", Range( -1 , 1)) = 0
		_BottomDitherContrast("Bottom Dither Contrast", Range( 1 , 10)) = 3
		[Header(Tint Color)][Toggle(_ENABLETINTVARIATIONCOLOR_ON)] _EnableTintVariationColor("Enable Tint Variation Color", Float) = 1
		[HDR]_TintColor("Tint Color", Color) = (0.5019608,0.5019608,0.5019608,0)
		_TintNoiseUVScale("Tint Noise UV Scale", Range( 0 , 50)) = 5
		_TintNoiseIntensity("Tint Noise Intensity", Range( 0 , 1)) = 1
		_TintNoiseContrast("Tint Noise Contrast", Range( 0 , 10)) = 5
		[IntRange]_TintNoiseInvertMask("Tint Noise Invert Mask", Range( 0 , 1)) = 0
		[Header(Wind)][Toggle(_ENABLEWIND_ON)] _EnableWind("Enable Wind", Float) = 1
		_WindGrassAmplitude("Wind Grass Amplitude", Range( 0 , 1)) = 1
		_WindGrassSpeed("Wind Grass Speed", Range( 0 , 1)) = 1
		_WindGrassScale("Wind Grass Scale", Range( 0 , 1)) = 1
		_WindGrassTurbulence("Wind Grass Turbulence", Range( 0 , 1)) = 1
		_WindGrassFlexibility("Wind Grass Flexibility", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

		//_TransmissionShadow( "Transmission Shadow", Range( 0, 1 ) ) = 0.5
		//_TransStrength( "Trans Strength", Range( 0, 50 ) ) = 1
		//_TransNormal( "Trans Normal Distortion", Range( 0, 1 ) ) = 0.5
		//_TransScattering( "Trans Scattering", Range( 1, 50 ) ) = 2
		//_TransDirect( "Trans Direct", Range( 0, 1 ) ) = 0.9
		//_TransAmbient( "Trans Ambient", Range( 0, 1 ) ) = 0.1
		//_TransShadow( "Trans Shadow", Range( 0, 1 ) ) = 0.5
		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25
		//[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		//[ToggleOff] _GlossyReflections("Reflections", Float) = 1.0
	}

	SubShader
	{
		
		Tags { "RenderType"="Opaque" "Queue"="Geometry" "DisableBatching"="False" }
	LOD 0

		Cull Off
		AlphaToMask Off
		ZWrite On
		ZTest LEqual
		ColorMask RGBA
		
		Blend Off
		

		CGINCLUDE
		#pragma target 3.5

		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}

		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		ENDCG

		
		Pass
		{
			
			Name "ForwardBase"
			Tags { "LightMode"="ForwardBase" }

			Blend One Zero

			CGPROGRAM
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#pragma multi_compile_instancing
			#pragma multi_compile __ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define ASE_VERSION 19801

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#ifndef UNITY_PASS_FORWARDBASE
				#define UNITY_PASS_FORWARDBASE
			#endif
			#include "HLSLSupport.cginc"
			#ifndef UNITY_INSTANCED_LOD_FADE
				#define UNITY_INSTANCED_LOD_FADE
			#endif
			#ifndef UNITY_INSTANCED_SH
				#define UNITY_INSTANCED_SH
			#endif
			#ifndef UNITY_INSTANCED_LIGHTMAPSTS
				#define UNITY_INSTANCED_LIGHTMAPSTS
			#endif
			#include "UnityShaderVariables.cginc"
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			#include "AutoLight.cginc"

			#include "UnityStandardUtils.cginc"
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_SCREEN_POSITION
			#pragma shader_feature_local _ENABLEWIND_ON
			#pragma shader_feature_local _ENABLEBOTTOMCOLOR_ON
			#pragma shader_feature_local _ENABLETINTVARIATIONCOLOR_ON
			#pragma shader_feature_local _ENABLESMOOTHNESSWAVES_ON
			#pragma shader_feature_local _ENABLEBOTTOMDITHER_ON

			struct appdata {
				float4 vertex : POSITION;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				half4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f {
				#if UNITY_VERSION >= 201810
					UNITY_POSITION(pos);
				#else
					float4 pos : SV_POSITION;
				#endif
				#if defined(LIGHTMAP_ON) || (!defined(LIGHTMAP_ON) && SHADER_TARGET >= 30)
					float4 lmap : TEXCOORD0;
				#endif
				#if !defined(LIGHTMAP_ON) && UNITY_SHOULD_SAMPLE_SH
					half3 sh : TEXCOORD1;
				#endif
				#if defined(UNITY_HALF_PRECISION_FRAGMENT_SHADER_REGISTERS) && UNITY_VERSION >= 201810 && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					UNITY_LIGHTING_COORDS(2,3)
				#elif defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if UNITY_VERSION >= 201710
						UNITY_SHADOW_COORDS(2)
					#else
						SHADOW_COORDS(2)
					#endif
				#endif
				#ifdef ASE_FOG
					UNITY_FOG_COORDS(4)
				#endif
				float4 tSpace0 : TEXCOORD5;
				float4 tSpace1 : TEXCOORD6;
				float4 tSpace2 : TEXCOORD7;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 screenPos : TEXCOORD8;
				#endif
				float4 ase_texcoord9 : TEXCOORD9;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			uniform sampler2D ASPW_WindGrassWavesNoiseTexture;
			uniform half3 ASPW_WindDirection;
			uniform half _WindGrassSpeed;
			uniform half ASPW_WindGrassSpeed;
			uniform half _WindGrassAmplitude;
			uniform half ASPW_WindGrassAmplitude;
			uniform half ASPW_WindGrassFlexibility;
			uniform half _WindGrassFlexibility;
			uniform half ASPW_WindGrassWavesAmplitude;
			uniform half ASPW_WindGrassWavesSpeed;
			uniform half ASPW_WindGrassWavesScale;
			uniform half _WindGrassScale;
			uniform half ASPW_WindGrassTurbulence;
			uniform half _WindGrassTurbulence;
			uniform half ASPW_WindToggle;
			uniform sampler2D _BaseAlbedo;
			uniform half _BaseAlbedoDesaturation;
			uniform half _BaseAlbedoBrightness;
			uniform half4 _BaseAlbedoColor;
			uniform half4 _TintColor;
			uniform sampler2D ASP_GlobalTintNoiseTexture;
			uniform half ASP_GlobalTintNoiseUVScale;
			uniform half _TintNoiseUVScale;
			uniform half _TintNoiseInvertMask;
			uniform half ASP_GlobalTintNoiseContrast;
			uniform half _TintNoiseContrast;
			uniform half ASP_GlobalTintNoiseToggle;
			uniform half _TintNoiseIntensity;
			uniform half ASP_GlobalTintNoiseIntensity;
			uniform half4 _BottomColor;
			uniform half _BottomColorOffset;
			uniform half _BottomColorContrast;
			uniform sampler2D _BaseNormal;
			uniform half _BaseNormalIntensity;
			uniform half _BaseSmoothnessIntensity;
			uniform half _BaseSmoothnessWaves;
			uniform half _BottomDitherOffset;
			uniform half _BottomDitherContrast;
			uniform half _BaseOpacityCutoff;


			float3 ASESafeNormalize(float3 inVec)
			{
				float dp3 = max(1.175494351e-38, dot(inVec, inVec));
				return inVec* rsqrt(dp3);
			}
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			
			float4 ASEScreenPositionNormalizedToPixel( float4 screenPosNorm )
			{
				float4 screenPosPixel = screenPosNorm * float4( _ScreenParams.xy, 1, 1 );
				#if UNITY_UV_STARTS_AT_TOP
					screenPosPixel.xy = float2( screenPosPixel.x, ( _ProjectionParams.x < 0 ) ? _ScreenParams.y - screenPosPixel.y : screenPosPixel.y );
				#else
					screenPosPixel.xy = float2( screenPosPixel.x, ( _ProjectionParams.x > 0 ) ? _ScreenParams.y - screenPosPixel.y : screenPosPixel.y );
				#endif
				return screenPosPixel;
			}
			
			inline float Dither4x4Bayer( int x, int y )
			{
				const float dither[ 16 ] = {
				     1,  9,  3, 11,
				    13,  5, 15,  7,
				     4, 12,  2, 10,
				    16,  8, 14,  6 };
				int r = y * 4 + x;
				return dither[ r ] / 16; // same # of instructions as pre-dividing due to compiler magic
			}
			

			v2f VertexFunction (appdata v  ) {
				UNITY_SETUP_INSTANCE_ID(v);
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_TRANSFER_INSTANCE_ID(v,o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				half3 temp_cast_0 = (0.0).xxx;
				half3 Global_Wind_Direction238_g1 = ASPW_WindDirection;
				half3 normalizeResult41_g1 = ASESafeNormalize( Global_Wind_Direction238_g1 );
				half3 worldToObjDir40_g1 = mul( unity_WorldToObject, float4( normalizeResult41_g1, 0.0 ) ).xyz;
				half3 Wind_Direction_Leaf50_g1 = worldToObjDir40_g1;
				half3 break42_g1 = Wind_Direction_Leaf50_g1;
				half3 appendResult43_g1 = (half3(break42_g1.z , 0.0 , ( break42_g1.x * -1.0 )));
				half3 Wind_Direction52_g1 = appendResult43_g1;
				float3 ase_objectPosition = UNITY_MATRIX_M._m03_m13_m23;
				half Wind_Grass_Randomization65_g1 = frac( ( ( ase_objectPosition.x + ase_objectPosition.y + ase_objectPosition.z ) * 1.23 ) );
				half temp_output_5_0_g1 = ( Wind_Grass_Randomization65_g1 + _Time.y );
				half Global_Wind_Grass_Speed144_g1 = ASPW_WindGrassSpeed;
				half temp_output_9_0_g1 = ( _WindGrassSpeed * Global_Wind_Grass_Speed144_g1 * 10.0 );
				half Local_Wind_Grass_Aplitude180_g1 = _WindGrassAmplitude;
				half Global_Wind_Grass_Amplitude172_g1 = ASPW_WindGrassAmplitude;
				half temp_output_27_0_g1 = ( Local_Wind_Grass_Aplitude180_g1 * Global_Wind_Grass_Amplitude172_g1 );
				half Global_Wind_Grass_Flexibility164_g1 = ASPW_WindGrassFlexibility;
				half Wind_Main31_g1 = ( ( ( ( ( sin( ( temp_output_5_0_g1 * ( temp_output_9_0_g1 * 1.0 ) ) ) + sin( ( temp_output_5_0_g1 * ( temp_output_9_0_g1 * 1.25 ) ) ) + sin( ( temp_output_5_0_g1 * ( temp_output_9_0_g1 * 1.5 ) ) ) ) + temp_output_27_0_g1 ) * temp_output_27_0_g1 ) / 50.0 ) * ( ( Global_Wind_Grass_Flexibility164_g1 * _WindGrassFlexibility ) * 0.1 ) );
				half Global_Wind_Grass_Waves_Amplitude162_g1 = ASPW_WindGrassWavesAmplitude;
				half3 appendResult119_g1 = (half3(( normalizeResult41_g1.x * -1.0 ) , ( 0.0 * -1.0 ) , 0.0));
				half3 Wind_Direction_Waves118_g1 = appendResult119_g1;
				half Global_Wind_Grass_Waves_Speed166_g1 = ASPW_WindGrassWavesSpeed;
				float3 ase_positionWS = mul( unity_ObjectToWorld, float4( ( v.vertex ).xyz, 1 ) ).xyz;
				half2 appendResult73_g1 = (half2(ase_positionWS.x , ase_positionWS.z));
				half Global_Wind_Grass_Waves_Scale168_g1 = ASPW_WindGrassWavesScale;
				half Wind_Waves93_g1 = tex2Dlod( ASPW_WindGrassWavesNoiseTexture, float4( ( ( ( Wind_Direction_Waves118_g1 * _Time.y ) * ( Global_Wind_Grass_Waves_Speed166_g1 * 0.1 ) ) + half3( ( ( appendResult73_g1 * Global_Wind_Grass_Waves_Scale168_g1 ) * 0.1 ) ,  0.0 ) ).xy, 0, 0.0) ).r;
				half lerpResult96_g1 = lerp( Wind_Main31_g1 , ( Wind_Main31_g1 * Global_Wind_Grass_Waves_Amplitude162_g1 ) , Wind_Waves93_g1);
				half Wind_Main_with_Waves108_g1 = lerpResult96_g1;
				half temp_output_141_0_g1 = ( ( ase_positionWS.y * ( _WindGrassScale * 10.0 ) ) + _Time.y );
				half Local_Wind_Grass_Speed186_g1 = _WindGrassSpeed;
				half temp_output_146_0_g1 = ( Global_Wind_Grass_Speed144_g1 * Local_Wind_Grass_Speed186_g1 * 10.0 );
				half Global_Wind_Grass_Turbulence161_g1 = ASPW_WindGrassTurbulence;
				half clampResult175_g1 = clamp( Global_Wind_Grass_Amplitude172_g1 , 0.0 , 1.0 );
				half temp_output_188_0_g1 = ( ( ( sin( ( temp_output_141_0_g1 * ( temp_output_146_0_g1 * 1.0 ) ) ) + sin( ( temp_output_141_0_g1 * ( temp_output_146_0_g1 * 1.25 ) ) ) ) * 0.5 ) * ( ( Global_Wind_Grass_Turbulence161_g1 * ( clampResult175_g1 * ( _WindGrassTurbulence * Local_Wind_Grass_Aplitude180_g1 ) ) ) * 0.1 ) );
				half3 appendResult183_g1 = (half3(temp_output_188_0_g1 , ( temp_output_188_0_g1 * 0.2 ) , temp_output_188_0_g1));
				half3 Wind_Turbulence185_g1 = appendResult183_g1;
				half3 rotatedValue56_g1 = RotateAroundAxis( float3( 0,0,0 ), v.vertex.xyz, Wind_Direction52_g1, ( Wind_Main_with_Waves108_g1 + Wind_Turbulence185_g1 ).x );
				half3 Output_Wind35_g1 = ( rotatedValue56_g1 - v.vertex.xyz );
				half Wind_Mask225_g1 = v.ase_color.r;
				half3 lerpResult232_g1 = lerp( float3( 0,0,0 ) , ( Output_Wind35_g1 * Wind_Mask225_g1 ) , ASPW_WindToggle);
				#ifdef _ENABLEWIND_ON
				half3 staticSwitch192_g1 = lerpResult232_g1;
				#else
				half3 staticSwitch192_g1 = temp_cast_0;
				#endif
				
				o.ase_texcoord9.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord9.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = staticSwitch192_g1;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.vertex.w = 1;
				v.normal = v.normal;
				v.tangent = v.tangent;

				o.pos = UnityObjectToClipPos(v.vertex);
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
				o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

				#ifdef DYNAMICLIGHTMAP_ON
				o.lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif
				#ifdef LIGHTMAP_ON
				o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif

				#ifndef LIGHTMAP_ON
					#if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
						o.sh = 0;
						#ifdef VERTEXLIGHT_ON
						o.sh += Shade4PointLights (
							unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
							unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
							unity_4LightAtten0, worldPos, worldNormal);
						#endif
						o.sh = ShadeSHPerVertex (worldNormal, o.sh);
					#endif
				#endif

				#if UNITY_VERSION >= 201810 && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					UNITY_TRANSFER_LIGHTING(o, v.texcoord1.xy);
				#elif defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if UNITY_VERSION >= 201710
						UNITY_TRANSFER_SHADOW(o, v.texcoord1.xy);
					#else
						TRANSFER_SHADOW(o);
					#endif
				#endif

				#ifdef ASE_FOG
					UNITY_TRANSFER_FOG(o,o.pos);
				#endif
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
					o.screenPos = ComputeScreenPos(o.pos);
				#endif
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				half4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( appdata v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.tangent = v.tangent;
				o.normal = v.normal;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				o.ase_color = v.ase_color;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, UNITY_MATRIX_M, _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, UNITY_MATRIX_M, _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, UNITY_MATRIX_M, _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			v2f DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				appdata o = (appdata) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.tangent = patch[0].tangent * bary.x + patch[1].tangent * bary.y + patch[2].tangent * bary.z;
				o.normal = patch[0].normal * bary.x + patch[1].normal * bary.y + patch[2].normal * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].normal * (dot(o.vertex.xyz, patch[i].normal) - dot(patch[i].vertex.xyz, patch[i].normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			v2f vert ( appdata v )
			{
				return VertexFunction( v );
			}
			#endif

			fixed4 frag (v2f IN 
				#ifdef _DEPTHOFFSET_ON
				, out float outputDepth : SV_Depth
				#endif
				) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);

				#ifdef LOD_FADE_CROSSFADE
					UNITY_APPLY_DITHER_CROSSFADE(IN.pos.xy);
				#endif

				#if defined(_SPECULAR_SETUP)
					SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
				#else
					SurfaceOutputStandard o = (SurfaceOutputStandard)0;
				#endif
				float3 WorldTangent = float3(IN.tSpace0.x,IN.tSpace1.x,IN.tSpace2.x);
				float3 WorldBiTangent = float3(IN.tSpace0.y,IN.tSpace1.y,IN.tSpace2.y);
				float3 WorldNormal = float3(IN.tSpace0.z,IN.tSpace1.z,IN.tSpace2.z);
				float3 worldPos = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
				#else
					half atten = 1;
				#endif
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 ScreenPos = IN.screenPos;
				#endif

				float2 uv_BaseAlbedo280 = IN.ase_texcoord9.xy;
				half4 tex2DNode280 = tex2D( _BaseAlbedo, uv_BaseAlbedo280 );
				half3 desaturateInitialColor281 = tex2DNode280.rgb;
				half desaturateDot281 = dot( desaturateInitialColor281, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar281 = lerp( desaturateInitialColor281, desaturateDot281.xxx, _BaseAlbedoDesaturation );
				half3 Albedo_Texture299 = saturate( ( desaturateVar281 * _BaseAlbedoBrightness ) );
				half3 blendOpSrc283 = Albedo_Texture299;
				half3 blendOpDest283 = _BaseAlbedoColor.rgb;
				half3 Base_Albedo289 = (( blendOpDest283 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest283 ) * ( 1.0 - blendOpSrc283 ) ) : ( 2.0 * blendOpDest283 * blendOpSrc283 ) );
				half3 blendOpSrc345 = Albedo_Texture299;
				half3 blendOpDest345 = _TintColor.rgb;
				half2 appendResult649 = (half2(worldPos.x , worldPos.z));
				half4 tex2DNode651 = tex2D( ASP_GlobalTintNoiseTexture, ( appendResult649 * ( 0.01 * ASP_GlobalTintNoiseUVScale * _TintNoiseUVScale ) ) );
				half lerpResult676 = lerp( tex2DNode651.r , ( 1.0 - tex2DNode651.r ) , _TintNoiseInvertMask);
				half Base_Tint_Color_Mask659 = saturate( ( lerpResult676 * ( ASP_GlobalTintNoiseContrast * _TintNoiseContrast ) * IN.ase_color.r ) );
				half3 lerpResult656 = lerp( Base_Albedo289 , (( blendOpDest345 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest345 ) * ( 1.0 - blendOpSrc345 ) ) : ( 2.0 * blendOpDest345 * blendOpSrc345 ) ) , Base_Tint_Color_Mask659);
				half3 lerpResult661 = lerp( Base_Albedo289 , lerpResult656 , ( ASP_GlobalTintNoiseToggle * _TintNoiseIntensity * ASP_GlobalTintNoiseIntensity ));
				#ifdef _ENABLETINTVARIATIONCOLOR_ON
				half3 staticSwitch403 = lerpResult661;
				#else
				half3 staticSwitch403 = Base_Albedo289;
				#endif
				half3 Base_Albedo_and_Tint_Color374 = staticSwitch403;
				half3 blendOpSrc331 = Albedo_Texture299;
				half3 blendOpDest331 = _BottomColor.rgb;
				half saferPower336 = abs( ( 1.0 - IN.ase_color.a ) );
				half3 lerpResult340 = lerp( Base_Albedo_and_Tint_Color374 , (( blendOpDest331 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest331 ) * ( 1.0 - blendOpSrc331 ) ) : ( 2.0 * blendOpDest331 * blendOpSrc331 ) ) , saturate( ( _BottomColorOffset * pow( saferPower336 , _BottomColorContrast ) ) ));
				#ifdef _ENABLEBOTTOMCOLOR_ON
				half3 staticSwitch375 = lerpResult340;
				#else
				half3 staticSwitch375 = Base_Albedo_and_Tint_Color374;
				#endif
				half3 Output_Albedo342 = staticSwitch375;
				
				float2 uv_BaseNormal318 = IN.ase_texcoord9.xy;
				half3 Base_Normal642 = UnpackScaleNormal( tex2D( _BaseNormal, uv_BaseNormal318 ), _BaseNormalIntensity );
				
				half3 Global_Wind_Direction238_g1 = ASPW_WindDirection;
				half3 normalizeResult41_g1 = ASESafeNormalize( Global_Wind_Direction238_g1 );
				half3 appendResult119_g1 = (half3(( normalizeResult41_g1.x * -1.0 ) , ( 0.0 * -1.0 ) , 0.0));
				half3 Wind_Direction_Waves118_g1 = appendResult119_g1;
				half Global_Wind_Grass_Waves_Speed166_g1 = ASPW_WindGrassWavesSpeed;
				half2 appendResult73_g1 = (half2(worldPos.x , worldPos.z));
				half Global_Wind_Grass_Waves_Scale168_g1 = ASPW_WindGrassWavesScale;
				half Wind_Waves93_g1 = tex2D( ASPW_WindGrassWavesNoiseTexture, ( ( ( Wind_Direction_Waves118_g1 * _Time.y ) * ( Global_Wind_Grass_Waves_Speed166_g1 * 0.1 ) ) + half3( ( ( appendResult73_g1 * Global_Wind_Grass_Waves_Scale168_g1 ) * 0.1 ) ,  0.0 ) ).xy ).r;
				half Wind_Waves621 = Wind_Waves93_g1;
				half lerpResult304 = lerp( 0.0 , _BaseSmoothnessIntensity , ( IN.ase_color.r * ( Wind_Waves621 + _BaseSmoothnessWaves ) ));
				#ifdef _ENABLESMOOTHNESSWAVES_ON
				half staticSwitch719 = lerpResult304;
				#else
				half staticSwitch719 = _BaseSmoothnessIntensity;
				#endif
				half Base_Smoothness314 = saturate( staticSwitch719 );
				
				half Base_Opacity295 = tex2DNode280.a;
				half4 ase_positionSSNorm = ScreenPos / ScreenPos.w;
				ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
				half4 ase_positionSS_Pixel = ASEScreenPositionNormalizedToPixel( ase_positionSSNorm );
				half dither728 = Dither4x4Bayer( fmod( ase_positionSS_Pixel.x, 4 ), fmod( ase_positionSS_Pixel.y, 4 ) );
				dither728 = step( dither728, saturate( saturate( ( ( IN.ase_color.r - _BottomDitherOffset ) * ( _BottomDitherContrast * 2 ) ) ) * 1.00001 ) );
				#ifdef _ENABLEBOTTOMDITHER_ON
				half staticSwitch731 = ( dither728 * Base_Opacity295 );
				#else
				half staticSwitch731 = Base_Opacity295;
				#endif
				half Output_Opacity732 = staticSwitch731;
				
				o.Albedo = Output_Albedo342;
				o.Normal = Base_Normal642;
				o.Emission = half3( 0, 0, 0 );
				#if defined(_SPECULAR_SETUP)
					o.Specular = fixed3( 0, 0, 0 );
				#else
					o.Metallic = 0;
				#endif
				o.Smoothness = Base_Smoothness314;
				o.Occlusion = 1;
				o.Alpha = Output_Opacity732;
				float AlphaClipThreshold = _BaseOpacityCutoff;
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;

				#ifdef _ALPHATEST_ON
					clip( o.Alpha - AlphaClipThreshold );
				#endif

				#ifdef _DEPTHOFFSET_ON
					outputDepth = IN.pos.z;
				#endif

				#ifndef USING_DIRECTIONAL_LIGHT
					fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				#else
					fixed3 lightDir = _WorldSpaceLightPos0.xyz;
				#endif

				fixed4 c = 0;
				float3 worldN;
				worldN.x = dot(IN.tSpace0.xyz, o.Normal);
				worldN.y = dot(IN.tSpace1.xyz, o.Normal);
				worldN.z = dot(IN.tSpace2.xyz, o.Normal);
				worldN = normalize(worldN);
				o.Normal = worldN;

				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
				gi.indirect.diffuse = 0;
				gi.indirect.specular = 0;
				gi.light.color = _LightColor0.rgb;
				gi.light.dir = lightDir;

				UnityGIInput giInput;
				UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
				giInput.light = gi.light;
				giInput.worldPos = worldPos;
				giInput.worldViewDir = worldViewDir;
				giInput.atten = atten;
				#if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
					giInput.lightmapUV = IN.lmap;
				#else
					giInput.lightmapUV = 0.0;
				#endif
				#if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
					giInput.ambient = IN.sh;
				#else
					giInput.ambient.rgb = 0.0;
				#endif
				giInput.probeHDR[0] = unity_SpecCube0_HDR;
				giInput.probeHDR[1] = unity_SpecCube1_HDR;
				#if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
					giInput.boxMin[0] = unity_SpecCube0_BoxMin;
				#endif
				#ifdef UNITY_SPECCUBE_BOX_PROJECTION
					giInput.boxMax[0] = unity_SpecCube0_BoxMax;
					giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
					giInput.boxMax[1] = unity_SpecCube1_BoxMax;
					giInput.boxMin[1] = unity_SpecCube1_BoxMin;
					giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
				#endif

				#if defined(_SPECULAR_SETUP)
					LightingStandardSpecular_GI(o, giInput, gi);
				#else
					LightingStandard_GI( o, giInput, gi );
				#endif

				#ifdef ASE_BAKEDGI
					gi.indirect.diffuse = BakedGI;
				#endif

				#if UNITY_SHOULD_SAMPLE_SH && !defined(LIGHTMAP_ON) && defined(ASE_NO_AMBIENT)
					gi.indirect.diffuse = 0;
				#endif

				#if defined(_SPECULAR_SETUP)
					c += LightingStandardSpecular (o, worldViewDir, gi);
				#else
					c += LightingStandard( o, worldViewDir, gi );
				#endif

				#ifdef ASE_TRANSMISSION
				{
					float shadow = _TransmissionShadow;
					#ifdef DIRECTIONAL
						float3 lightAtten = lerp( _LightColor0.rgb, gi.light.color, shadow );
					#else
						float3 lightAtten = gi.light.color;
					#endif
					half3 transmission = max(0 , -dot(o.Normal, gi.light.dir)) * lightAtten * Transmission;
					c.rgb += o.Albedo * transmission;
				}
				#endif

				#ifdef ASE_TRANSLUCENCY
				{
					float shadow = _TransShadow;
					float normal = _TransNormal;
					float scattering = _TransScattering;
					float direct = _TransDirect;
					float ambient = _TransAmbient;
					float strength = _TransStrength;

					#ifdef DIRECTIONAL
						float3 lightAtten = lerp( _LightColor0.rgb, gi.light.color, shadow );
					#else
						float3 lightAtten = gi.light.color;
					#endif
					half3 lightDir = gi.light.dir + o.Normal * normal;
					half transVdotL = pow( saturate( dot( worldViewDir, -lightDir ) ), scattering );
					half3 translucency = lightAtten * (transVdotL * direct + gi.indirect.diffuse * ambient) * Translucency;
					c.rgb += o.Albedo * translucency * strength;
				}
				#endif

				//#ifdef ASE_REFRACTION
				//	float4 projScreenPos = ScreenPos / ScreenPos.w;
				//	float3 refractionOffset = ( RefractionIndex - 1.0 ) * mul( UNITY_MATRIX_V, WorldNormal ).xyz * ( 1.0 - dot( WorldNormal, WorldViewDirection ) );
				//	projScreenPos.xy += refractionOffset.xy;
				//	float3 refraction = UNITY_SAMPLE_SCREENSPACE_TEXTURE( _GrabTexture, projScreenPos ) * RefractionColor;
				//	color.rgb = lerp( refraction, color.rgb, color.a );
				//	color.a = 1;
				//#endif

				c.rgb += o.Emission;

				#ifdef ASE_FOG
					UNITY_APPLY_FOG(IN.fogCoord, c);
				#endif
				return c;
			}
			ENDCG
		}

		
		Pass
		{
			
			Name "ForwardAdd"
			Tags { "LightMode"="ForwardAdd" }
			ZWrite Off
			Blend One One

			CGPROGRAM
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#pragma multi_compile_instancing
			#pragma multi_compile __ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define ASE_VERSION 19801

			#pragma vertex vert
			#pragma fragment frag
			#pragma skip_variants INSTANCING_ON
			#pragma multi_compile_fwdadd_fullshadows
			#ifndef UNITY_PASS_FORWARDADD
				#define UNITY_PASS_FORWARDADD
			#endif
			#include "HLSLSupport.cginc"
			#if !defined( UNITY_INSTANCED_LOD_FADE )
				#define UNITY_INSTANCED_LOD_FADE
			#endif
			#if !defined( UNITY_INSTANCED_SH )
				#define UNITY_INSTANCED_SH
			#endif
			#if !defined( UNITY_INSTANCED_LIGHTMAPSTS )
				#define UNITY_INSTANCED_LIGHTMAPSTS
			#endif
			#include "UnityShaderVariables.cginc"
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			#include "AutoLight.cginc"

			#include "UnityStandardUtils.cginc"
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_SCREEN_POSITION
			#pragma shader_feature_local _ENABLEWIND_ON
			#pragma shader_feature_local _ENABLEBOTTOMCOLOR_ON
			#pragma shader_feature_local _ENABLETINTVARIATIONCOLOR_ON
			#pragma shader_feature_local _ENABLESMOOTHNESSWAVES_ON
			#pragma shader_feature_local _ENABLEBOTTOMDITHER_ON

			struct appdata {
				float4 vertex : POSITION;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				half4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			struct v2f {
				#if UNITY_VERSION >= 201810
					UNITY_POSITION(pos);
				#else
					float4 pos : SV_POSITION;
				#endif
				#if UNITY_VERSION >= 201810 && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					UNITY_LIGHTING_COORDS(1,2)
				#elif defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if UNITY_VERSION >= 201710
						UNITY_SHADOW_COORDS(1)
					#else
						SHADOW_COORDS(1)
					#endif
				#endif
				#ifdef ASE_FOG
					UNITY_FOG_COORDS(3)
				#endif
				float4 tSpace0 : TEXCOORD5;
				float4 tSpace1 : TEXCOORD6;
				float4 tSpace2 : TEXCOORD7;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 screenPos : TEXCOORD8;
				#endif
				float4 ase_texcoord9 : TEXCOORD9;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			uniform sampler2D ASPW_WindGrassWavesNoiseTexture;
			uniform half3 ASPW_WindDirection;
			uniform half _WindGrassSpeed;
			uniform half ASPW_WindGrassSpeed;
			uniform half _WindGrassAmplitude;
			uniform half ASPW_WindGrassAmplitude;
			uniform half ASPW_WindGrassFlexibility;
			uniform half _WindGrassFlexibility;
			uniform half ASPW_WindGrassWavesAmplitude;
			uniform half ASPW_WindGrassWavesSpeed;
			uniform half ASPW_WindGrassWavesScale;
			uniform half _WindGrassScale;
			uniform half ASPW_WindGrassTurbulence;
			uniform half _WindGrassTurbulence;
			uniform half ASPW_WindToggle;
			uniform sampler2D _BaseAlbedo;
			uniform half _BaseAlbedoDesaturation;
			uniform half _BaseAlbedoBrightness;
			uniform half4 _BaseAlbedoColor;
			uniform half4 _TintColor;
			uniform sampler2D ASP_GlobalTintNoiseTexture;
			uniform half ASP_GlobalTintNoiseUVScale;
			uniform half _TintNoiseUVScale;
			uniform half _TintNoiseInvertMask;
			uniform half ASP_GlobalTintNoiseContrast;
			uniform half _TintNoiseContrast;
			uniform half ASP_GlobalTintNoiseToggle;
			uniform half _TintNoiseIntensity;
			uniform half ASP_GlobalTintNoiseIntensity;
			uniform half4 _BottomColor;
			uniform half _BottomColorOffset;
			uniform half _BottomColorContrast;
			uniform sampler2D _BaseNormal;
			uniform half _BaseNormalIntensity;
			uniform half _BaseSmoothnessIntensity;
			uniform half _BaseSmoothnessWaves;
			uniform half _BottomDitherOffset;
			uniform half _BottomDitherContrast;
			uniform half _BaseOpacityCutoff;


			float3 ASESafeNormalize(float3 inVec)
			{
				float dp3 = max(1.175494351e-38, dot(inVec, inVec));
				return inVec* rsqrt(dp3);
			}
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			
			float4 ASEScreenPositionNormalizedToPixel( float4 screenPosNorm )
			{
				float4 screenPosPixel = screenPosNorm * float4( _ScreenParams.xy, 1, 1 );
				#if UNITY_UV_STARTS_AT_TOP
					screenPosPixel.xy = float2( screenPosPixel.x, ( _ProjectionParams.x < 0 ) ? _ScreenParams.y - screenPosPixel.y : screenPosPixel.y );
				#else
					screenPosPixel.xy = float2( screenPosPixel.x, ( _ProjectionParams.x > 0 ) ? _ScreenParams.y - screenPosPixel.y : screenPosPixel.y );
				#endif
				return screenPosPixel;
			}
			
			inline float Dither4x4Bayer( int x, int y )
			{
				const float dither[ 16 ] = {
				     1,  9,  3, 11,
				    13,  5, 15,  7,
				     4, 12,  2, 10,
				    16,  8, 14,  6 };
				int r = y * 4 + x;
				return dither[ r ] / 16; // same # of instructions as pre-dividing due to compiler magic
			}
			

			v2f VertexFunction (appdata v  ) {
				UNITY_SETUP_INSTANCE_ID(v);
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_TRANSFER_INSTANCE_ID(v,o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				half3 temp_cast_0 = (0.0).xxx;
				half3 Global_Wind_Direction238_g1 = ASPW_WindDirection;
				half3 normalizeResult41_g1 = ASESafeNormalize( Global_Wind_Direction238_g1 );
				half3 worldToObjDir40_g1 = mul( unity_WorldToObject, float4( normalizeResult41_g1, 0.0 ) ).xyz;
				half3 Wind_Direction_Leaf50_g1 = worldToObjDir40_g1;
				half3 break42_g1 = Wind_Direction_Leaf50_g1;
				half3 appendResult43_g1 = (half3(break42_g1.z , 0.0 , ( break42_g1.x * -1.0 )));
				half3 Wind_Direction52_g1 = appendResult43_g1;
				float3 ase_objectPosition = UNITY_MATRIX_M._m03_m13_m23;
				half Wind_Grass_Randomization65_g1 = frac( ( ( ase_objectPosition.x + ase_objectPosition.y + ase_objectPosition.z ) * 1.23 ) );
				half temp_output_5_0_g1 = ( Wind_Grass_Randomization65_g1 + _Time.y );
				half Global_Wind_Grass_Speed144_g1 = ASPW_WindGrassSpeed;
				half temp_output_9_0_g1 = ( _WindGrassSpeed * Global_Wind_Grass_Speed144_g1 * 10.0 );
				half Local_Wind_Grass_Aplitude180_g1 = _WindGrassAmplitude;
				half Global_Wind_Grass_Amplitude172_g1 = ASPW_WindGrassAmplitude;
				half temp_output_27_0_g1 = ( Local_Wind_Grass_Aplitude180_g1 * Global_Wind_Grass_Amplitude172_g1 );
				half Global_Wind_Grass_Flexibility164_g1 = ASPW_WindGrassFlexibility;
				half Wind_Main31_g1 = ( ( ( ( ( sin( ( temp_output_5_0_g1 * ( temp_output_9_0_g1 * 1.0 ) ) ) + sin( ( temp_output_5_0_g1 * ( temp_output_9_0_g1 * 1.25 ) ) ) + sin( ( temp_output_5_0_g1 * ( temp_output_9_0_g1 * 1.5 ) ) ) ) + temp_output_27_0_g1 ) * temp_output_27_0_g1 ) / 50.0 ) * ( ( Global_Wind_Grass_Flexibility164_g1 * _WindGrassFlexibility ) * 0.1 ) );
				half Global_Wind_Grass_Waves_Amplitude162_g1 = ASPW_WindGrassWavesAmplitude;
				half3 appendResult119_g1 = (half3(( normalizeResult41_g1.x * -1.0 ) , ( 0.0 * -1.0 ) , 0.0));
				half3 Wind_Direction_Waves118_g1 = appendResult119_g1;
				half Global_Wind_Grass_Waves_Speed166_g1 = ASPW_WindGrassWavesSpeed;
				float3 ase_positionWS = mul( unity_ObjectToWorld, float4( ( v.vertex ).xyz, 1 ) ).xyz;
				half2 appendResult73_g1 = (half2(ase_positionWS.x , ase_positionWS.z));
				half Global_Wind_Grass_Waves_Scale168_g1 = ASPW_WindGrassWavesScale;
				half Wind_Waves93_g1 = tex2Dlod( ASPW_WindGrassWavesNoiseTexture, float4( ( ( ( Wind_Direction_Waves118_g1 * _Time.y ) * ( Global_Wind_Grass_Waves_Speed166_g1 * 0.1 ) ) + half3( ( ( appendResult73_g1 * Global_Wind_Grass_Waves_Scale168_g1 ) * 0.1 ) ,  0.0 ) ).xy, 0, 0.0) ).r;
				half lerpResult96_g1 = lerp( Wind_Main31_g1 , ( Wind_Main31_g1 * Global_Wind_Grass_Waves_Amplitude162_g1 ) , Wind_Waves93_g1);
				half Wind_Main_with_Waves108_g1 = lerpResult96_g1;
				half temp_output_141_0_g1 = ( ( ase_positionWS.y * ( _WindGrassScale * 10.0 ) ) + _Time.y );
				half Local_Wind_Grass_Speed186_g1 = _WindGrassSpeed;
				half temp_output_146_0_g1 = ( Global_Wind_Grass_Speed144_g1 * Local_Wind_Grass_Speed186_g1 * 10.0 );
				half Global_Wind_Grass_Turbulence161_g1 = ASPW_WindGrassTurbulence;
				half clampResult175_g1 = clamp( Global_Wind_Grass_Amplitude172_g1 , 0.0 , 1.0 );
				half temp_output_188_0_g1 = ( ( ( sin( ( temp_output_141_0_g1 * ( temp_output_146_0_g1 * 1.0 ) ) ) + sin( ( temp_output_141_0_g1 * ( temp_output_146_0_g1 * 1.25 ) ) ) ) * 0.5 ) * ( ( Global_Wind_Grass_Turbulence161_g1 * ( clampResult175_g1 * ( _WindGrassTurbulence * Local_Wind_Grass_Aplitude180_g1 ) ) ) * 0.1 ) );
				half3 appendResult183_g1 = (half3(temp_output_188_0_g1 , ( temp_output_188_0_g1 * 0.2 ) , temp_output_188_0_g1));
				half3 Wind_Turbulence185_g1 = appendResult183_g1;
				half3 rotatedValue56_g1 = RotateAroundAxis( float3( 0,0,0 ), v.vertex.xyz, Wind_Direction52_g1, ( Wind_Main_with_Waves108_g1 + Wind_Turbulence185_g1 ).x );
				half3 Output_Wind35_g1 = ( rotatedValue56_g1 - v.vertex.xyz );
				half Wind_Mask225_g1 = v.ase_color.r;
				half3 lerpResult232_g1 = lerp( float3( 0,0,0 ) , ( Output_Wind35_g1 * Wind_Mask225_g1 ) , ASPW_WindToggle);
				#ifdef _ENABLEWIND_ON
				half3 staticSwitch192_g1 = lerpResult232_g1;
				#else
				half3 staticSwitch192_g1 = temp_cast_0;
				#endif
				
				o.ase_texcoord9.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord9.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = staticSwitch192_g1;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.vertex.w = 1;
				v.normal = v.normal;
				v.tangent = v.tangent;

				o.pos = UnityObjectToClipPos(v.vertex);
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
				o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

				#if UNITY_VERSION >= 201810 && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					UNITY_TRANSFER_LIGHTING(o, v.texcoord1.xy);
				#elif defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if UNITY_VERSION >= 201710
						UNITY_TRANSFER_SHADOW(o, v.texcoord1.xy);
					#else
						TRANSFER_SHADOW(o);
					#endif
				#endif

				#ifdef ASE_FOG
					UNITY_TRANSFER_FOG(o,o.pos);
				#endif
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
					o.screenPos = ComputeScreenPos(o.pos);
				#endif
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				half4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( appdata v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.tangent = v.tangent;
				o.normal = v.normal;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				o.ase_color = v.ase_color;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, UNITY_MATRIX_M, _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, UNITY_MATRIX_M, _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, UNITY_MATRIX_M, _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			v2f DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				appdata o = (appdata) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.tangent = patch[0].tangent * bary.x + patch[1].tangent * bary.y + patch[2].tangent * bary.z;
				o.normal = patch[0].normal * bary.x + patch[1].normal * bary.y + patch[2].normal * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].normal * (dot(o.vertex.xyz, patch[i].normal) - dot(patch[i].vertex.xyz, patch[i].normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			v2f vert ( appdata v )
			{
				return VertexFunction( v );
			}
			#endif

			fixed4 frag ( v2f IN 
				#ifdef _DEPTHOFFSET_ON
				, out float outputDepth : SV_Depth
				#endif
				) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);

				#ifdef LOD_FADE_CROSSFADE
					UNITY_APPLY_DITHER_CROSSFADE(IN.pos.xy);
				#endif

				#if defined(_SPECULAR_SETUP)
					SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
				#else
					SurfaceOutputStandard o = (SurfaceOutputStandard)0;
				#endif
				float3 WorldTangent = float3(IN.tSpace0.x,IN.tSpace1.x,IN.tSpace2.x);
				float3 WorldBiTangent = float3(IN.tSpace0.y,IN.tSpace1.y,IN.tSpace2.y);
				float3 WorldNormal = float3(IN.tSpace0.z,IN.tSpace1.z,IN.tSpace2.z);
				float3 worldPos = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
				#else
					half atten = 1;
				#endif
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 ScreenPos = IN.screenPos;
				#endif


				float2 uv_BaseAlbedo280 = IN.ase_texcoord9.xy;
				half4 tex2DNode280 = tex2D( _BaseAlbedo, uv_BaseAlbedo280 );
				half3 desaturateInitialColor281 = tex2DNode280.rgb;
				half desaturateDot281 = dot( desaturateInitialColor281, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar281 = lerp( desaturateInitialColor281, desaturateDot281.xxx, _BaseAlbedoDesaturation );
				half3 Albedo_Texture299 = saturate( ( desaturateVar281 * _BaseAlbedoBrightness ) );
				half3 blendOpSrc283 = Albedo_Texture299;
				half3 blendOpDest283 = _BaseAlbedoColor.rgb;
				half3 Base_Albedo289 = (( blendOpDest283 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest283 ) * ( 1.0 - blendOpSrc283 ) ) : ( 2.0 * blendOpDest283 * blendOpSrc283 ) );
				half3 blendOpSrc345 = Albedo_Texture299;
				half3 blendOpDest345 = _TintColor.rgb;
				half2 appendResult649 = (half2(worldPos.x , worldPos.z));
				half4 tex2DNode651 = tex2D( ASP_GlobalTintNoiseTexture, ( appendResult649 * ( 0.01 * ASP_GlobalTintNoiseUVScale * _TintNoiseUVScale ) ) );
				half lerpResult676 = lerp( tex2DNode651.r , ( 1.0 - tex2DNode651.r ) , _TintNoiseInvertMask);
				half Base_Tint_Color_Mask659 = saturate( ( lerpResult676 * ( ASP_GlobalTintNoiseContrast * _TintNoiseContrast ) * IN.ase_color.r ) );
				half3 lerpResult656 = lerp( Base_Albedo289 , (( blendOpDest345 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest345 ) * ( 1.0 - blendOpSrc345 ) ) : ( 2.0 * blendOpDest345 * blendOpSrc345 ) ) , Base_Tint_Color_Mask659);
				half3 lerpResult661 = lerp( Base_Albedo289 , lerpResult656 , ( ASP_GlobalTintNoiseToggle * _TintNoiseIntensity * ASP_GlobalTintNoiseIntensity ));
				#ifdef _ENABLETINTVARIATIONCOLOR_ON
				half3 staticSwitch403 = lerpResult661;
				#else
				half3 staticSwitch403 = Base_Albedo289;
				#endif
				half3 Base_Albedo_and_Tint_Color374 = staticSwitch403;
				half3 blendOpSrc331 = Albedo_Texture299;
				half3 blendOpDest331 = _BottomColor.rgb;
				half saferPower336 = abs( ( 1.0 - IN.ase_color.a ) );
				half3 lerpResult340 = lerp( Base_Albedo_and_Tint_Color374 , (( blendOpDest331 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest331 ) * ( 1.0 - blendOpSrc331 ) ) : ( 2.0 * blendOpDest331 * blendOpSrc331 ) ) , saturate( ( _BottomColorOffset * pow( saferPower336 , _BottomColorContrast ) ) ));
				#ifdef _ENABLEBOTTOMCOLOR_ON
				half3 staticSwitch375 = lerpResult340;
				#else
				half3 staticSwitch375 = Base_Albedo_and_Tint_Color374;
				#endif
				half3 Output_Albedo342 = staticSwitch375;
				
				float2 uv_BaseNormal318 = IN.ase_texcoord9.xy;
				half3 Base_Normal642 = UnpackScaleNormal( tex2D( _BaseNormal, uv_BaseNormal318 ), _BaseNormalIntensity );
				
				half3 Global_Wind_Direction238_g1 = ASPW_WindDirection;
				half3 normalizeResult41_g1 = ASESafeNormalize( Global_Wind_Direction238_g1 );
				half3 appendResult119_g1 = (half3(( normalizeResult41_g1.x * -1.0 ) , ( 0.0 * -1.0 ) , 0.0));
				half3 Wind_Direction_Waves118_g1 = appendResult119_g1;
				half Global_Wind_Grass_Waves_Speed166_g1 = ASPW_WindGrassWavesSpeed;
				half2 appendResult73_g1 = (half2(worldPos.x , worldPos.z));
				half Global_Wind_Grass_Waves_Scale168_g1 = ASPW_WindGrassWavesScale;
				half Wind_Waves93_g1 = tex2D( ASPW_WindGrassWavesNoiseTexture, ( ( ( Wind_Direction_Waves118_g1 * _Time.y ) * ( Global_Wind_Grass_Waves_Speed166_g1 * 0.1 ) ) + half3( ( ( appendResult73_g1 * Global_Wind_Grass_Waves_Scale168_g1 ) * 0.1 ) ,  0.0 ) ).xy ).r;
				half Wind_Waves621 = Wind_Waves93_g1;
				half lerpResult304 = lerp( 0.0 , _BaseSmoothnessIntensity , ( IN.ase_color.r * ( Wind_Waves621 + _BaseSmoothnessWaves ) ));
				#ifdef _ENABLESMOOTHNESSWAVES_ON
				half staticSwitch719 = lerpResult304;
				#else
				half staticSwitch719 = _BaseSmoothnessIntensity;
				#endif
				half Base_Smoothness314 = saturate( staticSwitch719 );
				
				half Base_Opacity295 = tex2DNode280.a;
				half4 ase_positionSSNorm = ScreenPos / ScreenPos.w;
				ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
				half4 ase_positionSS_Pixel = ASEScreenPositionNormalizedToPixel( ase_positionSSNorm );
				half dither728 = Dither4x4Bayer( fmod( ase_positionSS_Pixel.x, 4 ), fmod( ase_positionSS_Pixel.y, 4 ) );
				dither728 = step( dither728, saturate( saturate( ( ( IN.ase_color.r - _BottomDitherOffset ) * ( _BottomDitherContrast * 2 ) ) ) * 1.00001 ) );
				#ifdef _ENABLEBOTTOMDITHER_ON
				half staticSwitch731 = ( dither728 * Base_Opacity295 );
				#else
				half staticSwitch731 = Base_Opacity295;
				#endif
				half Output_Opacity732 = staticSwitch731;
				
				o.Albedo = Output_Albedo342;
				o.Normal = Base_Normal642;
				o.Emission = half3( 0, 0, 0 );
				#if defined(_SPECULAR_SETUP)
					o.Specular = fixed3( 0, 0, 0 );
				#else
					o.Metallic = 0;
				#endif
				o.Smoothness = Base_Smoothness314;
				o.Occlusion = 1;
				o.Alpha = Output_Opacity732;
				float AlphaClipThreshold = _BaseOpacityCutoff;
				float3 Transmission = 1;
				float3 Translucency = 1;

				#ifdef _ALPHATEST_ON
					clip( o.Alpha - AlphaClipThreshold );
				#endif

				#ifdef _DEPTHOFFSET_ON
					outputDepth = IN.pos.z;
				#endif

				#ifndef USING_DIRECTIONAL_LIGHT
					fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				#else
					fixed3 lightDir = _WorldSpaceLightPos0.xyz;
				#endif

				fixed4 c = 0;
				float3 worldN;
				worldN.x = dot(IN.tSpace0.xyz, o.Normal);
				worldN.y = dot(IN.tSpace1.xyz, o.Normal);
				worldN.z = dot(IN.tSpace2.xyz, o.Normal);
				worldN = normalize(worldN);
				o.Normal = worldN;

				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
				gi.indirect.diffuse = 0;
				gi.indirect.specular = 0;
				gi.light.color = _LightColor0.rgb;
				gi.light.dir = lightDir;
				gi.light.color *= atten;

				#if defined(_SPECULAR_SETUP)
					c += LightingStandardSpecular( o, worldViewDir, gi );
				#else
					c += LightingStandard( o, worldViewDir, gi );
				#endif

				#ifdef ASE_TRANSMISSION
				{
					float shadow = _TransmissionShadow;
					#ifdef DIRECTIONAL
						float3 lightAtten = lerp( _LightColor0.rgb, gi.light.color, shadow );
					#else
						float3 lightAtten = gi.light.color;
					#endif
					half3 transmission = max(0 , -dot(o.Normal, gi.light.dir)) * lightAtten * Transmission;
					c.rgb += o.Albedo * transmission;
				}
				#endif

				#ifdef ASE_TRANSLUCENCY
				{
					float shadow = _TransShadow;
					float normal = _TransNormal;
					float scattering = _TransScattering;
					float direct = _TransDirect;
					float ambient = _TransAmbient;
					float strength = _TransStrength;

					#ifdef DIRECTIONAL
						float3 lightAtten = lerp( _LightColor0.rgb, gi.light.color, shadow );
					#else
						float3 lightAtten = gi.light.color;
					#endif
					half3 lightDir = gi.light.dir + o.Normal * normal;
					half transVdotL = pow( saturate( dot( worldViewDir, -lightDir ) ), scattering );
					half3 translucency = lightAtten * (transVdotL * direct + gi.indirect.diffuse * ambient) * Translucency;
					c.rgb += o.Albedo * translucency * strength;
				}
				#endif

				//#ifdef ASE_REFRACTION
				//	float4 projScreenPos = ScreenPos / ScreenPos.w;
				//	float3 refractionOffset = ( RefractionIndex - 1.0 ) * mul( UNITY_MATRIX_V, WorldNormal ).xyz * ( 1.0 - dot( WorldNormal, WorldViewDirection ) );
				//	projScreenPos.xy += refractionOffset.xy;
				//	float3 refraction = UNITY_SAMPLE_SCREENSPACE_TEXTURE( _GrabTexture, projScreenPos ) * RefractionColor;
				//	color.rgb = lerp( refraction, color.rgb, color.a );
				//	color.a = 1;
				//#endif

				#ifdef ASE_FOG
					UNITY_APPLY_FOG(IN.fogCoord, c);
				#endif
				return c;
			}
			ENDCG
		}

		
		Pass
		{
			
			Name "Deferred"
			Tags { "LightMode"="Deferred" }

			AlphaToMask Off

			CGPROGRAM
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#pragma multi_compile_instancing
			#pragma multi_compile __ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define ASE_VERSION 19801

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.5
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#pragma multi_compile_prepassfinal
			#ifndef UNITY_PASS_DEFERRED
				#define UNITY_PASS_DEFERRED
			#endif
			#include "HLSLSupport.cginc"
			#if !defined( UNITY_INSTANCED_LOD_FADE )
				#define UNITY_INSTANCED_LOD_FADE
			#endif
			#if !defined( UNITY_INSTANCED_SH )
				#define UNITY_INSTANCED_SH
			#endif
			#if !defined( UNITY_INSTANCED_LIGHTMAPSTS )
				#define UNITY_INSTANCED_LIGHTMAPSTS
			#endif
			#include "UnityShaderVariables.cginc"
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"

			#include "UnityStandardUtils.cginc"
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_COLOR
			#pragma shader_feature_local _ENABLEWIND_ON
			#pragma shader_feature_local _ENABLEBOTTOMCOLOR_ON
			#pragma shader_feature_local _ENABLETINTVARIATIONCOLOR_ON
			#pragma shader_feature_local _ENABLESMOOTHNESSWAVES_ON
			#pragma shader_feature_local _ENABLEBOTTOMDITHER_ON

			struct appdata {
				float4 vertex : POSITION;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				half4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f {
				#if UNITY_VERSION >= 201810
					UNITY_POSITION(pos);
				#else
					float4 pos : SV_POSITION;
				#endif
				float4 lmap : TEXCOORD2;
				#ifndef LIGHTMAP_ON
					#if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
						half3 sh : TEXCOORD3;
					#endif
				#else
					#ifdef DIRLIGHTMAP_OFF
						float4 lmapFadePos : TEXCOORD4;
					#endif
				#endif
				float4 tSpace0 : TEXCOORD5;
				float4 tSpace1 : TEXCOORD6;
				float4 tSpace2 : TEXCOORD7;
				float4 ase_texcoord8 : TEXCOORD8;
				float4 ase_color : COLOR;
				float4 ase_texcoord9 : TEXCOORD9;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			#ifdef LIGHTMAP_ON
			float4 unity_LightmapFade;
			#endif
			fixed4 unity_Ambient;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			uniform sampler2D ASPW_WindGrassWavesNoiseTexture;
			uniform half3 ASPW_WindDirection;
			uniform half _WindGrassSpeed;
			uniform half ASPW_WindGrassSpeed;
			uniform half _WindGrassAmplitude;
			uniform half ASPW_WindGrassAmplitude;
			uniform half ASPW_WindGrassFlexibility;
			uniform half _WindGrassFlexibility;
			uniform half ASPW_WindGrassWavesAmplitude;
			uniform half ASPW_WindGrassWavesSpeed;
			uniform half ASPW_WindGrassWavesScale;
			uniform half _WindGrassScale;
			uniform half ASPW_WindGrassTurbulence;
			uniform half _WindGrassTurbulence;
			uniform half ASPW_WindToggle;
			uniform sampler2D _BaseAlbedo;
			uniform half _BaseAlbedoDesaturation;
			uniform half _BaseAlbedoBrightness;
			uniform half4 _BaseAlbedoColor;
			uniform half4 _TintColor;
			uniform sampler2D ASP_GlobalTintNoiseTexture;
			uniform half ASP_GlobalTintNoiseUVScale;
			uniform half _TintNoiseUVScale;
			uniform half _TintNoiseInvertMask;
			uniform half ASP_GlobalTintNoiseContrast;
			uniform half _TintNoiseContrast;
			uniform half ASP_GlobalTintNoiseToggle;
			uniform half _TintNoiseIntensity;
			uniform half ASP_GlobalTintNoiseIntensity;
			uniform half4 _BottomColor;
			uniform half _BottomColorOffset;
			uniform half _BottomColorContrast;
			uniform sampler2D _BaseNormal;
			uniform half _BaseNormalIntensity;
			uniform half _BaseSmoothnessIntensity;
			uniform half _BaseSmoothnessWaves;
			uniform half _BottomDitherOffset;
			uniform half _BottomDitherContrast;
			uniform half _BaseOpacityCutoff;


			float3 ASESafeNormalize(float3 inVec)
			{
				float dp3 = max(1.175494351e-38, dot(inVec, inVec));
				return inVec* rsqrt(dp3);
			}
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			
			float4 ASEScreenPositionNormalizedToPixel( float4 screenPosNorm )
			{
				float4 screenPosPixel = screenPosNorm * float4( _ScreenParams.xy, 1, 1 );
				#if UNITY_UV_STARTS_AT_TOP
					screenPosPixel.xy = float2( screenPosPixel.x, ( _ProjectionParams.x < 0 ) ? _ScreenParams.y - screenPosPixel.y : screenPosPixel.y );
				#else
					screenPosPixel.xy = float2( screenPosPixel.x, ( _ProjectionParams.x > 0 ) ? _ScreenParams.y - screenPosPixel.y : screenPosPixel.y );
				#endif
				return screenPosPixel;
			}
			
			inline float Dither4x4Bayer( int x, int y )
			{
				const float dither[ 16 ] = {
				     1,  9,  3, 11,
				    13,  5, 15,  7,
				     4, 12,  2, 10,
				    16,  8, 14,  6 };
				int r = y * 4 + x;
				return dither[ r ] / 16; // same # of instructions as pre-dividing due to compiler magic
			}
			

			v2f VertexFunction (appdata v  ) {
				UNITY_SETUP_INSTANCE_ID(v);
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_TRANSFER_INSTANCE_ID(v,o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				half3 temp_cast_0 = (0.0).xxx;
				half3 Global_Wind_Direction238_g1 = ASPW_WindDirection;
				half3 normalizeResult41_g1 = ASESafeNormalize( Global_Wind_Direction238_g1 );
				half3 worldToObjDir40_g1 = mul( unity_WorldToObject, float4( normalizeResult41_g1, 0.0 ) ).xyz;
				half3 Wind_Direction_Leaf50_g1 = worldToObjDir40_g1;
				half3 break42_g1 = Wind_Direction_Leaf50_g1;
				half3 appendResult43_g1 = (half3(break42_g1.z , 0.0 , ( break42_g1.x * -1.0 )));
				half3 Wind_Direction52_g1 = appendResult43_g1;
				float3 ase_objectPosition = UNITY_MATRIX_M._m03_m13_m23;
				half Wind_Grass_Randomization65_g1 = frac( ( ( ase_objectPosition.x + ase_objectPosition.y + ase_objectPosition.z ) * 1.23 ) );
				half temp_output_5_0_g1 = ( Wind_Grass_Randomization65_g1 + _Time.y );
				half Global_Wind_Grass_Speed144_g1 = ASPW_WindGrassSpeed;
				half temp_output_9_0_g1 = ( _WindGrassSpeed * Global_Wind_Grass_Speed144_g1 * 10.0 );
				half Local_Wind_Grass_Aplitude180_g1 = _WindGrassAmplitude;
				half Global_Wind_Grass_Amplitude172_g1 = ASPW_WindGrassAmplitude;
				half temp_output_27_0_g1 = ( Local_Wind_Grass_Aplitude180_g1 * Global_Wind_Grass_Amplitude172_g1 );
				half Global_Wind_Grass_Flexibility164_g1 = ASPW_WindGrassFlexibility;
				half Wind_Main31_g1 = ( ( ( ( ( sin( ( temp_output_5_0_g1 * ( temp_output_9_0_g1 * 1.0 ) ) ) + sin( ( temp_output_5_0_g1 * ( temp_output_9_0_g1 * 1.25 ) ) ) + sin( ( temp_output_5_0_g1 * ( temp_output_9_0_g1 * 1.5 ) ) ) ) + temp_output_27_0_g1 ) * temp_output_27_0_g1 ) / 50.0 ) * ( ( Global_Wind_Grass_Flexibility164_g1 * _WindGrassFlexibility ) * 0.1 ) );
				half Global_Wind_Grass_Waves_Amplitude162_g1 = ASPW_WindGrassWavesAmplitude;
				half3 appendResult119_g1 = (half3(( normalizeResult41_g1.x * -1.0 ) , ( 0.0 * -1.0 ) , 0.0));
				half3 Wind_Direction_Waves118_g1 = appendResult119_g1;
				half Global_Wind_Grass_Waves_Speed166_g1 = ASPW_WindGrassWavesSpeed;
				float3 ase_positionWS = mul( unity_ObjectToWorld, float4( ( v.vertex ).xyz, 1 ) ).xyz;
				half2 appendResult73_g1 = (half2(ase_positionWS.x , ase_positionWS.z));
				half Global_Wind_Grass_Waves_Scale168_g1 = ASPW_WindGrassWavesScale;
				half Wind_Waves93_g1 = tex2Dlod( ASPW_WindGrassWavesNoiseTexture, float4( ( ( ( Wind_Direction_Waves118_g1 * _Time.y ) * ( Global_Wind_Grass_Waves_Speed166_g1 * 0.1 ) ) + half3( ( ( appendResult73_g1 * Global_Wind_Grass_Waves_Scale168_g1 ) * 0.1 ) ,  0.0 ) ).xy, 0, 0.0) ).r;
				half lerpResult96_g1 = lerp( Wind_Main31_g1 , ( Wind_Main31_g1 * Global_Wind_Grass_Waves_Amplitude162_g1 ) , Wind_Waves93_g1);
				half Wind_Main_with_Waves108_g1 = lerpResult96_g1;
				half temp_output_141_0_g1 = ( ( ase_positionWS.y * ( _WindGrassScale * 10.0 ) ) + _Time.y );
				half Local_Wind_Grass_Speed186_g1 = _WindGrassSpeed;
				half temp_output_146_0_g1 = ( Global_Wind_Grass_Speed144_g1 * Local_Wind_Grass_Speed186_g1 * 10.0 );
				half Global_Wind_Grass_Turbulence161_g1 = ASPW_WindGrassTurbulence;
				half clampResult175_g1 = clamp( Global_Wind_Grass_Amplitude172_g1 , 0.0 , 1.0 );
				half temp_output_188_0_g1 = ( ( ( sin( ( temp_output_141_0_g1 * ( temp_output_146_0_g1 * 1.0 ) ) ) + sin( ( temp_output_141_0_g1 * ( temp_output_146_0_g1 * 1.25 ) ) ) ) * 0.5 ) * ( ( Global_Wind_Grass_Turbulence161_g1 * ( clampResult175_g1 * ( _WindGrassTurbulence * Local_Wind_Grass_Aplitude180_g1 ) ) ) * 0.1 ) );
				half3 appendResult183_g1 = (half3(temp_output_188_0_g1 , ( temp_output_188_0_g1 * 0.2 ) , temp_output_188_0_g1));
				half3 Wind_Turbulence185_g1 = appendResult183_g1;
				half3 rotatedValue56_g1 = RotateAroundAxis( float3( 0,0,0 ), v.vertex.xyz, Wind_Direction52_g1, ( Wind_Main_with_Waves108_g1 + Wind_Turbulence185_g1 ).x );
				half3 Output_Wind35_g1 = ( rotatedValue56_g1 - v.vertex.xyz );
				half Wind_Mask225_g1 = v.ase_color.r;
				half3 lerpResult232_g1 = lerp( float3( 0,0,0 ) , ( Output_Wind35_g1 * Wind_Mask225_g1 ) , ASPW_WindToggle);
				#ifdef _ENABLEWIND_ON
				half3 staticSwitch192_g1 = lerpResult232_g1;
				#else
				half3 staticSwitch192_g1 = temp_cast_0;
				#endif
				
				float4 ase_positionCS = UnityObjectToClipPos( v.vertex );
				float4 screenPos = ComputeScreenPos( ase_positionCS );
				o.ase_texcoord9 = screenPos;
				
				o.ase_texcoord8.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord8.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = staticSwitch192_g1;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.vertex.w = 1;
				v.normal = v.normal;
				v.tangent = v.tangent;

				o.pos = UnityObjectToClipPos(v.vertex);
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
				o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

				#ifdef DYNAMICLIGHTMAP_ON
					o.lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#else
					o.lmap.zw = 0;
				#endif
				#ifdef LIGHTMAP_ON
					o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
					#ifdef DIRLIGHTMAP_OFF
						o.lmapFadePos.xyz = (mul(unity_ObjectToWorld, v.vertex).xyz - unity_ShadowFadeCenterAndType.xyz) * unity_ShadowFadeCenterAndType.w;
						o.lmapFadePos.w = (-UnityObjectToViewPos(v.vertex).z) * (1.0 - unity_ShadowFadeCenterAndType.w);
					#endif
				#else
					o.lmap.xy = 0;
					#if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
						o.sh = 0;
						o.sh = ShadeSHPerVertex (worldNormal, o.sh);
					#endif
				#endif
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				half4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( appdata v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.tangent = v.tangent;
				o.normal = v.normal;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				o.ase_color = v.ase_color;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, UNITY_MATRIX_M, _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, UNITY_MATRIX_M, _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, UNITY_MATRIX_M, _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			v2f DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				appdata o = (appdata) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.tangent = patch[0].tangent * bary.x + patch[1].tangent * bary.y + patch[2].tangent * bary.z;
				o.normal = patch[0].normal * bary.x + patch[1].normal * bary.y + patch[2].normal * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].normal * (dot(o.vertex.xyz, patch[i].normal) - dot(patch[i].vertex.xyz, patch[i].normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			v2f vert ( appdata v )
			{
				return VertexFunction( v );
			}
			#endif

			void frag (v2f IN 
				, out half4 outGBuffer0 : SV_Target0
				, out half4 outGBuffer1 : SV_Target1
				, out half4 outGBuffer2 : SV_Target2
				, out half4 outEmission : SV_Target3
				#if defined(SHADOWS_SHADOWMASK) && (UNITY_ALLOWED_MRT_COUNT > 4)
				, out half4 outShadowMask : SV_Target4
				#endif
				#ifdef _DEPTHOFFSET_ON
				, out float outputDepth : SV_Depth
				#endif
			)
			{
				UNITY_SETUP_INSTANCE_ID(IN);

				#ifdef LOD_FADE_CROSSFADE
					UNITY_APPLY_DITHER_CROSSFADE(IN.pos.xy);
				#endif

				#if defined(_SPECULAR_SETUP)
					SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
				#else
					SurfaceOutputStandard o = (SurfaceOutputStandard)0;
				#endif
				float3 WorldTangent = float3(IN.tSpace0.x,IN.tSpace1.x,IN.tSpace2.x);
				float3 WorldBiTangent = float3(IN.tSpace0.y,IN.tSpace1.y,IN.tSpace2.y);
				float3 WorldNormal = float3(IN.tSpace0.z,IN.tSpace1.z,IN.tSpace2.z);
				float3 worldPos = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				half atten = 1;

				float2 uv_BaseAlbedo280 = IN.ase_texcoord8.xy;
				half4 tex2DNode280 = tex2D( _BaseAlbedo, uv_BaseAlbedo280 );
				half3 desaturateInitialColor281 = tex2DNode280.rgb;
				half desaturateDot281 = dot( desaturateInitialColor281, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar281 = lerp( desaturateInitialColor281, desaturateDot281.xxx, _BaseAlbedoDesaturation );
				half3 Albedo_Texture299 = saturate( ( desaturateVar281 * _BaseAlbedoBrightness ) );
				half3 blendOpSrc283 = Albedo_Texture299;
				half3 blendOpDest283 = _BaseAlbedoColor.rgb;
				half3 Base_Albedo289 = (( blendOpDest283 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest283 ) * ( 1.0 - blendOpSrc283 ) ) : ( 2.0 * blendOpDest283 * blendOpSrc283 ) );
				half3 blendOpSrc345 = Albedo_Texture299;
				half3 blendOpDest345 = _TintColor.rgb;
				half2 appendResult649 = (half2(worldPos.x , worldPos.z));
				half4 tex2DNode651 = tex2D( ASP_GlobalTintNoiseTexture, ( appendResult649 * ( 0.01 * ASP_GlobalTintNoiseUVScale * _TintNoiseUVScale ) ) );
				half lerpResult676 = lerp( tex2DNode651.r , ( 1.0 - tex2DNode651.r ) , _TintNoiseInvertMask);
				half Base_Tint_Color_Mask659 = saturate( ( lerpResult676 * ( ASP_GlobalTintNoiseContrast * _TintNoiseContrast ) * IN.ase_color.r ) );
				half3 lerpResult656 = lerp( Base_Albedo289 , (( blendOpDest345 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest345 ) * ( 1.0 - blendOpSrc345 ) ) : ( 2.0 * blendOpDest345 * blendOpSrc345 ) ) , Base_Tint_Color_Mask659);
				half3 lerpResult661 = lerp( Base_Albedo289 , lerpResult656 , ( ASP_GlobalTintNoiseToggle * _TintNoiseIntensity * ASP_GlobalTintNoiseIntensity ));
				#ifdef _ENABLETINTVARIATIONCOLOR_ON
				half3 staticSwitch403 = lerpResult661;
				#else
				half3 staticSwitch403 = Base_Albedo289;
				#endif
				half3 Base_Albedo_and_Tint_Color374 = staticSwitch403;
				half3 blendOpSrc331 = Albedo_Texture299;
				half3 blendOpDest331 = _BottomColor.rgb;
				half saferPower336 = abs( ( 1.0 - IN.ase_color.a ) );
				half3 lerpResult340 = lerp( Base_Albedo_and_Tint_Color374 , (( blendOpDest331 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest331 ) * ( 1.0 - blendOpSrc331 ) ) : ( 2.0 * blendOpDest331 * blendOpSrc331 ) ) , saturate( ( _BottomColorOffset * pow( saferPower336 , _BottomColorContrast ) ) ));
				#ifdef _ENABLEBOTTOMCOLOR_ON
				half3 staticSwitch375 = lerpResult340;
				#else
				half3 staticSwitch375 = Base_Albedo_and_Tint_Color374;
				#endif
				half3 Output_Albedo342 = staticSwitch375;
				
				float2 uv_BaseNormal318 = IN.ase_texcoord8.xy;
				half3 Base_Normal642 = UnpackScaleNormal( tex2D( _BaseNormal, uv_BaseNormal318 ), _BaseNormalIntensity );
				
				half3 Global_Wind_Direction238_g1 = ASPW_WindDirection;
				half3 normalizeResult41_g1 = ASESafeNormalize( Global_Wind_Direction238_g1 );
				half3 appendResult119_g1 = (half3(( normalizeResult41_g1.x * -1.0 ) , ( 0.0 * -1.0 ) , 0.0));
				half3 Wind_Direction_Waves118_g1 = appendResult119_g1;
				half Global_Wind_Grass_Waves_Speed166_g1 = ASPW_WindGrassWavesSpeed;
				half2 appendResult73_g1 = (half2(worldPos.x , worldPos.z));
				half Global_Wind_Grass_Waves_Scale168_g1 = ASPW_WindGrassWavesScale;
				half Wind_Waves93_g1 = tex2D( ASPW_WindGrassWavesNoiseTexture, ( ( ( Wind_Direction_Waves118_g1 * _Time.y ) * ( Global_Wind_Grass_Waves_Speed166_g1 * 0.1 ) ) + half3( ( ( appendResult73_g1 * Global_Wind_Grass_Waves_Scale168_g1 ) * 0.1 ) ,  0.0 ) ).xy ).r;
				half Wind_Waves621 = Wind_Waves93_g1;
				half lerpResult304 = lerp( 0.0 , _BaseSmoothnessIntensity , ( IN.ase_color.r * ( Wind_Waves621 + _BaseSmoothnessWaves ) ));
				#ifdef _ENABLESMOOTHNESSWAVES_ON
				half staticSwitch719 = lerpResult304;
				#else
				half staticSwitch719 = _BaseSmoothnessIntensity;
				#endif
				half Base_Smoothness314 = saturate( staticSwitch719 );
				
				half Base_Opacity295 = tex2DNode280.a;
				float4 screenPos = IN.ase_texcoord9;
				half4 ase_positionSSNorm = screenPos / screenPos.w;
				ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
				half4 ase_positionSS_Pixel = ASEScreenPositionNormalizedToPixel( ase_positionSSNorm );
				half dither728 = Dither4x4Bayer( fmod( ase_positionSS_Pixel.x, 4 ), fmod( ase_positionSS_Pixel.y, 4 ) );
				dither728 = step( dither728, saturate( saturate( ( ( IN.ase_color.r - _BottomDitherOffset ) * ( _BottomDitherContrast * 2 ) ) ) * 1.00001 ) );
				#ifdef _ENABLEBOTTOMDITHER_ON
				half staticSwitch731 = ( dither728 * Base_Opacity295 );
				#else
				half staticSwitch731 = Base_Opacity295;
				#endif
				half Output_Opacity732 = staticSwitch731;
				
				o.Albedo = Output_Albedo342;
				o.Normal = Base_Normal642;
				o.Emission = half3( 0, 0, 0 );
				#if defined(_SPECULAR_SETUP)
					o.Specular = fixed3( 0, 0, 0 );
				#else
					o.Metallic = 0;
				#endif
				o.Smoothness = Base_Smoothness314;
				o.Occlusion = 1;
				o.Alpha = Output_Opacity732;
				float AlphaClipThreshold = _BaseOpacityCutoff;
				float3 BakedGI = 0;

				#ifdef _ALPHATEST_ON
					clip( o.Alpha - AlphaClipThreshold );
				#endif

				#ifdef _DEPTHOFFSET_ON
					outputDepth = IN.pos.z;
				#endif

				#ifndef USING_DIRECTIONAL_LIGHT
					fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				#else
					fixed3 lightDir = _WorldSpaceLightPos0.xyz;
				#endif

				float3 worldN;
				worldN.x = dot(IN.tSpace0.xyz, o.Normal);
				worldN.y = dot(IN.tSpace1.xyz, o.Normal);
				worldN.z = dot(IN.tSpace2.xyz, o.Normal);
				worldN = normalize(worldN);
				o.Normal = worldN;

				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
				gi.indirect.diffuse = 0;
				gi.indirect.specular = 0;
				gi.light.color = 0;
				gi.light.dir = half3(0,1,0);

				UnityGIInput giInput;
				UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
				giInput.light = gi.light;
				giInput.worldPos = worldPos;
				giInput.worldViewDir = worldViewDir;
				giInput.atten = atten;
				#if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
					giInput.lightmapUV = IN.lmap;
				#else
					giInput.lightmapUV = 0.0;
				#endif
				#if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
					giInput.ambient = IN.sh;
				#else
					giInput.ambient.rgb = 0.0;
				#endif
				giInput.probeHDR[0] = unity_SpecCube0_HDR;
				giInput.probeHDR[1] = unity_SpecCube1_HDR;
				#if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
					giInput.boxMin[0] = unity_SpecCube0_BoxMin;
				#endif
				#ifdef UNITY_SPECCUBE_BOX_PROJECTION
					giInput.boxMax[0] = unity_SpecCube0_BoxMax;
					giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
					giInput.boxMax[1] = unity_SpecCube1_BoxMax;
					giInput.boxMin[1] = unity_SpecCube1_BoxMin;
					giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
				#endif

				#if defined(_SPECULAR_SETUP)
					LightingStandardSpecular_GI( o, giInput, gi );
				#else
					LightingStandard_GI( o, giInput, gi );
				#endif

				#ifdef ASE_BAKEDGI
					gi.indirect.diffuse = BakedGI;
				#endif

				#if UNITY_SHOULD_SAMPLE_SH && !defined(LIGHTMAP_ON) && defined(ASE_NO_AMBIENT)
					gi.indirect.diffuse = 0;
				#endif

				#if defined(_SPECULAR_SETUP)
					outEmission = LightingStandardSpecular_Deferred( o, worldViewDir, gi, outGBuffer0, outGBuffer1, outGBuffer2 );
				#else
					outEmission = LightingStandard_Deferred( o, worldViewDir, gi, outGBuffer0, outGBuffer1, outGBuffer2 );
				#endif

				#if defined(SHADOWS_SHADOWMASK) && (UNITY_ALLOWED_MRT_COUNT > 4)
					outShadowMask = UnityGetRawBakedOcclusions (IN.lmap.xy, float3(0, 0, 0));
				#endif
				#ifndef UNITY_HDR_ON
					outEmission.rgb = exp2(-outEmission.rgb);
				#endif
			}
			ENDCG
		}

		
		Pass
		{
			
			Name "Meta"
			Tags { "LightMode"="Meta" }
			Cull Off

			CGPROGRAM
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#pragma multi_compile_instancing
			#pragma multi_compile __ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define ASE_VERSION 19801

			#pragma vertex vert
			#pragma fragment frag
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#pragma shader_feature EDITOR_VISUALIZATION
			#ifndef UNITY_PASS_META
				#define UNITY_PASS_META
			#endif
			#include "HLSLSupport.cginc"
			#if !defined( UNITY_INSTANCED_LOD_FADE )
				#define UNITY_INSTANCED_LOD_FADE
			#endif
			#if !defined( UNITY_INSTANCED_SH )
				#define UNITY_INSTANCED_SH
			#endif
			#if !defined( UNITY_INSTANCED_LIGHTMAPSTS )
				#define UNITY_INSTANCED_LIGHTMAPSTS
			#endif
			#include "UnityShaderVariables.cginc"
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			#include "UnityMetaPass.cginc"

			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_COLOR
			#pragma shader_feature_local _ENABLEWIND_ON
			#pragma shader_feature_local _ENABLEBOTTOMCOLOR_ON
			#pragma shader_feature_local _ENABLETINTVARIATIONCOLOR_ON
			#pragma shader_feature_local _ENABLEBOTTOMDITHER_ON

			struct appdata {
				float4 vertex : POSITION;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				half4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			struct v2f {
				#if UNITY_VERSION >= 201810
					UNITY_POSITION(pos);
				#else
					float4 pos : SV_POSITION;
				#endif
				#ifdef EDITOR_VISUALIZATION
					float2 vizUV : TEXCOORD1;
					float4 lightCoord : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_color : COLOR;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			uniform sampler2D ASPW_WindGrassWavesNoiseTexture;
			uniform half3 ASPW_WindDirection;
			uniform half _WindGrassSpeed;
			uniform half ASPW_WindGrassSpeed;
			uniform half _WindGrassAmplitude;
			uniform half ASPW_WindGrassAmplitude;
			uniform half ASPW_WindGrassFlexibility;
			uniform half _WindGrassFlexibility;
			uniform half ASPW_WindGrassWavesAmplitude;
			uniform half ASPW_WindGrassWavesSpeed;
			uniform half ASPW_WindGrassWavesScale;
			uniform half _WindGrassScale;
			uniform half ASPW_WindGrassTurbulence;
			uniform half _WindGrassTurbulence;
			uniform half ASPW_WindToggle;
			uniform sampler2D _BaseAlbedo;
			uniform half _BaseAlbedoDesaturation;
			uniform half _BaseAlbedoBrightness;
			uniform half4 _BaseAlbedoColor;
			uniform half4 _TintColor;
			uniform sampler2D ASP_GlobalTintNoiseTexture;
			uniform half ASP_GlobalTintNoiseUVScale;
			uniform half _TintNoiseUVScale;
			uniform half _TintNoiseInvertMask;
			uniform half ASP_GlobalTintNoiseContrast;
			uniform half _TintNoiseContrast;
			uniform half ASP_GlobalTintNoiseToggle;
			uniform half _TintNoiseIntensity;
			uniform half ASP_GlobalTintNoiseIntensity;
			uniform half4 _BottomColor;
			uniform half _BottomColorOffset;
			uniform half _BottomColorContrast;
			uniform half _BottomDitherOffset;
			uniform half _BottomDitherContrast;
			uniform half _BaseOpacityCutoff;


			float3 ASESafeNormalize(float3 inVec)
			{
				float dp3 = max(1.175494351e-38, dot(inVec, inVec));
				return inVec* rsqrt(dp3);
			}
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			
			float4 ASEScreenPositionNormalizedToPixel( float4 screenPosNorm )
			{
				float4 screenPosPixel = screenPosNorm * float4( _ScreenParams.xy, 1, 1 );
				#if UNITY_UV_STARTS_AT_TOP
					screenPosPixel.xy = float2( screenPosPixel.x, ( _ProjectionParams.x < 0 ) ? _ScreenParams.y - screenPosPixel.y : screenPosPixel.y );
				#else
					screenPosPixel.xy = float2( screenPosPixel.x, ( _ProjectionParams.x > 0 ) ? _ScreenParams.y - screenPosPixel.y : screenPosPixel.y );
				#endif
				return screenPosPixel;
			}
			
			inline float Dither4x4Bayer( int x, int y )
			{
				const float dither[ 16 ] = {
				     1,  9,  3, 11,
				    13,  5, 15,  7,
				     4, 12,  2, 10,
				    16,  8, 14,  6 };
				int r = y * 4 + x;
				return dither[ r ] / 16; // same # of instructions as pre-dividing due to compiler magic
			}
			

			v2f VertexFunction (appdata v  ) {
				UNITY_SETUP_INSTANCE_ID(v);
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_TRANSFER_INSTANCE_ID(v,o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				half3 temp_cast_0 = (0.0).xxx;
				half3 Global_Wind_Direction238_g1 = ASPW_WindDirection;
				half3 normalizeResult41_g1 = ASESafeNormalize( Global_Wind_Direction238_g1 );
				half3 worldToObjDir40_g1 = mul( unity_WorldToObject, float4( normalizeResult41_g1, 0.0 ) ).xyz;
				half3 Wind_Direction_Leaf50_g1 = worldToObjDir40_g1;
				half3 break42_g1 = Wind_Direction_Leaf50_g1;
				half3 appendResult43_g1 = (half3(break42_g1.z , 0.0 , ( break42_g1.x * -1.0 )));
				half3 Wind_Direction52_g1 = appendResult43_g1;
				float3 ase_objectPosition = UNITY_MATRIX_M._m03_m13_m23;
				half Wind_Grass_Randomization65_g1 = frac( ( ( ase_objectPosition.x + ase_objectPosition.y + ase_objectPosition.z ) * 1.23 ) );
				half temp_output_5_0_g1 = ( Wind_Grass_Randomization65_g1 + _Time.y );
				half Global_Wind_Grass_Speed144_g1 = ASPW_WindGrassSpeed;
				half temp_output_9_0_g1 = ( _WindGrassSpeed * Global_Wind_Grass_Speed144_g1 * 10.0 );
				half Local_Wind_Grass_Aplitude180_g1 = _WindGrassAmplitude;
				half Global_Wind_Grass_Amplitude172_g1 = ASPW_WindGrassAmplitude;
				half temp_output_27_0_g1 = ( Local_Wind_Grass_Aplitude180_g1 * Global_Wind_Grass_Amplitude172_g1 );
				half Global_Wind_Grass_Flexibility164_g1 = ASPW_WindGrassFlexibility;
				half Wind_Main31_g1 = ( ( ( ( ( sin( ( temp_output_5_0_g1 * ( temp_output_9_0_g1 * 1.0 ) ) ) + sin( ( temp_output_5_0_g1 * ( temp_output_9_0_g1 * 1.25 ) ) ) + sin( ( temp_output_5_0_g1 * ( temp_output_9_0_g1 * 1.5 ) ) ) ) + temp_output_27_0_g1 ) * temp_output_27_0_g1 ) / 50.0 ) * ( ( Global_Wind_Grass_Flexibility164_g1 * _WindGrassFlexibility ) * 0.1 ) );
				half Global_Wind_Grass_Waves_Amplitude162_g1 = ASPW_WindGrassWavesAmplitude;
				half3 appendResult119_g1 = (half3(( normalizeResult41_g1.x * -1.0 ) , ( 0.0 * -1.0 ) , 0.0));
				half3 Wind_Direction_Waves118_g1 = appendResult119_g1;
				half Global_Wind_Grass_Waves_Speed166_g1 = ASPW_WindGrassWavesSpeed;
				float3 ase_positionWS = mul( unity_ObjectToWorld, float4( ( v.vertex ).xyz, 1 ) ).xyz;
				half2 appendResult73_g1 = (half2(ase_positionWS.x , ase_positionWS.z));
				half Global_Wind_Grass_Waves_Scale168_g1 = ASPW_WindGrassWavesScale;
				half Wind_Waves93_g1 = tex2Dlod( ASPW_WindGrassWavesNoiseTexture, float4( ( ( ( Wind_Direction_Waves118_g1 * _Time.y ) * ( Global_Wind_Grass_Waves_Speed166_g1 * 0.1 ) ) + half3( ( ( appendResult73_g1 * Global_Wind_Grass_Waves_Scale168_g1 ) * 0.1 ) ,  0.0 ) ).xy, 0, 0.0) ).r;
				half lerpResult96_g1 = lerp( Wind_Main31_g1 , ( Wind_Main31_g1 * Global_Wind_Grass_Waves_Amplitude162_g1 ) , Wind_Waves93_g1);
				half Wind_Main_with_Waves108_g1 = lerpResult96_g1;
				half temp_output_141_0_g1 = ( ( ase_positionWS.y * ( _WindGrassScale * 10.0 ) ) + _Time.y );
				half Local_Wind_Grass_Speed186_g1 = _WindGrassSpeed;
				half temp_output_146_0_g1 = ( Global_Wind_Grass_Speed144_g1 * Local_Wind_Grass_Speed186_g1 * 10.0 );
				half Global_Wind_Grass_Turbulence161_g1 = ASPW_WindGrassTurbulence;
				half clampResult175_g1 = clamp( Global_Wind_Grass_Amplitude172_g1 , 0.0 , 1.0 );
				half temp_output_188_0_g1 = ( ( ( sin( ( temp_output_141_0_g1 * ( temp_output_146_0_g1 * 1.0 ) ) ) + sin( ( temp_output_141_0_g1 * ( temp_output_146_0_g1 * 1.25 ) ) ) ) * 0.5 ) * ( ( Global_Wind_Grass_Turbulence161_g1 * ( clampResult175_g1 * ( _WindGrassTurbulence * Local_Wind_Grass_Aplitude180_g1 ) ) ) * 0.1 ) );
				half3 appendResult183_g1 = (half3(temp_output_188_0_g1 , ( temp_output_188_0_g1 * 0.2 ) , temp_output_188_0_g1));
				half3 Wind_Turbulence185_g1 = appendResult183_g1;
				half3 rotatedValue56_g1 = RotateAroundAxis( float3( 0,0,0 ), v.vertex.xyz, Wind_Direction52_g1, ( Wind_Main_with_Waves108_g1 + Wind_Turbulence185_g1 ).x );
				half3 Output_Wind35_g1 = ( rotatedValue56_g1 - v.vertex.xyz );
				half Wind_Mask225_g1 = v.ase_color.r;
				half3 lerpResult232_g1 = lerp( float3( 0,0,0 ) , ( Output_Wind35_g1 * Wind_Mask225_g1 ) , ASPW_WindToggle);
				#ifdef _ENABLEWIND_ON
				half3 staticSwitch192_g1 = lerpResult232_g1;
				#else
				half3 staticSwitch192_g1 = temp_cast_0;
				#endif
				
				o.ase_texcoord4.xyz = ase_positionWS;
				
				float4 ase_positionCS = UnityObjectToClipPos( v.vertex );
				float4 screenPos = ComputeScreenPos( ase_positionCS );
				o.ase_texcoord5 = screenPos;
				
				o.ase_texcoord3.xy = v.texcoord.xyzw.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				o.ase_texcoord4.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = staticSwitch192_g1;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.vertex.w = 1;
				v.normal = v.normal;
				v.tangent = v.tangent;

				#ifdef EDITOR_VISUALIZATION
					o.vizUV = 0;
					o.lightCoord = 0;
					if (unity_VisualizationMode == EDITORVIZ_TEXTURE)
						o.vizUV = UnityMetaVizUV(unity_EditorViz_UVIndex, v.texcoord.xy, v.texcoord1.xy, v.texcoord2.xy, unity_EditorViz_Texture_ST);
					else if (unity_VisualizationMode == EDITORVIZ_SHOWLIGHTMASK)
					{
						o.vizUV = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
						o.lightCoord = mul(unity_EditorViz_WorldToLight, mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1)));
					}
				#endif

				o.pos = UnityMetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord2.xy, unity_LightmapST, unity_DynamicLightmapST);

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				half4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( appdata v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.tangent = v.tangent;
				o.normal = v.normal;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, UNITY_MATRIX_M, _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, UNITY_MATRIX_M, _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, UNITY_MATRIX_M, _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			v2f DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				appdata o = (appdata) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.tangent = patch[0].tangent * bary.x + patch[1].tangent * bary.y + patch[2].tangent * bary.z;
				o.normal = patch[0].normal * bary.x + patch[1].normal * bary.y + patch[2].normal * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].normal * (dot(o.vertex.xyz, patch[i].normal) - dot(patch[i].vertex.xyz, patch[i].normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			v2f vert ( appdata v )
			{
				return VertexFunction( v );
			}
			#endif

			fixed4 frag (v2f IN 
				#ifdef _DEPTHOFFSET_ON
				, out float outputDepth : SV_Depth
				#endif
				) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);

				#ifdef LOD_FADE_CROSSFADE
					UNITY_APPLY_DITHER_CROSSFADE(IN.pos.xy);
				#endif

				#if defined(_SPECULAR_SETUP)
					SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
				#else
					SurfaceOutputStandard o = (SurfaceOutputStandard)0;
				#endif

				float2 uv_BaseAlbedo280 = IN.ase_texcoord3.xy;
				half4 tex2DNode280 = tex2D( _BaseAlbedo, uv_BaseAlbedo280 );
				half3 desaturateInitialColor281 = tex2DNode280.rgb;
				half desaturateDot281 = dot( desaturateInitialColor281, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar281 = lerp( desaturateInitialColor281, desaturateDot281.xxx, _BaseAlbedoDesaturation );
				half3 Albedo_Texture299 = saturate( ( desaturateVar281 * _BaseAlbedoBrightness ) );
				half3 blendOpSrc283 = Albedo_Texture299;
				half3 blendOpDest283 = _BaseAlbedoColor.rgb;
				half3 Base_Albedo289 = (( blendOpDest283 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest283 ) * ( 1.0 - blendOpSrc283 ) ) : ( 2.0 * blendOpDest283 * blendOpSrc283 ) );
				half3 blendOpSrc345 = Albedo_Texture299;
				half3 blendOpDest345 = _TintColor.rgb;
				float3 ase_positionWS = IN.ase_texcoord4.xyz;
				half2 appendResult649 = (half2(ase_positionWS.x , ase_positionWS.z));
				half4 tex2DNode651 = tex2D( ASP_GlobalTintNoiseTexture, ( appendResult649 * ( 0.01 * ASP_GlobalTintNoiseUVScale * _TintNoiseUVScale ) ) );
				half lerpResult676 = lerp( tex2DNode651.r , ( 1.0 - tex2DNode651.r ) , _TintNoiseInvertMask);
				half Base_Tint_Color_Mask659 = saturate( ( lerpResult676 * ( ASP_GlobalTintNoiseContrast * _TintNoiseContrast ) * IN.ase_color.r ) );
				half3 lerpResult656 = lerp( Base_Albedo289 , (( blendOpDest345 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest345 ) * ( 1.0 - blendOpSrc345 ) ) : ( 2.0 * blendOpDest345 * blendOpSrc345 ) ) , Base_Tint_Color_Mask659);
				half3 lerpResult661 = lerp( Base_Albedo289 , lerpResult656 , ( ASP_GlobalTintNoiseToggle * _TintNoiseIntensity * ASP_GlobalTintNoiseIntensity ));
				#ifdef _ENABLETINTVARIATIONCOLOR_ON
				half3 staticSwitch403 = lerpResult661;
				#else
				half3 staticSwitch403 = Base_Albedo289;
				#endif
				half3 Base_Albedo_and_Tint_Color374 = staticSwitch403;
				half3 blendOpSrc331 = Albedo_Texture299;
				half3 blendOpDest331 = _BottomColor.rgb;
				half saferPower336 = abs( ( 1.0 - IN.ase_color.a ) );
				half3 lerpResult340 = lerp( Base_Albedo_and_Tint_Color374 , (( blendOpDest331 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest331 ) * ( 1.0 - blendOpSrc331 ) ) : ( 2.0 * blendOpDest331 * blendOpSrc331 ) ) , saturate( ( _BottomColorOffset * pow( saferPower336 , _BottomColorContrast ) ) ));
				#ifdef _ENABLEBOTTOMCOLOR_ON
				half3 staticSwitch375 = lerpResult340;
				#else
				half3 staticSwitch375 = Base_Albedo_and_Tint_Color374;
				#endif
				half3 Output_Albedo342 = staticSwitch375;
				
				half Base_Opacity295 = tex2DNode280.a;
				float4 screenPos = IN.ase_texcoord5;
				half4 ase_positionSSNorm = screenPos / screenPos.w;
				ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
				half4 ase_positionSS_Pixel = ASEScreenPositionNormalizedToPixel( ase_positionSSNorm );
				half dither728 = Dither4x4Bayer( fmod( ase_positionSS_Pixel.x, 4 ), fmod( ase_positionSS_Pixel.y, 4 ) );
				dither728 = step( dither728, saturate( saturate( ( ( IN.ase_color.r - _BottomDitherOffset ) * ( _BottomDitherContrast * 2 ) ) ) * 1.00001 ) );
				#ifdef _ENABLEBOTTOMDITHER_ON
				half staticSwitch731 = ( dither728 * Base_Opacity295 );
				#else
				half staticSwitch731 = Base_Opacity295;
				#endif
				half Output_Opacity732 = staticSwitch731;
				
				o.Albedo = Output_Albedo342;
				o.Normal = fixed3( 0, 0, 1 );
				o.Emission = half3( 0, 0, 0 );
				o.Alpha = Output_Opacity732;
				float AlphaClipThreshold = _BaseOpacityCutoff;

				#ifdef _ALPHATEST_ON
					clip( o.Alpha - AlphaClipThreshold );
				#endif

				#ifdef _DEPTHOFFSET_ON
					outputDepth = IN.pos.z;
				#endif

				UnityMetaInput metaIN;
				UNITY_INITIALIZE_OUTPUT(UnityMetaInput, metaIN);
				metaIN.Albedo = o.Albedo;
				metaIN.Emission = o.Emission;
				#ifdef EDITOR_VISUALIZATION
					metaIN.VizUV = IN.vizUV;
					metaIN.LightCoord = IN.lightCoord;
				#endif
				return UnityMetaFragment(metaIN);
			}
			ENDCG
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }
			ZWrite On
			ZTest LEqual
			AlphaToMask Off

			CGPROGRAM
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#pragma multi_compile_instancing
			#pragma multi_compile __ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define ASE_VERSION 19801

			#pragma vertex vert
			#pragma fragment frag
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#pragma multi_compile_shadowcaster
			#ifndef UNITY_PASS_SHADOWCASTER
				#define UNITY_PASS_SHADOWCASTER
			#endif
			#include "HLSLSupport.cginc"
			#ifndef UNITY_INSTANCED_LOD_FADE
				#define UNITY_INSTANCED_LOD_FADE
			#endif
			#ifndef UNITY_INSTANCED_SH
				#define UNITY_INSTANCED_SH
			#endif
			#ifndef UNITY_INSTANCED_LIGHTMAPSTS
				#define UNITY_INSTANCED_LIGHTMAPSTS
			#endif
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityShaderVariables.cginc"
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"

			#define ASE_NEEDS_VERT_POSITION
			#pragma shader_feature_local _ENABLEWIND_ON
			#pragma shader_feature_local _ENABLEBOTTOMDITHER_ON

			struct appdata {
				float4 vertex : POSITION;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				half4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f {
				V2F_SHADOW_CASTER;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			#ifdef UNITY_STANDARD_USE_DITHER_MASK
				sampler3D _DitherMaskLOD;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			uniform sampler2D ASPW_WindGrassWavesNoiseTexture;
			uniform half3 ASPW_WindDirection;
			uniform half _WindGrassSpeed;
			uniform half ASPW_WindGrassSpeed;
			uniform half _WindGrassAmplitude;
			uniform half ASPW_WindGrassAmplitude;
			uniform half ASPW_WindGrassFlexibility;
			uniform half _WindGrassFlexibility;
			uniform half ASPW_WindGrassWavesAmplitude;
			uniform half ASPW_WindGrassWavesSpeed;
			uniform half ASPW_WindGrassWavesScale;
			uniform half _WindGrassScale;
			uniform half ASPW_WindGrassTurbulence;
			uniform half _WindGrassTurbulence;
			uniform half ASPW_WindToggle;
			uniform sampler2D _BaseAlbedo;
			uniform half _BottomDitherOffset;
			uniform half _BottomDitherContrast;
			uniform half _BaseOpacityCutoff;


			float3 ASESafeNormalize(float3 inVec)
			{
				float dp3 = max(1.175494351e-38, dot(inVec, inVec));
				return inVec* rsqrt(dp3);
			}
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			
			float4 ASEScreenPositionNormalizedToPixel( float4 screenPosNorm )
			{
				float4 screenPosPixel = screenPosNorm * float4( _ScreenParams.xy, 1, 1 );
				#if UNITY_UV_STARTS_AT_TOP
					screenPosPixel.xy = float2( screenPosPixel.x, ( _ProjectionParams.x < 0 ) ? _ScreenParams.y - screenPosPixel.y : screenPosPixel.y );
				#else
					screenPosPixel.xy = float2( screenPosPixel.x, ( _ProjectionParams.x > 0 ) ? _ScreenParams.y - screenPosPixel.y : screenPosPixel.y );
				#endif
				return screenPosPixel;
			}
			
			inline float Dither4x4Bayer( int x, int y )
			{
				const float dither[ 16 ] = {
				     1,  9,  3, 11,
				    13,  5, 15,  7,
				     4, 12,  2, 10,
				    16,  8, 14,  6 };
				int r = y * 4 + x;
				return dither[ r ] / 16; // same # of instructions as pre-dividing due to compiler magic
			}
			

			v2f VertexFunction (appdata v  ) {
				UNITY_SETUP_INSTANCE_ID(v);
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_TRANSFER_INSTANCE_ID(v,o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				half3 temp_cast_0 = (0.0).xxx;
				half3 Global_Wind_Direction238_g1 = ASPW_WindDirection;
				half3 normalizeResult41_g1 = ASESafeNormalize( Global_Wind_Direction238_g1 );
				half3 worldToObjDir40_g1 = mul( unity_WorldToObject, float4( normalizeResult41_g1, 0.0 ) ).xyz;
				half3 Wind_Direction_Leaf50_g1 = worldToObjDir40_g1;
				half3 break42_g1 = Wind_Direction_Leaf50_g1;
				half3 appendResult43_g1 = (half3(break42_g1.z , 0.0 , ( break42_g1.x * -1.0 )));
				half3 Wind_Direction52_g1 = appendResult43_g1;
				float3 ase_objectPosition = UNITY_MATRIX_M._m03_m13_m23;
				half Wind_Grass_Randomization65_g1 = frac( ( ( ase_objectPosition.x + ase_objectPosition.y + ase_objectPosition.z ) * 1.23 ) );
				half temp_output_5_0_g1 = ( Wind_Grass_Randomization65_g1 + _Time.y );
				half Global_Wind_Grass_Speed144_g1 = ASPW_WindGrassSpeed;
				half temp_output_9_0_g1 = ( _WindGrassSpeed * Global_Wind_Grass_Speed144_g1 * 10.0 );
				half Local_Wind_Grass_Aplitude180_g1 = _WindGrassAmplitude;
				half Global_Wind_Grass_Amplitude172_g1 = ASPW_WindGrassAmplitude;
				half temp_output_27_0_g1 = ( Local_Wind_Grass_Aplitude180_g1 * Global_Wind_Grass_Amplitude172_g1 );
				half Global_Wind_Grass_Flexibility164_g1 = ASPW_WindGrassFlexibility;
				half Wind_Main31_g1 = ( ( ( ( ( sin( ( temp_output_5_0_g1 * ( temp_output_9_0_g1 * 1.0 ) ) ) + sin( ( temp_output_5_0_g1 * ( temp_output_9_0_g1 * 1.25 ) ) ) + sin( ( temp_output_5_0_g1 * ( temp_output_9_0_g1 * 1.5 ) ) ) ) + temp_output_27_0_g1 ) * temp_output_27_0_g1 ) / 50.0 ) * ( ( Global_Wind_Grass_Flexibility164_g1 * _WindGrassFlexibility ) * 0.1 ) );
				half Global_Wind_Grass_Waves_Amplitude162_g1 = ASPW_WindGrassWavesAmplitude;
				half3 appendResult119_g1 = (half3(( normalizeResult41_g1.x * -1.0 ) , ( 0.0 * -1.0 ) , 0.0));
				half3 Wind_Direction_Waves118_g1 = appendResult119_g1;
				half Global_Wind_Grass_Waves_Speed166_g1 = ASPW_WindGrassWavesSpeed;
				float3 ase_positionWS = mul( unity_ObjectToWorld, float4( ( v.vertex ).xyz, 1 ) ).xyz;
				half2 appendResult73_g1 = (half2(ase_positionWS.x , ase_positionWS.z));
				half Global_Wind_Grass_Waves_Scale168_g1 = ASPW_WindGrassWavesScale;
				half Wind_Waves93_g1 = tex2Dlod( ASPW_WindGrassWavesNoiseTexture, float4( ( ( ( Wind_Direction_Waves118_g1 * _Time.y ) * ( Global_Wind_Grass_Waves_Speed166_g1 * 0.1 ) ) + half3( ( ( appendResult73_g1 * Global_Wind_Grass_Waves_Scale168_g1 ) * 0.1 ) ,  0.0 ) ).xy, 0, 0.0) ).r;
				half lerpResult96_g1 = lerp( Wind_Main31_g1 , ( Wind_Main31_g1 * Global_Wind_Grass_Waves_Amplitude162_g1 ) , Wind_Waves93_g1);
				half Wind_Main_with_Waves108_g1 = lerpResult96_g1;
				half temp_output_141_0_g1 = ( ( ase_positionWS.y * ( _WindGrassScale * 10.0 ) ) + _Time.y );
				half Local_Wind_Grass_Speed186_g1 = _WindGrassSpeed;
				half temp_output_146_0_g1 = ( Global_Wind_Grass_Speed144_g1 * Local_Wind_Grass_Speed186_g1 * 10.0 );
				half Global_Wind_Grass_Turbulence161_g1 = ASPW_WindGrassTurbulence;
				half clampResult175_g1 = clamp( Global_Wind_Grass_Amplitude172_g1 , 0.0 , 1.0 );
				half temp_output_188_0_g1 = ( ( ( sin( ( temp_output_141_0_g1 * ( temp_output_146_0_g1 * 1.0 ) ) ) + sin( ( temp_output_141_0_g1 * ( temp_output_146_0_g1 * 1.25 ) ) ) ) * 0.5 ) * ( ( Global_Wind_Grass_Turbulence161_g1 * ( clampResult175_g1 * ( _WindGrassTurbulence * Local_Wind_Grass_Aplitude180_g1 ) ) ) * 0.1 ) );
				half3 appendResult183_g1 = (half3(temp_output_188_0_g1 , ( temp_output_188_0_g1 * 0.2 ) , temp_output_188_0_g1));
				half3 Wind_Turbulence185_g1 = appendResult183_g1;
				half3 rotatedValue56_g1 = RotateAroundAxis( float3( 0,0,0 ), v.vertex.xyz, Wind_Direction52_g1, ( Wind_Main_with_Waves108_g1 + Wind_Turbulence185_g1 ).x );
				half3 Output_Wind35_g1 = ( rotatedValue56_g1 - v.vertex.xyz );
				half Wind_Mask225_g1 = v.ase_color.r;
				half3 lerpResult232_g1 = lerp( float3( 0,0,0 ) , ( Output_Wind35_g1 * Wind_Mask225_g1 ) , ASPW_WindToggle);
				#ifdef _ENABLEWIND_ON
				half3 staticSwitch192_g1 = lerpResult232_g1;
				#else
				half3 staticSwitch192_g1 = temp_cast_0;
				#endif
				
				float4 ase_positionCS = UnityObjectToClipPos( v.vertex );
				float4 screenPos = ComputeScreenPos( ase_positionCS );
				o.ase_texcoord3 = screenPos;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = staticSwitch192_g1;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.vertex.w = 1;
				v.normal = v.normal;
				v.tangent = v.tangent;

				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				half4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( appdata v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.tangent = v.tangent;
				o.normal = v.normal;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				o.ase_color = v.ase_color;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, UNITY_MATRIX_M, _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, UNITY_MATRIX_M, _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, UNITY_MATRIX_M, _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			v2f DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				appdata o = (appdata) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.tangent = patch[0].tangent * bary.x + patch[1].tangent * bary.y + patch[2].tangent * bary.z;
				o.normal = patch[0].normal * bary.x + patch[1].normal * bary.y + patch[2].normal * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].normal * (dot(o.vertex.xyz, patch[i].normal) - dot(patch[i].vertex.xyz, patch[i].normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			v2f vert ( appdata v )
			{
				return VertexFunction( v );
			}
			#endif

			fixed4 frag (v2f IN 
				#ifdef _DEPTHOFFSET_ON
				, out float outputDepth : SV_Depth
				#endif
				#if !defined( CAN_SKIP_VPOS )
				, UNITY_VPOS_TYPE vpos : VPOS
				#endif
				) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);

				#ifdef LOD_FADE_CROSSFADE
					UNITY_APPLY_DITHER_CROSSFADE(IN.pos.xy);
				#endif

				#if defined(_SPECULAR_SETUP)
					SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
				#else
					SurfaceOutputStandard o = (SurfaceOutputStandard)0;
				#endif

				float2 uv_BaseAlbedo280 = IN.ase_texcoord2.xy;
				half4 tex2DNode280 = tex2D( _BaseAlbedo, uv_BaseAlbedo280 );
				half Base_Opacity295 = tex2DNode280.a;
				float4 screenPos = IN.ase_texcoord3;
				half4 ase_positionSSNorm = screenPos / screenPos.w;
				ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
				half4 ase_positionSS_Pixel = ASEScreenPositionNormalizedToPixel( ase_positionSSNorm );
				half dither728 = Dither4x4Bayer( fmod( ase_positionSS_Pixel.x, 4 ), fmod( ase_positionSS_Pixel.y, 4 ) );
				dither728 = step( dither728, saturate( saturate( ( ( IN.ase_color.r - _BottomDitherOffset ) * ( _BottomDitherContrast * 2 ) ) ) * 1.00001 ) );
				#ifdef _ENABLEBOTTOMDITHER_ON
				half staticSwitch731 = ( dither728 * Base_Opacity295 );
				#else
				half staticSwitch731 = Base_Opacity295;
				#endif
				half Output_Opacity732 = staticSwitch731;
				
				o.Normal = fixed3( 0, 0, 1 );
				o.Occlusion = 1;
				o.Alpha = Output_Opacity732;
				float AlphaClipThreshold = _BaseOpacityCutoff;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_SHADOW_ON
					if (unity_LightShadowBias.z != 0.0)
						clip(o.Alpha - AlphaClipThresholdShadow);
					#ifdef _ALPHATEST_ON
					else
						clip(o.Alpha - AlphaClipThreshold);
					#endif
				#else
					#ifdef _ALPHATEST_ON
						clip(o.Alpha - AlphaClipThreshold);
					#endif
				#endif

				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif

				#ifdef UNITY_STANDARD_USE_DITHER_MASK
					half alphaRef = tex3D(_DitherMaskLOD, float3(vpos.xy*0.25,o.Alpha*0.9375)).a;
					clip(alphaRef - 0.01);
				#endif

				#ifdef _DEPTHOFFSET_ON
					outputDepth = IN.pos.z;
				#endif

				SHADOW_CASTER_FRAGMENT(IN)
			}
			ENDCG
		}
		
	}
	
	
	Fallback Off
}
/*ASEBEGIN
Version=19801
Node;AmplifyShaderEditor.CommentaryNode;720;-48,960;Inherit;False;2481;469;;12;732;731;730;729;728;727;726;725;724;723;722;721;Base Bottom Dither;1,1,1,1;0;0
Node;AmplifyShaderEditor.VertexColorNode;721;0,1024;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;722;0,1312;Inherit;False;Property;_BottomDitherContrast;Bottom Dither Contrast;17;0;Create;True;0;0;0;False;0;False;3;0;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;723;0,1216;Inherit;False;Property;_BottomDitherOffset;Bottom Dither Offset;16;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;639;-2752,-1840;Inherit;False;2241;429;;11;289;283;285;299;425;287;288;281;282;295;280;Base Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;724;384,1024;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;725;384,1280;Inherit;False;2;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;280;-2688,-1792;Inherit;True;Property;_BaseAlbedo;Base Albedo;9;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;d7b5f571c971c2844b6578a9de1662fb;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;726;640,1024;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;295;-2304,-1664;Inherit;False;Base Opacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;727;896,1024;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;728;1152,1024;Inherit;False;0;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;729;1152,1152;Inherit;False;295;Base Opacity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;730;1408,1024;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;731;1664,1024;Inherit;False;Property;_EnableBottomDither;Enable Bottom Dither;12;0;Create;True;0;0;0;False;1;;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;671;-64,-1840;Inherit;False;2498;1449;;32;401;654;678;655;677;670;658;653;676;374;403;404;661;662;665;656;412;664;663;657;660;345;343;344;651;650;647;649;354;652;648;659;Base Tint Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;673;-48,-176;Inherit;False;2481;941;;15;342;375;376;340;370;339;331;338;332;330;333;336;337;335;334;Base Bottom Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;675;3008,-1842;Inherit;False;768;689;;6;644;423;296;315;290;621;Output;1,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;674;-2751,-690;Inherit;False;1855;693;;10;719;314;424;304;714;307;306;312;622;311;Base Smoothness;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;643;-2752,-1200;Inherit;False;1087;302;;3;642;318;319;Base Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;732;2048,1024;Inherit;False;Output Opacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;648;0,-1024;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;652;0,-768;Half;False;Global;ASP_GlobalTintNoiseUVScale;ASP_GlobalTintNoiseUVScale;20;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;354;0,-672;Inherit;False;Property;_TintNoiseUVScale;Tint Noise UV Scale;20;0;Create;True;0;0;0;False;0;False;5;10;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;649;256,-1024;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;647;384,-768;Inherit;False;3;3;0;FLOAT;0.01;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;650;512,-1024;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DesaturateOpNode;281;-2304,-1792;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;287;-1920,-1792;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;425;-1664,-1792;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;299;-1408,-1792;Inherit;False;Albedo Texture;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;285;-1408,-1664;Inherit;False;Property;_BaseAlbedoColor;Base Albedo Color;3;1;[HDR];Create;True;0;0;0;False;0;False;0.5019608,0.5019608,0.5019608,0;0.1004732,0.2924528,0.06207726,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RegisterLocalVarNode;289;-768,-1792;Inherit;False;Base Albedo;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;344;0,-1664;Inherit;False;Property;_TintColor;Tint Color;19;1;[HDR];Create;True;0;0;0;False;0;False;0.5019608,0.5019608,0.5019608,0;0.6037736,0.5754763,0.1623354,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.GetLocalVarNode;343;0,-1792;Inherit;False;299;Albedo Texture;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BlendOpsNode;345;256,-1792;Inherit;False;Overlay;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;660;256,-1568;Inherit;False;659;Base Tint Color Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;657;256,-1664;Inherit;False;289;Base Albedo;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;663;640,-1536;Half;False;Global;ASP_GlobalTintNoiseToggle;ASP_GlobalTintNoiseToggle;1;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;664;640,-1344;Half;False;Global;ASP_GlobalTintNoiseIntensity;ASP_GlobalTintNoiseIntensity;1;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;412;640,-1440;Inherit;False;Property;_TintNoiseIntensity;Tint Noise Intensity;21;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;656;640,-1792;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;665;640,-1664;Inherit;False;289;Base Albedo;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;662;1024,-1536;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;661;1280,-1792;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;404;1280,-1536;Inherit;False;289;Base Albedo;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;374;2048,-1792;Inherit;False;Base Albedo and Tint Color;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;621;3456,-1328;Inherit;False;Wind Waves;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;290;3072,-1792;Inherit;False;342;Output Albedo;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;315;3072,-1632;Inherit;False;314;Base Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;644;3072,-1712;Inherit;False;642;Base Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;319;-2688,-1152;Inherit;False;Property;_BaseNormalIntensity;Base Normal Intensity;8;0;Create;True;0;0;0;False;0;False;0;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;318;-2304,-1152;Inherit;True;Property;_BaseNormal;Base Normal;10;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RegisterLocalVarNode;642;-1920,-1152;Inherit;False;Base Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;676;1280,-1024;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;653;1536,-1024;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;655;1280,-768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;654;768,-672;Half;False;Global;ASP_GlobalTintNoiseContrast;ASP_GlobalTintNoiseContrast;20;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;334;0,384;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;335;256,384;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;337;0,640;Inherit;False;Property;_BottomColorContrast;Bottom Color Contrast;15;0;Create;True;0;0;0;False;0;False;1;3;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;336;512,384;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;333;0,256;Inherit;False;Property;_BottomColorOffset;Bottom Color Offset;14;0;Create;True;0;0;0;False;0;False;1;2.53;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;332;0,0;Inherit;False;Property;_BottomColor;Bottom Color;13;1;[HDR];Create;True;0;0;0;False;0;False;0.5019608,0.5019608,0.5019608,0;0.05126947,0.1912017,0.04231142,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;338;768,256;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;331;384,-128;Inherit;False;Overlay;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;339;1024,256;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;370;896,0;Inherit;False;374;Base Albedo and Tint Color;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;340;1280,-128;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;376;1280,0;Inherit;False;374;Base Albedo and Tint Color;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;375;1664,-128;Inherit;False;Property;_EnableBottomColor;Enable Bottom Color;11;0;Create;True;0;0;0;False;1;Header(Bottom Color);False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;342;2176,-128;Inherit;False;Output Albedo;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;670;1280,-640;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;658;1792,-1024;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;659;2048,-1024;Inherit;False;Base Tint Color Mask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;401;768,-592;Inherit;False;Property;_TintNoiseContrast;Tint Noise Contrast;22;0;Create;True;0;0;0;False;0;False;5;5;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;678;768,-768;Inherit;False;Property;_TintNoiseInvertMask;Tint Noise Invert Mask;23;1;[IntRange];Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;677;1104,-896;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;651;768,-1024;Inherit;True;Global;ASP_GlobalTintNoiseTexture;ASP_GlobalTintNoiseTexture;0;1;[NoScaleOffset];Create;True;0;0;0;True;1;Header(Tint);False;-1;None;e93d8f0da5bea8144ad9925e81909be8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.BlendOpsNode;283;-1152,-1792;Inherit;False;Overlay;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;288;-2304,-1536;Inherit;False;Property;_BaseAlbedoBrightness;Base Albedo Brightness;4;0;Create;True;0;0;0;False;0;False;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;282;-2688,-1536;Inherit;False;Property;_BaseAlbedoDesaturation;Base Albedo Desaturation;5;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;718;3072,-1344;Inherit;False;MF_ASP_Global_WindGrass;24;;1;ebd015072dd6d824783224f1cda1c365;0;0;2;FLOAT3;0;FLOAT;229
Node;AmplifyShaderEditor.SaturateNode;424;-1408,-640;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;314;-1152,-640;Inherit;False;Base Smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;714;-2688,-640;Inherit;False;Property;_BaseSmoothnessIntensity;Base Smoothness Intensity;6;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;304;-1920,-512;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;311;-2368,-288;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;622;-2688,-288;Inherit;False;621;Wind Waves;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;306;-2688,-480;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;307;-2176,-480;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;312;-2688,-160;Inherit;False;Property;_BaseSmoothnessWaves;Base Smoothness Waves;7;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;719;-1792,-640;Inherit;False;Property;_EnableSmoothnessWaves;Enable Smoothness Waves;1;0;Create;True;0;0;0;False;1;Header(Base);False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;423;3072,-1440;Inherit;False;Property;_BaseOpacityCutoff;Base Opacity Cutoff;2;0;Create;True;0;0;0;False;0;False;0.3;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;330;0,-128;Inherit;False;299;Albedo Texture;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;296;3072,-1536;Inherit;False;732;Output Opacity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;403;1536,-1792;Inherit;False;Property;_EnableTintVariationColor;Enable Tint Variation Color;18;0;Create;True;0;0;0;False;1;Header(Tint Color);False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;708;3456,-1792;Float;False;False;-1;3;AmplifyShaderEditor.MaterialInspector;0;4;New Amplify Shader;ed95fe726fd7b4644bb42f4d1ddd2bcd;True;ExtraPrePass;0;0;ExtraPrePass;6;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;False;True;3;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;DisableBatching=False=DisableBatching;True;3;False;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;709;3456,-1792;Half;False;True;-1;3;;0;4;ANGRYMESH/Stylized Pack/Grass;ed95fe726fd7b4644bb42f4d1ddd2bcd;True;ForwardBase;0;1;ForwardBase;18;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;False;True;3;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;DisableBatching=False=DisableBatching;True;3;False;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;40;Workflow,InvertActionOnDeselection;1;0;Surface;0;0;  Blend;0;0;  Refraction Model;0;0;  Dither Shadows;1;0;Two Sided;0;638772260063199115;Deferred Pass;1;638773069729548435;Transmission;0;0;  Transmission Shadow;0.5,False,;0;Translucency;0;0;  Translucency Strength;1,True,_BaseSSSIntensity;0;  Normal Distortion;0.5,True,_BaseSSSNormalDistortion;0;  Scattering;2,True,_BaseSSSScattering;0;  Direct;0.9,True,_BaseSSSDirect;0;  Ambient;0.1,True,_BaseSSSAmbiet;0;  Shadow;0.5,True,_BaseSSSShadow;0;Cast Shadows;1;0;  Use Shadow Threshold;0;0;Receive Shadows;1;0;GPU Instancing;1;0;LOD CrossFade;1;0;Built-in Fog;1;0;Ambient Light;1;0;Meta Pass;1;0;Add Pass;1;0;Override Baked GI;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Fwd Specular Highlights Toggle;0;0;Fwd Reflections Toggle;0;0;Disable Batching;0;0;Vertex Position,InvertActionOnDeselection;1;0;0;6;False;True;True;True;True;True;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;710;3456,-1792;Float;False;False;-1;3;AmplifyShaderEditor.MaterialInspector;0;4;New Amplify Shader;ed95fe726fd7b4644bb42f4d1ddd2bcd;True;ForwardAdd;0;2;ForwardAdd;0;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;False;True;3;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;DisableBatching=False=DisableBatching;True;3;False;0;False;True;4;1;False;;1;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;True;1;LightMode=ForwardAdd;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;711;3456,-1792;Float;False;False;-1;3;AmplifyShaderEditor.MaterialInspector;0;4;New Amplify Shader;ed95fe726fd7b4644bb42f4d1ddd2bcd;True;Deferred;0;3;Deferred;0;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;False;True;3;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;DisableBatching=False=DisableBatching;True;3;False;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Deferred;True;3;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;712;3456,-1792;Float;False;False;-1;3;AmplifyShaderEditor.MaterialInspector;0;4;New Amplify Shader;ed95fe726fd7b4644bb42f4d1ddd2bcd;True;Meta;0;4;Meta;0;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;False;True;3;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;DisableBatching=False=DisableBatching;True;3;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;713;3456,-1792;Float;False;False;-1;3;AmplifyShaderEditor.MaterialInspector;0;4;New Amplify Shader;ed95fe726fd7b4644bb42f4d1ddd2bcd;True;ShadowCaster;0;5;ShadowCaster;0;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;False;True;3;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;DisableBatching=False=DisableBatching;True;3;False;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
WireConnection;724;0;721;1
WireConnection;724;1;723;0
WireConnection;725;0;722;0
WireConnection;726;0;724;0
WireConnection;726;1;725;0
WireConnection;295;0;280;4
WireConnection;727;0;726;0
WireConnection;728;0;727;0
WireConnection;730;0;728;0
WireConnection;730;1;729;0
WireConnection;731;1;729;0
WireConnection;731;0;730;0
WireConnection;732;0;731;0
WireConnection;649;0;648;1
WireConnection;649;1;648;3
WireConnection;647;1;652;0
WireConnection;647;2;354;0
WireConnection;650;0;649;0
WireConnection;650;1;647;0
WireConnection;281;0;280;5
WireConnection;281;1;282;0
WireConnection;287;0;281;0
WireConnection;287;1;288;0
WireConnection;425;0;287;0
WireConnection;299;0;425;0
WireConnection;289;0;283;0
WireConnection;345;0;343;0
WireConnection;345;1;344;5
WireConnection;656;0;657;0
WireConnection;656;1;345;0
WireConnection;656;2;660;0
WireConnection;662;0;663;0
WireConnection;662;1;412;0
WireConnection;662;2;664;0
WireConnection;661;0;665;0
WireConnection;661;1;656;0
WireConnection;661;2;662;0
WireConnection;374;0;403;0
WireConnection;621;0;718;229
WireConnection;318;5;319;0
WireConnection;642;0;318;0
WireConnection;676;0;651;1
WireConnection;676;1;677;0
WireConnection;676;2;678;0
WireConnection;653;0;676;0
WireConnection;653;1;655;0
WireConnection;653;2;670;1
WireConnection;655;0;654;0
WireConnection;655;1;401;0
WireConnection;335;0;334;4
WireConnection;336;0;335;0
WireConnection;336;1;337;0
WireConnection;338;0;333;0
WireConnection;338;1;336;0
WireConnection;331;0;330;0
WireConnection;331;1;332;5
WireConnection;339;0;338;0
WireConnection;340;0;370;0
WireConnection;340;1;331;0
WireConnection;340;2;339;0
WireConnection;375;1;376;0
WireConnection;375;0;340;0
WireConnection;342;0;375;0
WireConnection;658;0;653;0
WireConnection;659;0;658;0
WireConnection;677;0;651;1
WireConnection;651;1;650;0
WireConnection;283;0;299;0
WireConnection;283;1;285;5
WireConnection;424;0;719;0
WireConnection;314;0;424;0
WireConnection;304;1;714;0
WireConnection;304;2;307;0
WireConnection;311;0;622;0
WireConnection;311;1;312;0
WireConnection;307;0;306;1
WireConnection;307;1;311;0
WireConnection;719;1;714;0
WireConnection;719;0;304;0
WireConnection;403;1;404;0
WireConnection;403;0;661;0
WireConnection;709;0;290;0
WireConnection;709;1;644;0
WireConnection;709;5;315;0
WireConnection;709;7;296;0
WireConnection;709;8;423;0
WireConnection;709;15;718;0
ASEEND*/
//CHKSM=1037711E4EAE57A17091EA734A2881941770D922