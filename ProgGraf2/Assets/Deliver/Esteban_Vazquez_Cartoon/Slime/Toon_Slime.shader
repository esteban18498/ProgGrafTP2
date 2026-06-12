// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Toon_Slime"
{
	Properties
	{
		_BaseColor("Base Color ", Color) = (0.2361606,0.381261,0.5754717,0)
		_Step0("Step 0", Range( 0 , 1)) = 1
		_Step1("Step 1", Range( 0 , 1)) = 0.5
		_Step2("Step 2", Range( 0 , 1)) = 0.5
		_Step3("Step 3", Range( 0 , 1)) = 0.5
		_Step4("Step 4", Range( 0 , 1)) = 0.5
		_Deformationscale("Deformation scale", Range( 0 , 10)) = 0.2
		_FresnelScale("Fresnel Scale", Range( 0 , 10)) = 1.330371
		_FresnelPow("Fresnel Pow", Range( 1 , 10)) = 1
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Tessellation.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
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

		uniform float _Deformationscale;
		uniform float4 _BaseColor;
		uniform float _Step0;
		uniform float _FresnelScale;
		uniform float _FresnelPow;
		uniform float _Step1;
		uniform float _Step2;
		uniform float _Step3;
		uniform float _Step4;


		float2 voronoihash52( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi52( float2 v, float time, inout float2 id, inout float2 mr, float smoothness )
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
			 		float2 o = voronoihash52( n + g );
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


		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, 0.1);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float3 ase_vertex3Pos = v.vertex.xyz;
			float time52 = _Time.y;
			float2 coords52 = v.texcoord.xy * 1.29;
			float2 id52 = 0;
			float2 uv52 = 0;
			float fade52 = 0.5;
			float voroi52 = 0;
			float rest52 = 0;
			for( int it52 = 0; it52 <2; it52++ ){
			voroi52 += fade52 * voronoi52( coords52, time52, id52, uv52, 0 );
			rest52 += fade52;
			coords52 *= 2;
			fade52 *= 0.5;
			}//Voronoi52
			voroi52 /= rest52;
			v.vertex.xyz += ( ase_vertex3Pos * ( _Deformationscale * voroi52 ) );
			v.vertex.w = 1;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV45 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode45 = ( 0.0 + _FresnelScale * pow( 1.0 - fresnelNdotV45, _FresnelPow ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult15 = dot( ase_worldNormal , ase_worldlightDir );
			float Local_Light19 = max( fresnelNode45 , dotResult15 );
			c.rgb = ( _BaseColor * ( ( step( (-1.0 + (_Step0 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) , Local_Light19 ) + step( (-1.0 + (_Step1 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) , Local_Light19 ) + step( (-1.0 + (_Step2 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) , Local_Light19 ) + step( (-1.0 + (_Step3 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) , Local_Light19 ) + step( (-1.0 + (_Step4 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) , Local_Light19 ) ) / 4.0 ) ).rgb;
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
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows vertex:vertexDataFunc tessellate:tessFunction 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.6
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
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
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
				vertexDataFunc( v );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
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
668;73;884;575;595.5756;400.9563;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;39;-2390.259,-155.3629;Inherit;False;1130.713;1943.944;Toon;26;41;40;38;50;34;30;22;49;32;21;36;29;33;48;23;28;37;24;27;47;31;35;19;15;14;26;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;26;-2177.366,-102.7427;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;14;-2172.226,71.06597;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;68;-2247.237,-330.3397;Inherit;False;Property;_FresnelPow;Fresnel Pow;8;0;Create;True;0;0;0;False;0;False;1;2.33;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-2243.583,-472.7039;Inherit;False;Property;_FresnelScale;Fresnel Scale;7;0;Create;True;0;0;0;False;0;False;1.330371;2.35;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;15;-1932.286,-30.62939;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;45;-1967.341,-488.8709;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;30.79;False;3;FLOAT;0.78;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;51;-1649.803,-483.7779;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;19;-1663.79,-30.36913;Inherit;False;Local_Light;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-2345.308,552.5787;Inherit;False;Property;_Step1;Step 1;2;0;Create;True;0;0;0;False;0;False;0.5;0.54;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-2350.25,1468.975;Inherit;False;Property;_Step4;Step 4;5;0;Create;True;0;0;0;False;0;False;0.5;0.988;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-2353.488,1153.718;Inherit;False;Property;_Step3;Step 3;4;0;Create;True;0;0;0;False;0;False;0.5;0.876;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-2349.072,267.0978;Inherit;False;Property;_Step0;Step 0;1;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-2347.286,839.976;Inherit;False;Property;_Step2;Step 2;3;0;Create;True;0;0;0;False;0;False;0.5;0.695;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;48;-2049.674,1480.812;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;28;-2051.521,749.6459;Inherit;False;19;Local_Light;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;21;-2055.284,464.1661;Inherit;False;19;Local_Light;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;23;-2048.494,278.936;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;58;-677.2737,518.0887;Inherit;False;651.2913;582.5627;Water Deformation;6;54;53;56;57;52;55;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TFHCRemapNode;37;-2052.912,1165.555;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;36;-2047.666,1352.958;Inherit;False;19;Local_Light;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;32;-2053.499,1037.043;Inherit;False;19;Local_Light;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;29;-2044.731,564.4158;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;49;-2044.428,1668.215;Inherit;False;19;Local_Light;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;33;-2046.709,851.8132;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;55;-639.967,845.1862;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;38;-1834.508,1317.98;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;34;-1807.076,1005.057;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;50;-1831.27,1633.237;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;30;-1805.098,717.6594;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;22;-1808.861,432.1796;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;40;-1540.932,448.3322;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-486.5846,737.2717;Inherit;False;Property;_Deformationscale;Deformation scale;6;0;Create;True;0;0;0;False;0;False;0.2;2;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;52;-470.3152,821.3313;Inherit;True;0;0;1;0;2;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;-0.55;False;2;FLOAT;1.29;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-273.2728,781.5833;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;44;-42.35291,-52.01287;Inherit;False;Property;_BaseColor;Base Color ;0;0;Create;True;0;0;0;False;0;False;0.2361606,0.381261,0.5754717,0;0.09624801,0.5299825,0.9080001,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;53;-469.0786,574.0469;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;41;-1402.52,448.3604;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-260.1019,613.4935;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.EdgeLengthTessNode;13;239.5115,531.9692;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;87.25923,219.1516;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;8;288,13;Float;False;True;-1;6;ASEMaterialInspector;0;0;CustomLighting;Toon_Slime;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;15;0;26;0
WireConnection;15;1;14;0
WireConnection;45;2;69;0
WireConnection;45;3;68;0
WireConnection;51;0;45;0
WireConnection;51;1;15;0
WireConnection;19;0;51;0
WireConnection;48;0;47;0
WireConnection;23;0;24;0
WireConnection;37;0;35;0
WireConnection;29;0;27;0
WireConnection;33;0;31;0
WireConnection;38;0;37;0
WireConnection;38;1;36;0
WireConnection;34;0;33;0
WireConnection;34;1;32;0
WireConnection;50;0;48;0
WireConnection;50;1;49;0
WireConnection;30;0;29;0
WireConnection;30;1;28;0
WireConnection;22;0;23;0
WireConnection;22;1;21;0
WireConnection;40;0;22;0
WireConnection;40;1;30;0
WireConnection;40;2;34;0
WireConnection;40;3;38;0
WireConnection;40;4;50;0
WireConnection;52;1;55;0
WireConnection;56;0;57;0
WireConnection;56;1;52;0
WireConnection;41;0;40;0
WireConnection;54;0;53;0
WireConnection;54;1;56;0
WireConnection;18;0;44;0
WireConnection;18;1;41;0
WireConnection;8;13;18;0
WireConnection;8;11;54;0
WireConnection;8;14;13;0
ASEEND*/
//CHKSM=35E36FB1C426383946D6639AA7227B1287258FA7