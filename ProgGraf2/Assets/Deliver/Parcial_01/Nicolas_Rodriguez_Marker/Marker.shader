// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Marker"
{
	Properties
	{
		_MarkerColor("MarkerColor", Color) = (0.8396226,0.6476452,0,0)
		_TessellationStrength("Tessellation Strength", Range( 1 , 20)) = 2
		_EmissionStrength("Emission Strength", Range( 0 , 3)) = 0.578609
		_NormalsTexture("Normals Texture", 2D) = "white" {}
		_WaveStretch("WaveStretch", Vector) = (33,0.04,0,0)
		_WaveTileSize("Wave Tile Size", Range( 0.1 , 10)) = 0
		_NormalPanDirection1("Normal Pan Direction 1", Vector) = (1,0,0,0)
		_NormalPanSpeed1("Normal Pan Speed 1", Range( 0 , 1)) = 1
		_StretchSpeed("Stretch Speed", Range( 0 , 3)) = 0
		_StretchFrequency("Stretch Frequency", Range( 0 , 0.1)) = 0
		_StretchStrength("Stretch Strength", Range( 0 , 0.1)) = 0
		_StretchLetchPower("Stretch Letch Power", Range( 0 , 10)) = 1
		_ScanlineTexture("Scanline Texture", 2D) = "white" {}
		_ScanlinesspeedX("Scan lines speed X", Range( 0 , 0.1)) = 0
		_ScanlinesspeedY("Scan lines speed Y", Range( 0 , 0.2)) = 0
		_ScanLineTiles("Scan Line Tiles", Range( 0.01 , 0.5)) = 0.1
		_OpacitySpeed("OpacitySpeed", Range( 0 , 2)) = 0
		_OpacityFrequency("OpacityFrequency", Range( 0.1 , 1)) = 0
		_MaxOpacity("MaxOpacity", Range( 0 , 1)) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "Tessellation.cginc"
		#pragma target 4.6
		#pragma surface surf Lambert alpha:fade keepalpha noshadow vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float3 worldPos;
		};

		uniform float _StretchFrequency;
		uniform float _StretchSpeed;
		uniform float _StretchStrength;
		uniform float _StretchLetchPower;
		uniform sampler2D _NormalsTexture;
		uniform float2 _NormalPanDirection1;
		uniform float _NormalPanSpeed1;
		uniform float2 _WaveStretch;
		uniform float _WaveTileSize;
		uniform float4 _MarkerColor;
		uniform sampler2D _ScanlineTexture;
		uniform float _ScanlinesspeedX;
		uniform float _ScanlinesspeedY;
		uniform float _ScanLineTiles;
		uniform float _EmissionStrength;
		uniform float _OpacitySpeed;
		uniform float _OpacityFrequency;
		uniform float _MaxOpacity;
		uniform float _TessellationStrength;


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
			float4 temp_cast_2 = (_TessellationStrength).xxxx;
			return temp_cast_2;
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float2 temp_cast_0 = (_StretchSpeed).xx;
			float2 panner50 = ( ( _Time.y * _StretchFrequency ) * temp_cast_0 + v.texcoord.xy);
			float simplePerlin2D58 = snoise( panner50*5.0 );
			simplePerlin2D58 = simplePerlin2D58*0.5 + 0.5;
			float VertexOffset69 = ( simplePerlin2D58 * ( _StretchStrength / 100.0 ) * pow( v.texcoord.xy.y , _StretchLetchPower ) );
			float3 temp_cast_1 = (VertexOffset69).xxx;
			v.vertex.xyz += temp_cast_1;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldPos = i.worldPos;
			float4 appendResult25 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			float4 WorldSpaceTile26 = appendResult25;
			float4 WaveTileUV32 = ( ( WorldSpaceTile26 * float4( _WaveStretch, 0.0 , 0.0 ) ) * _WaveTileSize );
			float2 panner21 = ( 1.0 * _Time.y * ( ( _NormalPanDirection1 * _NormalPanSpeed1 ) / float2( 10,10 ) ) + WaveTileUV32.xy);
			float4 Normals39 = tex2D( _NormalsTexture, panner21 );
			o.Normal = Normals39.rgb;
			float4 appendResult79 = (float4(_ScanlinesspeedX , _ScanlinesspeedY , 0.0 , 0.0));
			float2 panner76 = ( 1.0 * _Time.y * appendResult79.xy + ( WorldSpaceTile26 * _ScanLineTiles ).xy);
			float4 ScanLines97 = ( tex2D( _ScanlineTexture, panner76 ) * 1.0 );
			float4 Albedo106 = ( _MarkerColor + ScanLines97 );
			o.Albedo = Albedo106.rgb;
			float4 Emission109 = ( Albedo106 * _EmissionStrength );
			o.Emission = Emission109.rgb;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float mulTime84 = _Time.y * _OpacitySpeed;
			float clampResult93 = clamp( ( ase_vertex3Pos.y - sin( ( ( ase_vertex3Pos.y + mulTime84 ) * ( _OpacityFrequency * 6.28318548202515 ) ) ) ) , 0.0 , _MaxOpacity );
			float OpacityEffect96 = clampResult93;
			o.Alpha = OpacityEffect96;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
-118;220;1920;987;690.7312;253.356;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;27;-3096.99,-1112.088;Inherit;False;866.4832;245.7069;World Position UVs;3;24;25;26;World Position UVs;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;24;-3046.99,-1062.088;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;25;-2746.505,-1049.381;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;98;-3164.36,-1810.907;Inherit;False;1613.797;473.1344;ScanLines;11;78;75;77;80;79;81;76;73;71;72;97;ScanLines;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;26;-2459.506,-1055.381;Inherit;False;WorldSpaceTile;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;75;-3037.461,-1760.907;Inherit;False;26;WorldSpaceTile;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-3068.323,-1666.565;Inherit;False;Property;_ScanLineTiles;Scan Line Tiles;17;0;Create;True;0;0;0;False;0;False;0.1;0.06544771;0.01;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-3112.36,-1532.617;Inherit;False;Property;_ScanlinesspeedX;Scan lines speed X;15;0;Create;True;0;0;0;False;0;False;0;0.0523;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-3114.36,-1458.617;Inherit;False;Property;_ScanlinesspeedY;Scan lines speed Y;16;0;Create;True;0;0;0;False;0;False;0;0.005;0;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;79;-2819.361,-1561.617;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;-2784.919,-1718.47;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PannerNode;76;-2615.397,-1689.032;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-2183.937,-1453.773;Inherit;False;Constant;_ScanMultip;Scan Multip;16;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;71;-2398.737,-1700.773;Inherit;True;Property;_ScanlineTexture;Scanline Texture;14;0;Create;True;0;0;0;False;0;False;-1;None;dc705aee96944ee458b0e398a62769b4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;95;-1776.918,592.7061;Inherit;False;2241.827;1053.282;OpacityEffect;15;96;93;90;102;100;86;87;83;89;84;82;88;85;103;104;OpacityEffect;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;35;-3194.704,-725.2817;Inherit;False;1236.071;400.6719;World Tile UV;6;30;31;32;33;34;36;World Tile UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-1924.936,-1657.773;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-1716.264,870.7063;Inherit;False;Property;_OpacitySpeed;OpacitySpeed;18;0;Create;True;0;0;0;False;0;False;0;0.9354611;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;33;-3144.704,-526.9778;Inherit;False;Property;_WaveStretch;WaveStretch;5;0;Create;True;0;0;0;False;0;False;33,0.04;0.07,0.02;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;36;-3130.63,-670.0711;Inherit;False;26;WorldSpaceTile;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleTimeNode;84;-1412.264,857.7061;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;82;-1540.264,642.7061;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TauNode;88;-1442.071,1290.826;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-2823.702,-675.2817;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;68;-3461.115,586.7804;Inherit;False;1455.207;629.2344;Vertex Offset;14;69;60;62;65;58;64;50;59;66;48;56;51;53;54;Vertex Offset;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;97;-1774.564,-1618.493;Inherit;False;ScanLines;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;38;-3691.965,-166.5858;Inherit;False;1703.895;569.7977;Normals;9;23;22;21;37;20;19;18;17;39;Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;105;-3145.861,-2827.482;Inherit;False;802.2515;536.2037;Albedo;4;106;74;99;6;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-2817.8,-440.6102;Inherit;False;Property;_WaveTileSize;Wave Tile Size;7;0;Create;True;0;0;0;False;0;False;0;7.27;0.1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-1726.918,1141.574;Inherit;False;Property;_OpacityFrequency;OpacityFrequency;19;0;Create;True;0;0;0;False;0;False;0;0.48326;0.1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;6;-3095.861,-2777.481;Inherit;False;Property;_MarkerColor;MarkerColor;1;0;Create;True;0;0;0;False;0;False;0.8396226,0.6476452,0,0;0.8396226,0.6476452,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;83;-1157.265,712.7058;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-2529.706,-674.2817;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-3641.965,140.5397;Inherit;False;Property;_NormalPanSpeed1;Normal Pan Speed 1;9;0;Create;True;0;0;0;False;0;False;1;0.325;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;17;-3583.974,-13.53706;Inherit;False;Property;_NormalPanDirection1;Normal Pan Direction 1;8;0;Create;True;0;0;0;False;0;False;1,0;0,5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;54;-3334.878,1092.557;Inherit;False;Property;_StretchFrequency;Stretch Frequency;11;0;Create;True;0;0;0;False;0;False;0;0.0578;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;53;-3329.878,1009.557;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-1208.865,1160.896;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;-3054.873,-2448.277;Inherit;False;97;ScanLines;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;74;-2820.609,-2588.881;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;48;-3411.115,727.9266;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-3127.878,1001.557;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-3231.624,-9.510066;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-974.9919,908.5896;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-2182.634,-665.0597;Inherit;False;WaveTileUV;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-3330.878,900.557;Inherit;False;Property;_StretchSpeed;Stretch Speed;10;0;Create;True;0;0;0;False;0;False;0;1.9;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;106;-2624.319,-2597.165;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;67;-3125.264,-2168.476;Inherit;False;705.9254;261.8631;Emission;4;15;14;107;109;Emission;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;37;-3435.741,-116.5858;Inherit;False;32;WaveTileUV;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BreakToComponentsNode;64;-3091.341,636.7803;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.PannerNode;50;-2963.878,824.557;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;104;-894.7512,627.9591;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-2960.654,1125.414;Inherit;False;Property;_StretchStrength;Stretch Strength;12;0;Create;True;0;0;0;False;0;False;0;0.0317;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-3090.039,731.6804;Inherit;False;Property;_StretchLetchPower;Stretch Letch Power;13;0;Create;True;0;0;0;False;0;False;1;10;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;20;-3061.451,90.83173;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;10,10;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SinOpNode;90;-752.8506,794.5181;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-3092.264,-2020.477;Inherit;False;Property;_EmissionStrength;Emission Strength;3;0;Create;True;0;0;0;False;0;False;0.578609;0.84;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;21;-2953.953,-102.3141;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;103;-536.261,768.3512;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;58;-2716.955,826.2141;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;62;-2628.949,1089.27;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;100;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-693.3176,1021.953;Inherit;False;Constant;_MinOpacity;MinOpacity;20;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;65;-2818.04,655.0803;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;107;-3025.515,-2112.791;Inherit;False;106;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;102;-690.5038,1095.681;Inherit;False;Property;_MaxOpacity;MaxOpacity;20;0;Create;True;0;0;0;False;0;False;0;0.537;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;93;-346.7426,888.9622;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.05;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;23;-2567.897,-44.47564;Inherit;True;Property;_NormalsTexture;Normals Texture;4;0;Create;True;0;0;0;False;0;False;-1;None;5d659934ea40cc54d9c37c44488f676d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-2440.355,755.2139;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-2778.337,-2090.613;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;96;195.7739,888.48;Inherit;False;OpacityEffect;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;-2178.568,126.2388;Inherit;False;Normals;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;69;-2300.35,771.9192;Inherit;False;VertexOffset;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;109;-2632.746,-2075.178;Inherit;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;40;229.5655,-95.57687;Inherit;False;39;Normals;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;110;229.5997,-1.588684;Inherit;False;109;Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;101;226.0482,118.6827;Inherit;False;96;OpacityEffect;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;108;233.8322,-178.202;Inherit;False;106;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-2861.925,183.8338;Inherit;False;Property;_NormalStrength;Normal Strength;6;0;Create;True;0;0;0;False;0;False;0;1.106635;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;243.8103,386.1929;Inherit;False;Property;_TessellationStrength;Tessellation Strength;2;0;Create;True;0;0;0;False;0;False;2;1.1;1;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;224.8284,204.8399;Inherit;False;69;VertexOffset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;539.731,-344.6168;Inherit;False;Property;_ClipMask;ClipMask;0;0;Create;True;0;0;0;False;0;False;0;0.3053553;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;580.0566,-90.69557;Float;False;True;-1;6;ASEMaterialInspector;0;0;Lambert;Marker;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;True;3;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;25;0;24;1
WireConnection;25;1;24;3
WireConnection;26;0;25;0
WireConnection;79;0;77;0
WireConnection;79;1;78;0
WireConnection;81;0;75;0
WireConnection;81;1;80;0
WireConnection;76;0;81;0
WireConnection;76;2;79;0
WireConnection;71;1;76;0
WireConnection;72;0;71;0
WireConnection;72;1;73;0
WireConnection;84;0;85;0
WireConnection;30;0;36;0
WireConnection;30;1;33;0
WireConnection;97;0;72;0
WireConnection;83;0;82;2
WireConnection;83;1;84;0
WireConnection;31;0;30;0
WireConnection;31;1;34;0
WireConnection;87;0;89;0
WireConnection;87;1;88;0
WireConnection;74;0;6;0
WireConnection;74;1;99;0
WireConnection;56;0;53;0
WireConnection;56;1;54;0
WireConnection;19;0;17;0
WireConnection;19;1;18;0
WireConnection;86;0;83;0
WireConnection;86;1;87;0
WireConnection;32;0;31;0
WireConnection;106;0;74;0
WireConnection;64;0;48;0
WireConnection;50;0;48;0
WireConnection;50;2;51;0
WireConnection;50;1;56;0
WireConnection;104;0;82;2
WireConnection;20;0;19;0
WireConnection;90;0;86;0
WireConnection;21;0;37;0
WireConnection;21;2;20;0
WireConnection;103;0;104;0
WireConnection;103;1;90;0
WireConnection;58;0;50;0
WireConnection;62;0;59;0
WireConnection;65;0;64;1
WireConnection;65;1;66;0
WireConnection;93;0;103;0
WireConnection;93;1;100;0
WireConnection;93;2;102;0
WireConnection;23;1;21;0
WireConnection;60;0;58;0
WireConnection;60;1;62;0
WireConnection;60;2;65;0
WireConnection;15;0;107;0
WireConnection;15;1;14;0
WireConnection;96;0;93;0
WireConnection;39;0;23;0
WireConnection;69;0;60;0
WireConnection;109;0;15;0
WireConnection;0;0;108;0
WireConnection;0;1;40;0
WireConnection;0;2;110;0
WireConnection;0;9;101;0
WireConnection;0;11;70;0
WireConnection;0;14;13;0
ASEEND*/
//CHKSM=2D3D8D8AD1B5ABE3C13714189EBEE24752EE27AF