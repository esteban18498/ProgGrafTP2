// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Island"
{
	Properties
	{
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		[HideInInspector]_TerrainHolesTexture("_TerrainHolesTexture", 2D) = "white" {}
		[Toggle(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)] _EnablePerpixelNormals("Enable Per-pixel Normals", Float) = 0
		[HideInInspector]_Mask2("_Mask2", 2D) = "white" {}
		[HideInInspector]_Mask0("_Mask0", 2D) = "white" {}
		[HideInInspector]_Mask1("_Mask1", 2D) = "white" {}
		[HideInInspector]_Mask3("_Mask3", 2D) = "white" {}
		_Tessellation_Min_Distance("Tessellation_Min_Distance", Range( 0 , 100)) = 0
		_Tessellation_Max_Distance("Tessellation_Max_Distance", Range( 0 , 100)) = 0
		_Tesselation("Tesselation", Range( 1 , 10)) = 8.376471
		_IslandMinimumHeight("Island Minimum Height", Range( -10 , 0)) = -1
		_IslandMaximumHeight("Island Maximum Height", Range( 0 , 20)) = 17.64826
		_HeightmapStrength("Heightmap Strength", Range( 0 , 10)) = 3.689999
		_MaskClipValue("Mask Clip Value", Range( 0 , 0.5)) = 0
		_TextureSample4("Texture Sample 3", 2D) = "white" {}
		_NormalScale("NormalScale", Range( 0 , 1)) = 0.1
		_Island_AlphaMask("Island_AlphaMask", Range( 0 , 0.5)) = 0.5
		_HeightTexture("HeightTexture", 2D) = "white" {}
		_TextureSample1("Texture Sample 1", 2D) = "bump" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#include "Tessellation.cginc"
		#pragma target 4.6
		#pragma shader_feature_local _TERRAIN_INSTANCED_PERPIXEL_NORMAL
		#pragma multi_compile_local __ _ALPHATEST_ON
		#pragma shader_feature_local _MASKMAP
		#pragma surface surf Lambert keepalpha addshadow fullforwardshadows vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
		};

		uniform sampler2D _Mask1;
		uniform sampler2D _Mask0;
		uniform sampler2D _Mask3;
		uniform sampler2D _Mask2;
		uniform float4 _MaskMapRemapScale1;
		uniform float4 _MaskMapRemapScale0;
		uniform float4 _MaskMapRemapOffset1;
		uniform float4 _MaskMapRemapOffset2;
		uniform float4 _MaskMapRemapScale2;
		uniform float4 _MaskMapRemapScale3;
		uniform float4 _MaskMapRemapOffset0;
		uniform float4 _MaskMapRemapOffset3;
		uniform sampler2D _HeightTexture;
		uniform float4 _HeightTexture_ST;
		uniform float _HeightmapStrength;
		uniform float _IslandMinimumHeight;
		uniform float _IslandMaximumHeight;
		uniform sampler2D _TextureSample1;
		uniform float _NormalScale;
		uniform sampler2D _TextureSample4;
		uniform float4 _TextureSample4_ST;
		uniform sampler2D _TextureSample0;
		uniform sampler2D _TerrainHolesTexture;
		uniform float4 _TerrainHolesTexture_ST;
		uniform float _Island_AlphaMask;
		uniform float _Tessellation_Min_Distance;
		uniform float _Tessellation_Max_Distance;
		uniform float _Tesselation;
		uniform float _MaskClipValue;

		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityDistanceBasedTess( v0.vertex, v1.vertex, v2.vertex, _Tessellation_Min_Distance,_Tessellation_Max_Distance,_Tesselation);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float2 uv_HeightTexture = v.texcoord * _HeightTexture_ST.xy + _HeightTexture_ST.zw;
			float4 appendResult28 = (float4(0.0 , ( tex2Dlod( _HeightTexture, float4( uv_HeightTexture, 0, 0.0) ).g * _HeightmapStrength ) , 0.0 , 0.0));
			float4 temp_cast_0 = (_IslandMinimumHeight).xxxx;
			float4 temp_cast_1 = (_IslandMaximumHeight).xxxx;
			float4 clampResult23 = clamp( ( appendResult28 * _HeightmapStrength ) , temp_cast_0 , temp_cast_1 );
			v.vertex.xyz += clampResult23.xyz;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldPos = i.worldPos;
			float4 appendResult7 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			float4 WorldPositionUV8 = appendResult7;
			float3 temp_output_61_0_g1 = UnpackScaleNormal( tex2D( _TextureSample1, WorldPositionUV8.xy ), _NormalScale );
			#ifdef _TERRAIN_INSTANCED_PERPIXEL_NORMAL
				float3 staticSwitch84_g1 = temp_output_61_0_g1;
			#else
				float3 staticSwitch84_g1 = temp_output_61_0_g1;
			#endif
			o.Normal = staticSwitch84_g1;
			float2 uv_TextureSample4 = i.uv_texcoord * _TextureSample4_ST.xy + _TextureSample4_ST.zw;
			float4 clampResult36 = clamp( ( tex2D( _TextureSample4, uv_TextureSample4 ) * tex2D( _TextureSample0, WorldPositionUV8.xy ) ) , float4( 0.1981132,0.1256519,0.05700427,0 ) , float4( 1,1,1,0 ) );
			float4 temp_output_60_0_g1 = clampResult36;
			float4 localClipHoles100_g1 = ( temp_output_60_0_g1 );
			float2 uv_TerrainHolesTexture = i.uv_texcoord * _TerrainHolesTexture_ST.xy + _TerrainHolesTexture_ST.zw;
			float holeClipValue99_g1 = tex2D( _TerrainHolesTexture, uv_TerrainHolesTexture ).r;
			float Hole100_g1 = holeClipValue99_g1;
			{
			#ifdef _ALPHATEST_ON
				clip(Hole100_g1 == 0.0f ? -1 : 1);
			#endif
			}
			o.Albedo = localClipHoles100_g1.xyz;
			o.Alpha = 1;
			float2 uv_HeightTexture = i.uv_texcoord * _HeightTexture_ST.xy + _HeightTexture_ST.zw;
			clip( (( tex2D( _HeightTexture, uv_HeightTexture ) + _Island_AlphaMask )).g - _MaskClipValue );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
7;388;1920;623;1590.648;-392.0878;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;9;-2396.826,-639.7609;Inherit;False;675.0381;303.2902;World Position UV;3;8;7;6;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;20;-2164.057,112.9891;Inherit;False;1260.338;565.6445;Height Map;7;17;16;19;18;26;27;28;Height Map;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;6;-2346.825,-588.5135;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexturePropertyNode;16;-2154.959,173.8227;Inherit;True;Property;_HeightTexture;HeightTexture;36;0;Create;True;0;0;0;False;0;False;None;214dc6b9f1e165042b56cf5fb036c3ad;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;17;-1861.454,175.9476;Inherit;True;Property;_TextureSample2;Texture Sample 2;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;7;-2134.806,-589.7608;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-1846.219,449.0337;Inherit;False;Property;_HeightmapStrength;Heightmap Strength;30;0;Create;True;0;0;0;False;0;False;3.689999;3.689999;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;40;-1470.604,-1014.881;Inherit;False;778.601;493.7401;Albedo based on Height;4;34;1;35;36;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;42;-1525.46,-176.7552;Inherit;False;1009.144;280;Mask - Cortar terreno;4;32;29;31;37;Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;8;-1987.638,-578.5363;Inherit;False;WorldPositionUV;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BreakToComponentsNode;26;-1530.038,263.4039;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.CommentaryNode;41;-1443.339,-491.4676;Inherit;False;627.6;273.6;Normals;2;2;33;Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;1;-1411.063,-751.1407;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;662d72b6ec210cf4cbeec2b4d3cb8b2a;662d72b6ec210cf4cbeec2b4d3cb8b2a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-1392.77,435.6628;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;29;-1475.46,-126.755;Inherit;True;Property;_TextureSample3;Texture Sample 3;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;34;-1420.604,-964.8808;Inherit;True;Property;_TextureSample4;Texture Sample 3;32;0;Create;True;0;0;0;False;0;False;-1;None;214dc6b9f1e165042b56cf5fb036c3ad;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;32;-1161.326,-33.88245;Inherit;False;Property;_Island_AlphaMask;Island_AlphaMask;35;0;Create;True;0;0;0;False;0;False;0.5;0.401;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;31;-876.6413,-121.4532;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-1427.815,-315.1361;Inherit;False;Property;_NormalScale;NormalScale;34;0;Create;True;0;0;0;False;0;False;0.1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;28;-1227.319,260.6203;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;24;-856.1433,125.4146;Inherit;False;556;390;Amecetamiento;3;23;21;22;Amecetamiento;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;39;-861.855,557.3369;Inherit;False;642.2681;304.5333;Tessellation;4;43;25;3;44;Tessellation;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-1058.603,-816.6805;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-806.6476,773.0878;Inherit;False;Property;_Tessellation_Max_Distance;Tessellation_Max_Distance;26;0;Create;True;0;0;0;False;0;False;0;80;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-781.7025,-292.2472;Inherit;False;Property;_Smoothness;Smoothness;33;0;Create;True;0;0;0;False;0;False;0.85;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-811.855,607.3369;Inherit;False;Property;_Tesselation;Tesselation;27;0;Create;True;0;0;0;False;0;False;8.376471;8.71;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-806.1433,315.415;Inherit;False;Property;_IslandMinimumHeight;Island Minimum Height;28;0;Create;True;0;0;0;False;0;False;-1;-2.03;-10;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-806.1433,396.4152;Inherit;False;Property;_IslandMaximumHeight;Island Maximum Height;29;0;Create;True;0;0;0;False;0;False;17.64826;8.4;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;37;-739.3157,-96.30737;Inherit;False;False;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-1061.72,258.5332;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;2;-1124.539,-447.8676;Inherit;True;Property;_TextureSample1;Texture Sample 1;37;0;Create;True;0;0;0;False;0;False;-1;f53512d44b91e954dae7bf028209df1a;f53512d44b91e954dae7bf028209df1a;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;43;-804.6476,696.0878;Inherit;False;Property;_Tessellation_Min_Distance;Tessellation_Min_Distance;25;0;Create;True;0;0;0;False;0;False;0;0;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;36;-863.0027,-800.0802;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0.1981132,0.1256519,0.05700427,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;23;-471.1432,175.4147;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT4;1,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;13;-428.7032,-367.027;Inherit;False;Four Splats First Pass Terrain;1;;1;37452fdfb732e1443b7e39720d05b708;2,85,1,102,1;7;59;FLOAT4;0,0,0,0;False;60;FLOAT4;0,0,0,0;False;61;FLOAT3;0,0,0;False;57;FLOAT;0;False;58;FLOAT;0;False;201;FLOAT;0;False;62;FLOAT;0;False;7;FLOAT4;0;FLOAT3;14;FLOAT;56;FLOAT;45;FLOAT;200;FLOAT;19;FLOAT3;17
Node;AmplifyShaderEditor.DistanceBasedTessNode;25;-474.5874,631.8702;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;80;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-819.1134,919.2971;Inherit;False;Property;_MaskClipValue;Mask Clip Value;31;0;Create;True;0;0;0;False;0;False;0;0.363;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;54,-142;Float;False;True;-1;6;ASEMaterialInspector;0;0;Lambert;Island;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.4;True;True;0;True;Transparent;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;True;38;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;17;0;16;0
WireConnection;7;0;6;1
WireConnection;7;1;6;3
WireConnection;8;0;7;0
WireConnection;26;0;17;0
WireConnection;1;1;8;0
WireConnection;27;0;26;1
WireConnection;27;1;19;0
WireConnection;29;0;16;0
WireConnection;31;0;29;0
WireConnection;31;1;32;0
WireConnection;28;1;27;0
WireConnection;35;0;34;0
WireConnection;35;1;1;0
WireConnection;37;0;31;0
WireConnection;18;0;28;0
WireConnection;18;1;19;0
WireConnection;2;1;8;0
WireConnection;2;5;33;0
WireConnection;36;0;35;0
WireConnection;23;0;18;0
WireConnection;23;1;21;0
WireConnection;23;2;22;0
WireConnection;13;60;36;0
WireConnection;13;61;2;0
WireConnection;13;58;14;0
WireConnection;13;62;37;0
WireConnection;25;0;3;0
WireConnection;25;1;43;0
WireConnection;25;2;44;0
WireConnection;0;0;13;0
WireConnection;0;1;13;14
WireConnection;0;10;13;19
WireConnection;0;11;23;0
WireConnection;0;14;25;0
ASEEND*/
//CHKSM=E0F75CBAADFD79D24C48DA515483C1FBA4018F82