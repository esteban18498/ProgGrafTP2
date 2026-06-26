// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ProjectorDeLuz"
{
	Properties
	{
		_LightTex("LightTex", 2D) = "white" {}
		_FalloffTex("FalloffTex", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_MaskPower("MaskPower", Float) = 4
		_MaskIntensity("MaskIntensity", Float) = 6

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
	LOD 0

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend DstColor One
		AlphaToMask Off
		Cull Back
		ColorMask RGB
		ZWrite Off
		ZTest LEqual
		Offset -1 , -1
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#define ASE_NEEDS_VERT_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float4 _Color;
			uniform sampler2D _LightTex;
			float4x4 unity_Projector;
			uniform sampler2D _FalloffTex;
			float4x4 unity_ProjectorClip;
			uniform float _MaskPower;
			uniform float _MaskIntensity;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 vertexToFrag5 = mul( unity_Projector, v.vertex );
				o.ase_texcoord1 = vertexToFrag5;
				float4 vertexToFrag12 = mul( unity_ProjectorClip, v.vertex );
				o.ase_texcoord2 = vertexToFrag12;
				
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float4 vertexToFrag5 = i.ase_texcoord1;
				float4 tex2DNode15 = tex2D( _LightTex, ( (vertexToFrag5).xy / (vertexToFrag5).w ) );
				float4 appendResult21 = (float4(( float4( (_Color).rgb , 0.0 ) * tex2DNode15 ).rgb , ( 1.0 - tex2DNode15.a )));
				float4 BaseTexture23 = appendResult21;
				float4 vertexToFrag12 = i.ase_texcoord2;
				float GradientTextureAlpha25 = tex2D( _FalloffTex, ( (vertexToFrag12).xy / (vertexToFrag12).w ) ).a;
				float temp_output_32_0 = step( 0.001 , pow( GradientTextureAlpha25 , _MaskPower ) );
				float AlphaTextureIntensity35 = ( ( GradientTextureAlpha25 * temp_output_32_0 ) * ( temp_output_32_0 * _MaskIntensity ) );
				
				
				finalColor = ( BaseTexture23 * AlphaTextureIntensity35 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18900
748;73;795;536;1597.583;736.9228;1.6;True;False
Node;AmplifyShaderEditor.PosVertexDataNode;6;-1971.877,-742.171;Inherit;False;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.UnityProjectorClipMatrixNode;4;-1971.877,-822.171;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-1763.877,-822.171;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.VertexToFragmentNode;12;-1619.877,-822.171;Inherit;False;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;13;-1379.877,-866.171;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;16;-1379.877,-754.171;Inherit;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;19;-1152.877,-819.171;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PosVertexDataNode;1;-1993.161,-226.7199;Inherit;False;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.UnityProjectorMatrixNode;2;-1957.161,-299.7201;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-1786.161,-299.7201;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;20;-999.0126,-848.7999;Inherit;True;Property;_FalloffTex;FalloffTex;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexToFragmentNode;5;-1633.161,-299.7201;Inherit;False;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-692.9867,-752.7266;Inherit;False;GradientTextureAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;7;-1403.161,-234.7199;Inherit;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-1593.685,379.5781;Inherit;False;Property;_MaskPower;MaskPower;3;0;Create;True;0;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;26;-1670.504,229.7528;Inherit;False;25;GradientTextureAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;8;-1406.161,-358.7201;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;11;-1160.161,-509.7201;Float;False;Property;_Color;Color;2;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;29;-1408.717,336.404;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;10;-1161.161,-306.7201;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-1161.57,594.5645;Inherit;False;Property;_MaskIntensity;MaskIntensity;4;0;Create;True;0;0;0;False;0;False;6;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;32;-1183.465,363.1965;Inherit;False;2;0;FLOAT;0.001;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;14;-920.1617,-415.72;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;15;-1017.162,-306.7201;Inherit;True;Property;_LightTex;LightTex;0;0;Create;True;0;0;0;False;0;False;-1;None;84508b93f15f2b64386ec07486afc7a3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-973.7437,235.2679;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-686.1619,-355.72;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;17;-690.1619,-205.7199;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-973.3817,495.0886;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;21;-505.1618,-274.72;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-713.1674,385.8076;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;35;-529.4275,380.3858;Inherit;False;AlphaTextureIntensity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;-334.0541,-279.9988;Inherit;False;BaseTexture;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;24;-92.31024,30.45024;Inherit;False;23;BaseTexture;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;36;-145.0694,116.0001;Inherit;False;35;AlphaTextureIntensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;112.7227,65.11654;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;262.5109,66.4473;Float;False;True;-1;2;ASEMaterialInspector;0;1;ProjectorDeLuz;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;1;2;False;-1;1;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;True;True;True;True;True;False;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;2;False;-1;True;0;False;-1;True;True;-1;False;-1;-1;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;9;0;4;0
WireConnection;9;1;6;0
WireConnection;12;0;9;0
WireConnection;13;0;12;0
WireConnection;16;0;12;0
WireConnection;19;0;13;0
WireConnection;19;1;16;0
WireConnection;3;0;2;0
WireConnection;3;1;1;0
WireConnection;20;1;19;0
WireConnection;5;0;3;0
WireConnection;25;0;20;4
WireConnection;7;0;5;0
WireConnection;8;0;5;0
WireConnection;29;0;26;0
WireConnection;29;1;28;0
WireConnection;10;0;8;0
WireConnection;10;1;7;0
WireConnection;32;1;29;0
WireConnection;14;0;11;0
WireConnection;15;1;10;0
WireConnection;31;0;26;0
WireConnection;31;1;32;0
WireConnection;18;0;14;0
WireConnection;18;1;15;0
WireConnection;17;0;15;4
WireConnection;34;0;32;0
WireConnection;34;1;33;0
WireConnection;21;0;18;0
WireConnection;21;3;17;0
WireConnection;30;0;31;0
WireConnection;30;1;34;0
WireConnection;35;0;30;0
WireConnection;23;0;21;0
WireConnection;22;0;24;0
WireConnection;22;1;36;0
WireConnection;0;0;22;0
ASEEND*/
//CHKSM=B958E89577BA11E6994BBF0369E133FD60906DA3