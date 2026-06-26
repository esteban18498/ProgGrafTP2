// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Callejon"
{
	Properties
	{
		_BrickColorTex("BrickColorTex", 2D) = "white" {}
		_BrickNormals("BrickNormals", 2D) = "white" {}
		_BrickHeight("BrickHeight", 2D) = "white" {}
		_BrickAlbedo("BrickAlbedo", Color) = (0.3396226,0.2158052,0.1906372,0)
		_BaseTextureScale("BaseTextureScale", Vector) = (0,0,0,0)
		_DirtTex("DirtTex", 2D) = "white" {}
		_DirtAlbedo("DirtAlbedo", Color) = (1,1,1,0)
		_DirtScale("DirtScale", Float) = 1
		_LowBorderTex("LowBorderTex", 2D) = "white" {}
		_LowBorderNormals("LowBorderNormals", 2D) = "bump" {}
		_LowBorderHeight("LowBorderHeight", 2D) = "white" {}
		_LowBorderAlbedo("LowBorderAlbedo", Color) = (1,1,1,0)
		_LowBorderTexScale("LowBorderTexScale", Vector) = (0,0,0,0)
		_LowBorderDistance("LowBorderDistance", Float) = 0
		_LowBorderDisplacement("LowBorderDisplacement", Float) = 2
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "Tessellation.cginc"
		#pragma target 4.6
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float3 worldPos;
		};

		uniform sampler2D _BrickHeight;
		uniform float2 _BaseTextureScale;
		uniform float _LowBorderDistance;
		uniform sampler2D _LowBorderHeight;
		uniform float2 _LowBorderTexScale;
		uniform float _LowBorderDisplacement;
		uniform sampler2D _BrickNormals;
		uniform sampler2D _LowBorderNormals;
		uniform sampler2D _DirtTex;
		uniform float4 _DirtAlbedo;
		uniform float _DirtScale;
		uniform sampler2D _BrickColorTex;
		uniform float4 _BrickAlbedo;
		uniform sampler2D _LowBorderTex;
		uniform float4 _LowBorderAlbedo;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, 0.1);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float2 appendResult4 = (float2(ase_worldPos.x , ase_worldPos.y));
			float2 ScaledUVs57 = ( appendResult4 / _BaseTextureScale );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float LowBorder82 = step( ase_vertex3Pos.z , _LowBorderDistance );
			float2 UVs54 = appendResult4;
			float2 LowBorderScaledUVs93 = ( UVs54 / _LowBorderTexScale );
			float4 appendResult79 = (float4(0.0 , _LowBorderDisplacement , 0.0 , 0.0));
			float4 HEIGHT130 = ( ( ( tex2Dlod( _BrickHeight, float4( ScaledUVs57, 0, 0.0) ) * float4( float3(0,1,0) , 0.0 ) ) * LowBorder82 ) + ( ( tex2Dlod( _LowBorderHeight, float4( LowBorderScaledUVs93, 0, 0.0) ) + appendResult79 ) * float4( float3(0,0.3,0) , 0.0 ) * ( 1.0 - LowBorder82 ) ) );
			v.vertex.xyz += HEIGHT130.rgb;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float2 appendResult4 = (float2(ase_worldPos.x , ase_worldPos.y));
			float2 ScaledUVs57 = ( appendResult4 / _BaseTextureScale );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float LowBorder82 = step( ase_vertex3Pos.z , _LowBorderDistance );
			float2 UVs54 = appendResult4;
			float2 LowBorderScaledUVs93 = ( UVs54 / _LowBorderTexScale );
			float4 NORMALS142 = ( ( tex2D( _BrickNormals, ScaledUVs57 ) * LowBorder82 ) + ( tex2D( _LowBorderNormals, LowBorderScaledUVs93 ) * ( 1.0 - LowBorder82 ) ) );
			o.Normal = NORMALS142.rgb;
			float simplePerlin2D31 = snoise( UVs54*_DirtScale );
			simplePerlin2D31 = simplePerlin2D31*0.5 + 0.5;
			float smoothstepResult125 = smoothstep( 0.7 , 1.0 , simplePerlin2D31);
			float clampResult123 = clamp( smoothstepResult125 , -1.0 , 1.0 );
			float DirtNoise100 = clampResult123;
			float4 ALBEDO115 = ( ( tex2D( _DirtTex, ScaledUVs57 ) * _DirtAlbedo * DirtNoise100 ) + ( ( ( tex2D( _BrickColorTex, ScaledUVs57 ) * _BrickAlbedo * ( 1.0 - DirtNoise100 ) ) * LowBorder82 ) + ( ( 1.0 - LowBorder82 ) * ( tex2D( _LowBorderTex, LowBorderScaledUVs93 ) * _LowBorderAlbedo * ( 1.0 - DirtNoise100 ) ) ) ) );
			o.Albedo = ALBEDO115.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
854;73;616;602;2950.981;638.9838;3.781115;False;False
Node;AmplifyShaderEditor.CommentaryNode;111;-3931.623,-440.638;Inherit;False;822.097;531.5579;UVs by World Position;6;3;4;7;5;57;54;;1,0.9995908,0,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;3;-3881.623,-295.143;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;4;-3696.624,-270.54;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;-3516.204,-390.638;Inherit;False;UVs;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;114;-3110.814,-2722.152;Inherit;False;3006.338;2071.785;ALBEDO;14;108;107;110;50;52;37;115;39;73;31;100;123;125;120;;0.7469271,0.3820755,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;108;-2787.734,-1595.152;Inherit;False;1785.337;944.786;Low Brick Border;5;47;65;118;119;122;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-3066.257,-2414.39;Inherit;False;Property;_DirtScale;DirtScale;7;0;Create;True;0;0;0;False;0;False;1;0.061;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;73;-3015.331,-2539.38;Inherit;False;54;UVs;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;119;-2713.356,-977.4916;Inherit;False;645.6021;294.1739;Low Border UVs;4;93;67;63;66;;1,1,1,1;0;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;31;-2754.322,-2544.337;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;63;-2627.654,-927.4916;Inherit;False;54;UVs;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;7;-3646.384,-73.08007;Inherit;False;Property;_BaseTextureScale;BaseTextureScale;4;0;Create;True;0;0;0;False;0;False;0,0;8,6;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;66;-2663.356,-847.3177;Inherit;False;Property;_LowBorderTexScale;LowBorderTexScale;12;0;Create;True;0;0;0;False;0;False;0,0;30,10;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SmoothstepOpNode;125;-2495.334,-2520.864;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.7;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;67;-2458.799,-921.3887;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;118;-2677.388,-1553.409;Inherit;False;876.1628;376.0577;Low Border Limit;4;45;53;46;82;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;5;-3472.606,-268.985;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;123;-2290.166,-2516.491;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-2618.041,-1343.806;Inherit;False;Property;_LowBorderDistance;LowBorderDistance;13;0;Create;True;0;0;0;False;0;False;0;-0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;107;-2277.022,-2088.704;Inherit;False;1176.823;459.2965;Brick Base Color;7;103;36;2;34;33;60;1;;0.509434,0.4194198,0.3676575,1;0;0
Node;AmplifyShaderEditor.PosVertexDataNode;45;-2627.388,-1503.409;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;57;-3333.528,-260.985;Inherit;False;ScaledUVs;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;93;-2327.754,-925.3713;Inherit;False;LowBorderScaledUVs;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;122;-2054.947,-1136.185;Inherit;False;839.8816;455.6223;Low Border Color;7;121;69;68;48;127;49;126;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;100;-2191.195,-2564.471;Inherit;False;DirtNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;126;-1698.349,-759.0579;Inherit;False;100;DirtNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;1;-2227.022,-2038.704;Inherit;True;Property;_BrickColorTex;BrickColorTex;0;0;Create;True;0;0;0;False;0;False;None;691a8d46920a79542ad4e36c394b547a;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;49;-2004.947,-1086.185;Inherit;True;Property;_LowBorderTex;LowBorderTex;8;0;Create;True;0;0;0;False;0;False;None;30829d5dd88841546aba2990deee25a0;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;60;-2174.274,-1850.982;Inherit;False;57;ScaledUVs;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;103;-1623.736,-1756.128;Inherit;False;100;DirtNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;145;-2497.09,434.2074;Inherit;False;1605.297;1233.001;Height;19;20;85;59;74;75;76;79;83;15;21;98;90;94;84;14;96;97;81;130;;0.5849056,0.4000534,0.4000534,1;0;0
Node;AmplifyShaderEditor.WireNode;121;-1797.598,-882.6459;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StepOpNode;46;-2396.712,-1431.351;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;20;-2415.09,484.2074;Inherit;True;Property;_BrickHeight;BrickHeight;2;0;Create;True;0;0;0;False;0;False;None;231dd91f52e60414aaaaa3dca6e0eb00;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;74;-2415.09,1092.208;Inherit;False;93;LowBorderScaledUVs;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;59;-2399.09,676.2078;Inherit;False;57;ScaledUVs;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;144;-2453.213,-505.3176;Inherit;False;1524.923;794.0171;Normals;13;136;132;134;8;58;137;9;133;138;139;135;140;142;;0.6646064,0.624733,0.9528302,1;0;0
Node;AmplifyShaderEditor.SamplerNode;48;-1728.326,-1085.607;Inherit;True;Property;_TextureSample4;Texture Sample 4;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;82;-2180.802,-1425.886;Inherit;False;LowBorder;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;127;-1510.585,-756.3318;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;36;-1435.972,-1753.402;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-1929.244,-2038.595;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;110;-1988.808,-2672.152;Inherit;False;934.7296;468.974;Dirt;6;72;22;23;101;38;128;;0.3867925,0.3090428,0.2682005,1;0;0
Node;AmplifyShaderEditor.ColorNode;69;-1666.299,-916.1405;Inherit;False;Property;_LowBorderAlbedo;LowBorderAlbedo;11;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.7830189,0.780562,0.7719384,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;75;-2447.09,900.2078;Inherit;True;Property;_LowBorderHeight;LowBorderHeight;10;0;Create;True;0;0;0;False;0;False;None;4994bd947cad2244b9a0809a2a40ee7e;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.ColorNode;34;-1858.219,-1841.407;Inherit;False;Property;_BrickAlbedo;BrickAlbedo;3;0;Create;True;0;0;0;False;0;False;0.3396226,0.2158052,0.1906372,0;0.8207547,0.6620238,0.6620238,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;85;-2188.961,1197.034;Inherit;False;Property;_LowBorderDisplacement;LowBorderDisplacement;14;0;Create;True;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;21;-2175.089,500.2074;Inherit;True;Property;_TextureSample2;Texture Sample 2;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;83;-2095.089,1540.208;Inherit;False;82;LowBorder;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;76;-2191.089,932.2078;Inherit;True;Property;_TextureSample5;Texture Sample 5;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;79;-1927.396,1170.555;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector3Node;15;-2047.089,708.2079;Inherit;False;Constant;_Vector1;Vector 1;3;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexturePropertyNode;132;-2400.095,-145.2824;Inherit;True;Property;_LowBorderNormals;LowBorderNormals;9;0;Create;True;0;0;0;False;0;False;None;ad22cbb417360744ab784ba075637399;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;134;-2298.913,57.7004;Inherit;False;93;LowBorderScaledUVs;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;8;-2403.213,-455.3176;Inherit;True;Property;_BrickNormals;BrickNormals;1;0;Create;True;0;0;0;False;0;False;None;923ecfa2c4e1ce0498cbe4c1fb3c8e41;True;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;136;-1925.217,169.3773;Inherit;False;82;LowBorder;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-1377.065,-1084.287;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;120;-1059.44,-1696.211;Inherit;False;82;LowBorder;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;72;-1933.429,-2328.223;Inherit;False;57;ScaledUVs;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;58;-2319.5,-259.7697;Inherit;False;57;ScaledUVs;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;22;-1938.808,-2622.152;Inherit;True;Property;_DirtTex;DirtTex;5;0;Create;True;0;0;0;False;0;False;None;ceb1bacd3e5dc9b4cb4b85eb1a74cfb6;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-1262.199,-2037.977;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;65;-1394.102,-1226.446;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;128;-1561.999,-2397.894;Inherit;False;Property;_DirtAlbedo;DirtAlbedo;6;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.5943396,0.5354664,0.5354664,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;90;-1679.088,676.2078;Inherit;False;82;LowBorder;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;94;-1949.208,1363.298;Inherit;False;Constant;_Vector0;Vector 0;3;0;Create;True;0;0;0;False;0;False;0,0.3,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;98;-1775.088,1044.208;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;84;-1903.088,1556.208;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-1807.088,596.2076;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;101;-1287.6,-2313.998;Inherit;False;100;DirtNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;133;-1997.998,-113.0135;Inherit;True;Property;_TextureSample6;Texture Sample 6;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-1164.401,-1197.771;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;137;-1750.428,177.6995;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;138;-1672.845,-227.072;Inherit;False;82;LowBorder;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;9;-2001.115,-423.0487;Inherit;True;Property;_TextureSample1;Texture Sample 1;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-867.2397,-1824.938;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;23;-1635.12,-2593.379;Inherit;True;Property;_TextureSample3;Texture Sample 3;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;-1567.088,1124.208;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;-1524.961,-357.2115;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-667.0739,-1667.957;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;135;-1652.998,-88.87932;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-1222.554,-2547.961;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;-1503.088,596.2076;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;81;-1343.089,692.2079;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;140;-1359.33,-260.5928;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;37;-510.1698,-1818.409;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;130;-1115.793,718.9478;Inherit;False;HEIGHT;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;115;-336.2748,-1822.89;Inherit;False;ALBEDO;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;142;-1152.289,-263.7708;Inherit;False;NORMALS;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;131;192,304;Inherit;False;130;HEIGHT;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;116;192,16;Inherit;False;115;ALBEDO;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;143;192,96;Inherit;False;142;NORMALS;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.EdgeLengthTessNode;13;192,416;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;410.9619,30.91698;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;Callejon;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;4;0;3;1
WireConnection;4;1;3;2
WireConnection;54;0;4;0
WireConnection;31;0;73;0
WireConnection;31;1;39;0
WireConnection;125;0;31;0
WireConnection;67;0;63;0
WireConnection;67;1;66;0
WireConnection;5;0;4;0
WireConnection;5;1;7;0
WireConnection;123;0;125;0
WireConnection;57;0;5;0
WireConnection;93;0;67;0
WireConnection;100;0;123;0
WireConnection;121;0;93;0
WireConnection;46;0;45;3
WireConnection;46;1;53;0
WireConnection;48;0;49;0
WireConnection;48;1;121;0
WireConnection;82;0;46;0
WireConnection;127;0;126;0
WireConnection;36;0;103;0
WireConnection;2;0;1;0
WireConnection;2;1;60;0
WireConnection;21;0;20;0
WireConnection;21;1;59;0
WireConnection;76;0;75;0
WireConnection;76;1;74;0
WireConnection;79;1;85;0
WireConnection;68;0;48;0
WireConnection;68;1;69;0
WireConnection;68;2;127;0
WireConnection;33;0;2;0
WireConnection;33;1;34;0
WireConnection;33;2;36;0
WireConnection;65;0;82;0
WireConnection;98;0;76;0
WireConnection;98;1;79;0
WireConnection;84;0;83;0
WireConnection;14;0;21;0
WireConnection;14;1;15;0
WireConnection;133;0;132;0
WireConnection;133;1;134;0
WireConnection;47;0;65;0
WireConnection;47;1;68;0
WireConnection;137;0;136;0
WireConnection;9;0;8;0
WireConnection;9;1;58;0
WireConnection;50;0;33;0
WireConnection;50;1;120;0
WireConnection;23;0;22;0
WireConnection;23;1;72;0
WireConnection;97;0;98;0
WireConnection;97;1;94;0
WireConnection;97;2;84;0
WireConnection;139;0;9;0
WireConnection;139;1;138;0
WireConnection;52;0;50;0
WireConnection;52;1;47;0
WireConnection;135;0;133;0
WireConnection;135;1;137;0
WireConnection;38;0;23;0
WireConnection;38;1;128;0
WireConnection;38;2;101;0
WireConnection;96;0;14;0
WireConnection;96;1;90;0
WireConnection;81;0;96;0
WireConnection;81;1;97;0
WireConnection;140;0;139;0
WireConnection;140;1;135;0
WireConnection;37;0;38;0
WireConnection;37;1;52;0
WireConnection;130;0;81;0
WireConnection;115;0;37;0
WireConnection;142;0;140;0
WireConnection;0;0;116;0
WireConnection;0;1;143;0
WireConnection;0;11;131;0
WireConnection;0;14;13;0
ASEEND*/
//CHKSM=20A5193CC2FAA030E44A45C954E8E0511363CBDF