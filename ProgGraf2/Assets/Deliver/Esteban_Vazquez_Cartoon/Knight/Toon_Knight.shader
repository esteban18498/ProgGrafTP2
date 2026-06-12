// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Toon_Knight"
{
	Properties
	{
		_ASEOutlineColor( "Outline Color", Color ) = (0,0,0,0)
		_ASEOutlineWidth( "Outline Width", Float ) = 0.02
		_BaseTexture("Base Texture", 2D) = "white" {}
		_Step0("Step 0", Range( 0 , 1)) = 1
		_Step1("Step 1", Range( 0 , 1)) = 0.5
		_Step2("Step 2", Range( 0 , 1)) = 0.5
		_Step3("Step 3", Range( 0 , 1)) = 0.5
		_Step4("Step 4", Range( 0 , 1)) = 0.5
		_FresnelOutlinethickness("Fresnel Outline thickness", Range( 0 , 1)) = 0.66
		_FresneloutlineColor("Fresnel outline Color", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ }
		Cull Front
		CGPROGRAM
		#pragma target 3.0
		#pragma surface outlineSurf Outline nofog  keepalpha noshadow noambient novertexlights nolightmap nodynlightmap nodirlightmap nometa noforwardadd vertex:outlineVertexDataFunc 
		
		float4 _ASEOutlineColor;
		float _ASEOutlineWidth;
		void outlineVertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			v.vertex.xyz += ( v.normal * _ASEOutlineWidth );
		}
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) { return half4 ( 0,0,0, s.Alpha); }
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			o.Emission = _ASEOutlineColor.rgb;
			o.Alpha = 1;
		}
		ENDCG
		

		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
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
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
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

		uniform sampler2D _BaseTexture;
		uniform float4 _BaseTexture_ST;
		uniform float _Step0;
		float4 _BaseTexture_TexelSize;
		uniform float _Step1;
		uniform float _Step2;
		uniform float _Step3;
		uniform float _Step4;
		uniform float _FresnelOutlinethickness;
		uniform float4 _FresneloutlineColor;


		float3 CombineSamplesSharp128_g1( float S0, float S1, float S2, float Strength )
		{
			{
			    float3 va = float3( 0.13, 0, ( S1 - S0 ) * Strength );
			    float3 vb = float3( 0, 0.13, ( S2 - S0 ) * Strength );
			    return normalize( cross( va, vb ) );
			}
		}


		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float2 uv_BaseTexture = i.uv_texcoord * _BaseTexture_ST.xy + _BaseTexture_ST.zw;
			float localCalculateUVsSharp110_g1 = ( 0.0 );
			float2 temp_output_85_0_g1 = uv_BaseTexture;
			float2 UV110_g1 = temp_output_85_0_g1;
			float4 TexelSize110_g1 = _BaseTexture_TexelSize;
			float2 UV0110_g1 = float2( 0,0 );
			float2 UV1110_g1 = float2( 0,0 );
			float2 UV2110_g1 = float2( 0,0 );
			{
			{
			    UV110_g1.y -= TexelSize110_g1.y * 0.5;
			    UV0110_g1 = UV110_g1;
			    UV1110_g1 = UV110_g1 + float2( TexelSize110_g1.x, 0 );
			    UV2110_g1 = UV110_g1 + float2( 0, TexelSize110_g1.y );
			}
			}
			float4 break134_g1 = tex2D( _BaseTexture, UV0110_g1 );
			float S0128_g1 = break134_g1.r;
			float4 break136_g1 = tex2D( _BaseTexture, UV1110_g1 );
			float S1128_g1 = break136_g1.r;
			float4 break138_g1 = tex2D( _BaseTexture, UV2110_g1 );
			float S2128_g1 = break138_g1.r;
			float temp_output_91_0_g1 = 1.5;
			float Strength128_g1 = temp_output_91_0_g1;
			float3 localCombineSamplesSharp128_g1 = CombineSamplesSharp128_g1( S0128_g1 , S1128_g1 , S2128_g1 , Strength128_g1 );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
			float3 tangentToWorldDir68_g1 = mul( ase_tangentToWorldFast, localCombineSamplesSharp128_g1 );
			float3 customnormal44 = tangentToWorldDir68_g1;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult6 = dot( customnormal44 , ase_worldlightDir );
			float Local_Light8 = dotResult6;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float fresnelNdotV34 = dot( customnormal44, ase_worldViewDir );
			float fresnelNode34 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV34, 1.0 ) );
			float temp_output_36_0 = step( (1.0 + (_FresnelOutlinethickness - 0.0) * (0.1 - 1.0) / (1.0 - 0.0)) , max( fresnelNode34 , 0.0 ) );
			c.rgb = ( ( tex2D( _BaseTexture, uv_BaseTexture ) * ( ( step( (-1.0 + (_Step0 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) , Local_Light8 ) + step( (-1.0 + (_Step1 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) , Local_Light8 ) + step( (-1.0 + (_Step2 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) , Local_Light8 ) + step( (-1.0 + (_Step3 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) , Local_Light8 ) + step( (-1.0 + (_Step4 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) , Local_Light8 ) ) / 4.0 ) * ( 1.0 - temp_output_36_0 ) ) + ( _FresneloutlineColor * temp_output_36_0 ) ).rgb;
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
668;73;884;575;2383.601;230.9552;1.3;True;False
Node;AmplifyShaderEditor.TexturePropertyNode;1;-679.205,-202.264;Inherit;True;Property;_BaseTexture;Base Texture;0;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.FunctionNode;31;-363.8687,-390.0777;Inherit;False;Normal From Texture;-1;;1;9728ee98a55193249b513caf9a0f1676;13,149,0,147,0,143,0,141,0,139,0,151,0,137,0,153,0,159,0,157,0,155,0,135,0,108,0;4;87;SAMPLER2D;0;False;85;FLOAT2;0,0;False;74;SAMPLERSTATE;0;False;91;FLOAT;1.5;False;2;FLOAT3;40;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;44;-65.58396,-367.6295;Inherit;False;customnormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;3;-2008.69,39.25261;Inherit;False;1130.713;1943.944;Toon;26;29;28;27;26;25;24;23;22;21;20;19;18;17;16;15;14;13;12;11;10;9;8;7;6;5;4;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;45;-1978.092,-64.61661;Inherit;False;44;customnormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;4;-1790.657,265.6815;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;6;-1550.717,163.9861;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;47;-676.064,848.7346;Inherit;False;1410.86;957.3022;Outline;10;41;42;36;37;35;38;34;32;33;46;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1971.919,1348.334;Inherit;False;Property;_Step3;Step 3;4;0;Create;True;0;0;0;False;0;False;0.5;0.876;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1968.681,1663.591;Inherit;False;Property;_Step4;Step 4;5;0;Create;True;0;0;0;False;0;False;0.5;0.988;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-630.3154,1592.695;Inherit;False;Constant;_FresnelPow;Fresnel Pow;6;0;Create;True;0;0;0;False;0;False;1;1;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;8;-1282.221,164.2464;Inherit;False;Local_Light;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-1967.503,461.7134;Inherit;False;Property;_Step0;Step 0;1;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-1963.739,747.1941;Inherit;False;Property;_Step1;Step 1;2;0;Create;True;0;0;0;False;0;False;0.5;0.54;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-634.7803,1499.044;Inherit;False;Constant;_FresnelScale;Fresnel Scale;6;0;Create;True;0;0;0;False;0;False;1;1.45;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;-567.3784,1393.542;Inherit;False;44;customnormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1965.717,1034.591;Inherit;False;Property;_Step2;Step 2;3;0;Create;True;0;0;0;False;0;False;0.5;0.695;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;13;-1662.859,1862.831;Inherit;False;8;Local_Light;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;22;-1665.14,1046.429;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;14;-1669.952,944.2613;Inherit;False;8;Local_Light;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;34;-332.8278,1449.049;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;30.79;False;3;FLOAT;0.78;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;16;-1671.343,1360.171;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;17;-1671.93,1231.659;Inherit;False;8;Local_Light;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;21;-1663.162,759.0311;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-1666.097,1547.574;Inherit;False;8;Local_Light;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-243.7978,1208.33;Inherit;False;Property;_FresnelOutlinethickness;Fresnel Outline thickness;6;0;Create;True;0;0;0;False;0;False;0.66;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;18;-1668.105,1675.428;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;15;-1673.715,658.7816;Inherit;False;8;Local_Light;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;19;-1666.925,473.5516;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;35;-15.28965,1454.142;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;25;-1425.507,1199.673;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;24;-1449.701,1827.853;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;27;-1423.529,912.2748;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;37;96.22437,1221.784;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;26;-1427.292,626.795;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;23;-1452.939,1512.596;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;36;331.1874,1210.894;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-1159.363,642.9476;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;29;-1020.951,642.9758;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;42;336.3115,991.9121;Inherit;False;Property;_FresneloutlineColor;Fresnel outline Color;7;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-392.828,-125.1046;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;40;-175.402,558.4037;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-258.9516,259.5123;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;561.6857,1163.29;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;43;151.7973,237.6981;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldNormalVector;5;-1795.797,91.8728;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;460.3562,19.7699;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Toon_Knight;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;True;0.02;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;31;87;1;0
WireConnection;44;0;31;0
WireConnection;6;0;45;0
WireConnection;6;1;4;0
WireConnection;8;0;6;0
WireConnection;22;0;7;0
WireConnection;34;0;46;0
WireConnection;34;2;32;0
WireConnection;34;3;33;0
WireConnection;16;0;11;0
WireConnection;21;0;12;0
WireConnection;18;0;10;0
WireConnection;19;0;9;0
WireConnection;35;0;34;0
WireConnection;25;0;22;0
WireConnection;25;1;17;0
WireConnection;24;0;18;0
WireConnection;24;1;13;0
WireConnection;27;0;21;0
WireConnection;27;1;14;0
WireConnection;37;0;38;0
WireConnection;26;0;19;0
WireConnection;26;1;15;0
WireConnection;23;0;16;0
WireConnection;23;1;20;0
WireConnection;36;0;37;0
WireConnection;36;1;35;0
WireConnection;28;0;26;0
WireConnection;28;1;27;0
WireConnection;28;2;25;0
WireConnection;28;3;23;0
WireConnection;28;4;24;0
WireConnection;29;0;28;0
WireConnection;2;0;1;0
WireConnection;40;0;36;0
WireConnection;30;0;2;0
WireConnection;30;1;29;0
WireConnection;30;2;40;0
WireConnection;41;0;42;0
WireConnection;41;1;36;0
WireConnection;43;0;30;0
WireConnection;43;1;41;0
WireConnection;5;0;45;0
WireConnection;0;13;43;0
ASEEND*/
//CHKSM=D1015E50D9105B5609916561AFD1F00D2F7422EA