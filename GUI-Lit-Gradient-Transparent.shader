Shader "Nate Nesler/uGUI/Lit/Gradient Transparent"
{
	Properties
	{
		_Color1 ("Color 1", Color) = (1,1,1,1)
		_Color2 ("Color 2", Color) = (1,1,1,1)
		_Gradient ("Gradient Position", Range(-1.0, 1.0) ) = -0.5
		_GradientScale ("Gradient Scale", Range(-5.0, 5.0) ) = -0.5
		_GradientU ("Gradient Position U", Range(-1.0, 1.0) ) = 1
		_GradientV ("Gradient Position v", Range(-1.0, 1.0) ) = 1

		_Specular ("Specular Color", Color) = (0,0,0,0)
		_MainTex ("Diffuse (RGB), Alpha (A)", 2D) = "white" {}
		
		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255

		_ColorMask ("Color Mask", Float) = 15
	}
	
	SubShader
	{
		LOD 400

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
		Fog { Mode Off }
		Offset -1, -1
		Blend SrcAlpha OneMinusSrcAlpha
		AlphaTest Greater 0
		ColorMask [_ColorMask]

		CGPROGRAM
			#pragma surface surf PPL alpha
			#include "UnityCG.cginc"
	
			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
				fixed4 color : COLOR;
			};
	
			struct Input
			{
				half2 uv_MainTex;
				fixed4 color : COLOR;
			};

			sampler2D _MainTex;
			uniform fixed4 _Color1;
			uniform fixed4 _Color2;
			uniform fixed  _Gradient;
			uniform half _GradientScale;
			uniform fixed  _GradientU;
			uniform fixed  _GradientV;
			fixed4 _Specular;
				
			void surf (Input IN, inout SurfaceOutput o)
			{
				fixed4 col = tex2D(_MainTex, IN.uv_MainTex) * IN.color;
				col = col.rgba * lerp(_Color2, _Color1, _Gradient + _GradientScale * (_GradientU * IN.uv_MainTex.x + _GradientV * IN.uv_MainTex.y)).rgba;
				o.Albedo = col.rgb;
				o.Alpha = col.a;
			}

			half4 LightingPPL (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
			{
				half3 nNormal = normalize(s.Normal);
				half shininess = s.Gloss * 250.0 + 4.0;

			#ifndef USING_DIRECTIONAL_LIGHT
				lightDir = normalize(lightDir);
			#endif

				// Phong shading model
				half reflectiveFactor = max(0.0, dot(-viewDir, reflect(lightDir, nNormal)));

				// Blinn-Phong shading model
				//half reflectiveFactor = max(0.0, dot(nNormal, normalize(lightDir + viewDir)));
				
				half diffuseFactor = max(0.0, dot(nNormal, lightDir));
				half specularFactor = pow(reflectiveFactor, shininess) * s.Specular;

				half4 c;
				c.rgb = (s.Albedo * diffuseFactor + _Specular.rgb * specularFactor) * _LightColor0.rgb;
				c.rgb *= (atten * 2.0);
				c.a = s.Alpha;
				clip (c.a - 0.01);
				return c;
			}
		ENDCG
	}
}

