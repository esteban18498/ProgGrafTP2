// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SinCity_Effect_Android"
{
	Properties
	{
		_AlbedoTexture("Albedo Texture", 2D) = "white" {}
		_ColorShadow_1("Color Shadow_1", Color) = (1,1,1,0)
		_ColorShadow_2("Color Shadow_2", Color) = (0,0,0,0)
		_NormalMap("Normal Map", 2D) = "white" {}
		_EmissionTint("Emission Tint", Color) = (1,1,1,0)
		_EmissionTexture("Emission Texture", 2D) = "white" {}
		_Shadow_Force_Step_1("Shadow_Force_Step_1", Range( 0 , 1)) = 0
		_Shadow_Force_Step_2("Shadow_Force_Step_2", Range( 0 , 1)) = 0
		_Shadow_Force_Step_4("Shadow_Force_Step_4", Range( 0 , 1)) = 0
		_Shadow_Force_Step_3("Shadow_Force_Step_3", Range( 0 , 1)) = 0
		_RimColor("Rim Color", Color) = (1,1,1,0)
		_RimPower("Rim Power", Range( 0 , 0.9)) = 0
		_RimOffset("Rim Offset", Range( 0 , 1)) = 0.8
		_Rimcirclerange("Rim circle range", Range( 0 , 2)) = 0.5
		_Voronoiscale("Voronoi scale", Range( 100 , 1000)) = 250
		_Voronoitimescale("Voronoi time scale", Range( 0 , 2)) = 1
		_Emissiontintstrength("Emission tint strength", Range( 1 , 4)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
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
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
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

		uniform sampler2D _EmissionTexture;
		uniform float4 _EmissionTexture_ST;
		uniform float4 _EmissionTint;
		uniform float _Emissiontintstrength;
		uniform float _Voronoiscale;
		uniform float _Voronoitimescale;
		uniform float4 _ColorShadow_1;
		uniform float4 _ColorShadow_2;
		uniform float _Shadow_Force_Step_1;
		uniform float _Shadow_Force_Step_2;
		uniform float _Shadow_Force_Step_3;
		uniform float _Shadow_Force_Step_4;
		uniform sampler2D _AlbedoTexture;
		uniform float4 _AlbedoTexture_ST;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _Rimcirclerange;
		uniform float _RimOffset;
		uniform float _RimPower;
		uniform float4 _RimColor;


		float2 voronoihash175( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi175( float2 v, float time, inout float2 id, inout float2 mr, float smoothness )
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
			 		float2 o = voronoihash175( n + g );
					o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
					float d = 0.707 * sqrt(dot( r, r ));
			 		if( d<F1 ) {
			 			F2 = F1;
			 			F1 = d; mg = g; mr = r; id = o;
			 		} else if( d<F2 ) {
			 			F2 = d;
			 		}
			 	}
			}
			return F2 - F1;
		}


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
			float2 uv_EmissionTexture = i.uv_texcoord * _EmissionTexture_ST.xy + _EmissionTexture_ST.zw;
			float4 tex2DNode95 = tex2D( _EmissionTexture, uv_EmissionTexture );
			float4 EmissionTexture188 = ( 1.0 - tex2DNode95 );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float dotResult10 = dot( ase_worldlightDir , ase_normWorldNormal );
			float Dot_Result_From_LightDir11 = dotResult10;
			float StepsShadow45 = ( ( step( (0.0 + (_Shadow_Force_Step_1 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) , Dot_Result_From_LightDir11 ) + step( (0.0 + (_Shadow_Force_Step_2 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) , Dot_Result_From_LightDir11 ) + step( (0.0 + (_Shadow_Force_Step_3 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) , Dot_Result_From_LightDir11 ) + step( (0.0 + (_Shadow_Force_Step_4 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) , Dot_Result_From_LightDir11 ) ) / 4.0 );
			float4 lerpResult51 = lerp( _ColorShadow_1 , _ColorShadow_2 , StepsShadow45);
			float2 uv_AlbedoTexture = i.uv_texcoord * _AlbedoTexture_ST.xy + _AlbedoTexture_ST.zw;
			float4 AlbedoTexture182 = tex2D( _AlbedoTexture, uv_AlbedoTexture );
			float4 AlbedoProperty54 = ( lerpResult51 * AlbedoTexture182 );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 NormalMap4 = UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) );
			UnityGI gi58 = gi;
			float3 diffNorm58 = WorldNormalVector( i , NormalMap4 );
			gi58 = UnityGI_Base( data, 1, diffNorm58 );
			float3 indirectDiffuse58 = gi58.indirect.diffuse + diffNorm58 * 0.0001;
			float4 Lighting66 = ( AlbedoProperty54 * ( ( ase_lightColor * ase_lightColor.a ) * float4( ( indirectDiffuse58 + ase_lightAtten ) , 0.0 ) ) );
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult16 = dot( ase_worldViewDir , ase_normWorldNormal );
			float Dot_Result_From_ViewDir17 = dotResult16;
			float4 RimLight84 = ( saturate( step( 0.5 , ( 1.0 - ( ( Dot_Result_From_LightDir11 * 1.0 ) + _Rimcirclerange ) ) ) ) * pow( ( 1.0 - saturate( ( Dot_Result_From_ViewDir17 + _RimOffset ) ) ) , (0.0 + (_RimPower - 1.0) * (1.0 - 0.0) / (0.0 - 1.0)) ) * ( _RimColor * ase_lightColor ) );
			c.rgb = ( EmissionTexture188 * ( Lighting66 + RimLight84 ) ).rgb;
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
			float2 uv_EmissionTexture = i.uv_texcoord * _EmissionTexture_ST.xy + _EmissionTexture_ST.zw;
			float4 tex2DNode95 = tex2D( _EmissionTexture, uv_EmissionTexture );
			float mulTime178 = _Time.y * _Voronoitimescale;
			float time175 = mulTime178;
			float voronoiSmooth0 = 0.0;
			float2 coords175 = i.uv_texcoord * _Voronoiscale;
			float2 id175 = 0;
			float2 uv175 = 0;
			float fade175 = 0.5;
			float voroi175 = 0;
			float rest175 = 0;
			for( int it175 = 0; it175 <2; it175++ ){
			voroi175 += fade175 * voronoi175( coords175, time175, id175, uv175, voronoiSmooth0 );
			rest175 += fade175;
			coords175 *= 2;
			fade175 *= 0.5;
			}//Voronoi175
			voroi175 /= rest175;
			float4 Emission125 = ( ( ( tex2DNode95 * _EmissionTint ) * _Emissiontintstrength ) * voroi175 );
			o.Emission = Emission125.rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

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
558;73;971;523;4789.549;197.4148;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;5;-2517.857,-1621.559;Inherit;False;1254.18;1137.74;DOT Results;4;13;12;7;6;DOT RESULTS;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;6;-2253.592,-939.2858;Inherit;False;679.609;385.1234;DOT Result from 'LightDir';4;11;10;9;8;DOT.LightDir;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;9;-2218.746,-890.0939;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;8;-2191.838,-737.1628;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;10;-1969.84,-818.0519;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;26;-1187.962,-1781.719;Inherit;False;1360.121;1172.11;Steps Calculation;19;45;44;43;42;41;40;39;38;37;36;35;34;33;32;31;30;29;28;27;Steps Calculation;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-1120.97,-900.15;Inherit;False;Property;_Shadow_Force_Step_4;Shadow_Force_Step_4;9;0;Create;True;0;0;0;False;0;False;0;0.9;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-1136.972,-1731.72;Inherit;False;Property;_Shadow_Force_Step_1;Shadow_Force_Step_1;7;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-1123.085,-1174.765;Inherit;False;Property;_Shadow_Force_Step_3;Shadow_Force_Step_3;10;0;Create;True;0;0;0;False;0;False;0;0.6;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;11;-1820.943,-823.6459;Inherit;False;Dot_Result_From_LightDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-1137.962,-1453.193;Inherit;False;Property;_Shadow_Force_Step_2;Shadow_Force_Step_2;8;0;Create;True;0;0;0;False;0;False;0;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;34;-778.457,-893.983;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;33;-779.4791,-1447.049;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;37;-780.571,-1168.599;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;38;-782.68,-1726.869;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;32;-772.0521,-725.6102;Inherit;False;11;Dot_Result_From_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;35;-774.075,-1559.497;Inherit;False;11;Dot_Result_From_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;-773.201,-1276.045;Inherit;False;11;Dot_Result_From_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;36;-774.1661,-1000.226;Inherit;False;11;Dot_Result_From_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;42;-571.1023,-1363.863;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;39;-577.3032,-1650.683;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;40;-574.0822,-812.796;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;12;-2294.251,-1464.926;Inherit;False;758.8868;387.141;DOT Result from 'ViewDir';4;17;16;15;14;DOT.ViewDir;1,1,1,1;0;0
Node;AmplifyShaderEditor.StepOpNode;41;-576.1953,-1087.412;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;43;-381.1106,-1389.76;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;15;-2244.251,-1260.785;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;1;-3517.105,-1285.362;Inherit;False;891.7764;280.295;Normal Map;3;4;3;2;Normal Map;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;195;-3513.376,-870.0833;Inherit;False;881.4879;280.3958;Albedo;3;49;52;182;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;14;-2231.551,-1414.926;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;44;-196.4918,-1390.237;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;49;-3463.375,-819.6874;Inherit;True;Property;_AlbedoTexture;Albedo Texture;0;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.CommentaryNode;67;-4858.054,-480.0115;Inherit;False;2264.95;992.556;;20;84;83;82;81;76;75;156;78;174;80;74;169;71;70;170;172;77;69;68;73;Rim Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;2;-3467.105,-1235.157;Inherit;True;Property;_NormalMap;Normal Map;3;0;Create;True;0;0;0;False;0;False;None;14fbeebef2ed6094483d60b9041036bb;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.DotProductOpNode;16;-1998.193,-1339.186;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;52;-3202.334,-819.9623;Inherit;True;Property;_TextureSample3;Texture Sample 3;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;45;-51.84061,-1395.173;Inherit;False;StepsShadow;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;46;-2509.218,-2644.76;Inherit;False;1261.108;843.7762;Albedo;8;55;54;53;51;196;47;50;48;Albedo Property;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;3;-3192.932,-1235.067;Inherit;True;Property;_TextureSample0;Texture Sample 0;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;17;-1816.363,-1344.74;Inherit;False;Dot_Result_From_ViewDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;73;-4791.115,-388.4114;Inherit;False;11;Dot_Result_From_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;-4553.606,-28.12877;Inherit;False;17;Dot_Result_From_ViewDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-4507.326,-357.9877;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;47;-2384.338,-2065.024;Inherit;False;45;StepsShadow;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;172;-4646.288,-221.1624;Inherit;False;Property;_Rimcirclerange;Rim circle range;14;0;Create;True;0;0;0;False;0;False;0.5;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-4560.762,80.80141;Float;False;Property;_RimOffset;Rim Offset;13;0;Create;True;0;0;0;False;0;False;0.8;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;48;-2393.266,-2344.382;Inherit;False;Property;_ColorShadow_2;Color Shadow_2;2;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;182;-2856.888,-820.0831;Inherit;False;AlbedoTexture;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;50;-2392.6,-2542.978;Inherit;False;Property;_ColorShadow_1;Color Shadow_1;1;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.5188679,0.5188679,0.5188679,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;56;-2517.316,-330.4633;Inherit;False;1232.484;846.561;Light section;10;66;65;64;63;62;61;60;59;58;57;Light section;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;4;-2849.329,-1235.362;Inherit;False;NormalMap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;196;-2121.933,-2001.316;Inherit;False;182;AlbedoTexture;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;57;-2470.185,151.4098;Inherit;False;4;NormalMap;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;70;-4244.935,2.440183;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;51;-2080.349,-2279.302;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;170;-4339.835,-298.9916;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-1875.798,-2138.475;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;151;-3440.629,705.04;Inherit;False;1740.879;890.7217;Emission;15;145;125;179;175;95;100;178;184;177;96;185;188;189;192;193;Emission Section;1,1,1,1;0;0
Node;AmplifyShaderEditor.LightColorNode;59;-2272.918,-42.11713;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.IndirectDiffuseLighting;58;-2283.185,156.4097;Inherit;False;Tangent;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;169;-4159.841,-298.7525;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-4218.104,147.2691;Float;False;Property;_RimPower;Rim Power;12;0;Create;True;0;0;0;False;0;False;0;0;0;0.9;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;71;-4086.932,1.440198;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;60;-2259.185,244.4098;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;156;-3894.617,152.8881;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;80;-3617.008,156.8428;Float;False;Property;_RimColor;Rim Color;11;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightColorNode;78;-3571.523,335.8199;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.StepOpNode;174;-3927.505,-397.4294;Inherit;True;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;-1585.864,-2144.324;Inherit;False;AlbedoProperty;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;96;-3389.211,752.2028;Inherit;True;Property;_EmissionTexture;Emission Texture;5;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-2090.419,-42.5727;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;61;-2028.186,180.4097;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;75;-3908.932,0.4401979;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;100;-3063.232,956.6174;Inherit;False;Property;_EmissionTint;Emission Tint;4;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-3395.071,230.2578;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;81;-3670.241,-287.1995;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;185;-3012.09,1309.063;Inherit;False;Property;_Voronoitimescale;Voronoi time scale;16;0;Create;True;0;0;0;False;0;False;1;1.48;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;95;-3143.132,752.2502;Inherit;True;Property;_TextureSample4;Texture Sample 4;14;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;76;-3663.876,-0.3884611;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-1884.186,50.40979;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;-1942.941,-211.4632;Inherit;False;54;AlbedoProperty;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-3136.945,-21.73844;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-1699.918,-79.11685;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;145;-2722.9,880.6039;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleTimeNode;178;-2724.663,1314.432;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;177;-2827.044,1409.74;Inherit;False;Property;_Voronoiscale;Voronoi scale;15;0;Create;True;0;0;0;False;0;False;250;667.6471;100;1000;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;184;-2748.09,1174.063;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;192;-2766.701,1000.811;Inherit;False;Property;_Emissiontintstrength;Emission tint strength;17;0;Create;True;0;0;0;False;0;False;1;0;1;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;66;-1528.918,-83.11684;Inherit;False;Lighting;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VoronoiNode;175;-2391.688,1173.263;Inherit;True;0;1;1;2;2;False;5;False;True;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.OneMinusNode;189;-2795.147,757.8738;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;193;-2430.616,881.7827;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;84;-2869.96,-28.69908;Inherit;False;RimLight;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;179;-2158.07,881.5742;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;188;-2596.491,753.7197;Inherit;False;EmissionTexture;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;86;-640.009,586.4875;Inherit;False;66;Lighting;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;153;-642.8411,689.5366;Inherit;False;84;RimLight;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;190;-483.8079,436.2885;Inherit;False;188;EmissionTexture;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;18;-1194.808,-437.3538;Inherit;False;1372.759;661.6814;Ramp;5;25;23;22;20;19;Ramp - Shadow;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;154;-409.8411,629.5366;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;125;-1899.357,874.9415;Inherit;True;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;-2383.399,-2146.53;Inherit;False;20;RampShadow;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;191;-221.5171,548.1748;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;19;-840.5338,-279.6177;Inherit;True;Property;_RampTexture;Ramp Texture;6;0;Create;True;0;0;0;False;0;False;None;c92f04f3c507cb649aedb4ba2ff262d1;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;23;-1094.764,-57.6869;Inherit;False;11;Dot_Result_From_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;13;-2470.374,-1265.415;Inherit;False;4;NormalMap;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;25;-553.4673,-161.0141;Inherit;True;Property;_TextureSample1;Texture Sample 1;9;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;22;-799.8803,-53.24793;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;7;-2441.973,-740.6898;Inherit;False;4;NormalMap;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;20;-185.2592,-160.9142;Inherit;False;RampShadow;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;135;-264.3785,344.7422;Inherit;False;125;Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;134;10.07547,304.192;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;SinCity_Effect_Android;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;10;0;9;0
WireConnection;10;1;8;0
WireConnection;11;0;10;0
WireConnection;34;0;27;0
WireConnection;33;0;29;0
WireConnection;37;0;28;0
WireConnection;38;0;30;0
WireConnection;42;0;33;0
WireConnection;42;1;31;0
WireConnection;39;0;38;0
WireConnection;39;1;35;0
WireConnection;40;0;34;0
WireConnection;40;1;32;0
WireConnection;41;0;37;0
WireConnection;41;1;36;0
WireConnection;43;0;39;0
WireConnection;43;1;42;0
WireConnection;43;2;41;0
WireConnection;43;3;40;0
WireConnection;44;0;43;0
WireConnection;16;0;14;0
WireConnection;16;1;15;0
WireConnection;52;0;49;0
WireConnection;45;0;44;0
WireConnection;3;0;2;0
WireConnection;17;0;16;0
WireConnection;77;0;73;0
WireConnection;182;0;52;0
WireConnection;4;0;3;0
WireConnection;70;0;68;0
WireConnection;70;1;69;0
WireConnection;51;0;50;0
WireConnection;51;1;48;0
WireConnection;51;2;47;0
WireConnection;170;0;77;0
WireConnection;170;1;172;0
WireConnection;53;0;51;0
WireConnection;53;1;196;0
WireConnection;58;0;57;0
WireConnection;169;0;170;0
WireConnection;71;0;70;0
WireConnection;156;0;74;0
WireConnection;174;1;169;0
WireConnection;54;0;53;0
WireConnection;62;0;59;0
WireConnection;62;1;59;2
WireConnection;61;0;58;0
WireConnection;61;1;60;0
WireConnection;75;0;71;0
WireConnection;82;0;80;0
WireConnection;82;1;78;0
WireConnection;81;0;174;0
WireConnection;95;0;96;0
WireConnection;76;0;75;0
WireConnection;76;1;156;0
WireConnection;63;0;62;0
WireConnection;63;1;61;0
WireConnection;83;0;81;0
WireConnection;83;1;76;0
WireConnection;83;2;82;0
WireConnection;65;0;64;0
WireConnection;65;1;63;0
WireConnection;145;0;95;0
WireConnection;145;1;100;0
WireConnection;178;0;185;0
WireConnection;66;0;65;0
WireConnection;175;0;184;0
WireConnection;175;1;178;0
WireConnection;175;2;177;0
WireConnection;189;0;95;0
WireConnection;193;0;145;0
WireConnection;193;1;192;0
WireConnection;84;0;83;0
WireConnection;179;0;193;0
WireConnection;179;1;175;0
WireConnection;188;0;189;0
WireConnection;154;0;86;0
WireConnection;154;1;153;0
WireConnection;125;0;179;0
WireConnection;191;0;190;0
WireConnection;191;1;154;0
WireConnection;25;0;19;0
WireConnection;25;1;22;0
WireConnection;22;0;23;0
WireConnection;20;0;25;0
WireConnection;134;2;135;0
WireConnection;134;13;191;0
ASEEND*/
//CHKSM=0BF8313C898E46515E399CBCEFB418E608E484E0