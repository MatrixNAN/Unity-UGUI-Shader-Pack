Shader "NateNesler/uGUI/Graident 3 Color"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color1 ("Color 1", Color) = (1,1,1,1)
		_Color2 ("Color 2", Color) = (1,1,1,1)
		_Color3 ("Color 3", Color) = (1,1,1,1)
		_GradientPosition ("Gradient Position", Range(-1.0, 1.0) ) = -0.5
		_GradientScale1 ("Gradient Scale 1", Range(-5.0, 5.0) ) = -0.5
		_GradientScale2 ("Gradient Scale 2", Range(-5.0, 5.0) ) = -0.5
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
		Tags
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
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
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				half2 texcoord  : TEXCOORD0;
			};
			
			uniform fixed4 _Color1;
			uniform fixed4 _Color2;
			uniform fixed4 _Color3;
			uniform fixed _GradientPosition;
			uniform half _GradientScale1;
			uniform half _GradientScale2;
			uniform fixed _GradientU;
			uniform fixed _GradientV;

			v2f vert(appdata_t IN)
			{
				v2f OUT;
				OUT.vertex = mul(UNITY_MATRIX_MVP, IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color; 
				fixed2 GradientCenter = float2(_GradientU,_GradientV);
				OUT.texcoord = OUT.texcoord - GradientCenter;
				return OUT;
			}

			sampler2D _MainTex;

			fixed4 frag(v2f IN) : SV_Target
			{
				half4 color = tex2D(_MainTex, IN.texcoord) * IN.color;
				clip (color.a - 0.01);
				color = color.rgba * lerp(_Color2, _Color1, _GradientPosition + _GradientScale1 * (IN.texcoord.x + _GradientV * IN.texcoord.y)).rgba;
				color = color.rgba * lerp(color, _Color3, _GradientPosition + _GradientScale2 * ( IN.texcoord.x + IN.texcoord.y)).rgba;
				return color; 
			}
		ENDCG
		}
	}
}
