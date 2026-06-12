// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "HeightMap"
{
	Properties
	{
		_Heightmap1("Heightmap1", 2D) = "white" {}
		_Texture("Texture", 2D) = "white" {}
		_maxHeight("maxHeight", Range( -1 , 5)) = 0
		_minHeight("minHeight", Range( -1 , 5)) = 0
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
			float2 uv_texcoord;
		};

		uniform sampler2D _Heightmap1;
		uniform float4 _Heightmap1_ST;
		uniform float _minHeight;
		uniform float _maxHeight;
		uniform sampler2D _Texture;
		uniform float4 _Texture_ST;

		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, 0.0);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float2 uv_Heightmap1 = v.texcoord * _Heightmap1_ST.xy + _Heightmap1_ST.zw;
			float4 temp_cast_1 = (_minHeight).xxxx;
			float4 temp_cast_2 = (_maxHeight).xxxx;
			float4 clampResult13 = clamp( ( tex2Dlod( _Heightmap1, float4( uv_Heightmap1, 0, 0.0) ) * float4( float3(0,1,0) , 0.0 ) ) , temp_cast_1 , temp_cast_2 );
			v.vertex.xyz += clampResult13.rgb;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Texture = i.uv_texcoord * _Texture_ST.xy + _Texture_ST.zw;
			o.Albedo = tex2D( _Texture, uv_Texture ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
-7;1025;2560;334;2762.051;562.0493;1.729264;True;True
Node;AmplifyShaderEditor.TexturePropertyNode;3;-1654.383,157.9485;Inherit;True;Property;_Heightmap1;Heightmap1;0;0;Create;True;0;0;0;False;0;False;9789d23040cb1fb45ad60392430c3c15;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.Vector3Node;6;-1296.285,445.2485;Inherit;False;Constant;_Vector0;Vector 0;1;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;4;-1339.385,177.2485;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;7;-1395.285,837.2485;Inherit;False;Property;_maxHeight;maxHeight;2;0;Create;True;0;0;0;False;0;False;0;0;-1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-1411.508,732.3151;Inherit;False;Property;_minHeight;minHeight;3;0;Create;True;0;0;0;False;0;False;0;0;-1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-721.1846,299.8484;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;10;-1113.76,-35.28719;Inherit;True;Property;_Texture;Texture;1;0;Create;True;0;0;0;False;0;False;662d72b6ec210cf4cbeec2b4d3cb8b2a;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.EdgeLengthTessNode;8;-202.7153,533.9086;Inherit;False;1;0;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ClampOpNode;13;-490.608,319.5151;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;11;-822.7606,-31.28719;Inherit;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;HeightMap;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;4;0;3;0
WireConnection;5;0;4;0
WireConnection;5;1;6;0
WireConnection;13;0;5;0
WireConnection;13;1;14;0
WireConnection;13;2;7;0
WireConnection;11;0;10;0
WireConnection;0;0;11;0
WireConnection;0;11;13;0
WireConnection;0;14;8;0
ASEEND*/
//CHKSM=8A11900461098B5E419D0F49812EFD5F3FEDC960