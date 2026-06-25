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
		[NoScaleOffset]_DistortionMask("Distortion Mask", 2D) = "white" {}
		_AlbedoTexture("AlbedoTexture", 2D) = "white" {}
		_DistortionTexture("DistortionTexture", 2D) = "bump" {}
		_DistortionAmount("DistortionAmount", Range( 0 , 1)) = 1
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
			uniform sampler2D _AlbedoTexture;
			uniform sampler2D _DistortionTexture;
			uniform float4 _AlbedoTexture_ST;
			uniform float _DistortionAmount;
			uniform sampler2D _DistortionMask;

			
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
				float2 uv_AlbedoTexture = IN.texcoord.xy * _AlbedoTexture_ST.xy + _AlbedoTexture_ST.zw;
				float2 MainUvs222_g1 = uv_AlbedoTexture;
				float4 tex2DNode65_g1 = tex2D( _DistortionTexture, ( ( float2( 0,0 ) * TimeVar197_g1 ) + MainUvs222_g1 ) );
				float4 appendResult82_g1 = (float4(0.0 , tex2DNode65_g1.g , 0.0 , tex2DNode65_g1.r));
				float2 temp_output_84_0_g1 = (UnpackScaleNormal( appendResult82_g1, _DistortionAmount )).xy;
				float2 panner179_g1 = ( 1.0 * _Time.y * float2( -1,0 ) + MainUvs222_g1);
				float2 temp_output_71_0_g1 = ( ( temp_output_84_0_g1 * tex2D( _DistortionMask, ( ( float2( 0,0 ) * TimeVar197_g1 ) + MainUvs222_g1 ) ).g ) + panner179_g1 );
				float4 tex2DNode96_g1 = tex2D( _AlbedoTexture, temp_output_71_0_g1 );
				float4 DistortionEffect22 = tex2DNode96_g1;
				float4 tex2DNode94 = tex2D( _AlbedoTexture, uv_AlbedoTexture );
				float luminance97 = Luminance(tex2DNode94.rgb);
				float4 Testasca101 = ( tex2DNode94 * step( 0.03 , luminance97 ) );
				
				half4 color = saturate( ( DistortionEffect22 * Testasca101 ) );
				
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
606;73;1024;600;889.5472;809.678;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;21;-2608.517,-2045.435;Inherit;False;1505.761;948.7743;Distortion Section;8;22;1;46;5;2;49;57;83;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;2;-2407.243,-1948.456;Inherit;True;Property;_AlbedoTexture;AlbedoTexture;8;0;Create;True;0;0;0;False;0;False;36be8d528a4fa024faa4680d7658642c;36be8d528a4fa024faa4680d7658642c;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;4;-3405.454,-1443.349;Inherit;True;Property;_DistortionTexture;DistortionTexture;9;0;Create;True;0;0;0;False;0;False;302951faffe230848aa0d3df7bb70faa;302951faffe230848aa0d3df7bb70faa;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;94;-2143.405,-2308.346;Inherit;True;Property;_TextureSample2;Texture Sample 2;17;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LuminanceNode;97;-1704.862,-2563.692;Inherit;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;82;-3126.124,-1439.02;Inherit;False;DistortionTexture;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2210.233,-1568.613;Inherit;False;Property;_DistortionAmount;DistortionAmount;10;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;83;-2150.109,-1653.302;Inherit;False;82;DistortionTexture;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;46;-2160.343,-1778.888;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;98;-1396.68,-2592.05;Inherit;True;2;0;FLOAT;0.03;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1;-1887.691,-1942.886;Inherit;True;UI-Sprite Effect Layer;0;;1;789bf62641c5cfe4ab7126850acc22b8;18,74,0,204,0,191,0,225,1,242,0,237,0,249,0,186,1,177,1,182,1,229,0,92,0,98,0,234,0,126,0,129,1,130,0,31,0;18;192;COLOR;1,1,1,1;False;39;COLOR;1,1,1,1;False;37;SAMPLER2D;;False;218;FLOAT2;0,0;False;239;FLOAT2;0,0;False;181;FLOAT2;-1,0;False;75;SAMPLER2D;;False;80;FLOAT;1;False;183;FLOAT2;0,0;False;188;SAMPLER2D;;False;33;SAMPLER2D;;False;248;FLOAT2;0,0;False;233;SAMPLER2D;;False;101;SAMPLER2D;;False;57;FLOAT4;0,0,0,0;False;40;FLOAT;0;False;231;FLOAT;1;False;30;FLOAT;1;False;2;COLOR;0;FLOAT2;172
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;100;-1079.434,-2514.212;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-1462.643,-1947.757;Inherit;False;DistortionEffect;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;101;-820.5952,-2452.906;Inherit;False;Testasca;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;-695.5882,-508.0688;Inherit;False;22;DistortionEffect;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;-662.2239,-600.4629;Inherit;False;101;Testasca;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;29;-2054.245,-952.7319;Inherit;False;936.6386;676.1577;FlowSection;8;24;26;43;23;50;54;65;28;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;41;-2441.415,-205.4314;Inherit;False;1377.215;872.1403;RotateSection;7;44;39;31;35;51;30;38;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;-418.1356,-572.209;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;48;-3129.428,-723.4587;Inherit;False;NormalTextureMask;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SamplerNode;61;-3287.757,-1211.978;Inherit;True;Property;_TextureSample1;Texture Sample 1;12;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;38;-2032.8,447.5891;Inherit;False;Property;_Pos_Scale;Pos_Scale;18;0;Create;True;0;0;0;False;0;False;0,-0.08,1,3;0,-0.08,1,3;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;62;-3538.105,-1217.174;Inherit;True;Property;_Texture0;Texture 0;15;0;Create;True;0;0;0;False;0;False;8ad4fab1bf3947d4c9e189afd00d307d;8ad4fab1bf3947d4c9e189afd00d307d;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;50;-1991.801,-441.6989;Inherit;False;48;NormalTextureMask;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;-1280.734,-814.3553;Inherit;False;FlowEffect;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleTimeNode;54;-1675.087,-365.3363;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;84;-2087.014,897.9119;Inherit;False;82;DistortionTexture;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;-2073.543,363.7145;Inherit;False;48;NormalTextureMask;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;-1336.504,115.2211;Inherit;True;RotateEffect;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;24;-1660.585,-807.4265;Inherit;True;UI-Sprite Effect Layer;0;;2;789bf62641c5cfe4ab7126850acc22b8;18,74,1,204,1,191,1,225,0,242,0,237,0,249,0,186,0,177,0,182,0,229,0,92,1,98,0,234,0,126,0,129,1,130,0,31,1;18;192;COLOR;0,0,0,0;False;39;COLOR;1,1,1,1;False;37;SAMPLER2D;;False;218;FLOAT2;0,0;False;239;FLOAT2;0,0;False;181;FLOAT2;0,0;False;75;SAMPLER2D;;False;80;FLOAT;1;False;183;FLOAT2;0,0;False;188;SAMPLER2D;;False;33;SAMPLER2D;;False;248;FLOAT2;0,0;False;233;SAMPLER2D;;False;101;SAMPLER2D;;False;57;FLOAT4;0,0,0,0;False;40;FLOAT;0;False;231;FLOAT;1;False;30;FLOAT;1;False;2;COLOR;0;FLOAT2;172
Node;AmplifyShaderEditor.TexturePropertyNode;18;-3384.926,-722.3295;Inherit;True;Property;_NormalTextureMask;NormalTextureMask;11;0;Create;True;0;0;0;False;0;False;596678c53fd54a640bf95ba7dfafd092;596678c53fd54a640bf95ba7dfafd092;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;23;-1977.081,-898.0073;Inherit;False;22;DistortionEffect;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;64;-3136.598,-912.0374;Inherit;False;FlowLineTexture;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;-2023.405,78.81889;Inherit;False;42;ColorTint;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;90;-2094.341,1168.766;Inherit;False;48;NormalTextureMask;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;57;-2128.037,-1491.71;Inherit;False;-1;;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;87;-2043.517,736.8179;Inherit;False;39;RotateEffect;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;-603.0317,-220.1238;Inherit;False;91;RotatePortalEffect;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;-1985.221,-524.0139;Inherit;False;64;FlowLineTexture;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.FunctionNode;31;-1690.714,122.3112;Inherit;True;UI-Sprite Effect Layer;0;;3;789bf62641c5cfe4ab7126850acc22b8;18,74,2,204,2,191,1,225,0,242,0,237,0,249,0,186,0,177,0,182,0,229,0,92,1,98,1,234,0,126,0,129,1,130,1,31,1;18;192;COLOR;1,1,1,1;False;39;COLOR;1,1,1,1;False;37;SAMPLER2D;;False;218;FLOAT2;0,0;False;239;FLOAT2;0,0;False;181;FLOAT2;0,0;False;75;SAMPLER2D;;False;80;FLOAT;1;False;183;FLOAT2;0,0;False;188;SAMPLER2D;;False;33;SAMPLER2D;;False;248;FLOAT2;0,0;False;233;SAMPLER2D;;False;101;SAMPLER2D;;False;57;FLOAT4;0,0,0,0;False;40;FLOAT;0;False;231;FLOAT;1;False;30;FLOAT;1;False;2;COLOR;0;FLOAT2;172
Node;AmplifyShaderEditor.SamplerNode;32;-3449.55,-311.8041;Inherit;True;Property;_TextureSample0;Texture Sample 0;11;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DesaturateOpNode;95;-1749.504,-2329.147;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;59;-3124.647,-269.7853;Inherit;False;BaseTexture2;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;88;-2097.467,970.1706;Inherit;True;Property;_Texture1;Texture 1;17;0;Create;True;0;0;0;False;0;False;a99649a3ac7df724eb781c969383e632;a99649a3ac7df724eb781c969383e632;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.Vector4Node;86;-2053.598,1252.64;Inherit;False;Property;_Vector1;Vector 1;19;0;Create;True;0;0;0;False;0;False;0,0,1,1;0,0,1,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;25;-3369.353,-501.4491;Inherit;False;Property;_ColorTint;Color Tint;7;0;Create;True;0;0;0;False;0;False;1,0,0,1;1,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;35;-2076.669,165.1189;Inherit;True;Property;_RotateTexture;RotateTexture;16;0;Create;True;0;0;0;False;0;False;a99649a3ac7df724eb781c969383e632;a99649a3ac7df724eb781c969383e632;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;49;-2160.569,-1403.896;Inherit;False;48;NormalTextureMask;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.FunctionNode;89;-1711.512,927.3629;Inherit;True;UI-Sprite Effect Layer;0;;4;789bf62641c5cfe4ab7126850acc22b8;18,74,2,204,2,191,1,225,0,242,0,237,0,249,0,186,0,177,0,182,0,229,0,92,1,98,1,234,0,126,0,129,1,130,1,31,1;18;192;COLOR;1,1,1,1;False;39;COLOR;1,0.504717,0.504717,1;False;37;SAMPLER2D;;False;218;FLOAT2;0,0;False;239;FLOAT2;0,0;False;181;FLOAT2;0,0;False;75;SAMPLER2D;;False;80;FLOAT;1;False;183;FLOAT2;0,0;False;188;SAMPLER2D;;False;33;SAMPLER2D;;False;248;FLOAT2;0,0;False;233;SAMPLER2D;;False;101;SAMPLER2D;;False;57;FLOAT4;0,0,0,0;False;40;FLOAT;0;False;231;FLOAT;1;False;30;FLOAT;1;False;2;COLOR;0;FLOAT2;172
Node;AmplifyShaderEditor.TexturePropertyNode;33;-3687.449,-311.8041;Inherit;True;Property;_BaseTexture;BaseTexture;14;0;Create;True;0;0;0;False;0;False;80ab37a9e4f49c842903bb43bdd7bcd2;80ab37a9e4f49c842903bb43bdd7bcd2;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;30;-2024.443,-6.083462;Inherit;False;28;FlowEffect;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;56;-3449.535,-96.09161;Inherit;False;BaseTexture;-1;True;1;0;SAMPLER2D;0,0,0,0;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SaturateNode;111;-152.5472,-544.678;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;42;-3123.608,-502.1231;Inherit;False;ColorTint;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;85;-2042.479,821.7203;Inherit;False;42;ColorTint;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;96;-1394.504,-2347.146;Inherit;True;2;0;FLOAT3;0.04,1,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;43;-1966.101,-803.1133;Inherit;False;42;ColorTint;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;26;-2004.245,-718.2771;Inherit;True;Property;_Ramp;Ramp;13;0;Create;True;0;0;0;False;0;False;131633c45b26caa4f9673a16077a1970;131633c45b26caa4f9673a16077a1970;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;63;-3374.44,-942.8284;Inherit;True;Property;_FlowLineTexture;FlowLineTexture;12;0;Create;True;0;0;0;False;0;False;5228a04ef529d2641937cab585cc1a02;5228a04ef529d2641937cab585cc1a02;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;91;-1346.567,843.2838;Inherit;False;RotatePortalEffect;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;85.84671,-551.7226;Float;False;True;-1;2;ASEMaterialInspector;0;6;Distortion_Effect;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;True;-9;False;False;False;False;False;False;False;True;True;0;True;-5;255;True;-8;255;True;-7;0;True;-4;0;True;-6;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;0;True;-11;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;94;0;2;0
WireConnection;97;0;94;0
WireConnection;82;0;4;0
WireConnection;46;2;2;0
WireConnection;98;1;97;0
WireConnection;1;37;2;0
WireConnection;1;218;46;0
WireConnection;1;75;83;0
WireConnection;1;80;5;0
WireConnection;100;0;94;0
WireConnection;100;1;98;0
WireConnection;22;0;1;0
WireConnection;101;0;100;0
WireConnection;110;0;93;0
WireConnection;110;1;102;0
WireConnection;48;0;18;0
WireConnection;61;0;62;0
WireConnection;28;0;24;0
WireConnection;39;0;31;0
WireConnection;24;192;23;0
WireConnection;24;39;43;0
WireConnection;24;37;26;0
WireConnection;24;33;65;0
WireConnection;64;0;63;0
WireConnection;31;192;30;0
WireConnection;31;39;44;0
WireConnection;31;37;35;0
WireConnection;31;57;38;0
WireConnection;32;0;33;0
WireConnection;95;0;94;0
WireConnection;59;0;32;0
WireConnection;89;192;87;0
WireConnection;89;39;85;0
WireConnection;89;37;84;0
WireConnection;89;57;86;0
WireConnection;56;0;33;0
WireConnection;111;0;110;0
WireConnection;42;0;25;0
WireConnection;96;1;95;0
WireConnection;91;0;89;0
WireConnection;0;0;111;0
ASEEND*/
//CHKSM=F89878B6AF54717CB7B181662BF066C9A4C303BA