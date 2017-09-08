Shader "Nate Nesler/uGUI/Unlit/Gradient Transparent"
{
	Properties
	{
		_MainTex ("Base (RGB), Alpha (A)", 2D) = "white" {}

		_Color1 ("Color 1", Color) = (1,1,1,1)
		_Color2 ("Color 2", Color) = (1,1,1,1)
		_Gradient ("Gradient Position", Range(-1.0, 1.0) ) = -0.5
		_GradientScale ("Gradient Scale", Range(-5.0, 5.0) ) = -0.5
		_GradientU ("Gradient Position U", Range(-1.0, 1.0) ) = 1
		_GradientV ("Gradient Position v", Range(-1.0, 1.0) ) = 1

		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255

		_ColorMask ("Color Mask", Float) = 15
	}
	
	SubShader
	{
		LOD 100

		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
			"PreviewType"="Plane"
		}

		Stencil
		{
			Ref [_Stencil]
			Comp [_StencilComp]
			Pass [_StencilOp] 
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
		}
		
		Cull Off
		Lighting Off
		ZWrite Off
		ZTest [unity_GUIZTestMode]
		Offset -1, -1
		Fog { Mode Off }
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]

		Pass
		{
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"

				struct appdata_t
				{
					float4 vertex : POSITION;
					float2 texcoord : TEXCOORD0;
					fixed4 color : COLOR;
				};
	
				struct v2f
				{
					float4 vertex : SV_POSITION;
					half2 texcoord : TEXCOORD0;
					fixed4 color : COLOR;
				};
	
				sampler2D _MainTex;
				float4 _MainTex_ST;
				uniform fixed4 _Color1;
				uniform fixed4 _Color2;
				uniform fixed  _Gradient;
				uniform half _GradientScale;
				uniform fixed  _GradientU;
				uniform fixed  _GradientV;
				
				v2f vert (appdata_t v)
				{
					v2f o;
					o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
					o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
					o.color = v.color;
					return o;
				}
				
				fixed4 frag (v2f IN) : COLOR
				{
					fixed4 col = tex2D(_MainTex, IN.texcoord) * IN.color;
					clip (col.a - 0.01);
					col = col.rgba * lerp(_Color2, _Color1, _Gradient + _GradientScale * (_GradientU * IN.texcoord.x + _GradientV * IN.texcoord.y)).rgba;
					return col;
				}
			ENDCG
		}
	}
}
