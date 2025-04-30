// Made with Amplify Shader Editor v1.9.8.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ANGRYMESH/Stylized Pack/Props"
{
	Properties
	{
		[HDR][Header(Base)]_BaseAlbedoColor("Base Albedo Color", Color) = (0.5019608,0.5019608,0.5019608,0.5019608)
		_BaseAlbedoBrightness("Base Albedo Brightness", Range( 0 , 5)) = 1
		_BaseAlbedoDesaturation("Base Albedo Desaturation", Range( 0 , 1)) = 0
		_BaseUVScale("Base UV Scale", Range( 0 , 50)) = 1
		_BaseMetallicIntensity("Base Metallic Intensity", Range( 0 , 1)) = 0
		_BaseSmoothnessMin("Base Smoothness Min", Range( 0 , 5)) = 0
		_BaseSmoothnessMax("Base Smoothness Max", Range( 0 , 5)) = 1
		_BaseNormalIntensity("Base Normal Intensity", Range( 0 , 5)) = 1
		_BaseAOIntensity("Base AO Intensity", Range( 0 , 1)) = 0.5
		[HDR]_BaseEmissiveColor("Base Emissive Color", Color) = (0,0,0)
		_BaseEmissiveIntensity("Base Emissive Intensity", Float) = 2
		_BaseEmissiveMaskContrast("Base Emissive Mask Contrast", Float) = 2
		[NoScaleOffset]_BaseAlbedo("Base Albedo", 2D) = "gray" {}
		[NoScaleOffset][Normal]_BaseNormal("Base Normal", 2D) = "bump" {}
		[NoScaleOffset]_BaseSMAE("Base SMAE", 2D) = "gray" {}
		[Header(Top Layer)][Toggle(_ENABLETOPLAYERBLEND_ON)] _EnableTopLayerBlend("Enable Top Layer Blend", Float) = 1
		[HDR]_TopLayerAlbedoColor("Top Layer Albedo Color", Color) = (0.5019608,0.5019608,0.5019608,0.5019608)
		_TopLayerUVScale("Top Layer UV Scale", Range( 0 , 50)) = 5
		_TopLayerSmoothnessMin("Top Layer Smoothness Min", Range( 0 , 5)) = 0
		_TopLayerSmoothnessMax("Top Layer Smoothness Max", Range( 0 , 5)) = 1
		_TopLayerNormalIntensity("Top Layer Normal Intensity", Range( 0 , 5)) = 1
		_TopLayerNormalInfluence("Top Layer Normal Influence", Range( 0 , 1)) = 0
		_TopLayerIntensity("Top Layer Intensity", Range( 0 , 1)) = 1
		_TopLayerOffset("Top Layer Offset", Range( 0 , 1)) = 0.5
		_TopLayerContrast("Top Layer Contrast", Range( 0 , 30)) = 10
		_TopLayerVPaintMaskIntensity("Top Layer VPaint Mask Intensity", Range( 0 , 1)) = 0
		[NoScaleOffset]_TopLayerAlbedo("Top Layer Albedo", 2D) = "gray" {}
		[NoScaleOffset][Normal]_TopLayerNormal("Top Layer Normal", 2D) = "bump" {}
		[NoScaleOffset]_TopLayerSmoothness("Top Layer Smoothness", 2D) = "gray" {}
		[Header(Top Layer Noise)][Toggle(_ENABLETOPLAYERNOISE_ON)] _EnableTopLayerNoise("Enable Top Layer Noise", Float) = 0
		_TopLayerNoiseUVScale("Top Layer Noise UV Scale", Range( 0 , 50)) = 5
		_TopLayerNoiseContrast("Top Layer Noise Contrast", Range( 0 , 20)) = 1
		[NoScaleOffset]_TopLayerNoise("Top Layer Noise", 2D) = "black" {}
		[Header(Detail)][Toggle(_ENABLEDETAIL_ON)] _EnableDetail("Enable Detail", Float) = 1
		_DetailUVScale("Detail UV Scale", Range( 0 , 50)) = 2
		_DetailAlbedoIntensity("Detail Albedo Intensity", Range( 0 , 1)) = 1
		_DetailAlbedoPower("Detail Albedo Power", Range( 0 , 10)) = 1
		_DetailNormalIntensity("Detail Normal Intensity", Range( 0 , 5)) = 1
		[NoScaleOffset]_DetailAlbedo("Detail Albedo", 2D) = "gray" {}
		[NoScaleOffset][Normal]_DetailNormal("Detail Normal", 2D) = "bump" {}

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

		Cull Back
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
			#define ASE_NEEDS_FRAG_WORLD_TANGENT
			#define ASE_NEEDS_FRAG_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_BITANGENT
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma shader_feature_local _ENABLETOPLAYERBLEND_ON
			#pragma shader_feature_local _ENABLEDETAIL_ON
			#pragma shader_feature_local _ENABLETOPLAYERNOISE_ON

			struct appdata {
				float4 vertex : POSITION;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				half4 ase_color : COLOR;
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
			uniform sampler2D _BaseAlbedo;
			uniform half _BaseUVScale;
			uniform half _BaseAlbedoDesaturation;
			uniform half _BaseAlbedoBrightness;
			uniform half4 _BaseAlbedoColor;
			uniform sampler2D _DetailAlbedo;
			uniform half _DetailUVScale;
			uniform half _DetailAlbedoPower;
			uniform half _DetailAlbedoIntensity;
			uniform sampler2D _TopLayerAlbedo;
			uniform half _TopLayerUVScale;
			uniform half4 _TopLayerAlbedoColor;
			uniform sampler2D _BaseNormal;
			uniform half _BaseNormalIntensity;
			uniform half _TopLayerOffset;
			uniform half ASPP_TopLayerOffset;
			uniform half _TopLayerContrast;
			uniform half ASPP_TopLayerContrast;
			uniform half _TopLayerIntensity;
			uniform half ASPP_TopLayerIntensity;
			uniform sampler2D _TopLayerNoise;
			uniform half _TopLayerNoiseUVScale;
			uniform half _TopLayerNoiseContrast;
			uniform half ASPT_TopLayerHeightStart;
			uniform half ASPT_TopLayerHeightFade;
			uniform half _TopLayerVPaintMaskIntensity;
			uniform sampler2D _DetailNormal;
			uniform half _DetailNormalIntensity;
			uniform sampler2D _TopLayerNormal;
			uniform half _TopLayerNormalIntensity;
			uniform half _TopLayerNormalInfluence;
			uniform half3 _BaseEmissiveColor;
			uniform sampler2D _BaseSMAE;
			uniform half _BaseEmissiveMaskContrast;
			uniform half _BaseEmissiveIntensity;
			uniform half _BaseMetallicIntensity;
			uniform half _BaseSmoothnessMin;
			uniform half _BaseSmoothnessMax;
			uniform half _TopLayerSmoothnessMin;
			uniform half _TopLayerSmoothnessMax;
			uniform sampler2D _TopLayerSmoothness;
			uniform half _BaseAOIntensity;


			
			v2f VertexFunction (appdata v  ) {
				UNITY_SETUP_INSTANCE_ID(v);
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_TRANSFER_INSTANCE_ID(v,o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord9.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord9.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
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
				float4 ase_texcoord : TEXCOORD0;
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
				o.ase_texcoord = v.ase_texcoord;
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
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
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

				half2 texCoord339 = IN.ase_texcoord9.xy * float2( 1,1 ) + float2( 0,0 );
				half2 Base_UV_Scale342 = ( texCoord339 * _BaseUVScale );
				half3 desaturateInitialColor658 = tex2D( _BaseAlbedo, Base_UV_Scale342 ).rgb;
				half desaturateDot658 = dot( desaturateInitialColor658, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar658 = lerp( desaturateInitialColor658, desaturateDot658.xxx, _BaseAlbedoDesaturation );
				half3 blendOpSrc345 = ( desaturateVar658 * _BaseAlbedoBrightness );
				half3 blendOpDest345 = _BaseAlbedoColor.rgb;
				half3 Base_Albedo350 = ( saturate( (( blendOpDest345 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest345 ) * ( 1.0 - blendOpSrc345 ) ) : ( 2.0 * blendOpDest345 * blendOpSrc345 ) ) ));
				half2 texCoord392 = IN.ase_texcoord9.xy * float2( 1,1 ) + float2( 0,0 );
				half2 Detail_UV_Scale395 = ( texCoord392 * _DetailUVScale );
				half3 saferPower400 = abs( ( tex2D( _DetailAlbedo, Detail_UV_Scale395 ).rgb * float3( 2,2,2 ) ) );
				half3 temp_cast_0 = (_DetailAlbedoPower).xxx;
				half3 blendOpSrc402 = Base_Albedo350;
				half3 blendOpDest402 = pow( saferPower400 , temp_cast_0 );
				half3 lerpResult407 = lerp( Base_Albedo350 , saturate( (( blendOpDest402 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest402 ) * ( 1.0 - blendOpSrc402 ) ) : ( 2.0 * blendOpDest402 * blendOpSrc402 ) ) ) , _DetailAlbedoIntensity);
				half3 Detail_Albedo410 = lerpResult407;
				#ifdef _ENABLEDETAIL_ON
				half3 staticSwitch421 = Detail_Albedo410;
				#else
				half3 staticSwitch421 = Base_Albedo350;
				#endif
				half3 Base_Detail_Albedo474 = staticSwitch421;
				half2 texCoord426 = IN.ase_texcoord9.xy * float2( 1,1 ) + float2( 0,0 );
				half2 Top_Layer_UV_Scale428 = ( texCoord426 * _TopLayerUVScale );
				half3 blendOpSrc432 = tex2D( _TopLayerAlbedo, Top_Layer_UV_Scale428 ).rgb;
				half3 blendOpDest432 = _TopLayerAlbedoColor.rgb;
				half3 Base_Normal355 = UnpackScaleNormal( tex2D( _BaseNormal, Base_UV_Scale342 ), _BaseNormalIntensity );
				half3 tanToWorld0 = float3( WorldTangent.x, WorldBiTangent.x, WorldNormal.x );
				half3 tanToWorld1 = float3( WorldTangent.y, WorldBiTangent.y, WorldNormal.y );
				half3 tanToWorld2 = float3( WorldTangent.z, WorldBiTangent.z, WorldNormal.z );
				float3 tanNormal558 = Base_Normal355;
				half3 worldNormal558 = float3( dot( tanToWorld0, tanNormal558 ), dot( tanToWorld1, tanNormal558 ), dot( tanToWorld2, tanNormal558 ) );
				half saferPower17_g5 = abs( abs( ( saturate( worldNormal558.y ) + ( _TopLayerOffset * ASPP_TopLayerOffset ) ) ) );
				half3 temp_cast_1 = (1.0).xxx;
				half3 temp_cast_2 = (1.0).xxx;
				half2 texCoord535 = IN.ase_texcoord9.xy * float2( 0.1,0.1 ) + float2( 0,0 );
				half3 saferPower647 = abs( ( 1.0 - tex2D( _TopLayerNoise, ( texCoord535 * _TopLayerNoiseUVScale ) ).rgb ) );
				half3 temp_cast_3 = (_TopLayerNoiseContrast).xxx;
				#ifdef _ENABLETOPLAYERBLEND_ON
				half3 staticSwitch545 = saturate( pow( saferPower647 , temp_cast_3 ) );
				#else
				half3 staticSwitch545 = temp_cast_2;
				#endif
				#ifdef _ENABLETOPLAYERNOISE_ON
				half3 staticSwitch551 = staticSwitch545;
				#else
				half3 staticSwitch551 = temp_cast_1;
				#endif
				half3 Top_Layer_Noise_Mask547 = staticSwitch551;
				half lerpResult664 = lerp( 1.0 , IN.ase_color.r , _TopLayerVPaintMaskIntensity);
				half Top_Layer_VPaint_Mask665 = lerpResult664;
				half3 Top_Layer_Mask462 = ( ( ( saturate( pow( saferPower17_g5 , ( _TopLayerContrast * ASPP_TopLayerContrast ) ) ) * ( _TopLayerIntensity * ASPP_TopLayerIntensity ) ) * Top_Layer_Noise_Mask547 ) * saturate( (0.0 + (worldPos.y - ASPT_TopLayerHeightStart) * (1.0 - 0.0) / (( ASPT_TopLayerHeightStart + ASPT_TopLayerHeightFade ) - ASPT_TopLayerHeightStart)) ) * Top_Layer_VPaint_Mask665 );
				half3 lerpResult464 = lerp( Base_Detail_Albedo474 , (( blendOpDest432 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest432 ) * ( 1.0 - blendOpSrc432 ) ) : ( 2.0 * blendOpDest432 * blendOpSrc432 ) ) , Top_Layer_Mask462);
				half3 Top_Layer_Albedo467 = lerpResult464;
				#ifdef _ENABLETOPLAYERBLEND_ON
				half3 staticSwitch472 = Top_Layer_Albedo467;
				#else
				half3 staticSwitch472 = Base_Detail_Albedo474;
				#endif
				half3 Output_Albedo520 = staticSwitch472;
				
				half3 Detail_Normal416 = BlendNormals( UnpackScaleNormal( tex2D( _DetailNormal, Detail_UV_Scale395 ), _DetailNormalIntensity ) , Base_Normal355 );
				#ifdef _ENABLEDETAIL_ON
				half3 staticSwitch446 = Detail_Normal416;
				#else
				half3 staticSwitch446 = Base_Normal355;
				#endif
				half3 Base_Detail_Normal475 = staticSwitch446;
				half3 tex2DNode436 = UnpackScaleNormal( tex2D( _TopLayerNormal, Top_Layer_UV_Scale428 ), _TopLayerNormalIntensity );
				half3 lerpResult438 = lerp( BlendNormals( tex2DNode436 , Base_Normal355 ) , tex2DNode436 , _TopLayerNormalInfluence);
				half3 lerpResult443 = lerp( Base_Detail_Normal475 , lerpResult438 , Top_Layer_Mask462);
				half3 Top_Layer_Normal470 = lerpResult443;
				#ifdef _ENABLETOPLAYERBLEND_ON
				half3 staticSwitch473 = Top_Layer_Normal470;
				#else
				half3 staticSwitch473 = Base_Detail_Normal475;
				#endif
				half3 Output_Normal523 = staticSwitch473;
				
				half4 tex2DNode357 = tex2D( _BaseSMAE, Base_UV_Scale342 );
				half Emissive_Mask371 = tex2DNode357.a;
				half saferPower373 = abs( Emissive_Mask371 );
				half3 Base_Emissive377 = ( ( _BaseEmissiveColor * pow( saferPower373 , _BaseEmissiveMaskContrast ) ) * _BaseEmissiveIntensity );
				half3 lerpResult507 = lerp( Base_Emissive377 , float3( 0,0,0 ) , Top_Layer_Mask462);
				half3 Top_Layer_Emissive509 = lerpResult507;
				#ifdef _ENABLETOPLAYERBLEND_ON
				half3 staticSwitch510 = Top_Layer_Emissive509;
				#else
				half3 staticSwitch510 = Base_Emissive377;
				#endif
				half3 Output_Emissive526 = staticSwitch510;
				
				half Base_Metallic364 = ( tex2DNode357.g * _BaseMetallicIntensity );
				half lerpResult483 = lerp( Base_Metallic364 , 0.0 , Top_Layer_Mask462.x);
				half Top_Layer_Metallic486 = lerpResult483;
				#ifdef _ENABLETOPLAYERBLEND_ON
				half staticSwitch489 = Top_Layer_Metallic486;
				#else
				half staticSwitch489 = Base_Metallic364;
				#endif
				half Output_Metallic524 = staticSwitch489;
				
				half Texture_Smoothness675 = tex2DNode357.r;
				half lerpResult679 = lerp( _BaseSmoothnessMin , _BaseSmoothnessMax , Texture_Smoothness675);
				half Base_Smoothness361 = saturate( lerpResult679 );
				half lerpResult685 = lerp( _TopLayerSmoothnessMin , _TopLayerSmoothnessMax , tex2D( _TopLayerSmoothness, Top_Layer_UV_Scale428 ).r);
				half lerpResult499 = lerp( Base_Smoothness361 , lerpResult685 , Top_Layer_Mask462.x);
				half Top_Layer_Smoothness502 = saturate( lerpResult499 );
				#ifdef _ENABLETOPLAYERBLEND_ON
				half staticSwitch503 = Top_Layer_Smoothness502;
				#else
				half staticSwitch503 = Base_Smoothness361;
				#endif
				half Output_Smoothness525 = staticSwitch503;
				
				half lerpResult365 = lerp( 1.0 , tex2DNode357.b , _BaseAOIntensity);
				half Base_AO348 = lerpResult365;
				half lerpResult514 = lerp( Base_AO348 , 1.0 , Top_Layer_Mask462.x);
				half Top_Layer_AO516 = lerpResult514;
				#ifdef _ENABLETOPLAYERBLEND_ON
				half staticSwitch517 = Top_Layer_AO516;
				#else
				half staticSwitch517 = Base_AO348;
				#endif
				half Output_AO527 = staticSwitch517;
				
				o.Albedo = Output_Albedo520;
				o.Normal = Output_Normal523;
				o.Emission = Output_Emissive526;
				#if defined(_SPECULAR_SETUP)
					o.Specular = fixed3( 0, 0, 0 );
				#else
					o.Metallic = Output_Metallic524;
				#endif
				o.Smoothness = Output_Smoothness525;
				o.Occlusion = Output_AO527;
				o.Alpha = 1;
				float AlphaClipThreshold = 0.5;
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
			#define ASE_NEEDS_FRAG_WORLD_TANGENT
			#define ASE_NEEDS_FRAG_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_BITANGENT
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma shader_feature_local _ENABLETOPLAYERBLEND_ON
			#pragma shader_feature_local _ENABLEDETAIL_ON
			#pragma shader_feature_local _ENABLETOPLAYERNOISE_ON

			struct appdata {
				float4 vertex : POSITION;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				half4 ase_color : COLOR;
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
			uniform sampler2D _BaseAlbedo;
			uniform half _BaseUVScale;
			uniform half _BaseAlbedoDesaturation;
			uniform half _BaseAlbedoBrightness;
			uniform half4 _BaseAlbedoColor;
			uniform sampler2D _DetailAlbedo;
			uniform half _DetailUVScale;
			uniform half _DetailAlbedoPower;
			uniform half _DetailAlbedoIntensity;
			uniform sampler2D _TopLayerAlbedo;
			uniform half _TopLayerUVScale;
			uniform half4 _TopLayerAlbedoColor;
			uniform sampler2D _BaseNormal;
			uniform half _BaseNormalIntensity;
			uniform half _TopLayerOffset;
			uniform half ASPP_TopLayerOffset;
			uniform half _TopLayerContrast;
			uniform half ASPP_TopLayerContrast;
			uniform half _TopLayerIntensity;
			uniform half ASPP_TopLayerIntensity;
			uniform sampler2D _TopLayerNoise;
			uniform half _TopLayerNoiseUVScale;
			uniform half _TopLayerNoiseContrast;
			uniform half ASPT_TopLayerHeightStart;
			uniform half ASPT_TopLayerHeightFade;
			uniform half _TopLayerVPaintMaskIntensity;
			uniform sampler2D _DetailNormal;
			uniform half _DetailNormalIntensity;
			uniform sampler2D _TopLayerNormal;
			uniform half _TopLayerNormalIntensity;
			uniform half _TopLayerNormalInfluence;
			uniform half3 _BaseEmissiveColor;
			uniform sampler2D _BaseSMAE;
			uniform half _BaseEmissiveMaskContrast;
			uniform half _BaseEmissiveIntensity;
			uniform half _BaseMetallicIntensity;
			uniform half _BaseSmoothnessMin;
			uniform half _BaseSmoothnessMax;
			uniform half _TopLayerSmoothnessMin;
			uniform half _TopLayerSmoothnessMax;
			uniform sampler2D _TopLayerSmoothness;
			uniform half _BaseAOIntensity;


			
			v2f VertexFunction (appdata v  ) {
				UNITY_SETUP_INSTANCE_ID(v);
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_TRANSFER_INSTANCE_ID(v,o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord9.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord9.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
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
				float4 ase_texcoord : TEXCOORD0;
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
				o.ase_texcoord = v.ase_texcoord;
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
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
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


				half2 texCoord339 = IN.ase_texcoord9.xy * float2( 1,1 ) + float2( 0,0 );
				half2 Base_UV_Scale342 = ( texCoord339 * _BaseUVScale );
				half3 desaturateInitialColor658 = tex2D( _BaseAlbedo, Base_UV_Scale342 ).rgb;
				half desaturateDot658 = dot( desaturateInitialColor658, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar658 = lerp( desaturateInitialColor658, desaturateDot658.xxx, _BaseAlbedoDesaturation );
				half3 blendOpSrc345 = ( desaturateVar658 * _BaseAlbedoBrightness );
				half3 blendOpDest345 = _BaseAlbedoColor.rgb;
				half3 Base_Albedo350 = ( saturate( (( blendOpDest345 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest345 ) * ( 1.0 - blendOpSrc345 ) ) : ( 2.0 * blendOpDest345 * blendOpSrc345 ) ) ));
				half2 texCoord392 = IN.ase_texcoord9.xy * float2( 1,1 ) + float2( 0,0 );
				half2 Detail_UV_Scale395 = ( texCoord392 * _DetailUVScale );
				half3 saferPower400 = abs( ( tex2D( _DetailAlbedo, Detail_UV_Scale395 ).rgb * float3( 2,2,2 ) ) );
				half3 temp_cast_0 = (_DetailAlbedoPower).xxx;
				half3 blendOpSrc402 = Base_Albedo350;
				half3 blendOpDest402 = pow( saferPower400 , temp_cast_0 );
				half3 lerpResult407 = lerp( Base_Albedo350 , saturate( (( blendOpDest402 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest402 ) * ( 1.0 - blendOpSrc402 ) ) : ( 2.0 * blendOpDest402 * blendOpSrc402 ) ) ) , _DetailAlbedoIntensity);
				half3 Detail_Albedo410 = lerpResult407;
				#ifdef _ENABLEDETAIL_ON
				half3 staticSwitch421 = Detail_Albedo410;
				#else
				half3 staticSwitch421 = Base_Albedo350;
				#endif
				half3 Base_Detail_Albedo474 = staticSwitch421;
				half2 texCoord426 = IN.ase_texcoord9.xy * float2( 1,1 ) + float2( 0,0 );
				half2 Top_Layer_UV_Scale428 = ( texCoord426 * _TopLayerUVScale );
				half3 blendOpSrc432 = tex2D( _TopLayerAlbedo, Top_Layer_UV_Scale428 ).rgb;
				half3 blendOpDest432 = _TopLayerAlbedoColor.rgb;
				half3 Base_Normal355 = UnpackScaleNormal( tex2D( _BaseNormal, Base_UV_Scale342 ), _BaseNormalIntensity );
				half3 tanToWorld0 = float3( WorldTangent.x, WorldBiTangent.x, WorldNormal.x );
				half3 tanToWorld1 = float3( WorldTangent.y, WorldBiTangent.y, WorldNormal.y );
				half3 tanToWorld2 = float3( WorldTangent.z, WorldBiTangent.z, WorldNormal.z );
				float3 tanNormal558 = Base_Normal355;
				half3 worldNormal558 = float3( dot( tanToWorld0, tanNormal558 ), dot( tanToWorld1, tanNormal558 ), dot( tanToWorld2, tanNormal558 ) );
				half saferPower17_g5 = abs( abs( ( saturate( worldNormal558.y ) + ( _TopLayerOffset * ASPP_TopLayerOffset ) ) ) );
				half3 temp_cast_1 = (1.0).xxx;
				half3 temp_cast_2 = (1.0).xxx;
				half2 texCoord535 = IN.ase_texcoord9.xy * float2( 0.1,0.1 ) + float2( 0,0 );
				half3 saferPower647 = abs( ( 1.0 - tex2D( _TopLayerNoise, ( texCoord535 * _TopLayerNoiseUVScale ) ).rgb ) );
				half3 temp_cast_3 = (_TopLayerNoiseContrast).xxx;
				#ifdef _ENABLETOPLAYERBLEND_ON
				half3 staticSwitch545 = saturate( pow( saferPower647 , temp_cast_3 ) );
				#else
				half3 staticSwitch545 = temp_cast_2;
				#endif
				#ifdef _ENABLETOPLAYERNOISE_ON
				half3 staticSwitch551 = staticSwitch545;
				#else
				half3 staticSwitch551 = temp_cast_1;
				#endif
				half3 Top_Layer_Noise_Mask547 = staticSwitch551;
				half lerpResult664 = lerp( 1.0 , IN.ase_color.r , _TopLayerVPaintMaskIntensity);
				half Top_Layer_VPaint_Mask665 = lerpResult664;
				half3 Top_Layer_Mask462 = ( ( ( saturate( pow( saferPower17_g5 , ( _TopLayerContrast * ASPP_TopLayerContrast ) ) ) * ( _TopLayerIntensity * ASPP_TopLayerIntensity ) ) * Top_Layer_Noise_Mask547 ) * saturate( (0.0 + (worldPos.y - ASPT_TopLayerHeightStart) * (1.0 - 0.0) / (( ASPT_TopLayerHeightStart + ASPT_TopLayerHeightFade ) - ASPT_TopLayerHeightStart)) ) * Top_Layer_VPaint_Mask665 );
				half3 lerpResult464 = lerp( Base_Detail_Albedo474 , (( blendOpDest432 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest432 ) * ( 1.0 - blendOpSrc432 ) ) : ( 2.0 * blendOpDest432 * blendOpSrc432 ) ) , Top_Layer_Mask462);
				half3 Top_Layer_Albedo467 = lerpResult464;
				#ifdef _ENABLETOPLAYERBLEND_ON
				half3 staticSwitch472 = Top_Layer_Albedo467;
				#else
				half3 staticSwitch472 = Base_Detail_Albedo474;
				#endif
				half3 Output_Albedo520 = staticSwitch472;
				
				half3 Detail_Normal416 = BlendNormals( UnpackScaleNormal( tex2D( _DetailNormal, Detail_UV_Scale395 ), _DetailNormalIntensity ) , Base_Normal355 );
				#ifdef _ENABLEDETAIL_ON
				half3 staticSwitch446 = Detail_Normal416;
				#else
				half3 staticSwitch446 = Base_Normal355;
				#endif
				half3 Base_Detail_Normal475 = staticSwitch446;
				half3 tex2DNode436 = UnpackScaleNormal( tex2D( _TopLayerNormal, Top_Layer_UV_Scale428 ), _TopLayerNormalIntensity );
				half3 lerpResult438 = lerp( BlendNormals( tex2DNode436 , Base_Normal355 ) , tex2DNode436 , _TopLayerNormalInfluence);
				half3 lerpResult443 = lerp( Base_Detail_Normal475 , lerpResult438 , Top_Layer_Mask462);
				half3 Top_Layer_Normal470 = lerpResult443;
				#ifdef _ENABLETOPLAYERBLEND_ON
				half3 staticSwitch473 = Top_Layer_Normal470;
				#else
				half3 staticSwitch473 = Base_Detail_Normal475;
				#endif
				half3 Output_Normal523 = staticSwitch473;
				
				half4 tex2DNode357 = tex2D( _BaseSMAE, Base_UV_Scale342 );
				half Emissive_Mask371 = tex2DNode357.a;
				half saferPower373 = abs( Emissive_Mask371 );
				half3 Base_Emissive377 = ( ( _BaseEmissiveColor * pow( saferPower373 , _BaseEmissiveMaskContrast ) ) * _BaseEmissiveIntensity );
				half3 lerpResult507 = lerp( Base_Emissive377 , float3( 0,0,0 ) , Top_Layer_Mask462);
				half3 Top_Layer_Emissive509 = lerpResult507;
				#ifdef _ENABLETOPLAYERBLEND_ON
				half3 staticSwitch510 = Top_Layer_Emissive509;
				#else
				half3 staticSwitch510 = Base_Emissive377;
				#endif
				half3 Output_Emissive526 = staticSwitch510;
				
				half Base_Metallic364 = ( tex2DNode357.g * _BaseMetallicIntensity );
				half lerpResult483 = lerp( Base_Metallic364 , 0.0 , Top_Layer_Mask462.x);
				half Top_Layer_Metallic486 = lerpResult483;
				#ifdef _ENABLETOPLAYERBLEND_ON
				half staticSwitch489 = Top_Layer_Metallic486;
				#else
				half staticSwitch489 = Base_Metallic364;
				#endif
				half Output_Metallic524 = staticSwitch489;
				
				half Texture_Smoothness675 = tex2DNode357.r;
				half lerpResult679 = lerp( _BaseSmoothnessMin , _BaseSmoothnessMax , Texture_Smoothness675);
				half Base_Smoothness361 = saturate( lerpResult679 );
				half lerpResult685 = lerp( _TopLayerSmoothnessMin , _TopLayerSmoothnessMax , tex2D( _TopLayerSmoothness, Top_Layer_UV_Scale428 ).r);
				half lerpResult499 = lerp( Base_Smoothness361 , lerpResult685 , Top_Layer_Mask462.x);
				half Top_Layer_Smoothness502 = saturate( lerpResult499 );
				#ifdef _ENABLETOPLAYERBLEND_ON
				half staticSwitch503 = Top_Layer_Smoothness502;
				#else
				half staticSwitch503 = Base_Smoothness361;
				#endif
				half Output_Smoothness525 = staticSwitch503;
				
				half lerpResult365 = lerp( 1.0 , tex2DNode357.b , _BaseAOIntensity);
				half Base_AO348 = lerpResult365;
				half lerpResult514 = lerp( Base_AO348 , 1.0 , Top_Layer_Mask462.x);
				half Top_Layer_AO516 = lerpResult514;
				#ifdef _ENABLETOPLAYERBLEND_ON
				half staticSwitch517 = Top_Layer_AO516;
				#else
				half staticSwitch517 = Base_AO348;
				#endif
				half Output_AO527 = staticSwitch517;
				
				o.Albedo = Output_Albedo520;
				o.Normal = Output_Normal523;
				o.Emission = Output_Emissive526;
				#if defined(_SPECULAR_SETUP)
					o.Specular = fixed3( 0, 0, 0 );
				#else
					o.Metallic = Output_Metallic524;
				#endif
				o.Smoothness = Output_Smoothness525;
				o.Occlusion = Output_AO527;
				o.Alpha = 1;
				float AlphaClipThreshold = 0.5;
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
			#define ASE_NEEDS_FRAG_WORLD_TANGENT
			#define ASE_NEEDS_FRAG_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_BITANGENT
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma shader_feature_local _ENABLETOPLAYERBLEND_ON
			#pragma shader_feature_local _ENABLEDETAIL_ON
			#pragma shader_feature_local _ENABLETOPLAYERNOISE_ON

			struct appdata {
				float4 vertex : POSITION;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				half4 ase_color : COLOR;
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
			uniform sampler2D _BaseAlbedo;
			uniform half _BaseUVScale;
			uniform half _BaseAlbedoDesaturation;
			uniform half _BaseAlbedoBrightness;
			uniform half4 _BaseAlbedoColor;
			uniform sampler2D _DetailAlbedo;
			uniform half _DetailUVScale;
			uniform half _DetailAlbedoPower;
			uniform half _DetailAlbedoIntensity;
			uniform sampler2D _TopLayerAlbedo;
			uniform half _TopLayerUVScale;
			uniform half4 _TopLayerAlbedoColor;
			uniform sampler2D _BaseNormal;
			uniform half _BaseNormalIntensity;
			uniform half _TopLayerOffset;
			uniform half ASPP_TopLayerOffset;
			uniform half _TopLayerContrast;
			uniform half ASPP_TopLayerContrast;
			uniform half _TopLayerIntensity;
			uniform half ASPP_TopLayerIntensity;
			uniform sampler2D _TopLayerNoise;
			uniform half _TopLayerNoiseUVScale;
			uniform half _TopLayerNoiseContrast;
			uniform half ASPT_TopLayerHeightStart;
			uniform half ASPT_TopLayerHeightFade;
			uniform half _TopLayerVPaintMaskIntensity;
			uniform sampler2D _DetailNormal;
			uniform half _DetailNormalIntensity;
			uniform sampler2D _TopLayerNormal;
			uniform half _TopLayerNormalIntensity;
			uniform half _TopLayerNormalInfluence;
			uniform half3 _BaseEmissiveColor;
			uniform sampler2D _BaseSMAE;
			uniform half _BaseEmissiveMaskContrast;
			uniform half _BaseEmissiveIntensity;
			uniform half _BaseMetallicIntensity;
			uniform half _BaseSmoothnessMin;
			uniform half _BaseSmoothnessMax;
			uniform half _TopLayerSmoothnessMin;
			uniform half _TopLayerSmoothnessMax;
			uniform sampler2D _TopLayerSmoothness;
			uniform half _BaseAOIntensity;


			
			v2f VertexFunction (appdata v  ) {
				UNITY_SETUP_INSTANCE_ID(v);
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_TRANSFER_INSTANCE_ID(v,o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord8.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord8.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
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
				float4 ase_texcoord : TEXCOORD0;
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
				o.ase_texcoord = v.ase_texcoord;
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
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
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

				half2 texCoord339 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				half2 Base_UV_Scale342 = ( texCoord339 * _BaseUVScale );
				half3 desaturateInitialColor658 = tex2D( _BaseAlbedo, Base_UV_Scale342 ).rgb;
				half desaturateDot658 = dot( desaturateInitialColor658, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar658 = lerp( desaturateInitialColor658, desaturateDot658.xxx, _BaseAlbedoDesaturation );
				half3 blendOpSrc345 = ( desaturateVar658 * _BaseAlbedoBrightness );
				half3 blendOpDest345 = _BaseAlbedoColor.rgb;
				half3 Base_Albedo350 = ( saturate( (( blendOpDest345 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest345 ) * ( 1.0 - blendOpSrc345 ) ) : ( 2.0 * blendOpDest345 * blendOpSrc345 ) ) ));
				half2 texCoord392 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				half2 Detail_UV_Scale395 = ( texCoord392 * _DetailUVScale );
				half3 saferPower400 = abs( ( tex2D( _DetailAlbedo, Detail_UV_Scale395 ).rgb * float3( 2,2,2 ) ) );
				half3 temp_cast_0 = (_DetailAlbedoPower).xxx;
				half3 blendOpSrc402 = Base_Albedo350;
				half3 blendOpDest402 = pow( saferPower400 , temp_cast_0 );
				half3 lerpResult407 = lerp( Base_Albedo350 , saturate( (( blendOpDest402 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest402 ) * ( 1.0 - blendOpSrc402 ) ) : ( 2.0 * blendOpDest402 * blendOpSrc402 ) ) ) , _DetailAlbedoIntensity);
				half3 Detail_Albedo410 = lerpResult407;
				#ifdef _ENABLEDETAIL_ON
				half3 staticSwitch421 = Detail_Albedo410;
				#else
				half3 staticSwitch421 = Base_Albedo350;
				#endif
				half3 Base_Detail_Albedo474 = staticSwitch421;
				half2 texCoord426 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				half2 Top_Layer_UV_Scale428 = ( texCoord426 * _TopLayerUVScale );
				half3 blendOpSrc432 = tex2D( _TopLayerAlbedo, Top_Layer_UV_Scale428 ).rgb;
				half3 blendOpDest432 = _TopLayerAlbedoColor.rgb;
				half3 Base_Normal355 = UnpackScaleNormal( tex2D( _BaseNormal, Base_UV_Scale342 ), _BaseNormalIntensity );
				half3 tanToWorld0 = float3( WorldTangent.x, WorldBiTangent.x, WorldNormal.x );
				half3 tanToWorld1 = float3( WorldTangent.y, WorldBiTangent.y, WorldNormal.y );
				half3 tanToWorld2 = float3( WorldTangent.z, WorldBiTangent.z, WorldNormal.z );
				float3 tanNormal558 = Base_Normal355;
				half3 worldNormal558 = float3( dot( tanToWorld0, tanNormal558 ), dot( tanToWorld1, tanNormal558 ), dot( tanToWorld2, tanNormal558 ) );
				half saferPower17_g5 = abs( abs( ( saturate( worldNormal558.y ) + ( _TopLayerOffset * ASPP_TopLayerOffset ) ) ) );
				half3 temp_cast_1 = (1.0).xxx;
				half3 temp_cast_2 = (1.0).xxx;
				half2 texCoord535 = IN.ase_texcoord8.xy * float2( 0.1,0.1 ) + float2( 0,0 );
				half3 saferPower647 = abs( ( 1.0 - tex2D( _TopLayerNoise, ( texCoord535 * _TopLayerNoiseUVScale ) ).rgb ) );
				half3 temp_cast_3 = (_TopLayerNoiseContrast).xxx;
				#ifdef _ENABLETOPLAYERBLEND_ON
				half3 staticSwitch545 = saturate( pow( saferPower647 , temp_cast_3 ) );
				#else
				half3 staticSwitch545 = temp_cast_2;
				#endif
				#ifdef _ENABLETOPLAYERNOISE_ON
				half3 staticSwitch551 = staticSwitch545;
				#else
				half3 staticSwitch551 = temp_cast_1;
				#endif
				half3 Top_Layer_Noise_Mask547 = staticSwitch551;
				half lerpResult664 = lerp( 1.0 , IN.ase_color.r , _TopLayerVPaintMaskIntensity);
				half Top_Layer_VPaint_Mask665 = lerpResult664;
				half3 Top_Layer_Mask462 = ( ( ( saturate( pow( saferPower17_g5 , ( _TopLayerContrast * ASPP_TopLayerContrast ) ) ) * ( _TopLayerIntensity * ASPP_TopLayerIntensity ) ) * Top_Layer_Noise_Mask547 ) * saturate( (0.0 + (worldPos.y - ASPT_TopLayerHeightStart) * (1.0 - 0.0) / (( ASPT_TopLayerHeightStart + ASPT_TopLayerHeightFade ) - ASPT_TopLayerHeightStart)) ) * Top_Layer_VPaint_Mask665 );
				half3 lerpResult464 = lerp( Base_Detail_Albedo474 , (( blendOpDest432 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest432 ) * ( 1.0 - blendOpSrc432 ) ) : ( 2.0 * blendOpDest432 * blendOpSrc432 ) ) , Top_Layer_Mask462);
				half3 Top_Layer_Albedo467 = lerpResult464;
				#ifdef _ENABLETOPLAYERBLEND_ON
				half3 staticSwitch472 = Top_Layer_Albedo467;
				#else
				half3 staticSwitch472 = Base_Detail_Albedo474;
				#endif
				half3 Output_Albedo520 = staticSwitch472;
				
				half3 Detail_Normal416 = BlendNormals( UnpackScaleNormal( tex2D( _DetailNormal, Detail_UV_Scale395 ), _DetailNormalIntensity ) , Base_Normal355 );
				#ifdef _ENABLEDETAIL_ON
				half3 staticSwitch446 = Detail_Normal416;
				#else
				half3 staticSwitch446 = Base_Normal355;
				#endif
				half3 Base_Detail_Normal475 = staticSwitch446;
				half3 tex2DNode436 = UnpackScaleNormal( tex2D( _TopLayerNormal, Top_Layer_UV_Scale428 ), _TopLayerNormalIntensity );
				half3 lerpResult438 = lerp( BlendNormals( tex2DNode436 , Base_Normal355 ) , tex2DNode436 , _TopLayerNormalInfluence);
				half3 lerpResult443 = lerp( Base_Detail_Normal475 , lerpResult438 , Top_Layer_Mask462);
				half3 Top_Layer_Normal470 = lerpResult443;
				#ifdef _ENABLETOPLAYERBLEND_ON
				half3 staticSwitch473 = Top_Layer_Normal470;
				#else
				half3 staticSwitch473 = Base_Detail_Normal475;
				#endif
				half3 Output_Normal523 = staticSwitch473;
				
				half4 tex2DNode357 = tex2D( _BaseSMAE, Base_UV_Scale342 );
				half Emissive_Mask371 = tex2DNode357.a;
				half saferPower373 = abs( Emissive_Mask371 );
				half3 Base_Emissive377 = ( ( _BaseEmissiveColor * pow( saferPower373 , _BaseEmissiveMaskContrast ) ) * _BaseEmissiveIntensity );
				half3 lerpResult507 = lerp( Base_Emissive377 , float3( 0,0,0 ) , Top_Layer_Mask462);
				half3 Top_Layer_Emissive509 = lerpResult507;
				#ifdef _ENABLETOPLAYERBLEND_ON
				half3 staticSwitch510 = Top_Layer_Emissive509;
				#else
				half3 staticSwitch510 = Base_Emissive377;
				#endif
				half3 Output_Emissive526 = staticSwitch510;
				
				half Base_Metallic364 = ( tex2DNode357.g * _BaseMetallicIntensity );
				half lerpResult483 = lerp( Base_Metallic364 , 0.0 , Top_Layer_Mask462.x);
				half Top_Layer_Metallic486 = lerpResult483;
				#ifdef _ENABLETOPLAYERBLEND_ON
				half staticSwitch489 = Top_Layer_Metallic486;
				#else
				half staticSwitch489 = Base_Metallic364;
				#endif
				half Output_Metallic524 = staticSwitch489;
				
				half Texture_Smoothness675 = tex2DNode357.r;
				half lerpResult679 = lerp( _BaseSmoothnessMin , _BaseSmoothnessMax , Texture_Smoothness675);
				half Base_Smoothness361 = saturate( lerpResult679 );
				half lerpResult685 = lerp( _TopLayerSmoothnessMin , _TopLayerSmoothnessMax , tex2D( _TopLayerSmoothness, Top_Layer_UV_Scale428 ).r);
				half lerpResult499 = lerp( Base_Smoothness361 , lerpResult685 , Top_Layer_Mask462.x);
				half Top_Layer_Smoothness502 = saturate( lerpResult499 );
				#ifdef _ENABLETOPLAYERBLEND_ON
				half staticSwitch503 = Top_Layer_Smoothness502;
				#else
				half staticSwitch503 = Base_Smoothness361;
				#endif
				half Output_Smoothness525 = staticSwitch503;
				
				half lerpResult365 = lerp( 1.0 , tex2DNode357.b , _BaseAOIntensity);
				half Base_AO348 = lerpResult365;
				half lerpResult514 = lerp( Base_AO348 , 1.0 , Top_Layer_Mask462.x);
				half Top_Layer_AO516 = lerpResult514;
				#ifdef _ENABLETOPLAYERBLEND_ON
				half staticSwitch517 = Top_Layer_AO516;
				#else
				half staticSwitch517 = Base_AO348;
				#endif
				half Output_AO527 = staticSwitch517;
				
				o.Albedo = Output_Albedo520;
				o.Normal = Output_Normal523;
				o.Emission = Output_Emissive526;
				#if defined(_SPECULAR_SETUP)
					o.Specular = fixed3( 0, 0, 0 );
				#else
					o.Metallic = Output_Metallic524;
				#endif
				o.Smoothness = Output_Smoothness525;
				o.Occlusion = Output_AO527;
				o.Alpha = 1;
				float AlphaClipThreshold = 0.5;
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

			#include "UnityStandardUtils.cginc"
			#define ASE_NEEDS_VERT_TANGENT
			#define ASE_NEEDS_VERT_NORMAL
			#pragma shader_feature_local _ENABLETOPLAYERBLEND_ON
			#pragma shader_feature_local _ENABLEDETAIL_ON
			#pragma shader_feature_local _ENABLETOPLAYERNOISE_ON

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
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_color : COLOR;
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
			uniform sampler2D _BaseAlbedo;
			uniform half _BaseUVScale;
			uniform half _BaseAlbedoDesaturation;
			uniform half _BaseAlbedoBrightness;
			uniform half4 _BaseAlbedoColor;
			uniform sampler2D _DetailAlbedo;
			uniform half _DetailUVScale;
			uniform half _DetailAlbedoPower;
			uniform half _DetailAlbedoIntensity;
			uniform sampler2D _TopLayerAlbedo;
			uniform half _TopLayerUVScale;
			uniform half4 _TopLayerAlbedoColor;
			uniform sampler2D _BaseNormal;
			uniform half _BaseNormalIntensity;
			uniform half _TopLayerOffset;
			uniform half ASPP_TopLayerOffset;
			uniform half _TopLayerContrast;
			uniform half ASPP_TopLayerContrast;
			uniform half _TopLayerIntensity;
			uniform half ASPP_TopLayerIntensity;
			uniform sampler2D _TopLayerNoise;
			uniform half _TopLayerNoiseUVScale;
			uniform half _TopLayerNoiseContrast;
			uniform half ASPT_TopLayerHeightStart;
			uniform half ASPT_TopLayerHeightFade;
			uniform half _TopLayerVPaintMaskIntensity;
			uniform half3 _BaseEmissiveColor;
			uniform sampler2D _BaseSMAE;
			uniform half _BaseEmissiveMaskContrast;
			uniform half _BaseEmissiveIntensity;


			
			v2f VertexFunction (appdata v  ) {
				UNITY_SETUP_INSTANCE_ID(v);
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_TRANSFER_INSTANCE_ID(v,o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				half3 ase_tangentWS = UnityObjectToWorldDir( v.tangent );
				o.ase_texcoord4.xyz = ase_tangentWS;
				half3 ase_normalWS = UnityObjectToWorldNormal( v.normal );
				o.ase_texcoord5.xyz = ase_normalWS;
				half ase_tangentSign = v.tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_bitangentWS = cross( ase_normalWS, ase_tangentWS ) * ase_tangentSign;
				o.ase_texcoord6.xyz = ase_bitangentWS;
				float3 ase_positionWS = mul( unity_ObjectToWorld, float4( ( v.vertex ).xyz, 1 ) ).xyz;
				o.ase_texcoord7.xyz = ase_positionWS;
				
				o.ase_texcoord3.xy = v.texcoord.xyzw.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				o.ase_texcoord6.w = 0;
				o.ase_texcoord7.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
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

				half2 texCoord339 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				half2 Base_UV_Scale342 = ( texCoord339 * _BaseUVScale );
				half3 desaturateInitialColor658 = tex2D( _BaseAlbedo, Base_UV_Scale342 ).rgb;
				half desaturateDot658 = dot( desaturateInitialColor658, float3( 0.299, 0.587, 0.114 ));
				half3 desaturateVar658 = lerp( desaturateInitialColor658, desaturateDot658.xxx, _BaseAlbedoDesaturation );
				half3 blendOpSrc345 = ( desaturateVar658 * _BaseAlbedoBrightness );
				half3 blendOpDest345 = _BaseAlbedoColor.rgb;
				half3 Base_Albedo350 = ( saturate( (( blendOpDest345 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest345 ) * ( 1.0 - blendOpSrc345 ) ) : ( 2.0 * blendOpDest345 * blendOpSrc345 ) ) ));
				half2 texCoord392 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				half2 Detail_UV_Scale395 = ( texCoord392 * _DetailUVScale );
				half3 saferPower400 = abs( ( tex2D( _DetailAlbedo, Detail_UV_Scale395 ).rgb * float3( 2,2,2 ) ) );
				half3 temp_cast_0 = (_DetailAlbedoPower).xxx;
				half3 blendOpSrc402 = Base_Albedo350;
				half3 blendOpDest402 = pow( saferPower400 , temp_cast_0 );
				half3 lerpResult407 = lerp( Base_Albedo350 , saturate( (( blendOpDest402 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest402 ) * ( 1.0 - blendOpSrc402 ) ) : ( 2.0 * blendOpDest402 * blendOpSrc402 ) ) ) , _DetailAlbedoIntensity);
				half3 Detail_Albedo410 = lerpResult407;
				#ifdef _ENABLEDETAIL_ON
				half3 staticSwitch421 = Detail_Albedo410;
				#else
				half3 staticSwitch421 = Base_Albedo350;
				#endif
				half3 Base_Detail_Albedo474 = staticSwitch421;
				half2 texCoord426 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				half2 Top_Layer_UV_Scale428 = ( texCoord426 * _TopLayerUVScale );
				half3 blendOpSrc432 = tex2D( _TopLayerAlbedo, Top_Layer_UV_Scale428 ).rgb;
				half3 blendOpDest432 = _TopLayerAlbedoColor.rgb;
				half3 Base_Normal355 = UnpackScaleNormal( tex2D( _BaseNormal, Base_UV_Scale342 ), _BaseNormalIntensity );
				half3 ase_tangentWS = IN.ase_texcoord4.xyz;
				half3 ase_normalWS = IN.ase_texcoord5.xyz;
				float3 ase_bitangentWS = IN.ase_texcoord6.xyz;
				half3 tanToWorld0 = float3( ase_tangentWS.x, ase_bitangentWS.x, ase_normalWS.x );
				half3 tanToWorld1 = float3( ase_tangentWS.y, ase_bitangentWS.y, ase_normalWS.y );
				half3 tanToWorld2 = float3( ase_tangentWS.z, ase_bitangentWS.z, ase_normalWS.z );
				float3 tanNormal558 = Base_Normal355;
				half3 worldNormal558 = float3( dot( tanToWorld0, tanNormal558 ), dot( tanToWorld1, tanNormal558 ), dot( tanToWorld2, tanNormal558 ) );
				half saferPower17_g5 = abs( abs( ( saturate( worldNormal558.y ) + ( _TopLayerOffset * ASPP_TopLayerOffset ) ) ) );
				half3 temp_cast_1 = (1.0).xxx;
				half3 temp_cast_2 = (1.0).xxx;
				half2 texCoord535 = IN.ase_texcoord3.xy * float2( 0.1,0.1 ) + float2( 0,0 );
				half3 saferPower647 = abs( ( 1.0 - tex2D( _TopLayerNoise, ( texCoord535 * _TopLayerNoiseUVScale ) ).rgb ) );
				half3 temp_cast_3 = (_TopLayerNoiseContrast).xxx;
				#ifdef _ENABLETOPLAYERBLEND_ON
				half3 staticSwitch545 = saturate( pow( saferPower647 , temp_cast_3 ) );
				#else
				half3 staticSwitch545 = temp_cast_2;
				#endif
				#ifdef _ENABLETOPLAYERNOISE_ON
				half3 staticSwitch551 = staticSwitch545;
				#else
				half3 staticSwitch551 = temp_cast_1;
				#endif
				half3 Top_Layer_Noise_Mask547 = staticSwitch551;
				float3 ase_positionWS = IN.ase_texcoord7.xyz;
				half lerpResult664 = lerp( 1.0 , IN.ase_color.r , _TopLayerVPaintMaskIntensity);
				half Top_Layer_VPaint_Mask665 = lerpResult664;
				half3 Top_Layer_Mask462 = ( ( ( saturate( pow( saferPower17_g5 , ( _TopLayerContrast * ASPP_TopLayerContrast ) ) ) * ( _TopLayerIntensity * ASPP_TopLayerIntensity ) ) * Top_Layer_Noise_Mask547 ) * saturate( (0.0 + (ase_positionWS.y - ASPT_TopLayerHeightStart) * (1.0 - 0.0) / (( ASPT_TopLayerHeightStart + ASPT_TopLayerHeightFade ) - ASPT_TopLayerHeightStart)) ) * Top_Layer_VPaint_Mask665 );
				half3 lerpResult464 = lerp( Base_Detail_Albedo474 , (( blendOpDest432 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest432 ) * ( 1.0 - blendOpSrc432 ) ) : ( 2.0 * blendOpDest432 * blendOpSrc432 ) ) , Top_Layer_Mask462);
				half3 Top_Layer_Albedo467 = lerpResult464;
				#ifdef _ENABLETOPLAYERBLEND_ON
				half3 staticSwitch472 = Top_Layer_Albedo467;
				#else
				half3 staticSwitch472 = Base_Detail_Albedo474;
				#endif
				half3 Output_Albedo520 = staticSwitch472;
				
				half4 tex2DNode357 = tex2D( _BaseSMAE, Base_UV_Scale342 );
				half Emissive_Mask371 = tex2DNode357.a;
				half saferPower373 = abs( Emissive_Mask371 );
				half3 Base_Emissive377 = ( ( _BaseEmissiveColor * pow( saferPower373 , _BaseEmissiveMaskContrast ) ) * _BaseEmissiveIntensity );
				half3 lerpResult507 = lerp( Base_Emissive377 , float3( 0,0,0 ) , Top_Layer_Mask462);
				half3 Top_Layer_Emissive509 = lerpResult507;
				#ifdef _ENABLETOPLAYERBLEND_ON
				half3 staticSwitch510 = Top_Layer_Emissive509;
				#else
				half3 staticSwitch510 = Base_Emissive377;
				#endif
				half3 Output_Emissive526 = staticSwitch510;
				
				o.Albedo = Output_Albedo520;
				o.Normal = fixed3( 0, 0, 1 );
				o.Emission = Output_Emissive526;
				o.Alpha = 1;
				float AlphaClipThreshold = 0.5;

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

			
			struct appdata {
				float4 vertex : POSITION;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f {
				V2F_SHADOW_CASTER;
				
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
			

			
			v2f VertexFunction (appdata v  ) {
				UNITY_SETUP_INSTANCE_ID(v);
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_TRANSFER_INSTANCE_ID(v,o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
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

				
				o.Normal = fixed3( 0, 0, 1 );
				o.Occlusion = 1;
				o.Alpha = 1;
				float AlphaClipThreshold = 0.5;
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
Node;AmplifyShaderEditor.CommentaryNode;667;1726,2896;Inherit;False;960.5;429.0999;;4;663;665;664;662;Top Layer VPaint Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;626;1728,590;Inherit;False;832;305;;4;428;427;429;426;Top Layer UVs;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;625;1727,1104;Inherit;False;1983;914;;17;650;462;649;549;455;454;453;548;460;461;459;558;456;458;457;448;666;Top Layer Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;624;1730,78;Inherit;False;960;304;;4;509;507;508;506;Top Layer Emissive;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;623;1729,-434;Inherit;False;955;304;;4;516;514;513;515;Top Layer AO;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;622;1731,-946;Inherit;False;957;308;;4;486;483;484;482;Top Layer Metallic;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;621;1732,-1586;Inherit;False;2242;471;;10;684;681;685;500;501;496;502;584;499;495;Top Layer Smoothness;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;620;1733,-2240;Inherit;False;2233;447;;11;436;442;435;470;443;477;469;438;439;440;437;Top Layer Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;619;1730,-2994;Inherit;False;1852;559;;8;466;430;476;433;467;464;432;431;Top Layer Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;618;-1469,-1714;Inherit;False;831;304;;4;395;394;393;392;Detail UVs;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;617;-1473,-2354;Inherit;False;1473;434;;6;416;413;411;414;415;412;Detail Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;616;-1471,-2994;Inherit;False;2495;432;;12;409;401;396;410;407;408;406;402;400;403;398;397;Detail Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;615;-3776,80;Inherit;False;827;303;;4;342;341;340;339;Base UVs;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;614;-3776,-688;Inherit;False;1602;560;;8;376;374;369;377;375;370;373;372;Base Emissive;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;613;-3774,-1840;Inherit;False;1599;909;[R] Smoothness | [G] Metallic | [B] AmbientOcclusion | [A] Emissive;16;678;361;570;676;679;675;364;348;362;371;365;357;367;363;358;683;Base SMAE;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;612;-3777,-2352;Inherit;False;1600;303;;4;352;355;354;353;Base Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;611;-3772,-2994;Inherit;False;1853;501;;9;350;345;481;660;659;661;658;343;344;Base Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;552;1729,2256;Inherit;False;2882;431;;12;539;536;543;545;547;551;546;544;541;537;535;647;Top Layer Noise Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;556;4804,-2992;Inherit;False;1729;1580;;30;527;517;519;518;525;524;526;523;520;472;510;503;489;473;380;504;490;488;512;511;471;468;474;475;421;446;319;419;420;356;Switches;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;603;6979,-2992;Inherit;False;889;688;Comment;6;533;532;531;530;529;522;Output;1,0,0,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;344;-3712,-2944;Inherit;False;342;Base UV Scale;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;353;-3712,-2304;Inherit;False;342;Base UV Scale;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;354;-3712,-2176;Half;False;Property;_BaseNormalIntensity;Base Normal Intensity;7;0;Create;True;0;0;0;False;0;False;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;358;-3712,-1792;Inherit;False;342;Base UV Scale;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;355;-2432,-2304;Inherit;False;Base Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;397;-1408,-2944;Inherit;False;395;Detail UV Scale;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;398;-640,-2944;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;2,2,2;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;403;-256,-2816;Inherit;False;350;Base Albedo;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;406;256,-2944;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;408;256,-2816;Inherit;False;350;Base Albedo;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;407;512,-2944;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;396;-1024,-2944;Inherit;True;Property;_DetailAlbedo;Detail Albedo;38;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;3b5ec0ed815e27d4c80112b53c024182;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;401;-640,-2816;Inherit;False;Property;_DetailAlbedoPower;Detail Albedo Power;36;0;Create;True;0;0;0;False;0;False;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;409;256,-2720;Inherit;False;Property;_DetailAlbedoIntensity;Detail Albedo Intensity;35;0;Create;True;0;0;0;False;0;False;1;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;412;-1408,-2304;Inherit;False;395;Detail UV Scale;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;415;-1024,-2080;Inherit;False;355;Base Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BlendNormalsNode;414;-640,-2304;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;411;-1024,-2304;Inherit;True;Property;_DetailNormal;Detail Normal;39;2;[NoScaleOffset];[Normal];Create;True;0;0;0;False;0;False;-1;None;df04d36d54fbf4248bdad4d753206afe;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.TextureCoordinatesNode;392;-1408,-1664;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;393;-1408,-1536;Inherit;False;Property;_DetailUVScale;Detail UV Scale;34;0;Create;True;0;0;0;False;0;False;2;2;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;394;-1152,-1664;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;395;-880,-1664;Inherit;False;Detail UV Scale;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;431;1792,-2944;Inherit;False;428;Top Layer UV Scale;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BlendOpsNode;432;2688,-2944;Inherit;False;Overlay;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;464;3072,-2944;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;467;3328,-2944;Inherit;False;Top Layer Albedo;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;433;2304,-2688;Half;False;Property;_TopLayerAlbedoColor;Top Layer Albedo Color;16;1;[HDR];Create;True;0;0;0;False;0;False;0.5019608,0.5019608,0.5019608,0.5019608;0.5019608,0.5019608,0.5019608,0.5019608;False;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.GetLocalVarNode;476;2688,-2816;Inherit;False;474;Base Detail Albedo;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;437;1792,-2176;Inherit;False;428;Top Layer UV Scale;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;440;2304,-1920;Inherit;False;355;Base Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BlendNormalsNode;439;2688,-2048;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;438;3072,-2176;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;469;3072,-1920;Inherit;False;462;Top Layer Mask;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;477;3072,-2048;Inherit;False;475;Base Detail Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;443;3456,-2176;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;470;3712,-2176;Inherit;False;Top Layer Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;435;1792,-2048;Half;False;Property;_TopLayerNormalIntensity;Top Layer Normal Intensity;20;0;Create;True;0;0;0;False;0;False;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;442;2688,-1920;Half;False;Property;_TopLayerNormalInfluence;Top Layer Normal Influence;21;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;495;1792,-1536;Inherit;False;428;Top Layer UV Scale;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;499;2944,-1536;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;584;3200,-1536;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;502;3712,-1536;Inherit;False;Top Layer Smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;482;1792,-896;Inherit;False;364;Base Metallic;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;484;1792,-768;Inherit;False;462;Top Layer Mask;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;483;2176,-896;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;486;2432,-896;Inherit;False;Top Layer Metallic;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;515;1792,-256;Inherit;False;462;Top Layer Mask;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;513;1792,-384;Inherit;False;348;Base AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;514;2176,-384;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;516;2432,-384;Inherit;False;Top Layer AO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;506;1792,128;Inherit;False;377;Base Emissive;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;508;1792,256;Inherit;False;462;Top Layer Mask;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;507;2176,128;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;509;2432,128;Inherit;False;Top Layer Emissive;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;496;2304,-1536;Inherit;True;Property;_TopLayerSmoothness;Top Layer Smoothness;28;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;8e8ac0c4acbd18f45891d51182feebda;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode;436;2304,-2176;Inherit;True;Property;_TopLayerNormal;Top Layer Normal;27;2;[NoScaleOffset];[Normal];Create;True;0;0;0;False;0;False;-1;None;ce33c7bbfcc6ff044979c54b9fb01fae;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode;430;2304,-2944;Inherit;True;Property;_TopLayerAlbedo;Top Layer Albedo;26;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;f6dc7c0cfcd8cb54cb5f4dbe15bb7047;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.GetLocalVarNode;448;1792,1152;Inherit;False;355;Base Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;457;1792,1888;Half;False;Global;ASPP_TopLayerContrast;ASPP_TopLayerContrast;27;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;458;1792,1696;Half;False;Global;ASPP_TopLayerOffset;ASPP_TopLayerOffset;27;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;456;1792,1504;Half;False;Global;ASPP_TopLayerIntensity;ASPP_TopLayerIntensity;27;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;558;2048,1152;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;459;2176,1408;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;461;2176,1792;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;460;2176,1600;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;548;2816,1152;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;453;1792,1408;Half;False;Property;_TopLayerIntensity;Top Layer Intensity;22;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;454;1792,1600;Half;False;Property;_TopLayerOffset;Top Layer Offset;23;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;455;1792,1792;Half;False;Property;_TopLayerContrast;Top Layer Contrast;24;0;Create;True;0;0;0;False;0;False;10;10;0;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;537;2048,2304;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;541;2688,2304;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;544;3328,2304;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;545;3584,2304;Inherit;False;Property;_EnableDetail8;Enable Detail;15;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;472;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;426;1792,640;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;429;1792,768;Inherit;False;Property;_TopLayerUVScale;Top Layer UV Scale;17;0;Create;True;0;0;0;False;0;False;5;5;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;427;2048,640;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;428;2304,640;Inherit;False;Top Layer UV Scale;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;356;4864,-2688;Inherit;False;355;Base Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;420;4864,-2560;Inherit;False;416;Detail Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;419;4864,-2816;Inherit;False;410;Detail Albedo;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;319;4864,-2944;Inherit;False;350;Base Albedo;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;446;5248,-2688;Inherit;False;Property;_EnableDetail2;Enable Detail;33;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;421;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;421;5248,-2944;Inherit;False;Property;_EnableDetail;Enable Detail;33;0;Create;True;0;0;0;False;1;Header(Detail);False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;475;5504,-2688;Inherit;False;Base Detail Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;474;5504,-2944;Inherit;False;Base Detail Albedo;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;468;5504,-2816;Inherit;False;467;Top Layer Albedo;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;471;5504,-2560;Inherit;False;470;Top Layer Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;511;5504,-2432;Inherit;False;377;Base Emissive;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;512;5504,-2336;Inherit;False;509;Top Layer Emissive;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;488;5504,-2080;Inherit;False;486;Top Layer Metallic;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;490;5504,-2176;Inherit;False;364;Base Metallic;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;504;5504,-1824;Inherit;False;502;Top Layer Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;380;5504,-1920;Inherit;False;361;Base Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;473;5888,-2688;Inherit;False;Property;_EnableDetail3;Enable Detail;15;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;472;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;489;5888,-2176;Inherit;False;Property;_EnableDetail4;Enable Detail;15;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;472;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;503;5888,-1920;Inherit;False;Property;_EnableDetail5;Enable Detail;15;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;472;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;510;5888,-2432;Inherit;False;Property;_EnableDetail6;Enable Detail;15;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;472;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;472;5888,-2944;Inherit;False;Property;_EnableTopLayerBlend;Enable Top Layer Blend;15;0;Create;True;0;0;0;False;1;Header(Top Layer);False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;520;6272,-2944;Inherit;False;Output Albedo;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;523;6272,-2688;Inherit;False;Output Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;526;6272,-2432;Inherit;False;Output Emissive;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;524;6272,-2176;Inherit;False;Output Metallic;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;525;6272,-1920;Inherit;False;Output Smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;518;5504,-1664;Inherit;False;348;Base AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;519;5504,-1568;Inherit;False;516;Top Layer AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;517;5888,-1664;Inherit;False;Property;_EnableDetail7;Enable Detail;15;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;472;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;527;6272,-1664;Inherit;False;Output AO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;522;7040,-2944;Inherit;False;520;Output Albedo;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;529;7040,-2848;Inherit;False;523;Output Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;530;7040,-2752;Inherit;False;526;Output Emissive;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;531;7040,-2656;Inherit;False;524;Output Metallic;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;532;7040,-2560;Inherit;False;525;Output Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;533;7040,-2464;Inherit;False;527;Output AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;343;-3328,-2944;Inherit;True;Property;_BaseAlbedo;Base Albedo;12;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;1c7b87cad3de94e4a8b4db83be10366f;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode;352;-3328,-2304;Inherit;True;Property;_BaseNormal;Base Normal;13;2;[NoScaleOffset];[Normal];Create;True;0;0;0;False;0;False;-1;None;988a757117eb83b418d8e0372d15c040;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode;357;-3328,-1792;Inherit;True;Property;_BaseSMAE;Base SMAE;14;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;3dee2eec0b6a3a74c868dd970b9ba25c;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.GetLocalVarNode;466;2688,-2688;Inherit;False;462;Top Layer Mask;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;416;-256,-2304;Inherit;False;Detail Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;413;-1408,-2176;Half;False;Property;_DetailNormalIntensity;Detail Normal Intensity;37;0;Create;True;0;0;0;False;0;False;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;402;0,-2944;Inherit;False;Overlay;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;410;768,-2944;Inherit;False;Detail Albedo;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;535;1792,2304;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;0.1,0.1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;547;4352,2304;Inherit;False;Top Layer Noise Mask;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;549;2432,1408;Inherit;False;547;Top Layer Noise Mask;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;649;2432,1152;Inherit;False;MF_ASP_Global_TopLayer;-1;;5;6dc1725aa9649cc439f99987e8365ea2;0;4;22;FLOAT;0;False;24;FLOAT;1;False;23;FLOAT;0.5;False;25;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;462;3456,1152;Inherit;False;Top Layer Mask;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;650;3200,1152;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;657;2816,1408;Inherit;False;MF_ASP_Global_TopLayerHeight;-1;;44;0851e7dd80a2406479a4b23dfe36fe1f;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DesaturateOpNode;658;-2944,-2944;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;661;-2688,-2944;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;659;-3328,-2688;Inherit;False;Property;_BaseAlbedoDesaturation;Base Albedo Desaturation;2;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;481;-2688,-2816;Half;False;Property;_BaseAlbedoColor;Base Albedo Color;0;1;[HDR];Create;True;0;0;0;False;1;Header(Base);False;0.5019608,0.5019608,0.5019608,0.5019608;0.5520116,0.4178852,0.3419144,0;False;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RegisterLocalVarNode;350;-2176,-2944;Inherit;False;Base Albedo;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BlendOpsNode;345;-2432,-2944;Inherit;False;Overlay;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;400;-256,-2944;Inherit;False;True;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;647;3072,2304;Inherit;False;True;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;660;-3328,-2592;Inherit;False;Property;_BaseAlbedoBrightness;Base Albedo Brightness;1;0;Create;True;0;0;0;False;0;False;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;666;2816,1536;Inherit;False;665;Top Layer VPaint Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;543;2688,2432;Inherit;False;Property;_TopLayerNoiseContrast;Top Layer Noise Contrast;31;0;Create;True;0;0;0;False;0;False;1;1;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;536;1792,2432;Inherit;False;Property;_TopLayerNoiseUVScale;Top Layer Noise UV Scale;30;0;Create;True;0;0;0;False;0;False;5;5;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;539;2304,2304;Inherit;True;Property;_TopLayerNoise;Top Layer Noise;32;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;e93d8f0da5bea8144ad9925e81909be8;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;546;3328,2432;Inherit;False;Constant;_One;One;40;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;551;3968,2304;Inherit;False;Property;_EnableTopLayerNoise;Enable Top Layer Noise;29;0;Create;True;0;0;0;False;1;Header(Top Layer Noise);False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;662;1792,2946;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;664;2176,2946;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;665;2432,2946;Inherit;False;Top Layer VPaint Mask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;663;1792,3136;Inherit;False;Property;_TopLayerVPaintMaskIntensity;Top Layer VPaint Mask Intensity;25;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;371;-2944,-1408;Inherit;False;Emissive Mask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;372;-3712,-384;Inherit;False;371;Emissive Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;370;-3200,-640;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;375;-2816,-640;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;377;-2432,-640;Inherit;False;Base Emissive;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;369;-3712,-640;Half;False;Property;_BaseEmissiveColor;Base Emissive Color;9;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,1;False;False;0;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;374;-3712,-256;Inherit;False;Property;_BaseEmissiveMaskContrast;Base Emissive Mask Contrast;11;0;Create;True;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;376;-3072,-384;Inherit;False;Property;_BaseEmissiveIntensity;Base Emissive Intensity;10;0;Create;True;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;339;-3712,128;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;340;-3712,256;Inherit;False;Property;_BaseUVScale;Base UV Scale;3;0;Create;True;0;0;0;False;0;False;1;1;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;341;-3456,128;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;342;-3200,128;Inherit;False;Base UV Scale;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;373;-3328,-384;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;365;-2944,-1568;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;362;-2944,-1696;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;348;-2432,-1568;Inherit;False;Base AO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;364;-2432,-1696;Inherit;False;Base Metallic;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;361;-2432,-1280;Inherit;False;Base Smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;501;2688,-1280;Inherit;False;462;Top Layer Mask;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;500;2688,-1408;Inherit;False;361;Base Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;675;-2944,-1792;Inherit;False;Texture Smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;685;2688,-1536;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;363;-3328,-1568;Half;False;Property;_BaseMetallicIntensity;Base Metallic Intensity;4;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;367;-3328,-1472;Half;False;Property;_BaseAOIntensity;Base AO Intensity;8;0;Create;True;0;0;0;False;0;False;0.5;0.491;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;676;-3328,-1088;Inherit;False;675;Texture Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;679;-2944,-1280;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;570;-2688,-1280;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;681;2304,-1312;Half;False;Property;_TopLayerSmoothnessMin;Top Layer Smoothness Min;18;0;Create;True;0;0;0;False;0;False;0;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;684;2304,-1216;Half;False;Property;_TopLayerSmoothnessMax;Top Layer Smoothness Max;19;0;Create;True;0;0;0;False;0;False;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;678;-3328,-1280;Half;False;Property;_BaseSmoothnessMin;Base Smoothness Min;5;0;Create;True;0;0;0;False;0;False;0;0.5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;683;-3328,-1184;Inherit;False;Property;_BaseSmoothnessMax;Base Smoothness Max;6;0;Create;True;0;0;0;False;0;False;1;2.5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;669;7552,-2944;Float;False;False;-1;3;AmplifyShaderEditor.MaterialInspector;0;4;New Amplify Shader;ed95fe726fd7b4644bb42f4d1ddd2bcd;True;ExtraPrePass;0;0;ExtraPrePass;6;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;False;True;3;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;DisableBatching=False=DisableBatching;True;3;False;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;670;7552,-2944;Half;False;True;-1;3;;0;4;ANGRYMESH/Stylized Pack/Props;ed95fe726fd7b4644bb42f4d1ddd2bcd;True;ForwardBase;0;1;ForwardBase;18;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;False;True;3;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;DisableBatching=False=DisableBatching;True;3;False;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;40;Workflow,InvertActionOnDeselection;1;0;Surface;0;0;  Blend;0;0;  Refraction Model;0;0;  Dither Shadows;1;0;Two Sided;1;0;Deferred Pass;1;0;Transmission;0;0;  Transmission Shadow;0.5,False,;0;Translucency;0;0;  Translucency Strength;1,True,_BaseSSSIntensity;0;  Normal Distortion;0.5,True,_BaseSSSNormalDistortion;0;  Scattering;2,True,_BaseSSSScattering;0;  Direct;0.9,True,_BaseSSSDirect;0;  Ambient;0.1,True,_BaseSSSAmbiet;0;  Shadow;0.5,True,_BaseSSSShadow;0;Cast Shadows;1;0;  Use Shadow Threshold;0;0;Receive Shadows;1;0;GPU Instancing;1;0;LOD CrossFade;1;0;Built-in Fog;1;0;Ambient Light;1;0;Meta Pass;1;0;Add Pass;1;0;Override Baked GI;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Fwd Specular Highlights Toggle;0;0;Fwd Reflections Toggle;0;0;Disable Batching;0;0;Vertex Position,InvertActionOnDeselection;1;0;0;6;False;True;True;True;True;True;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;671;7552,-2944;Float;False;False;-1;3;AmplifyShaderEditor.MaterialInspector;0;4;New Amplify Shader;ed95fe726fd7b4644bb42f4d1ddd2bcd;True;ForwardAdd;0;2;ForwardAdd;0;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;False;True;3;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;DisableBatching=False=DisableBatching;True;3;False;0;False;True;4;1;False;;1;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;True;1;LightMode=ForwardAdd;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;672;7552,-2944;Float;False;False;-1;3;AmplifyShaderEditor.MaterialInspector;0;4;New Amplify Shader;ed95fe726fd7b4644bb42f4d1ddd2bcd;True;Deferred;0;3;Deferred;0;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;False;True;3;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;DisableBatching=False=DisableBatching;True;3;False;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Deferred;True;3;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;673;7552,-2944;Float;False;False;-1;3;AmplifyShaderEditor.MaterialInspector;0;4;New Amplify Shader;ed95fe726fd7b4644bb42f4d1ddd2bcd;True;Meta;0;4;Meta;0;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;False;True;3;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;DisableBatching=False=DisableBatching;True;3;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;674;7552,-2944;Float;False;False;-1;3;AmplifyShaderEditor.MaterialInspector;0;4;New Amplify Shader;ed95fe726fd7b4644bb42f4d1ddd2bcd;True;ShadowCaster;0;5;ShadowCaster;0;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;False;True;3;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;DisableBatching=False=DisableBatching;True;3;False;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
WireConnection;355;0;352;0
WireConnection;398;0;396;5
WireConnection;406;0;402;0
WireConnection;407;0;408;0
WireConnection;407;1;406;0
WireConnection;407;2;409;0
WireConnection;396;1;397;0
WireConnection;414;0;411;0
WireConnection;414;1;415;0
WireConnection;411;1;412;0
WireConnection;411;5;413;0
WireConnection;394;0;392;0
WireConnection;394;1;393;0
WireConnection;395;0;394;0
WireConnection;432;0;430;5
WireConnection;432;1;433;5
WireConnection;464;0;476;0
WireConnection;464;1;432;0
WireConnection;464;2;466;0
WireConnection;467;0;464;0
WireConnection;439;0;436;0
WireConnection;439;1;440;0
WireConnection;438;0;439;0
WireConnection;438;1;436;0
WireConnection;438;2;442;0
WireConnection;443;0;477;0
WireConnection;443;1;438;0
WireConnection;443;2;469;0
WireConnection;470;0;443;0
WireConnection;499;0;500;0
WireConnection;499;1;685;0
WireConnection;499;2;501;0
WireConnection;584;0;499;0
WireConnection;502;0;584;0
WireConnection;483;0;482;0
WireConnection;483;2;484;0
WireConnection;486;0;483;0
WireConnection;514;0;513;0
WireConnection;514;2;515;0
WireConnection;516;0;514;0
WireConnection;507;0;506;0
WireConnection;507;2;508;0
WireConnection;509;0;507;0
WireConnection;496;1;495;0
WireConnection;436;1;437;0
WireConnection;436;5;435;0
WireConnection;430;1;431;0
WireConnection;558;0;448;0
WireConnection;459;0;453;0
WireConnection;459;1;456;0
WireConnection;461;0;455;0
WireConnection;461;1;457;0
WireConnection;460;0;454;0
WireConnection;460;1;458;0
WireConnection;548;0;649;0
WireConnection;548;1;549;0
WireConnection;537;0;535;0
WireConnection;537;1;536;0
WireConnection;541;0;539;5
WireConnection;544;0;647;0
WireConnection;545;1;546;0
WireConnection;545;0;544;0
WireConnection;427;0;426;0
WireConnection;427;1;429;0
WireConnection;428;0;427;0
WireConnection;446;1;356;0
WireConnection;446;0;420;0
WireConnection;421;1;319;0
WireConnection;421;0;419;0
WireConnection;475;0;446;0
WireConnection;474;0;421;0
WireConnection;473;1;475;0
WireConnection;473;0;471;0
WireConnection;489;1;490;0
WireConnection;489;0;488;0
WireConnection;503;1;380;0
WireConnection;503;0;504;0
WireConnection;510;1;511;0
WireConnection;510;0;512;0
WireConnection;472;1;474;0
WireConnection;472;0;468;0
WireConnection;520;0;472;0
WireConnection;523;0;473;0
WireConnection;526;0;510;0
WireConnection;524;0;489;0
WireConnection;525;0;503;0
WireConnection;517;1;518;0
WireConnection;517;0;519;0
WireConnection;527;0;517;0
WireConnection;343;1;344;0
WireConnection;352;1;353;0
WireConnection;352;5;354;0
WireConnection;357;1;358;0
WireConnection;416;0;414;0
WireConnection;402;0;403;0
WireConnection;402;1;400;0
WireConnection;410;0;407;0
WireConnection;547;0;551;0
WireConnection;649;22;558;2
WireConnection;649;24;459;0
WireConnection;649;23;460;0
WireConnection;649;25;461;0
WireConnection;462;0;650;0
WireConnection;650;0;548;0
WireConnection;650;1;657;0
WireConnection;650;2;666;0
WireConnection;658;0;343;5
WireConnection;658;1;659;0
WireConnection;661;0;658;0
WireConnection;661;1;660;0
WireConnection;350;0;345;0
WireConnection;345;0;661;0
WireConnection;345;1;481;5
WireConnection;400;0;398;0
WireConnection;400;1;401;0
WireConnection;647;0;541;0
WireConnection;647;1;543;0
WireConnection;539;1;537;0
WireConnection;551;1;546;0
WireConnection;551;0;545;0
WireConnection;664;1;662;1
WireConnection;664;2;663;0
WireConnection;665;0;664;0
WireConnection;371;0;357;4
WireConnection;370;0;369;0
WireConnection;370;1;373;0
WireConnection;375;0;370;0
WireConnection;375;1;376;0
WireConnection;377;0;375;0
WireConnection;341;0;339;0
WireConnection;341;1;340;0
WireConnection;342;0;341;0
WireConnection;373;0;372;0
WireConnection;373;1;374;0
WireConnection;365;1;357;3
WireConnection;365;2;367;0
WireConnection;362;0;357;2
WireConnection;362;1;363;0
WireConnection;348;0;365;0
WireConnection;364;0;362;0
WireConnection;361;0;570;0
WireConnection;675;0;357;1
WireConnection;685;0;681;0
WireConnection;685;1;684;0
WireConnection;685;2;496;1
WireConnection;679;0;678;0
WireConnection;679;1;683;0
WireConnection;679;2;676;0
WireConnection;570;0;679;0
WireConnection;670;0;522;0
WireConnection;670;1;529;0
WireConnection;670;2;530;0
WireConnection;670;4;531;0
WireConnection;670;5;532;0
WireConnection;670;6;533;0
ASEEND*/
//CHKSM=042F55017035EC1DD7E335ACE99C67F2239FBC07