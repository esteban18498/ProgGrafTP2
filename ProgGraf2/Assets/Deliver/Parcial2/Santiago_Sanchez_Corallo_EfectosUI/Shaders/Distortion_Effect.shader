// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Distortion_Effect"
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
		_PannerDirection("PannerDirection", Vector) = (-2,0,0,0)
		_PannerTimeScale("PannerTimeScale", Float) = 1
		_DistortionTexture("DistortionTexture", 2D) = "bump" {}
		_DistortionAmount("DistortionAmount", Range( 0 , 1)) = 1
		_ColorTint("Color Tint", Color) = (1,0,0,1)

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
			#include "UnityStandardUtils.cginc"

			
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
			uniform sampler2D _DistortionTexture;
			uniform float4 _BaseTexture_ST;
			uniform float _DistortionAmount;
			uniform float4 _ColorTint;
			uniform float _PannerTimeScale;
			uniform float2 _PannerDirection;

			
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

				float TimeVar197_g1 = _Time.y;
				float2 uv_BaseTexture = IN.texcoord.xy * _BaseTexture_ST.xy + _BaseTexture_ST.zw;
				float2 MainUvs222_g1 = uv_BaseTexture;
				float4 tex2DNode65_g1 = tex2D( _DistortionTexture, ( ( float2( 0,0 ) * TimeVar197_g1 ) + MainUvs222_g1 ) );
				float4 appendResult82_g1 = (float4(0.0 , tex2DNode65_g1.g , 0.0 , tex2DNode65_g1.r));
				float2 temp_output_84_0_g1 = (UnpackScaleNormal( appendResult82_g1, _DistortionAmount )).xy;
				float2 panner179_g1 = ( 1.0 * _Time.y * float2( -1,0 ) + MainUvs222_g1);
				float2 temp_output_71_0_g1 = ( temp_output_84_0_g1 + panner179_g1 );
				float4 tex2DNode96_g1 = tex2D( _BaseTexture, temp_output_71_0_g1 );
				float4 ColorTint42 = _ColorTint;
				float4 DistortionEffect22 = ( tex2DNode96_g1 * ColorTint42 );
				float mulTime132 = _Time.y * _PannerTimeScale;
				float2 panner122 = ( mulTime132 * _PannerDirection + uv_BaseTexture);
				float2 BaseTexturePanner124 = panner122;
				float4 BaseTextureColor115 = tex2D( _BaseTexture, BaseTexturePanner124 );
				float luminance97 = Luminance(BaseTextureColor115.rgb);
				float4 BaseTextureMask101 = ( BaseTextureColor115 * step( 0.02 , luminance97 ) );
				
				half4 color = saturate( ( DistortionEffect22 * BaseTextureMask101 ) );
				
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
763;73;832;546;2976.292;2072.851;3.873111;False;False
Node;AmplifyShaderEditor.TexturePropertyNode;2;-2610.259,-2717.668;Inherit;True;Property;_BaseTexture;BaseTexture;7;0;Create;True;0;0;0;False;0;False;36be8d528a4fa024faa4680d7658642c;36be8d528a4fa024faa4680d7658642c;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;127;-2487.851,-2251.597;Inherit;False;Property;_PannerTimeScale;PannerTimeScale;9;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;132;-2280.547,-2246.337;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;128;-2291.946,-2388.771;Inherit;False;Property;_PannerDirection;PannerDirection;8;0;Create;True;0;0;0;False;0;False;-2,0;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;123;-2322.86,-2511.247;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;122;-2080.047,-2435.689;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;-2,0;False;1;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;124;-1815.521,-2441.652;Inherit;False;BaseTexturePanner;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;125;-2332.327,-2634.026;Inherit;False;124;BaseTexturePanner;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;94;-2087.18,-2719.013;Inherit;True;Property;_TextureSample2;Texture Sample 2;17;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;115;-1757.593,-2719.757;Inherit;False;BaseTextureColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;4;-2647.261,-3534.948;Inherit;True;Property;_DistortionTexture;DistortionTexture;10;0;Create;True;0;0;0;False;0;False;302951faffe230848aa0d3df7bb70faa;302951faffe230848aa0d3df7bb70faa;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;112;-2337.57,-2806.742;Inherit;False;BaseTexture;-1;True;1;0;SAMPLER2D;0;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;116;-2634.93,-3136.873;Inherit;False;115;BaseTextureColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;21;-2608.517,-2045.435;Inherit;False;1627.405;526.598;Distortion Section;7;22;1;133;46;83;5;113;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;25;-2547.718,-576.5969;Inherit;False;Property;_ColorTint;Color Tint;12;0;Create;True;0;0;0;False;0;False;1,0,0,1;1,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;42;-2301.973,-577.2709;Inherit;False;ColorTint;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;113;-2381.825,-1948.95;Inherit;False;112;BaseTexture;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.LuminanceNode;97;-2377.32,-3131.233;Inherit;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;82;-2390.932,-3534.619;Inherit;False;DistortionTexture;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;117;-2188.62,-3307.903;Inherit;False;115;BaseTextureColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;98;-2176.628,-3156.322;Inherit;True;2;0;FLOAT;0.02;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;46;-2168.853,-1885.129;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;83;-2168.109,-1753.302;Inherit;False;82;DistortionTexture;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2222.233,-1660.613;Inherit;False;Property;_DistortionAmount;DistortionAmount;11;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;133;-2144.318,-1990.765;Inherit;False;42;ColorTint;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;1;-1887.691,-1942.886;Inherit;True;UI-Sprite Effect Layer;0;;1;789bf62641c5cfe4ab7126850acc22b8;18,74,0,204,0,191,1,225,1,242,0,237,0,249,0,186,0,177,1,182,1,229,0,92,0,98,0,234,0,126,0,129,1,130,0,31,0;18;192;COLOR;1,1,1,1;False;39;COLOR;1,1,1,1;False;37;SAMPLER2D;;False;218;FLOAT2;0,0;False;239;FLOAT2;0,0;False;181;FLOAT2;-1,0;False;75;SAMPLER2D;;False;80;FLOAT;1;False;183;FLOAT2;0,0;False;188;SAMPLER2D;;False;33;SAMPLER2D;;False;248;FLOAT2;0,0;False;233;SAMPLER2D;;False;101;SAMPLER2D;;False;57;FLOAT4;0,0,0,0;False;40;FLOAT;0;False;231;FLOAT;1;False;30;FLOAT;1;False;2;COLOR;0;FLOAT2;172
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;100;-1933.541,-3239.527;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;101;-1611.955,-3243.643;Inherit;False;BaseTextureMask;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-1343.643,-1947.757;Inherit;False;DistortionEffect;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;-2131.539,-1399.807;Inherit;False;22;DistortionEffect;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;-2138.175,-1314.201;Inherit;False;101;BaseTextureMask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;-1870.086,-1368.947;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;29;-2054.245,-952.7319;Inherit;False;936.6386;676.1577;FlowSection;6;24;26;43;23;65;28;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;63;-2563.436,-792.9447;Inherit;True;Property;_FlowLineTexture;FlowLineTexture;13;0;Create;True;0;0;0;False;0;False;36be8d528a4fa024faa4680d7658642c;5228a04ef529d2641937cab585cc1a02;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SaturateNode;134;-1629.881,-1368.665;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;-1310.223,-794.6956;Inherit;False;FlowEffect;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;23;-2006.57,-878.3477;Inherit;False;101;BaseTextureMask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;26;-2033.734,-698.6174;Inherit;True;Property;_Ramp;Ramp;14;0;Create;True;0;0;0;False;0;False;131633c45b26caa4f9673a16077a1970;131633c45b26caa4f9673a16077a1970;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;65;-2017.71,-488.3542;Inherit;False;112;BaseTexture;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.FunctionNode;24;-1690.074,-787.7668;Inherit;True;UI-Sprite Effect Layer;0;;2;789bf62641c5cfe4ab7126850acc22b8;18,74,1,204,1,191,1,225,0,242,0,237,0,249,0,186,0,177,0,182,0,229,0,92,1,98,0,234,0,126,0,129,1,130,0,31,1;18;192;COLOR;0,0,0,0;False;39;COLOR;1,1,1,1;False;37;SAMPLER2D;;False;218;FLOAT2;0,0;False;239;FLOAT2;0,0;False;181;FLOAT2;0,0;False;75;SAMPLER2D;;False;80;FLOAT;1;False;183;FLOAT2;0,0;False;188;SAMPLER2D;;False;33;SAMPLER2D;;False;248;FLOAT2;0,0;False;233;SAMPLER2D;;False;101;SAMPLER2D;;False;57;FLOAT4;0,0,0,0;False;40;FLOAT;0;False;231;FLOAT;1;False;30;FLOAT;1;False;2;COLOR;0;FLOAT2;172
Node;AmplifyShaderEditor.GetLocalVarNode;43;-1995.59,-783.4536;Inherit;False;42;ColorTint;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;64;-2325.594,-793.1537;Inherit;False;FlowLineTexture;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;-1441.104,-1368.461;Float;False;True;-1;2;ASEMaterialInspector;0;6;Distortion_Effect;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;True;-9;False;False;False;False;False;False;False;True;True;0;True;-5;255;True;-8;255;True;-7;0;True;-4;0;True;-6;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;0;True;-11;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;132;0;127;0
WireConnection;123;2;2;0
WireConnection;122;0;123;0
WireConnection;122;2;128;0
WireConnection;122;1;132;0
WireConnection;124;0;122;0
WireConnection;94;0;2;0
WireConnection;94;1;125;0
WireConnection;115;0;94;0
WireConnection;112;0;2;0
WireConnection;42;0;25;0
WireConnection;97;0;116;0
WireConnection;82;0;4;0
WireConnection;98;1;97;0
WireConnection;46;2;113;0
WireConnection;1;39;133;0
WireConnection;1;37;113;0
WireConnection;1;218;46;0
WireConnection;1;75;83;0
WireConnection;1;80;5;0
WireConnection;100;0;117;0
WireConnection;100;1;98;0
WireConnection;101;0;100;0
WireConnection;22;0;1;0
WireConnection;110;0;93;0
WireConnection;110;1;102;0
WireConnection;134;0;110;0
WireConnection;28;0;24;0
WireConnection;24;192;23;0
WireConnection;24;39;43;0
WireConnection;24;37;26;0
WireConnection;24;33;65;0
WireConnection;64;0;63;0
WireConnection;0;0;134;0
ASEEND*/
//CHKSM=333C905CD4A12C02A3668DF903E0FC35696584A0