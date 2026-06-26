// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Occluder_Cutout"
{
	Properties
	{
		_CutoutCameraWS("CutoutCameraWS", Vector) = (0,0,0,0)
		_CutoutAvatarWS("CutoutAvatarWS", Vector) = (0,0,0,0)
		_CutoutRadius("CutoutRadius", Range( 0 , 5)) = 1
		_CutoutFeather("CutoutFeather", Range( 0 , 1)) = 0.35
		_CutoutActive("CutoutActive", Float) = 0
		_RingWidth("RingWidth", Range( 0 , 1)) = 0.08
		_HoleAlpha("HoleAlpha ", Range( 0 , 1)) = 0
		_RingColor("RingColor", Color) = (0.09433961,0.0725347,0.0725347,0)
		_RingIntensity("RingIntensity", Range( 0 , 5)) = 1
		_CutoutEnd("CutoutEnd", Range( 0 , 1)) = 0
		_BaseColor("BaseColor", Color) = (0,0,0,0)
		_BaseTexture("BaseTexture", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float4 screenPosition;
		};

		uniform sampler2D _BaseTexture;
		uniform float4 _BaseTexture_ST;
		uniform float4 _BaseColor;
		uniform float _RingWidth;
		uniform float3 _CutoutCameraWS;
		uniform float3 _CutoutAvatarWS;
		uniform float _CutoutEnd;
		uniform float _CutoutRadius;
		uniform float _CutoutActive;
		uniform float _RingIntensity;
		uniform float4 _RingColor;
		uniform float _HoleAlpha;
		uniform float _CutoutFeather;


		inline float Dither8x8Bayer( int x, int y )
		{
			const float dither[ 64 ] = {
				 1, 49, 13, 61,  4, 52, 16, 64,
				33, 17, 45, 29, 36, 20, 48, 32,
				 9, 57,  5, 53, 12, 60,  8, 56,
				41, 25, 37, 21, 44, 28, 40, 24,
				 3, 51, 15, 63,  2, 50, 14, 62,
				35, 19, 47, 31, 34, 18, 46, 30,
				11, 59,  7, 55, 10, 58,  6, 54,
				43, 27, 39, 23, 42, 26, 38, 22};
			int r = y * 8 + x;
			return dither[r] / 64; // same # of instructions as pre-dividing due to compiler magic
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float4 ase_screenPos = ComputeScreenPos( UnityObjectToClipPos( v.vertex ) );
			o.screenPosition = ase_screenPos;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_BaseTexture = i.uv_texcoord * _BaseTexture_ST.xy + _BaseTexture_ST.zw;
			o.Albedo = ( tex2D( _BaseTexture, uv_BaseTexture ) * _BaseColor ).rgb;
			float3 ase_worldPos = i.worldPos;
			float3 CutoutCameraWS34 = _CutoutCameraWS;
			float3 temp_output_13_0 = ( _CutoutAvatarWS - _CutoutCameraWS );
			float dotResult18 = dot( ( ase_worldPos - _CutoutCameraWS ) , temp_output_13_0 );
			float dotResult21 = dot( temp_output_13_0 , temp_output_13_0 );
			float3 PlayerMinusCameraCutout36 = temp_output_13_0;
			float3 ClosestPoint38 = ( CutoutCameraWS34 + ( min( saturate( ( dotResult18 / max( dotResult21 , 0.001 ) ) ) , _CutoutEnd ) * PlayerMinusCameraCutout36 ) );
			float DistanceToLine41 = distance( ase_worldPos , ClosestPoint38 );
			float CutoutRadius62 = _CutoutRadius;
			float smoothstepResult65 = smoothstep( 0.0 , _RingWidth , abs( ( DistanceToLine41 - CutoutRadius62 ) ));
			float CutoutActive68 = _CutoutActive;
			float4 ase_screenPos = i.screenPosition;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 clipScreen76 = ase_screenPosNorm.xy * _ScreenParams.xy;
			float dither76 = Dither8x8Bayer( fmod(clipScreen76.x, 8), fmod(clipScreen76.y, 8) );
			o.Emission = ( ( ( ( ( 1.0 - smoothstepResult65 ) * CutoutActive68 ) * _RingIntensity ) * _RingColor ) * dither76 ).rgb;
			float OuterRadius43 = ( _CutoutRadius + _CutoutFeather );
			float smoothstepResult47 = smoothstep( _CutoutRadius , OuterRadius43 , DistanceToLine41);
			float CutoutSoftMask49 = smoothstepResult47;
			float lerpResult50 = lerp( _HoleAlpha , 1.0 , CutoutSoftMask49);
			float AlphaWhenActive54 = lerpResult50;
			float lerpResult55 = lerp( 1.0 , AlphaWhenActive54 , _CutoutActive);
			o.Alpha = lerpResult55;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows vertex:vertexDataFunc 

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
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 customPack2 : TEXCOORD2;
				float3 worldPos : TEXCOORD3;
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
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.customPack2.xyzw = customInputData.screenPosition;
				o.worldPos = worldPos;
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
				surfIN.screenPosition = IN.customPack2.xyzw;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
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
1;81;1920;880;-1072.006;272.9714;1.31029;True;False
Node;AmplifyShaderEditor.CommentaryNode;16;-2661.135,156.4096;Inherit;False;493.1454;384.8077;Este vector apunta desde la cámara hacia cada pixel de una pared.;4;12;14;1;34;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;17;-2645.135,620.4101;Inherit;False;475.7062;238.942;Este vector apunta desde la cámara hacia el player.;2;2;13;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;1;-2581.135,380.4096;Inherit;False;Property;_CutoutCameraWS;CutoutCameraWS;0;0;Create;True;0;0;0;False;0;False;0,0,0;0,2,-6;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;2;-2597.135,668.4102;Inherit;False;Property;_CutoutAvatarWS;CutoutAvatarWS;1;0;Create;True;0;0;0;False;0;False;0,0,0;0,1,-1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;22;-2117.143,620.4101;Inherit;False;272.3716;235.5403;Este nodo calcula el largo de la línea cámara-player al cuadrado.;3;21;25;24;Este nodo calcula el largo de la línea cámara-player al cuadrado.;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;12;-2581.135,236.4096;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;13;-2325.138,716.4103;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;20;-2117.143,316.4097;Inherit;False;269.8568;194.2202;En qué punto de la línea cámara-player cae el pixel de una pared.;1;18;En qué punto de la línea cámara-player cae el pixel de una pared.;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;21;-2069.143,668.4102;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-2069.143,764.4104;Inherit;False;Constant;_constanteMAX;constante MAX;7;0;Create;True;0;0;0;False;0;False;0.001;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;14;-2341.137,284.4097;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;24;-1941.145,668.4102;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;18;-2053.143,380.4096;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;75;-1445.145,268.4096;Inherit;False;492;298;Prevenimos que la parte detrás del player se le pase el efecto;2;74;73;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;26;-1685.145,380.4096;Inherit;False;215;161;0 = cam, 1= player;1;19;0 = punto más cercano a la cámara 1 = punto más cercano al player 0.5 = mitad del camino cámara-player;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;23;-1813.145,428.4098;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;19;-1637.145,428.4098;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;36;-2087.403,892.8994;Inherit;False;PlayerMinusCameraCutout;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-1429.144,476.4099;Inherit;False;Property;_CutoutEnd;CutoutEnd;9;0;Create;True;0;0;0;False;0;False;0;0.85;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;73;-1093.144,316.4097;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;37;-879.5093,576.9614;Inherit;False;36;PlayerMinusCameraCutout;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;34;-2357.137,428.4098;Inherit;False;CutoutCameraWS;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-566.9968,421.1236;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;35;-721.0075,233.7523;Inherit;False;34;CutoutCameraWS;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;44;-551.2894,943.0313;Inherit;False;727.9969;262.7679;Radio Exterior del Fade;4;4;42;3;43;Radio Exterior del Fade;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;-478.7687,269.2831;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-501.2895,1000.119;Inherit;False;Property;_CutoutRadius;CutoutRadius;2;0;Create;True;0;0;0;False;0;False;1;1.33;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-492.0173,1089.799;Inherit;False;Property;_CutoutFeather;CutoutFeather;3;0;Create;True;0;0;0;False;0;False;0.35;0.355;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;-352.7207,274.9801;Inherit;False;ClosestPoint;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;39;-349.2607,105.68;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;42;-178.2699,1034.031;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;40;-100.9113,238.4875;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;45;-553.2925,711.1964;Inherit;False;841;219;máscara suave del agujero;4;46;47;49;48;Máscara suave del agujero;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;41;40.79992,249.4889;Inherit;False;DistanceToLine;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;62;-211.0015,1226.568;Inherit;False;CutoutRadius;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;43;-30.29244,1032.196;Inherit;False;OuterRadius;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;63;354.9985,346.5682;Inherit;False;62;CutoutRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;-502.2926,753.1963;Inherit;False;41;DistanceToLine;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;-486.2926,840.1963;Inherit;False;43;OuterRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;60;345.8797,266.8368;Inherit;False;41;DistanceToLine;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;47;-111.2924,797.1963;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;59;1091.075,591.3228;Inherit;False;535.426;351.874;Activar o desactivar el efecto;5;55;5;57;56;68;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;61;675.2133,270.9598;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;53;329.7426,714.8173;Inherit;False;695.3358;338.0372;Crear alpha del agujero;5;50;51;54;52;6;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;5;1152.738,813.5246;Inherit;False;Property;_CutoutActive;CutoutActive;4;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;759.6138,385.6112;Inherit;False;Property;_RingWidth;RingWidth;5;0;Create;True;0;0;0;False;0;False;0.08;0.08;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;64;846.9985,283.5682;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;78.70753,815.1963;Inherit;False;CutoutSoftMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;379.7426,764.8173;Inherit;False;Property;_HoleAlpha;HoleAlpha ;6;0;Create;True;0;0;0;False;0;False;0;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;381.0784,853.8546;Inherit;False;Constant;_Cons1;Cons 1;10;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;68;1353.222,851.1513;Inherit;False;CutoutActive;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;366.0784,942.8546;Inherit;False;49;CutoutSoftMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;65;1042.999,273.5682;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;50;621.0784,771.8546;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;69;1478.223,381.5517;Inherit;False;68;CutoutActive;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;66;1299.653,283.5276;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;1697.263,397.0181;Inherit;False;Property;_RingIntensity;RingIntensity;8;0;Create;True;0;0;0;False;0;False;1;1.13;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;1681.156,284.2277;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;812.0784,772.8546;Inherit;False;AlphaWhenActive;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;57;1129.075,732.3223;Inherit;False;54;AlphaWhenActive;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;1165.075,641.3227;Inherit;False;Constant;_Float0;Float 0;10;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;84;1965.624,-80.3587;Inherit;True;Property;_BaseTexture;BaseTexture;12;0;Create;True;0;0;0;False;0;False;None;5cc960c3a338eef4eb00f9854eae4364;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.ColorNode;9;1973.872,407.7896;Inherit;False;Property;_RingColor;RingColor;7;0;Create;True;0;0;0;False;0;False;0.09433961,0.0725347,0.0725347,0;1,0.5167899,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;1955.076,290.2765;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;55;1375.075,699.3225;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;2214.904,305.6728;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DitheringNode;76;2352.585,451.2391;Inherit;False;1;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;83;2283.734,100.0015;Inherit;False;Property;_BaseColor;BaseColor;11;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;80;2234.268,-84.20235;Inherit;True;Property;_Texture;Texture;10;0;Create;True;0;0;0;False;0;False;-1;None;5cc960c3a338eef4eb00f9854eae4364;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;2530.775,365.5776;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;2614.133,36.02225;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;71;2061.754,723.5009;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2824.464,232.3325;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Occluder_Cutout;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;13;0;2;0
WireConnection;13;1;1;0
WireConnection;21;0;13;0
WireConnection;21;1;13;0
WireConnection;14;0;12;0
WireConnection;14;1;1;0
WireConnection;24;0;21;0
WireConnection;24;1;25;0
WireConnection;18;0;14;0
WireConnection;18;1;13;0
WireConnection;23;0;18;0
WireConnection;23;1;24;0
WireConnection;19;0;23;0
WireConnection;36;0;13;0
WireConnection;73;0;19;0
WireConnection;73;1;74;0
WireConnection;34;0;1;0
WireConnection;27;0;73;0
WireConnection;27;1;37;0
WireConnection;32;0;35;0
WireConnection;32;1;27;0
WireConnection;38;0;32;0
WireConnection;42;0;3;0
WireConnection;42;1;4;0
WireConnection;40;0;39;0
WireConnection;40;1;38;0
WireConnection;41;0;40;0
WireConnection;62;0;3;0
WireConnection;43;0;42;0
WireConnection;47;0;48;0
WireConnection;47;1;3;0
WireConnection;47;2;46;0
WireConnection;61;0;60;0
WireConnection;61;1;63;0
WireConnection;64;0;61;0
WireConnection;49;0;47;0
WireConnection;68;0;5;0
WireConnection;65;0;64;0
WireConnection;65;2;7;0
WireConnection;50;0;6;0
WireConnection;50;1;51;0
WireConnection;50;2;52;0
WireConnection;66;0;65;0
WireConnection;67;0;66;0
WireConnection;67;1;69;0
WireConnection;54;0;50;0
WireConnection;70;0;67;0
WireConnection;70;1;10;0
WireConnection;55;0;56;0
WireConnection;55;1;57;0
WireConnection;55;2;5;0
WireConnection;72;0;70;0
WireConnection;72;1;9;0
WireConnection;80;0;84;0
WireConnection;77;0;72;0
WireConnection;77;1;76;0
WireConnection;81;0;80;0
WireConnection;81;1;83;0
WireConnection;71;0;55;0
WireConnection;0;0;81;0
WireConnection;0;2;77;0
WireConnection;0;9;71;0
ASEEND*/
//CHKSM=5309E9C6C0938DDDFE2BB5E7EE5F30B49209148D