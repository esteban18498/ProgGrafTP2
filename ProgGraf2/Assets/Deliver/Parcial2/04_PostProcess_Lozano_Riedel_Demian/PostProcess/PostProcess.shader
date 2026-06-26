// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PostProcess"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		_ColorMult("Color", Color) = (0,0,0,0)
		_CenterVector("Center", Vector) = (0,0,0,0)
		_StepValueVector("StepMinimum", Vector) = (0,0,0,0)
		_Switcher("Switcher", Float) = 1
		_CameraNoiseIntensity("CameraNoiseIntensity", Float) = 0.5
		_CameraNoiseSpeed("CameraNoiseSpeed", Float) = 0.5
		_CameraTint("CameraTint", Color) = (0.4518103,0.764151,0.4145159,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		
		
		ZTest Always
		Cull Off
		ZWrite Off

		
		Pass
		{ 
			CGPROGRAM 

			

			#pragma vertex vert_img_custom 
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"


			struct appdata_img_custom
			{
				float4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
				
			};

			struct v2f_img_custom
			{
				float4 pos : SV_POSITION;
				half2 uv   : TEXCOORD0;
				half2 stereoUV : TEXCOORD2;
		#if UNITY_UV_STARTS_AT_TOP
				half4 uv2 : TEXCOORD1;
				half4 stereoUV2 : TEXCOORD3;
		#endif
				
			};

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform half4 _MainTex_ST;
			
			uniform float _CameraNoiseSpeed;
			uniform float _CameraNoiseIntensity;
			uniform float4 _CameraTint;
			uniform float4 _ColorMult;
			uniform float2 _StepValueVector;
			uniform float2 _CenterVector;
			uniform float _Switcher;
					float2 voronoihash27( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi27( float2 v, float time, inout float2 id, inout float2 mr, float smoothness )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash27( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						 		}
						 	}
						}
						return F1;
					}
			


			v2f_img_custom vert_img_custom ( appdata_img_custom v  )
			{
				v2f_img_custom o;
				
				o.pos = UnityObjectToClipPos( v.vertex );
				o.uv = float4( v.texcoord.xy, 1, 1 );

				#if UNITY_UV_STARTS_AT_TOP
					o.uv2 = float4( v.texcoord.xy, 1, 1 );
					o.stereoUV2 = UnityStereoScreenSpaceUVAdjust ( o.uv2, _MainTex_ST );

					if ( _MainTex_TexelSize.y < 0.0 )
						o.uv.y = 1.0 - o.uv.y;
				#endif
				o.stereoUV = UnityStereoScreenSpaceUVAdjust ( o.uv, _MainTex_ST );
				return o;
			}

			half4 frag ( v2f_img_custom i ) : SV_Target
			{
				#ifdef UNITY_UV_STARTS_AT_TOP
					half2 uv = i.uv2;
					half2 stereoUV = i.stereoUV2;
				#else
					half2 uv = i.uv;
					half2 stereoUV = i.stereoUV;
				#endif	
				
				half4 finalColor;

				// ase common template code
				float2 uv_MainTex = i.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode23 = tex2D( _MainTex, uv_MainTex );
				float time27 = 0.0;
				float2 temp_cast_0 = (_CameraNoiseSpeed).xx;
				float2 texCoord33 = i.uv.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner37 = ( _Time.y * temp_cast_0 + texCoord33);
				float2 coords27 = panner37 * 500.0;
				float2 id27 = 0;
				float2 uv27 = 0;
				float fade27 = 0.5;
				float voroi27 = 0;
				float rest27 = 0;
				for( int it27 = 0; it27 <4; it27++ ){
				voroi27 += fade27 * voronoi27( coords27, time27, id27, uv27, 0 );
				rest27 += fade27;
				coords27 *= 2;
				fade27 *= 0.5;
				}//Voronoi27
				voroi27 /= rest27;
				float4 lerpResult61 = lerp( ( tex2DNode23 * voroi27 ) , tex2DNode23 , _CameraNoiseIntensity);
				float2 texCoord6 = i.uv.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_cast_1 = (_CenterVector.y).xx;
				float smoothstepResult10 = smoothstep( _StepValueVector.x , _StepValueVector.y , length( ( texCoord6 - temp_cast_1 ) ));
				float4 lerpResult59 = lerp( _ColorMult , tex2D( _MainTex, texCoord6 ) , ( 1.0 - smoothstepResult10 ));
				float4 lerpResult65 = lerp( ( lerpResult61 * _CameraTint ) , lerpResult59 , _Switcher);
				

				finalColor = lerpResult65;

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18900
1;286;1913;725;450.3172;1212.158;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;56;-148.1521,-1421.084;Inherit;False;1267.109;865.3562;Noise;12;39;26;22;27;31;37;23;41;33;24;38;60;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;60;23.23627,-630.4736;Inherit;False;Constant;_Float5;Float 5;3;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;17;-293.8217,-394.5321;Inherit;False;1370.855;733.9206;Vignette;11;6;1;2;8;7;9;11;10;13;4;59;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-243.8217,-128.1746;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;33;-98.15208,-813.311;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;39;181.1319,-801.2618;Inherit;False;Property;_CameraNoiseSpeed;CameraNoiseSpeed;5;0;Create;False;0;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;8;-25.27466,73.38852;Inherit;False;Property;_CenterVector;Center;1;0;Create;False;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;38;167.9419,-718.3029;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;7;171.7263,-27.61142;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;37;396.0578,-842.7597;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;26;711.66,-714.3936;Inherit;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;0;False;0;False;500;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;22;29.09182,-1368.047;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LengthOpNode;9;365.7263,23.38853;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;23;202.0918,-1366.047;Inherit;True;Property;_TextureSample3;Texture Sample 3;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VoronoiNode;27;918.9569,-799.728;Inherit;True;0;0;1;0;4;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.Vector2Node;11;376.7263,175.3885;Inherit;False;Property;_StepValueVector;StepMinimum;2;0;Create;False;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;1;-219.1428,-266.532;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;10;606.726,109.3885;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;724.0679,-1371.084;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;62;1228.379,-1098.9;Inherit;False;Property;_CameraNoiseIntensity;CameraNoiseIntensity;4;0;Create;False;0;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;13;849.8505,72.69818;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;18.8573,-342.5321;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;61;1394.364,-1255.749;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;57;-3498.426,-7.982911;Inherit;False;1326.347;492.0884;Color inversion +;5;21;47;46;49;48;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;4;475.5091,-149.9964;Inherit;False;Property;_ColorMult;Color;0;0;Create;False;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;64;1450.707,-949.6658;Inherit;False;Property;_CameraTint;CameraTint;6;0;Create;False;0;0;0;False;0;False;0.4518103,0.764151,0.4145159,0;0.4518103,0.764151,0.4145159,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;59;837.4711,-283.7747;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;58;-1623.106,-1515.616;Inherit;False;1115.28;511.3381;Pixelate;6;52;55;50;54;53;51;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;1612.124,-1156.766;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;21;-3448.426,85.36415;Inherit;False;717.4485;282;Color Inversion;3;18;19;20;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;16;-1455.447,-738.3727;Inherit;False;793.013;282;GreyScale;3;14;15;3;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;66;1540.84,-330.4697;Inherit;False;Property;_Switcher;Switcher;3;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DegreesOpNode;47;-2555.078,189.1055;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;65;1762.146,-739.5876;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;52;-1573.106,-1412.277;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCGrayscale;3;-874.4336,-679.1322;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-1246.106,-1120.277;Inherit;False;Constant;_Float4;Float 4;3;0;Create;True;0;0;0;False;0;False;200;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;51;-827.826,-1463.616;Inherit;True;Property;_TextureSample4;Texture Sample 4;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;54;-1206.106,-1212.277;Inherit;False;Constant;_Float3;Float 3;3;0;Create;True;0;0;0;False;0;False;200;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;18;-3398.426,135.3641;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;14;-1405.447,-688.3727;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;15;-1232.447,-686.3727;Inherit;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;20;-2938.978,42.0171;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCPixelate;53;-1026.106,-1310.277;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;50;-1000.826,-1465.616;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;49;-2493.078,336.1054;Inherit;False;Constant;_Float2;Float 2;3;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;48;-2407.078,230.1055;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;41;721.222,-940.413;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;31;171.1758,-944.2369;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RGBToHSVNode;46;-2832.078,145.1055;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;19;-3225.426,137.3641;Inherit;True;Property;_TextureSample2;Texture Sample 2;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;2409.08,-720.9093;Float;False;True;-1;2;ASEMaterialInspector;0;4;PostProcess;c71b220b631b6344493ea3cf87110c93;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;True;0;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;38;0;60;0
WireConnection;7;0;6;0
WireConnection;7;1;8;2
WireConnection;37;0;33;0
WireConnection;37;2;39;0
WireConnection;37;1;38;0
WireConnection;9;0;7;0
WireConnection;23;0;22;0
WireConnection;27;0;37;0
WireConnection;27;2;26;0
WireConnection;10;0;9;0
WireConnection;10;1;11;1
WireConnection;10;2;11;2
WireConnection;24;0;23;0
WireConnection;24;1;27;0
WireConnection;13;0;10;0
WireConnection;2;0;1;0
WireConnection;2;1;6;0
WireConnection;61;0;24;0
WireConnection;61;1;23;0
WireConnection;61;2;62;0
WireConnection;59;0;4;0
WireConnection;59;1;2;0
WireConnection;59;2;13;0
WireConnection;63;0;61;0
WireConnection;63;1;64;0
WireConnection;47;0;46;1
WireConnection;65;0;63;0
WireConnection;65;1;59;0
WireConnection;65;2;66;0
WireConnection;3;0;15;0
WireConnection;51;0;50;0
WireConnection;51;1;53;0
WireConnection;15;0;14;0
WireConnection;20;0;19;0
WireConnection;53;0;52;0
WireConnection;53;1;54;0
WireConnection;53;2;55;0
WireConnection;48;0;47;0
WireConnection;48;1;49;0
WireConnection;41;1;37;0
WireConnection;46;0;19;0
WireConnection;19;0;18;0
WireConnection;0;0;65;0
ASEEND*/
//CHKSM=F3C55B8D6371D091D7FFC340C76A2E492D977008