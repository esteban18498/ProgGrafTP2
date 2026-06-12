// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SinCity_Effect"
{
	Properties
	{
		_ColorShadow_1("Color Shadow_1", Color) = (1,1,1,0)
		_ColorShadow_2("Color Shadow_2", Color) = (0,0,0,0)
		_NormalMap("Normal Map", 2D) = "white" {}
		_MetallicColor("Metallic Color", Color) = (0,0,0,0)
		_NonMetallicMetallic("NonMetallic/Metallic", Range( 0 , 1)) = 0
		_RoughnessMetallic("Roughness/Metallic", Range( 0 , 1)) = 0
		_MetallicTexture("Metallic Texture", 2D) = "white" {}
		_RoughnessTexture("Roughness Texture", 2D) = "white" {}
		_AmbienceOcclusion("Ambience Occlusion", 2D) = "white" {}
		_Shadow_Force_Step_1("Shadow_Force_Step_1", Range( 0 , 1)) = 0
		_Shadow_Force_Step_2("Shadow_Force_Step_2", Range( 0 , 1)) = 0
		_Shadow_Force_Step_3("Shadow_Force_Step_3", Range( 0 , 1)) = 0
		_Shadow_Force_Step_4("Shadow_Force_Step_4", Range( 0 , 1)) = 0
		_RimColor1("Rim Color", Color) = (1,1,1,0)
		_RimPower1("Rim Power", Range( 0 , 0.9)) = 0
		_RimOffset1("Rim Offset", Range( 0 , 1)) = 0.8
		_Rimcirclerange1("Rim circle range", Range( 0 , 2)) = 0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
			float2 uv_texcoord;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float4 _ColorShadow_1;
		uniform float4 _ColorShadow_2;
		uniform float _Shadow_Force_Step_1;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _Shadow_Force_Step_2;
		uniform float _Shadow_Force_Step_3;
		uniform float _Shadow_Force_Step_4;
		uniform sampler2D _MetallicTexture;
		uniform float4 _MetallicTexture_ST;
		uniform float4 _MetallicColor;
		uniform float _NonMetallicMetallic;
		uniform sampler2D _RoughnessTexture;
		uniform float4 _RoughnessTexture_ST;
		uniform float _RoughnessMetallic;
		uniform sampler2D _AmbienceOcclusion;
		uniform float4 _AmbienceOcclusion_ST;
		uniform float _Rimcirclerange1;
		uniform float _RimOffset1;
		uniform float _RimPower1;
		uniform float4 _RimColor1;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			SurfaceOutputStandard s144 = (SurfaceOutputStandard ) 0;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 NormalMap78 = UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) );
			float dotResult3 = dot( ase_worldlightDir , normalize( (WorldNormalVector( i , NormalMap78 )) ) );
			float Dot_Result_From_LightDir10 = dotResult3;
			float StepsShadow22 = ( ( step( (0.0 + (_Shadow_Force_Step_1 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) , Dot_Result_From_LightDir10 ) + step( (0.0 + (_Shadow_Force_Step_2 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) , Dot_Result_From_LightDir10 ) + step( (0.0 + (_Shadow_Force_Step_3 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) , Dot_Result_From_LightDir10 ) + step( (0.0 + (_Shadow_Force_Step_4 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) , Dot_Result_From_LightDir10 ) ) / 4.0 );
			float4 lerpResult131 = lerp( _ColorShadow_1 , _ColorShadow_2 , StepsShadow22);
			float2 uv_MetallicTexture = i.uv_texcoord * _MetallicTexture_ST.xy + _MetallicTexture_ST.zw;
			float4 MetallicTexture163 = tex2D( _MetallicTexture, uv_MetallicTexture );
			s144.Albedo = ( lerpResult131 + ( MetallicTexture163 * _MetallicColor ) ).rgb;
			s144.Normal = WorldNormalVector( i , NormalMap78 );
			s144.Emission = float3( 0,0,0 );
			s144.Metallic = ( MetallicTexture163 * _NonMetallicMetallic ).r;
			float2 uv_RoughnessTexture = i.uv_texcoord * _RoughnessTexture_ST.xy + _RoughnessTexture_ST.zw;
			float4 RoughnessTexture168 = tex2D( _RoughnessTexture, uv_RoughnessTexture );
			s144.Smoothness = ( ( MetallicTexture163 * RoughnessTexture168 ) * _RoughnessMetallic ).r;
			float2 uv_AmbienceOcclusion = i.uv_texcoord * _AmbienceOcclusion_ST.xy + _AmbienceOcclusion_ST.zw;
			float4 AmbienceOcclusion165 = tex2D( _AmbienceOcclusion, uv_AmbienceOcclusion );
			s144.Occlusion = ( AmbienceOcclusion165 * 0.0 ).r;

			data.light = gi.light;

			UnityGI gi144 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g144 = UnityGlossyEnvironmentSetup( s144.Smoothness, data.worldViewDir, s144.Normal, float3(0,0,0));
			gi144 = UnityGlobalIllumination( data, s144.Occlusion, s144.Normal, g144 );
			#endif

			float3 surfResult144 = LightingStandard ( s144, viewDir, gi144 ).rgb;
			surfResult144 += s144.Emission;

			#ifdef UNITY_PASS_FORWARDADD//144
			surfResult144 -= s144.Emission;
			#endif//144
			float3 AlbedoProperty86 = surfResult144;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			UnityGI gi98 = gi;
			float3 diffNorm98 = WorldNormalVector( i , NormalMap78 );
			gi98 = UnityGI_Base( data, 1, diffNorm98 );
			float3 indirectDiffuse98 = gi98.indirect.diffuse + diffNorm98 * 0.0001;
			float4 Lighting93 = ( float4( AlbedoProperty86 , 0.0 ) * ( ( ase_lightColor * ase_lightColor.a ) * float4( ( indirectDiffuse98 + ase_lightAtten ) , 0.0 ) ) );
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult60 = dot( ase_worldViewDir , normalize( (WorldNormalVector( i , NormalMap78 )) ) );
			float Dot_Result_From_ViewDir62 = dotResult60;
			float4 RimLight262 = ( saturate( step( 0.5 , ( 1.0 - ( ( Dot_Result_From_LightDir10 * 1.0 ) + _Rimcirclerange1 ) ) ) ) * pow( ( 1.0 - saturate( ( Dot_Result_From_ViewDir62 + _RimOffset1 ) ) ) , (0.0 + (_RimPower1 - 1.0) * (1.0 - 0.0) / (0.0 - 1.0)) ) * ( _RimColor1 * ase_lightColor ) );
			c.rgb = ( Lighting93 + RimLight262 ).rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows exclude_path:deferred 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
558;73;971;523;3765.639;633.1697;1.3;True;False
Node;AmplifyShaderEditor.CommentaryNode;81;-2573.303,-2418.268;Inherit;False;891.7764;280.295;Normal Map;3;76;78;77;Normal Map;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;76;-2523.303,-2368.063;Inherit;True;Property;_NormalMap;Normal Map;3;0;Create;True;0;0;0;False;0;False;None;691a95141f9d5804c9421cfa159a001f;True;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;77;-2249.13,-2367.973;Inherit;True;Property;_TextureSample2;Texture Sample 2;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;78;-1905.528,-2368.268;Inherit;False;NormalMap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;72;-2746.37,-1932.661;Inherit;False;1254.18;1137.74;DOT Results;4;63;36;79;80;DOT RESULTS;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;36;-2482.105,-1250.388;Inherit;False;679.609;385.1234;DOT Result from 'LightDir';4;10;3;2;52;DOT.LightDir;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;80;-2662.752,-1051.792;Inherit;False;78;NormalMap;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;2;-2420.351,-1048.265;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;52;-2447.259,-1201.196;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;3;-2198.354,-1129.154;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;57;90.83139,-1946.244;Inherit;False;1360.121;1172.11;Steps Calculation;19;27;53;5;26;20;17;54;55;9;16;11;13;14;4;56;18;12;21;22;Steps Calculation;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;10;-2049.457,-1134.748;Inherit;False;Dot_Result_From_LightDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;155.7086,-1339.289;Inherit;False;Property;_Shadow_Force_Step_3;Shadow_Force_Step_3;13;0;Create;True;0;0;0;False;0;False;0;0.6;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;140.8316,-1617.719;Inherit;False;Property;_Shadow_Force_Step_2;Shadow_Force_Step_2;12;0;Create;True;0;0;0;False;0;False;0;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;141.8216,-1896.245;Inherit;False;Property;_Shadow_Force_Step_1;Shadow_Force_Step_1;11;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;157.8236,-1064.674;Inherit;False;Property;_Shadow_Force_Step_4;Shadow_Force_Step_4;14;0;Create;True;0;0;0;False;0;False;0;0.9;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;17;504.6258,-1164.75;Inherit;False;10;Dot_Result_From_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;9;496.1117,-1891.394;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;16;499.3128,-1611.574;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;54;500.3348,-1058.507;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;13;435.5906,-1438.57;Inherit;False;10;Dot_Result_From_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;20;498.2208,-1333.124;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;11;504.7166,-1724.022;Inherit;False;10;Dot_Result_From_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;506.7398,-890.1337;Inherit;False;10;Dot_Result_From_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;14;707.6901,-1528.387;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;171;-2565.83,-3267.68;Inherit;False;884.832;280;Roughness;3;167;168;178;Roughness;1,1,1,1;0;0
Node;AmplifyShaderEditor.StepOpNode;56;704.7101,-977.3198;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;4;701.4891,-1815.208;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;18;702.597,-1251.937;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;173;-2571.468,-3696.343;Inherit;False;884.2592;281.031;Metallic;3;143;139;163;Metallic;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;79;-2687.049,-1577.365;Inherit;False;78;NormalMap;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;63;-2522.765,-1776.028;Inherit;False;758.8868;387.141;DOT Result from 'ViewDir';4;58;60;62;59;DOT.ViewDir;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;170;-2580.345,-2852.649;Inherit;False;863.8891;280.2124;Ambience Occlusion;3;149;165;148;Ambience Occlusion;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;12;897.6844,-1422.858;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;167;-2515.83,-3217.679;Inherit;True;Property;_RoughnessTexture;Roughness Texture;8;0;Create;True;0;0;0;False;0;False;None;d457772a9dc38af4bba55e37e1e0b22d;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;143;-2521.469,-3645.903;Inherit;True;Property;_MetallicTexture;Metallic Texture;7;0;Create;True;0;0;0;False;0;False;None;a129974b0dd69584785c700a1d6ed5be;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleDivideOpNode;21;1083.303,-1422.335;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;178;-2255.516,-3217.866;Inherit;True;Property;_TextureSample5;Texture Sample 5;18;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;148;-2530.345,-2802.437;Inherit;True;Property;_AmbienceOcclusion;Ambience Occlusion;9;0;Create;True;0;0;0;False;0;False;None;3a58d339adb709a4aa960402d59bd991;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;139;-2295.156,-3645.312;Inherit;True;Property;_TextureSample0;Texture Sample 0;13;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;59;-2472.765,-1571.887;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;58;-2460.064,-1726.028;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;168;-1928,-3216.722;Inherit;False;RoughnessTexture;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;149;-2295.009,-2802.648;Inherit;True;Property;_TextureSample4;Texture Sample 4;13;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;87;-1346.717,-3796.981;Inherit;False;1777.482;1715.409;Albedo;21;147;86;144;157;204;242;155;203;195;158;162;166;153;131;199;84;190;169;134;130;164;Albedo Property;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;60;-2226.707,-1650.288;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;105;-3849.009,-707.2736;Inherit;False;2361.457;984.9711;;20;280;279;278;277;276;275;274;273;272;271;270;269;268;267;266;265;264;263;262;261;Rim Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;163;-1915.209,-3646.343;Inherit;False;MetallicTexture;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;1232.546,-1427.271;Inherit;False;StepsShadow;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;84;-1170.19,-3702.188;Inherit;False;Property;_ColorShadow_1;Color Shadow_1;0;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;130;-1166.225,-3522.244;Inherit;False;Property;_ColorShadow_2;Color Shadow_2;1;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;62;-2044.877,-1655.842;Inherit;False;Dot_Result_From_ViewDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;169;-1165.613,-2547.587;Inherit;False;168;RoughnessTexture;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;164;-1150.359,-2756.947;Inherit;False;163;MetallicTexture;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;199;-1157.469,-3240.232;Inherit;False;163;MetallicTexture;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;261;-3738.678,-620.6865;Inherit;False;10;Dot_Result_From_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;190;-1161.124,-3162.614;Inherit;False;Property;_MetallicColor;Metallic Color;4;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;134;-1149.107,-3345.881;Inherit;False;22;StepsShadow;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;165;-1969.457,-2802.649;Inherit;False;AmbienceOcclusion;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;203;-1199.769,-2251.85;Inherit;False;Constant;_Occlusion;Occlusion;18;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;162;-878.4374,-2653.142;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;263;-3508.325,-151.4732;Float;False;Property;_RimOffset1;Rim Offset;17;0;Create;True;0;0;0;False;0;False;0.8;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;195;-942.1466,-3211.318;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;131;-819.9942,-3388.511;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;153;-1218.596,-2668.639;Inherit;False;Property;_NonMetallicMetallic;NonMetallic/Metallic;5;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;264;-3501.169,-260.403;Inherit;False;62;Dot_Result_From_ViewDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;166;-1159.57,-2336.809;Inherit;False;165;AmbienceOcclusion;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;158;-1217.177,-2461.095;Inherit;False;Property;_RoughnessMetallic;Roughness/Metallic;6;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;265;-3454.889,-590.2626;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;104;-1320.42,-1082.913;Inherit;False;1232.484;846.561;Light section;10;93;92;103;90;102;94;98;91;100;99;Light section;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;266;-3593.851,-453.4368;Inherit;False;Property;_Rimcirclerange1;Rim circle range;18;0;Create;True;0;0;0;False;0;False;0.5;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;155;-877.567,-2804.698;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;204;-799.9339,-2316.065;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;268;-3287.398,-531.2664;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;242;-562.8008,-3305.951;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;157;-726.5453,-2576.62;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;147;-1138.199,-2907.538;Inherit;False;78;NormalMap;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;-1273.289,-601.0381;Inherit;False;78;NormalMap;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;267;-3192.498,-229.8342;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;270;-3107.404,-531.0272;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;100;-1062.289,-508.0381;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomStandardSurface;144;-155.7931,-2921.547;Inherit;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;271;-3165.667,-85.00558;Float;False;Property;_RimPower1;Rim Power;16;0;Create;True;0;0;0;False;0;False;0;0;0;0.9;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;91;-1076.022,-794.5652;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.IndirectDiffuseLighting;98;-1086.289,-596.0381;Inherit;False;Tangent;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;269;-3034.495,-230.8342;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;276;-2875.068,-629.7045;Inherit;True;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;275;-2519.086,103.5454;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.ColorNode;274;-2564.571,-75.43184;Float;False;Property;_RimColor1;Rim Color;15;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;273;-2842.18,-79.38655;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;272;-2856.495,-231.8342;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;-893.5231,-795.0208;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;102;-831.2897,-572.0381;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;86;130.4454,-2927.268;Inherit;False;AlbedoProperty;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;279;-2611.439,-232.6629;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;278;-2617.804,-519.4742;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;277;-2342.634,-2.01678;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;-687.2897,-702.0381;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;90;-735.7533,-919.5836;Inherit;False;86;AlbedoProperty;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;280;-2084.506,-254.0127;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-503.0221,-831.5649;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;93;-332.022,-835.5649;Inherit;False;Lighting;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;262;-1812.522,-252.7122;Inherit;False;RimLight;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;75;447.5252,-279.2809;Inherit;False;93;Lighting;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;124;447.2263,-104.9013;Inherit;False;262;RimLight;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;71;-1391.381,-1746.926;Inherit;False;1351.851;511.1436;Ramp;5;73;70;29;74;30;Ramp - Shadow;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;175;-2578.835,-4093.117;Inherit;False;948.7377;280.2761;Albedo;3;83;145;82;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;145;-1843.246,-4027.679;Inherit;False;AlbedoTexture;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;82;-2255.941,-4028.216;Inherit;True;Property;_TextureSample3;Texture Sample 3;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;74;-728.0057,-1493.164;Inherit;True;Property;_TextureSample1;Texture Sample 1;9;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;73;-1047.725,-1674.984;Inherit;True;Property;_RampTexture;Ramp Texture;10;0;Create;True;0;0;0;False;0;False;None;c92f04f3c507cb649aedb4ba2ff262d1;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TFHCRemapNode;29;-1002.768,-1463.651;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;30;-1335.955,-1468.522;Inherit;False;10;Dot_Result_From_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;70;-280.9867,-1494.063;Inherit;False;RampShadow;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;83;-2516.982,-4027.94;Inherit;True;Property;_Albedo;Albedo;2;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleAddOpNode;123;629.5434,-179.7608;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;859.8737,-511.988;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;SinCity_Effect;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;2;False;-1;3;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0.005;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;77;0;76;0
WireConnection;78;0;77;0
WireConnection;2;0;80;0
WireConnection;3;0;52;0
WireConnection;3;1;2;0
WireConnection;10;0;3;0
WireConnection;9;0;5;0
WireConnection;16;0;26;0
WireConnection;54;0;53;0
WireConnection;20;0;27;0
WireConnection;14;0;16;0
WireConnection;14;1;13;0
WireConnection;56;0;54;0
WireConnection;56;1;55;0
WireConnection;4;0;9;0
WireConnection;4;1;11;0
WireConnection;18;0;20;0
WireConnection;18;1;17;0
WireConnection;12;0;4;0
WireConnection;12;1;14;0
WireConnection;12;2;18;0
WireConnection;12;3;56;0
WireConnection;21;0;12;0
WireConnection;178;0;167;0
WireConnection;139;0;143;0
WireConnection;59;0;79;0
WireConnection;168;0;178;0
WireConnection;149;0;148;0
WireConnection;60;0;58;0
WireConnection;60;1;59;0
WireConnection;163;0;139;0
WireConnection;22;0;21;0
WireConnection;62;0;60;0
WireConnection;165;0;149;0
WireConnection;162;0;164;0
WireConnection;162;1;169;0
WireConnection;195;0;199;0
WireConnection;195;1;190;0
WireConnection;131;0;84;0
WireConnection;131;1;130;0
WireConnection;131;2;134;0
WireConnection;265;0;261;0
WireConnection;155;0;164;0
WireConnection;155;1;153;0
WireConnection;204;0;166;0
WireConnection;204;1;203;0
WireConnection;268;0;265;0
WireConnection;268;1;266;0
WireConnection;242;0;131;0
WireConnection;242;1;195;0
WireConnection;157;0;162;0
WireConnection;157;1;158;0
WireConnection;267;0;264;0
WireConnection;267;1;263;0
WireConnection;270;0;268;0
WireConnection;144;0;242;0
WireConnection;144;1;147;0
WireConnection;144;3;155;0
WireConnection;144;4;157;0
WireConnection;144;5;204;0
WireConnection;98;0;99;0
WireConnection;269;0;267;0
WireConnection;276;1;270;0
WireConnection;273;0;271;0
WireConnection;272;0;269;0
WireConnection;94;0;91;0
WireConnection;94;1;91;2
WireConnection;102;0;98;0
WireConnection;102;1;100;0
WireConnection;86;0;144;0
WireConnection;279;0;272;0
WireConnection;279;1;273;0
WireConnection;278;0;276;0
WireConnection;277;0;274;0
WireConnection;277;1;275;0
WireConnection;103;0;94;0
WireConnection;103;1;102;0
WireConnection;280;0;278;0
WireConnection;280;1;279;0
WireConnection;280;2;277;0
WireConnection;92;0;90;0
WireConnection;92;1;103;0
WireConnection;93;0;92;0
WireConnection;262;0;280;0
WireConnection;145;0;82;0
WireConnection;82;0;83;0
WireConnection;74;0;73;0
WireConnection;74;1;29;0
WireConnection;29;0;30;0
WireConnection;70;0;74;0
WireConnection;123;0;75;0
WireConnection;123;1;124;0
WireConnection;0;13;123;0
ASEEND*/
//CHKSM=C0FCDF2E29AA256BA4CD76CC74E3A334798808A8