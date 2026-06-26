// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Rotate_Effect"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		
		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255

		_ColorMask ("Color Mask", Float) = 15

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
		[NoScaleOffset]_RotateMask("Rotate Mask", 2D) = "white" {}
		_ColorTint("Color Tint", Color) = (1,0,0,1)
		_BaseTexture("BaseTexture", 2D) = "bump" {}
		_PosScale("PosScale", Vector) = (0,0,2,1)
		_KnobTexture("KnobTexture", 2D) = "white" {}
		_MaskIntensity("MaskIntensity", Float) = 6
		_MaskPower("MaskPower", Float) = 4
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }
		
		Stencil
		{
			Ref [_Stencil]
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
			CompFront [_StencilComp]
			PassFront [_StencilOp]
			FailFront Keep
			ZFailFront Keep
			CompBack Always
			PassBack Keep
			FailBack Keep
			ZFailBack Keep
		}


		Cull Off
		Lighting Off
		ZWrite Off
		ZTest [unity_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]

		
		Pass
		{
			Name "Default"
		CGPROGRAM
			
			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"

			#pragma multi_compile __ UNITY_UI_CLIP_RECT
			#pragma multi_compile __ UNITY_UI_ALPHACLIP
			
			#include "UnityShaderVariables.cginc"

			
			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				half2 texcoord  : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				
			};
			
			uniform fixed4 _Color;
			uniform fixed4 _TextureSampleAdd;
			uniform float4 _ClipRect;
			uniform sampler2D _MainTex;
			uniform sampler2D _BaseTexture;
			uniform float4 _PosScale;
			uniform sampler2D _RotateMask;
			uniform float4 _ColorTint;
			uniform sampler2D _KnobTexture;
			uniform float4 _KnobTexture_ST;
			uniform float _MaskPower;
			uniform float _MaskIntensity;

			
			v2f vert( appdata_t IN  )
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID( IN );
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
				OUT.worldPosition = IN.vertex;
				
				
				OUT.worldPosition.xyz +=  float3( 0, 0, 0 ) ;
				OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

				OUT.texcoord = IN.texcoord;
				
				OUT.color = IN.color * _Color;
				return OUT;
			}

			fixed4 frag(v2f IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				float4 temp_output_57_0_g3 = _PosScale;
				float2 temp_output_2_0_g3 = (temp_output_57_0_g3).zw;
				float2 temp_cast_0 = (1.0).xx;
				float2 temp_output_13_0_g3 = ( ( ( IN.texcoord.xy + (temp_output_57_0_g3).xy ) * temp_output_2_0_g3 ) + -( ( temp_output_2_0_g3 - temp_cast_0 ) * 0.5 ) );
				float TimeVar197_g3 = _Time.y;
				float cos17_g3 = cos( TimeVar197_g3 );
				float sin17_g3 = sin( TimeVar197_g3 );
				float2 rotator17_g3 = mul( temp_output_13_0_g3 - float2( 0.5,0.5 ) , float2x2( cos17_g3 , -sin17_g3 , sin17_g3 , cos17_g3 )) + float2( 0.5,0.5 );
				float4 tex2DNode97_g3 = tex2D( _BaseTexture, rotator17_g3 );
				float temp_output_115_0_g3 = step( ( (temp_output_13_0_g3).y + -0.5 ) , 0.0 );
				float lerpResult125_g3 = lerp( 1.0 , tex2D( _RotateMask, IN.texcoord.xy ).g , ( 1.0 - temp_output_115_0_g3 ));
				float4 ColorTint13 = _ColorTint;
				float4 break74 = ( ( tex2DNode97_g3 * lerpResult125_g3 * tex2DNode97_g3.a ) * ColorTint13 );
				float2 uv_KnobTexture = IN.texcoord.xy * _KnobTexture_ST.xy + _KnobTexture_ST.zw;
				float4 KnobTextureColor90 = tex2D( _KnobTexture, uv_KnobTexture );
				float3 desaturateInitialColor34 = KnobTextureColor90.rgb;
				float desaturateDot34 = dot( desaturateInitialColor34, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar34 = lerp( desaturateInitialColor34, desaturateDot34.xxx, 0.0 );
				float3 temp_cast_2 = (_MaskPower).xxx;
				float3 temp_output_35_0 = step( float3( 0.001,1,1 ) , pow( desaturateVar34 , temp_cast_2 ) );
				float4 KnobMask32 = ( ( KnobTextureColor90 * float4( temp_output_35_0 , 0.0 ) ) * float4( ( temp_output_35_0 * _MaskIntensity ) , 0.0 ) );
				float4 appendResult75 = (float4(break74.r , break74.g , break74.b , ( break74.a * KnobMask32 ).r));
				float4 RotateEffect16 = appendResult75;
				
				half4 color = RotateEffect16;
				
				#ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif
				
				#ifdef UNITY_UI_ALPHACLIP
				clip (color.a - 0.001);
				#endif

				return color;
			}
		ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18900
826;73;708;546;441.1285;-152.2945;1;False;False
Node;AmplifyShaderEditor.TexturePropertyNode;29;-2073.994,822.2728;Inherit;True;Property;_KnobTexture;KnobTexture;12;0;Create;True;0;0;0;False;0;False;5228a04ef529d2641937cab585cc1a02;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;65;-1806.089,822.661;Inherit;True;Property;_TextureSample1;Texture Sample 1;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;90;-1491.298,821.6194;Inherit;False;KnobTextureColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;-2209.308,1282.926;Inherit;False;90;KnobTextureColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-1950.18,1399.512;Inherit;False;Property;_MaskPower;MaskPower;15;0;Create;True;0;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DesaturateOpNode;34;-1963.07,1288.406;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;80;-1748.741,1314.624;Inherit;False;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;4;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;91;-1580.842,1156.262;Inherit;False;90;KnobTextureColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;10;-2727.224,564.1908;Inherit;False;Property;_ColorTint;Color Tint;7;0;Create;True;0;0;0;False;0;False;1,0,0,1;1,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;83;-1519.025,1522.589;Inherit;False;Property;_MaskIntensity;MaskIntensity;14;0;Create;True;0;0;0;False;0;False;6;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;35;-1540.92,1291.221;Inherit;False;2;0;FLOAT3;0.001,1,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;1;-2181.622,365.3479;Inherit;True;Property;_BaseTexture;BaseTexture;9;0;Create;True;0;0;0;False;0;False;302951faffe230848aa0d3df7bb70faa;302951faffe230848aa0d3df7bb70faa;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-1331.198,1163.292;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;2;-1921.965,271.1764;Inherit;False;BaseTexture;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;13;-2481.475,563.5168;Inherit;False;ColorTint;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-1330.836,1423.113;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;-1070.622,1313.832;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;17;-1337.56,270.2467;Inherit;False;13;ColorTint;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;25;-1345.96,350.5804;Inherit;False;2;BaseTexture;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.Vector4Node;15;-1327.839,431.9528;Inherit;False;Property;_PosScale;PosScale;11;0;Create;True;0;0;0;False;0;False;0,0,2,1;0,-0.08,1,3;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-883.1923,1308.819;Inherit;False;KnobMask;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;18;-1115.604,330.9877;Inherit;True;UI-Sprite Effect Layer;0;;3;789bf62641c5cfe4ab7126850acc22b8;18,74,2,204,2,191,1,225,0,242,0,237,0,249,0,186,0,177,0,182,0,229,0,92,1,98,1,234,0,126,0,129,1,130,1,31,0;18;192;COLOR;0,0,0,1;False;39;COLOR;1,1,1,1;False;37;SAMPLER2D;;False;218;FLOAT2;0,0;False;239;FLOAT2;0,0;False;181;FLOAT2;0,0;False;75;SAMPLER2D;;False;80;FLOAT;1;False;183;FLOAT2;0,0;False;188;SAMPLER2D;;False;33;SAMPLER2D;;False;248;FLOAT2;0,0;False;233;SAMPLER2D;;False;101;SAMPLER2D;;False;57;FLOAT4;0,0,0,0;False;40;FLOAT;0;False;231;FLOAT;1;False;30;FLOAT;1;False;2;COLOR;0;FLOAT2;172
Node;AmplifyShaderEditor.GetLocalVarNode;87;-803.2473,511.9153;Inherit;False;32;KnobMask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;74;-773.9213,332.2097;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;-586.7137,469.4772;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;75;-385.6652,331.2378;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-40.9903,328.0148;Inherit;False;RotateEffect;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;104;-1194.015,-943.6443;Inherit;False;BaseTextureDistortionColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;-1600.13,363.688;Inherit;False;BaseTextureColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;109;-1499.601,-1173.564;Inherit;False;2;0;FLOAT;0.02;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;120;-1363.829,135.1244;Inherit;False;114;DistortionMask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;110;-1640.893,-1315.25;Inherit;False;104;BaseTextureDistortionColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;94;-1925.529,-390.0461;Inherit;False;Property;_DistortionAmount;DistortionAmount;13;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;107;-2113.303,-673.9174;Inherit;False;105;BaseTextureDistortion;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;106;-1988.111,-1152.77;Inherit;False;104;BaseTextureDistortionColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;114;-1087.532,-1269.637;Inherit;False;DistortionMask;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;103;-1523.602,-942.9001;Inherit;True;Property;_TextureSample2;Texture Sample 2;17;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LuminanceNode;108;-1700.293,-1148.475;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;113;-1594.143,-667.584;Inherit;True;UI-Sprite Effect Layer;0;;1;789bf62641c5cfe4ab7126850acc22b8;18,74,0,204,0,191,0,225,1,242,0,237,0,249,0,186,0,177,1,182,1,229,0,92,0,98,0,234,0,126,0,129,1,130,0,31,0;18;192;COLOR;1,1,1,1;False;39;COLOR;1,1,1,1;False;37;SAMPLER2D;;False;218;FLOAT2;0,0;False;239;FLOAT2;0,0;False;181;FLOAT2;-1,0;False;75;SAMPLER2D;;False;80;FLOAT;1;False;183;FLOAT2;-0.7,0;False;188;SAMPLER2D;;False;33;SAMPLER2D;;False;248;FLOAT2;0,0;False;233;SAMPLER2D;;False;101;SAMPLER2D;;False;57;FLOAT4;0,0,0,0;False;40;FLOAT;0;False;231;FLOAT;1;False;30;FLOAT;1;False;2;COLOR;0;FLOAT2;172
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;119;-1103.448,89.63245;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;115;-1169.094,-672.455;Inherit;False;DistortionEffect;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;19;-2739.957,347.5731;Inherit;True;Property;_RotateTexture;RotateTexture;10;0;Create;True;0;0;0;False;0;False;a99649a3ac7df724eb781c969383e632;a99649a3ac7df724eb781c969383e632;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;112;-1350.842,-1264.216;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;105;-1516.921,-1030.629;Inherit;False;BaseTextureDistortion;-1;True;1;0;SAMPLER2D;0;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;116;-1863.448,-481.9455;Inherit;False;2;BaseTexture;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-2499.943,346.6305;Inherit;False;RotateTexture;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;197.3353,216.6258;Inherit;False;16;RotateEffect;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;21;-1925.62,363.8512;Inherit;True;Property;_TextureSample0;Texture Sample 0;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;30;-1803.191,718.2662;Inherit;False;KnobTexture;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;95;-1789.61,-941.5552;Inherit;True;Property;_DistortionTexture;DistortionTexture;8;0;Create;True;0;0;0;False;0;False;36be8d528a4fa024faa4680d7658642c;36be8d528a4fa024faa4680d7658642c;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;118;-1368.323,46.52428;Inherit;False;115;DistortionEffect;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;111;-1875.305,-609.8272;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;121;-226.3158,280.9102;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;464.7993,223.327;Float;False;True;-1;2;ASEMaterialInspector;0;6;Rotate_Effect;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;True;-9;False;False;False;False;False;False;False;True;True;0;True;-5;255;True;-8;255;True;-7;0;True;-4;0;True;-6;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;0;True;-11;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;65;0;29;0
WireConnection;90;0;65;0
WireConnection;34;0;92;0
WireConnection;80;0;34;0
WireConnection;80;1;89;0
WireConnection;35;1;80;0
WireConnection;38;0;91;0
WireConnection;38;1;35;0
WireConnection;2;0;1;0
WireConnection;13;0;10;0
WireConnection;82;0;35;0
WireConnection;82;1;83;0
WireConnection;88;0;38;0
WireConnection;88;1;82;0
WireConnection;32;0;88;0
WireConnection;18;39;17;0
WireConnection;18;37;25;0
WireConnection;18;57;15;0
WireConnection;74;0;18;0
WireConnection;76;0;74;3
WireConnection;76;1;87;0
WireConnection;75;0;74;0
WireConnection;75;1;74;1
WireConnection;75;2;74;2
WireConnection;75;3;76;0
WireConnection;16;0;75;0
WireConnection;104;0;103;0
WireConnection;23;0;21;0
WireConnection;109;1;108;0
WireConnection;114;0;112;0
WireConnection;103;0;95;0
WireConnection;108;0;106;0
WireConnection;113;37;107;0
WireConnection;113;218;111;0
WireConnection;113;75;116;0
WireConnection;113;80;94;0
WireConnection;119;0;118;0
WireConnection;119;1;120;0
WireConnection;115;0;113;0
WireConnection;112;0;110;0
WireConnection;112;1;109;0
WireConnection;105;0;95;0
WireConnection;24;0;19;0
WireConnection;21;0;1;0
WireConnection;30;0;29;0
WireConnection;111;2;107;0
WireConnection;0;0;20;0
ASEEND*/
//CHKSM=9C77A3FC732C697DA749BE9DCDFADA2311AFA068