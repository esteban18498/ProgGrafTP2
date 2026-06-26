// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "HeightMap"
{
	Properties
	{
		_Heightmap1("Heightmap1", 2D) = "white" {}
		_Heightmap2("Heightmap2", 2D) = "white" {}
		_Albedo("Albedo", 2D) = "white" {}
		_HMap1Mult("HMap1 Mult", Range( 0 , 0.7)) = 0
		_HMap2Mult("HMap2 Mult", Range( 0 , 1)) = 0
		_ClampHeight("ClampHeight", Range( 0 , 1)) = 1
		_LerpHeightmaps("Lerp Heightmaps", Range( 0 , 1)) = 0.3
		_ScaleY("Scale Y", Range( 10 , 50)) = 10
		_ScaleX("Scale X", Range( 10 , 50)) = 10
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "Tessellation.cginc"
		#pragma target 4.6
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float3 worldPos;
		};

		uniform sampler2D _Heightmap1;
		uniform float _ScaleX;
		uniform float _ScaleY;
		uniform float _HMap1Mult;
		uniform sampler2D _Heightmap2;
		uniform float4 _Heightmap2_ST;
		uniform float _HMap2Mult;
		uniform float _LerpHeightmaps;
		uniform float _ClampHeight;
		uniform sampler2D _Albedo;

		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, 0.0);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float2 appendResult105 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 appendResult124 = (float2(_ScaleX , _ScaleY));
			float2 UVScale111 = ( appendResult105 / appendResult124 );
			float2 uv_Heightmap2 = v.texcoord * _Heightmap2_ST.xy + _Heightmap2_ST.zw;
			float4 lerpResult84 = lerp( ( tex2Dlod( _Heightmap1, float4( UVScale111, 0, 0.0) ) * float4( float3(0,1,0) , 0.0 ) * _HMap1Mult ) , ( tex2Dlod( _Heightmap2, float4( uv_Heightmap2, 0, 0.0) ) * float4( float3(0,1,0) , 0.0 ) * _HMap2Mult ) , _LerpHeightmaps);
			float4 break81 = lerpResult84;
			float clampResult83 = clamp( break81.g , 0.0 , _ClampHeight );
			float4 appendResult82 = (float4(break81.r , clampResult83 , break81.b , 0.0));
			v.vertex.xyz += appendResult82.xyz;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float2 appendResult105 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 appendResult124 = (float2(_ScaleX , _ScaleY));
			float2 UVScale111 = ( appendResult105 / appendResult124 );
			o.Albedo = tex2D( _Albedo, UVScale111 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
2;814;2546;604;918.2666;167.6534;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;112;-1182.086,-816.4671;Inherit;False;1362.45;414.9139;UVs by World Position;7;111;108;105;103;124;126;127;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;126;-950.0486,-495.5354;Inherit;False;Property;_ScaleY;Scale Y;7;0;Create;True;0;0;0;False;0;False;10;0;10;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;127;-965.0486,-575.5354;Inherit;False;Property;_ScaleX;Scale X;8;0;Create;True;0;0;0;False;0;False;10;10;10;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;103;-1124.396,-766.4673;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;105;-768.3835,-753.4452;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;124;-676.0486,-577.5354;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;108;-496.0876,-708.0059;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;59;-1196.075,341.0822;Inherit;False;929.6606;609.0651;Bricks;5;69;66;65;61;60;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;58;-1190.052,-339.5295;Inherit;False;929.6606;609.0651;SandOffSet;6;68;67;64;63;62;93;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;111;-25.68731,-593.5332;Inherit;False;UVScale;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;61;-1146.074,396.4832;Inherit;True;Property;_Heightmap2;Heightmap2;1;0;Create;True;0;0;0;False;0;False;9789d23040cb1fb45ad60392430c3c15;9789d23040cb1fb45ad60392430c3c15;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;93;-1042.643,-9.177917;Inherit;True;111;UVScale;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;62;-1140.052,-284.1285;Inherit;True;Property;_Heightmap1;Heightmap1;0;0;Create;True;0;0;0;False;0;False;0bc54efceb10bb04f9d2ceccad88cbe8;5afe5582df30721448e7a290c5c73fbb;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.Vector3Node;64;-732.1005,-56.46008;Inherit;False;Constant;_Vector2;Vector 2;1;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;63;-871.8556,-289.5294;Inherit;True;Property;_TextureSample5;Texture Sample 5;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;67;-726.2416,153.5348;Inherit;False;Property;_HMap1Mult;HMap1 Mult;3;0;Create;True;0;0;0;False;0;False;0;0;0;0.7;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-732.2623,834.1476;Inherit;False;Property;_HMap2Mult;HMap2 Mult;4;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;66;-738.1223,624.152;Inherit;False;Constant;_Direction;Direction;1;0;Create;True;0;0;0;False;0;False;0,1,0;0,1,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;65;-877.8763,391.0822;Inherit;True;Property;_TextureSample3;Texture Sample 3;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;85;-61.8214,115.8141;Inherit;False;Property;_LerpHeightmaps;Lerp Heightmaps;6;0;Create;True;0;0;0;False;0;False;0.3;1.55;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-447.0906,-228.2366;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-428.4113,457.5751;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;79;437.9424,13.48978;Inherit;False;688.1;383.3;Clamp Height;4;83;82;81;80;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;84;174.8843,73.7404;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;81;487.9425,75.78905;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;80;528.9424,280.7892;Inherit;False;Property;_ClampHeight;ClampHeight;5;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;123;371.559,-499.3162;Inherit;False;663.8959;384.2195;Albedo;3;73;98;75;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;98;502.8906,-231.0967;Inherit;False;111;UVScale;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;83;720.2424,171.2892;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;73;421.559,-449.3162;Inherit;True;Property;_Albedo;Albedo;2;0;Create;True;0;0;0;False;0;False;97be2fca38ea3d74697518f3fd6681f3;1d5d9561a88dd694cbd6597eed64e574;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;75;715.4549,-427.835;Inherit;True;Property;_TextureSample6;Texture Sample 6;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;82;965.0424,63.48907;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.EdgeLengthTessNode;8;1215.697,140.3751;Inherit;False;1;0;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1454.871,-222.3984;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;HeightMap;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;2;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;105;0;103;1
WireConnection;105;1;103;3
WireConnection;124;0;127;0
WireConnection;124;1;126;0
WireConnection;108;0;105;0
WireConnection;108;1;124;0
WireConnection;111;0;108;0
WireConnection;63;0;62;0
WireConnection;63;1;93;0
WireConnection;65;0;61;0
WireConnection;68;0;63;0
WireConnection;68;1;64;0
WireConnection;68;2;67;0
WireConnection;69;0;65;0
WireConnection;69;1;66;0
WireConnection;69;2;60;0
WireConnection;84;0;68;0
WireConnection;84;1;69;0
WireConnection;84;2;85;0
WireConnection;81;0;84;0
WireConnection;83;0;81;1
WireConnection;83;2;80;0
WireConnection;75;0;73;0
WireConnection;75;1;98;0
WireConnection;82;0;81;0
WireConnection;82;1;83;0
WireConnection;82;2;81;2
WireConnection;0;0;75;0
WireConnection;0;11;82;0
WireConnection;0;14;8;0
ASEEND*/
//CHKSM=40777F2223163CEA91C79A349B16065DAE5EF417