// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Edificio"
{
	Properties
	{
		_UVScale("UVScale", Vector) = (1,1,0,0)
		_BrickColorTex("BrickColorTex", 2D) = "white" {}
		_BrickAlbedo("BrickAlbedo", Color) = (0.3396226,0.2158052,0.1906372,0)
		_DirtTex("DirtTex", 2D) = "white" {}
		_DirtAlbedo("DirtAlbedo", Color) = (1,1,1,0)
		_DirtScale("DirtScale", Float) = 1
		_DirtSmoothStep("DirtSmoothStep", Range( 0 , 1)) = 0.5
		_LowBorderTex("LowBorderTex", 2D) = "white" {}
		_LowBorderAlbedo("LowBorderAlbedo", Color) = (1,1,1,0)
		_LowBorderTexScale("LowBorderTexScale", Vector) = (0,0,0,0)
		_LowBorderDistance("LowBorderDistance", Float) = 0
		_WindowMaskTex("WindowMaskTex", 2D) = "white" {}
		_WindowColor("WindowColor", Color) = (0.6048861,0.6271376,0.6509434,0)
		_InteriorWindowTex("InteriorWindowTex", 2D) = "white" {}
		_InteriorVisibility("InteriorVisibility", Range( 0 , 1)) = 0.2606635
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float3 viewDir;
		};

		uniform sampler2D _DirtTex;
		uniform float4 _DirtAlbedo;
		uniform float _DirtSmoothStep;
		uniform float _DirtScale;
		uniform float _LowBorderDistance;
		uniform sampler2D _WindowMaskTex;
		uniform float2 _UVScale;
		uniform sampler2D _BrickColorTex;
		uniform float4 _BrickAlbedo;
		uniform sampler2D _LowBorderTex;
		uniform float2 _LowBorderTexScale;
		uniform float4 _LowBorderAlbedo;
		uniform sampler2D _InteriorWindowTex;
		uniform float _InteriorVisibility;
		uniform float4 _WindowColor;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float2 appendResult136 = (float2(ase_worldPos.x , ase_worldPos.y));
			float2 appendResult193 = (float2(ase_worldPos.z , ase_worldPos.y));
			float2 DirtUVs187 = ( appendResult136 + appendResult193 );
			float simplePerlin2D5 = snoise( DirtUVs187*_DirtScale );
			simplePerlin2D5 = simplePerlin2D5*0.5 + 0.5;
			float smoothstepResult134 = smoothstep( _DirtSmoothStep , 1.0 , simplePerlin2D5);
			float clampResult135 = clamp( smoothstepResult134 , -1.0 , 1.0 );
			float DirtNoise13 = clampResult135;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float LowBorder27 = step( ase_vertex3Pos.y , _LowBorderDistance );
			float2 appendResult78 = (float2(ase_worldPos.x , ase_worldPos.y));
			float2 appendResult80 = (float2(ase_worldPos.z , ase_worldPos.y));
			float2 UVs61 = ( ( appendResult78 / _UVScale ) + ( appendResult80 / _UVScale ) );
			float WindowMask91 = step( tex2D( _WindowMaskTex, UVs61 ).r , 0.8 );
			float2 LowBorderScaledUVs12 = ( i.uv_texcoord / _LowBorderTexScale );
			float4 WallAlbedo98 = ( ( tex2D( _DirtTex, DirtUVs187 ) * _DirtAlbedo * DirtNoise13 * ( 1.0 - LowBorder27 ) * ( 1.0 - WindowMask91 ) ) + ( ( ( tex2D( _BrickColorTex, UVs61 ) * _BrickAlbedo * ( 1.0 - DirtNoise13 ) ) * ( 1.0 - LowBorder27 ) * ( 1.0 - WindowMask91 ) ) + ( LowBorder27 * ( tex2D( _LowBorderTex, LowBorderScaledUVs12 ) * _LowBorderAlbedo ) ) ) );
			float2 Offset108 = ( ( 0.5 - 1 ) * i.viewDir.xy * 0.5 ) + UVs61;
			float4 WindowAlbedo99 = ( WindowMask91 * saturate( ( ( tex2D( _InteriorWindowTex, Offset108 ) * _InteriorVisibility ) + ( _WindowColor * (0.5 + (sin( ( ( i.viewDir.x * i.viewDir.z * 6.28318548202515 ) * 5.0 ) ) - -1.0) * (0.7 - 0.5) / (1.0 - -1.0)) ) ) ) * ( 1.0 - LowBorder27 ) );
			float4 ALBEDO47 = ( WallAlbedo98 + WindowAlbedo99 );
			o.Albedo = ALBEDO47.rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

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
				float3 worldPos : TEXCOORD2;
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
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
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
908;73;562;602;1494.408;220.4519;4.922109;False;False
Node;AmplifyShaderEditor.CommentaryNode;185;-2438.949,-1460.819;Inherit;False;4416.025;3522.815;Comment;4;184;181;179;180;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;184;-2057.612,-1410.819;Inherit;False;3206.686;2291.31;Brick Albedo;21;4;15;28;140;45;46;98;188;189;13;135;134;5;187;2;191;137;192;193;136;195;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;183;-3616.821,75.03653;Inherit;False;965.6951;468.5852;UVs;9;79;77;68;80;78;81;60;82;61;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;77;-3565.076,125.0366;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;79;-3566.821,294.8449;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;137;-1986.086,-1230.584;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;192;-1988.849,-1083.734;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;136;-1818.954,-1209.654;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;80;-3323.802,408.6217;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;193;-1821.717,-1062.804;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;68;-3318.786,248.2657;Inherit;False;Property;_UVScale;UVScale;0;0;Create;True;0;0;0;False;0;False;1,1;10.59,8;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DynamicAppendNode;78;-3324.059,144.8135;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;60;-3150.203,178.339;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;4;-1659.187,-71.60306;Inherit;False;1785.337;944.786;Low Brick Border;5;43;14;10;48;67;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;81;-3156.005,362.4302;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;191;-1638.617,-1214.883;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-1510.594,-1093.231;Inherit;False;Property;_DirtScale;DirtScale;5;0;Create;True;0;0;0;False;0;False;1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;82;-3001.005,277.4303;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;48;-1587.809,480.0574;Inherit;False;645.6021;361.0231;Low Border UVs;3;12;9;6;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;195;-2038.849,-1290.749;Inherit;False;1517.885;390.0151;;1;196;DirtNoise;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;187;-1516.586,-1227.395;Inherit;False;DirtUVs;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;61;-2875.125,270.339;Inherit;False;UVs;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;5;-1315.66,-1228.379;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;179;-1124.495,955.8372;Inherit;False;1894.146;1064.108;Window Albedo;23;99;126;128;119;115;103;102;116;94;90;122;124;125;186;114;112;111;108;109;110;113;200;201;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;67;-1543.172,544.0115;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;181;-2388.949,982.4436;Inherit;False;1207.098;462.6238;Window Mask;5;96;86;87;88;91;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;196;-1340.548,-1007.593;Inherit;False;Property;_DirtSmoothStep;DirtSmoothStep;6;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;6;-1531.542,689.6151;Inherit;False;Property;_LowBorderTexScale;LowBorderTexScale;9;0;Create;True;0;0;0;False;0;False;0,0;1,0.1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;10;-1548.841,-29.86014;Inherit;False;876.1628;376.0577;Low Border Limit;4;27;22;17;16;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TauNode;201;-1005.819,1679.607;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;96;-2215.558,1259.817;Inherit;False;61;UVs;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;9;-1326.985,615.5442;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;134;-1068.56,-1231.449;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;110;-1063.944,1504.313;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexturePropertyNode;86;-2338.948,1030.265;Inherit;True;Property;_WindowMaskTex;WindowMaskTex;11;0;Create;True;0;0;0;False;0;False;None;1d7bcf945feff5a41bf626491be1c59c;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;122;-845.4648,1716.908;Inherit;False;Constant;_Float0;Float 0;13;0;Create;True;0;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1503.566,165.6711;Inherit;False;Property;_LowBorderDistance;LowBorderDistance;10;0;Create;True;0;0;0;False;0;False;0;-0.44;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;16;-1498.841,20.13986;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;124;-863.074,1581.416;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;87;-2021.882,1032.553;Inherit;True;Property;_TextureSample2;Texture Sample 2;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;14;-926.4003,387.364;Inherit;False;839.8816;455.6223;Low Border Color;7;33;31;29;26;24;20;18;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;12;-1195.94,611.5616;Inherit;False;LowBorderScaledUVs;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;135;-906.5851,-1240.749;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;20;-669.0513,640.9031;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;15;-1255.294,-705.6812;Inherit;False;1404.327;617.2109;Brick Base Color;13;143;39;54;37;107;38;25;32;30;106;21;65;19;;0.509434,0.4194198,0.3676575,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;109;-1017.66,1294.993;Inherit;False;61;UVs;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StepOpNode;88;-1714.7,1191.068;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;24;-876.4003,437.364;Inherit;True;Property;_LowBorderTex;LowBorderTex;7;0;Create;True;0;0;0;False;0;False;None;30829d5dd88841546aba2990deee25a0;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;13;-744.9641,-1232.124;Inherit;True;DirtNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;22;-1268.165,92.19799;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;113;-1074.495,1380.384;Inherit;False;Constant;_InteriorDepth;InteriorDepth;12;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;-668.0349,1623.731;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;19;-1205.295,-655.6809;Inherit;True;Property;_BrickColorTex;BrickColorTex;1;0;Create;True;0;0;0;False;0;False;None;a675b98d74bd99e4c88dd989b39bdcbd;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.ParallaxMappingNode;108;-805.1536,1309.122;Inherit;False;Normal;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;27;-1052.255,97.66288;Inherit;False;LowBorder;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;26;-537.7523,607.4084;Inherit;False;Property;_LowBorderAlbedo;LowBorderAlbedo;8;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;31;-599.7792,437.942;Inherit;True;Property;_TextureSample1;Texture Sample 1;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;28;-515.2607,-1367.222;Inherit;False;934.7296;605.4763;Dirt;9;44;139;141;41;42;40;66;138;34;;0.3867925,0.3090428,0.2682005,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;-1219.6,-444.9996;Inherit;False;61;UVs;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;111;-780.3967,1065.708;Inherit;True;Property;_InteriorWindowTex;InteriorWindowTex;13;0;Create;True;0;0;0;False;0;False;7b120c3c3229f1245b47281ba7c9b80b;7b120c3c3229f1245b47281ba7c9b80b;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SinOpNode;200;-559.2911,1813.071;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;91;-1405.851,1232.719;Inherit;False;WindowMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;21;-602.0095,-373.1054;Inherit;False;13;DirtNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;140;-358.2305,-819.1898;Inherit;False;91;WindowMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;32;-836.4925,-458.3841;Inherit;False;Property;_BrickAlbedo;BrickAlbedo;2;0;Create;True;0;0;0;False;0;False;0.3396226,0.2158052,0.1906372,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;34;-465.2608,-1317.222;Inherit;True;Property;_DirtTex;DirtTex;3;0;Create;True;0;0;0;False;0;False;None;ceb1bacd3e5dc9b4cb4b85eb1a74cfb6;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-248.5182,439.262;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;112;-528.4777,1276.885;Inherit;True;Property;_TextureSample4;Texture Sample 4;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;119;-450.2614,1599.952;Inherit;False;Property;_WindowColor;WindowColor;12;0;Create;True;0;0;0;False;0;False;0.6048861,0.6271376,0.6509434,0;0.6018156,0.6971342,0.7924528,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;138;-106.4913,-903.2647;Inherit;False;27;LowBorder;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;25;-907.5169,-655.572;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;115;-364.9168,1485.273;Inherit;False;Property;_InteriorVisibility;InteriorVisibility;14;0;Create;True;0;0;0;False;0;False;0.2606635;0.498;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;-405.7752,-1110.932;Inherit;False;187;DirtUVs;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;38;-380.098,-269.2975;Inherit;False;27;LowBorder;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;128;-361.96,1814.872;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0.5;False;4;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;30;-414.2454,-370.3794;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;106;-382.9142,-189.6308;Inherit;False;91;WindowMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;139;119.7928,-894.5638;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-240.4727,-654.954;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-170.9848,1283.901;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;107;-197.8968,-197.3362;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;54;-207.3443,-271.3026;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;126;-124.0466,1591.707;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;41;-161.5725,-1288.449;Inherit;True;Property;_TextureSample3;Texture Sample 3;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-9.088923,130.3925;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;141;106.5526,-831.1472;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;40;-88.45131,-1092.964;Inherit;False;Property;_DirtAlbedo;DirtAlbedo;4;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;42;111.6107,-1015.531;Inherit;False;13;DirtNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;132.3326,1422.369;Inherit;False;27;LowBorder;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;250.9935,-1243.031;Inherit;False;5;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;116;77.29527,1321.109;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;9.809033,-482.3989;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;189;375.5989,-51.04185;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;94;232.3509,1208.972;Inherit;False;91;WindowMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;45;453.982,-237.364;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;186;238.5704,1301.435;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;103;310.5967,1429.755;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;188;544.2192,-548.8731;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;625.1966,-303.9962;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;422.0259,1276.567;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;99;567.4017,1276.674;Inherit;False;WindowAlbedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;180;1292.893,257.7332;Inherit;False;634.183;316.4266;Final Albedo;4;100;101;97;47;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;98;946.4863,-302.2772;Inherit;False;WallAlbedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;101;1342.893,458.1595;Inherit;False;99;WindowAlbedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;100;1346.398,356.3522;Inherit;False;98;WallAlbedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;97;1572.511,339.0011;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;1703.077,307.7331;Inherit;False;ALBEDO;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;143;-1016.616,-397.2169;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;50;2689.834,435.8362;Inherit;False;47;ALBEDO;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;18;-569.8022,764.491;Inherit;False;13;DirtNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;29;-382.0382,767.2171;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2891.619,432.5418;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Edificio;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;136;0;137;1
WireConnection;136;1;137;2
WireConnection;80;0;79;3
WireConnection;80;1;79;2
WireConnection;193;0;192;3
WireConnection;193;1;192;2
WireConnection;78;0;77;1
WireConnection;78;1;77;2
WireConnection;60;0;78;0
WireConnection;60;1;68;0
WireConnection;81;0;80;0
WireConnection;81;1;68;0
WireConnection;191;0;136;0
WireConnection;191;1;193;0
WireConnection;82;0;60;0
WireConnection;82;1;81;0
WireConnection;187;0;191;0
WireConnection;61;0;82;0
WireConnection;5;0;187;0
WireConnection;5;1;2;0
WireConnection;9;0;67;0
WireConnection;9;1;6;0
WireConnection;134;0;5;0
WireConnection;134;1;196;0
WireConnection;124;0;110;1
WireConnection;124;1;110;3
WireConnection;124;2;201;0
WireConnection;87;0;86;0
WireConnection;87;1;96;0
WireConnection;12;0;9;0
WireConnection;135;0;134;0
WireConnection;20;0;12;0
WireConnection;88;0;87;1
WireConnection;13;0;135;0
WireConnection;22;0;16;2
WireConnection;22;1;17;0
WireConnection;125;0;124;0
WireConnection;125;1;122;0
WireConnection;108;0;109;0
WireConnection;108;1;113;0
WireConnection;108;2;113;0
WireConnection;108;3;110;0
WireConnection;27;0;22;0
WireConnection;31;0;24;0
WireConnection;31;1;20;0
WireConnection;200;0;125;0
WireConnection;91;0;88;0
WireConnection;33;0;31;0
WireConnection;33;1;26;0
WireConnection;112;0;111;0
WireConnection;112;1;108;0
WireConnection;25;0;19;0
WireConnection;25;1;65;0
WireConnection;128;0;200;0
WireConnection;30;0;21;0
WireConnection;139;0;138;0
WireConnection;37;0;25;0
WireConnection;37;1;32;0
WireConnection;37;2;30;0
WireConnection;114;0;112;0
WireConnection;114;1;115;0
WireConnection;107;0;106;0
WireConnection;54;0;38;0
WireConnection;126;0;119;0
WireConnection;126;1;128;0
WireConnection;41;0;34;0
WireConnection;41;1;66;0
WireConnection;43;0;27;0
WireConnection;43;1;33;0
WireConnection;141;0;140;0
WireConnection;44;0;41;0
WireConnection;44;1;40;0
WireConnection;44;2;42;0
WireConnection;44;3;139;0
WireConnection;44;4;141;0
WireConnection;116;0;114;0
WireConnection;116;1;126;0
WireConnection;39;0;37;0
WireConnection;39;1;54;0
WireConnection;39;2;107;0
WireConnection;189;0;43;0
WireConnection;45;0;39;0
WireConnection;45;1;189;0
WireConnection;186;0;116;0
WireConnection;103;0;102;0
WireConnection;188;0;44;0
WireConnection;46;0;188;0
WireConnection;46;1;45;0
WireConnection;90;0;94;0
WireConnection;90;1;186;0
WireConnection;90;2;103;0
WireConnection;99;0;90;0
WireConnection;98;0;46;0
WireConnection;97;0;100;0
WireConnection;97;1;101;0
WireConnection;47;0;97;0
WireConnection;143;0;65;0
WireConnection;29;0;18;0
WireConnection;0;0;50;0
ASEEND*/
//CHKSM=21551F40C3814446094FBF6C81E1F4D6A23823CD