// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Flow_Effect"
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
		_BaseTexture("BaseTexture", 2D) = "white" {}
		_ColorTint("Color Tint", Color) = (1,0,0,1)
		_FlowLineTexture("FlowLineTexture", 2D) = "white" {}
		_Ramp("Ramp", 2D) = "white" {}
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
			uniform sampler2D _Ramp;
			uniform sampler2D _FlowLineTexture;
			uniform float4 _FlowLineTexture_ST;
			uniform float4 _ColorTint;
			uniform sampler2D _BaseTexture;
			uniform float4 _BaseTexture_ST;
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

				float2 uv_FlowLineTexture = IN.texcoord.xy * _FlowLineTexture_ST.xy + _FlowLineTexture_ST.zw;
				float4 tex2DNode14_g2 = tex2D( _FlowLineTexture, uv_FlowLineTexture );
				float2 appendResult20_g2 = (float2(tex2DNode14_g2.r , tex2DNode14_g2.g));
				float TimeVar197_g2 = _Time.y;
				float2 temp_cast_0 = (TimeVar197_g2).xx;
				float2 temp_output_18_0_g2 = ( appendResult20_g2 - temp_cast_0 );
				float4 tex2DNode72_g2 = tex2D( _Ramp, temp_output_18_0_g2 );
				float4 ColorTint10 = _ColorTint;
				float2 uv_BaseTexture = IN.texcoord.xy * _BaseTexture_ST.xy + _BaseTexture_ST.zw;
				float4 BaseTextureColor15 = tex2D( _BaseTexture, uv_BaseTexture );
				float4 temp_output_192_0_g2 = BaseTextureColor15;
				float4 break38 = ( ( ( tex2DNode72_g2 * tex2DNode14_g2.a ) * ColorTint10 ) + temp_output_192_0_g2 );
				float3 desaturateInitialColor30 = BaseTextureColor15.rgb;
				float desaturateDot30 = dot( desaturateInitialColor30, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar30 = lerp( desaturateInitialColor30, desaturateDot30.xxx, 0.0 );
				float3 temp_cast_2 = (_MaskPower).xxx;
				float3 temp_output_33_0 = step( float3( 0.001,1,1 ) , pow( desaturateVar30 , temp_cast_2 ) );
				float4 BaseTextureMask25 = ( ( BaseTextureColor15 * float4( temp_output_33_0 , 0.0 ) ) * float4( ( temp_output_33_0 * _MaskIntensity ) , 0.0 ) );
				float4 appendResult40 = (float4(break38.r , break38.g , break38.b , ( break38.a * BaseTextureMask25 ).r));
				float4 FlowEffect3 = saturate( appendResult40 );
				
				half4 color = FlowEffect3;
				
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
826;73;708;546;154.9503;84.87708;1;False;False
Node;AmplifyShaderEditor.TexturePropertyNode;13;-1834.114,-493.5771;Inherit;True;Property;_BaseTexture;BaseTexture;7;0;Create;True;0;0;0;False;0;False;8ad4fab1bf3947d4c9e189afd00d307d;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;14;-1570.609,-493.5771;Inherit;True;Property;_TextureSample0;Texture Sample 0;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;-1250.138,-495.918;Inherit;False;BaseTextureColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;18;-1606.984,-1109.239;Inherit;False;15;BaseTextureColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-1340.831,-991.5941;Inherit;False;Property;_MaskPower;MaskPower;12;0;Create;True;0;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DesaturateOpNode;30;-1353.721,-1102.7;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;32;-1139.392,-1076.482;Inherit;False;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;4;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StepOpNode;33;-931.5708,-1099.885;Inherit;False;2;0;FLOAT3;0.001,1,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;11;-1811.015,-92.38002;Inherit;True;Property;_FlowLineTexture;FlowLineTexture;9;0;Create;True;0;0;0;False;0;False;7071609c253e9504c8a649c64fc24d08;5228a04ef529d2641937cab585cc1a02;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;23;-983.1254,-1276.413;Inherit;False;15;BaseTextureColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-909.6758,-868.5178;Inherit;False;Property;_MaskIntensity;MaskIntensity;11;0;Create;True;0;0;0;False;0;False;6;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;9;-1800.796,119.8432;Inherit;False;Property;_ColorTint;Color Tint;8;0;Create;True;0;0;0;False;0;False;1,0,0,1;1,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-721.4868,-967.9932;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;10;-1555.051,119.1693;Inherit;False;ColorTint;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;1;-1268.828,-265.9156;Inherit;False;1822.692;933.4572;FlowSection;12;41;3;42;40;39;26;38;5;4;17;2;7;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-721.8488,-1227.814;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;8;-1573.172,-92.589;Inherit;False;FlowLineTexture;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;7;-1175.131,85.13734;Inherit;False;10;ColorTint;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;2;-1194.251,364.237;Inherit;False;8;FlowLineTexture;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;17;-1215.704,-13.30159;Inherit;False;15;BaseTextureColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-461.2722,-1077.274;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;4;-1213.275,169.9736;Inherit;True;Property;_Ramp;Ramp;10;0;Create;True;0;0;0;False;0;False;131633c45b26caa4f9673a16077a1970;131633c45b26caa4f9673a16077a1970;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.FunctionNode;5;-869.6163,80.82416;Inherit;True;UI-Sprite Effect Layer;0;;2;789bf62641c5cfe4ab7126850acc22b8;18,74,1,204,1,191,1,225,0,242,0,237,0,249,0,186,0,177,0,182,0,229,0,92,1,98,0,234,0,126,0,129,1,130,0,31,1;18;192;COLOR;0,0,0,0;False;39;COLOR;1,1,1,1;False;37;SAMPLER2D;;False;218;FLOAT2;0,0;False;239;FLOAT2;0,0;False;181;FLOAT2;0,0;False;75;SAMPLER2D;;False;80;FLOAT;1;False;183;FLOAT2;0,0;False;188;SAMPLER2D;;False;33;SAMPLER2D;;False;248;FLOAT2;0,0;False;233;SAMPLER2D;;False;101;SAMPLER2D;;False;57;FLOAT4;0,0,0,0;False;40;FLOAT;0;False;231;FLOAT;1;False;30;FLOAT;1;False;2;COLOR;0;FLOAT2;172
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-301.9024,-1082.647;Inherit;False;BaseTextureMask;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;26;-506.9904,487.0128;Inherit;False;25;BaseTextureMask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;38;-472.2423,237.0805;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-271.228,368.8255;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;40;-83.98601,236.1086;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SaturateNode;42;65.41898,236.4506;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;3;223.8191,231.0764;Inherit;False;FlowEffect;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-1571.542,-602.4525;Inherit;False;BaseTexture;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;-1174.391,448.8325;Inherit;False;16;BaseTexture;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;12;-158.3855,-580.32;Inherit;False;3;FlowEffect;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;43.42725,-576.0298;Float;False;True;-1;2;ASEMaterialInspector;0;6;Flow_Effect;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;True;-9;False;False;False;False;False;False;False;True;True;0;True;-5;255;True;-8;255;True;-7;0;True;-4;0;True;-6;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;0;True;-11;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;14;0;13;0
WireConnection;15;0;14;0
WireConnection;30;0;18;0
WireConnection;32;0;30;0
WireConnection;32;1;31;0
WireConnection;33;1;32;0
WireConnection;35;0;33;0
WireConnection;35;1;34;0
WireConnection;10;0;9;0
WireConnection;36;0;23;0
WireConnection;36;1;33;0
WireConnection;8;0;11;0
WireConnection;37;0;36;0
WireConnection;37;1;35;0
WireConnection;5;192;17;0
WireConnection;5;39;7;0
WireConnection;5;37;4;0
WireConnection;5;33;2;0
WireConnection;25;0;37;0
WireConnection;38;0;5;0
WireConnection;39;0;38;3
WireConnection;39;1;26;0
WireConnection;40;0;38;0
WireConnection;40;1;38;1
WireConnection;40;2;38;2
WireConnection;40;3;39;0
WireConnection;42;0;40;0
WireConnection;3;0;42;0
WireConnection;16;0;13;0
WireConnection;0;0;12;0
ASEEND*/
//CHKSM=DDB2DEC927137CF1A448A19220CA0CB5A99A3F22