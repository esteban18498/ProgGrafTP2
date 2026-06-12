// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Ghost"
{
	Properties
	{
		_BaseColor("Base Color", Color) = (1,1,1,0)
		_Lenght("Lenght", Range( 0 , 10)) = 0.5
		_Amount("Amount", Range( 0 , 1)) = 0
		_Mask_clip("Mask_clip", Range( 0.1 , 0.9)) = 0.5
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float4 screenPosition;
			float3 worldPos;
		};

		uniform float4 _BaseColor;
		uniform float _Amount;
		uniform float _Lenght;
		uniform float _Mask_clip;


		inline float Dither4x4Bayer( int x, int y )
		{
			const float dither[ 16 ] = {
				 1,  9,  3, 11,
				13,  5, 15,  7,
				 4, 12,  2, 10,
				16,  8, 14,  6 };
			int r = y * 4 + x;
			return dither[r] / 16; // same # of instructions as pre-dividing due to compiler magic
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float4 ase_screenPos = ComputeScreenPos( UnityObjectToClipPos( v.vertex ) );
			o.screenPosition = ase_screenPos;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Albedo = _BaseColor.rgb;
			o.Alpha = 1;
			float4 ase_screenPos = i.screenPosition;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 clipScreen8 = ase_screenPosNorm.xy * _ScreenParams.xy;
			float dither8 = Dither4x4Bayer( fmod(clipScreen8.x, 4), fmod(clipScreen8.y, 4) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			dither8 = step( dither8, pow( ( (0.0 + (ase_vertex3Pos.y - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) + (-1.0 + (_Amount - 1.0) * (1.0 - -1.0) / (0.0 - 1.0)) ) , _Lenght ) );
			clip( dither8 - _Mask_clip );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
668;73;884;575;578.0585;-131.2211;1.3;True;False
Node;AmplifyShaderEditor.PosVertexDataNode;10;-1027.411,-25.07888;Inherit;True;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;33;-1153.344,311.9401;Inherit;False;Property;_Amount;Amount;2;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;37;-715.7169,143.1035;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;35;-846.2477,348.4893;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;-476.3814,290.4905;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-623.8159,520.9115;Inherit;False;Property;_Lenght;Lenght;1;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;36;-323.8291,422.8125;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;8;-174.5827,397.7899;Inherit;False;0;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;9;-243.8439,-121.2916;Inherit;False;Property;_BaseColor;Base Color;0;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;39;102.2062,780.278;Inherit;False;Constant;_Mask_clip;Mask_clip;4;0;Create;True;0;0;0;False;0;False;0.5;0;0.1;0.9;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;30;119,-1;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Ghost;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;2;-1;-1;-1;0;False;0;0;False;-1;-1;0;True;39;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;37;0;10;2
WireConnection;35;0;33;0
WireConnection;32;0;37;0
WireConnection;32;1;35;0
WireConnection;36;0;32;0
WireConnection;36;1;14;0
WireConnection;8;0;36;0
WireConnection;30;0;9;0
WireConnection;30;10;8;0
ASEEND*/
//CHKSM=0BBDEE1E0733D916E6EEA7A282ED534C4A3938CA