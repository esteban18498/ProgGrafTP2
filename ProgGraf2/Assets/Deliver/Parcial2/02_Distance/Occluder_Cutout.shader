// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Occluder_Cutout"
{
	Properties
	{
		_BaseColor("BaseColor", Color) = (0.6886792,0.6886792,0.6886792,0)
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard alpha:fade keepalpha addshadow fullforwardshadows 
		struct Input
		{
			half filler;
		};

		uniform float4 _BaseColor;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Albedo = _BaseColor.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
0;0;1920;1011;2063.524;-208.5217;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;44;-468.192,629.7972;Inherit;False;727.9969;262.7679;Radio Exterior del Fade;4;4;42;3;43;Radio Exterior del Fade;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;26;-612.7928,116.5167;Inherit;False;215;161;0 = cam, 1= player;1;19;0 = punto más cercano a la cámara 1 = punto más cercano al player 0.5 = mitad del camino cámara-player;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;22;-1046.629,283.2991;Inherit;False;272.3716;235.5403;Este nodo calcula el largo de la línea cámara-player al cuadrado.;2;21;25;Este nodo calcula el largo de la línea cámara-player al cuadrado.;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;20;-1041.036,56.87296;Inherit;False;269.8568;194.2202;En qué punto de la línea cámara-player cae el pixel de una pared.;1;18;En qué punto de la línea cámara-player cae el pixel de una pared.;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;17;-1576.309,286.9241;Inherit;False;475.7062;238.942;Este vector apunta desde la cámara hacia el player.;2;2;13;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;16;-1580.514,-106.968;Inherit;False;493.1454;384.8077;Este vector apunta desde la cámara hacia cada pixel de una pared.;4;12;14;1;34;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;45;-470.1951,397.9622;Inherit;False;841;219;máscara suave del agujero;4;46;47;49;48;Máscara suave del agujero;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;34;-1286.663,168.2793;Inherit;False;CutoutCameraWS;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-306.9104,159.8395;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-408.9198,776.5651;Inherit;False;Property;_CutoutFeather;CutoutFeather;3;0;Create;True;0;0;0;False;0;False;0.35;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;18;-970.5787,120.1099;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;19;-562.7928,166.5167;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;36;-1036.583,543.4254;Inherit;False;PlayerMinusCameraCutout;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1003.061,713.5845;Inherit;False;Property;_RingWidth;RingWidth;5;0;Create;True;0;0;0;False;0;False;0.08;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;42;-95.17261,720.7972;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;-403.1951,526.9622;Inherit;False;43;OuterRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;13;-1266.603,390.8661;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;43;52.80493,718.9622;Inherit;False;OuterRadius;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-981.8595,886.4844;Inherit;False;Property;_HoleAlpha;HoleAlpha ;6;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1006.527,785.7473;Inherit;False;Property;_RingIntensity;RingIntensity;8;0;Create;True;0;0;0;False;0;False;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-807.8605,885.7239;Inherit;False;Property;_CutoutActive;CutoutActive;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;-419.1951,439.9622;Inherit;False;41;DistanceToLine;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;37;-622.5833,294.4254;Inherit;False;36;PlayerMinusCameraCutout;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;21;-996.6294,333.2992;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-418.192,686.885;Inherit;False;Property;_CutoutRadius;CutoutRadius;2;0;Create;True;0;0;0;False;0;False;1;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;40;232.433,-53.98563;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;41;374.144,-42.98425;Inherit;False;DistanceToLine;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;12;-1500.056,-36.32655;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;-19.37708,-17.49301;Inherit;False;ClosestPoint;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;39;-15.917,-186.7931;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMaxOpNode;24;-879.1879,333.2103;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;161.8049,501.9622;Inherit;False;CutoutSoftMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;23;-739.8306,161.9316;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;35;-387.6632,-58.72073;Inherit;False;34;CutoutCameraWS;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SmoothstepOpNode;47;-28.19507,483.9622;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;-145.4255,-23.19003;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-1006.908,440.0369;Inherit;False;Constant;_constanteMAX;constante MAX;7;0;Create;True;0;0;0;False;0;False;0.001;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;1;-1508.854,111.5025;Inherit;False;Property;_CutoutCameraWS;CutoutCameraWS;0;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;2;-1526.309,336.9242;Inherit;False;Property;_CutoutAvatarWS;CutoutAvatarWS;1;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;11;331.5497,-516.9039;Inherit;False;Property;_BaseColor;BaseColor;9;0;Create;True;0;0;0;False;0;False;0.6886792,0.6886792,0.6886792,0;0.6886792,0.6886792,0.6886792,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;9;-980.3862,969.2512;Inherit;False;Property;_RingColor;RingColor;7;0;Create;True;0;0;0;False;0;False;0.09433961,0.0725347,0.0725347,0;0.09433961,0.0725347,0.0725347,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;14;-1266.606,19.02775;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;690.3409,-419.9312;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Occluder_Cutout;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;34;0;1;0
WireConnection;27;0;19;0
WireConnection;27;1;37;0
WireConnection;18;0;14;0
WireConnection;18;1;13;0
WireConnection;19;0;23;0
WireConnection;36;0;13;0
WireConnection;42;0;3;0
WireConnection;42;1;4;0
WireConnection;13;0;2;0
WireConnection;13;1;1;0
WireConnection;43;0;42;0
WireConnection;21;0;13;0
WireConnection;21;1;13;0
WireConnection;40;0;39;0
WireConnection;40;1;38;0
WireConnection;41;0;40;0
WireConnection;38;0;32;0
WireConnection;24;0;21;0
WireConnection;24;1;25;0
WireConnection;49;0;47;0
WireConnection;23;0;18;0
WireConnection;23;1;24;0
WireConnection;47;0;48;0
WireConnection;47;1;3;0
WireConnection;47;2;46;0
WireConnection;32;0;35;0
WireConnection;32;1;27;0
WireConnection;14;0;12;0
WireConnection;14;1;1;0
WireConnection;0;0;11;0
ASEEND*/
//CHKSM=2051FFC32E8A07B77F3722D9F627BF2EB2CC6D75