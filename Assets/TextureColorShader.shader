Shader "Custom/TextureColorShader"
{
	Properties
	{
		_MainColor("Main color", Color) = (1.0, 1.0, 1.0, 1.0) //RGBA
		_MainTex("Texture", 2D) = "white" { }
	}

	SubShader // Unity chooses the subshader that fits the GPU best
	{
		Pass // some shaders require multiple passes
		{
			CGPROGRAM // here begins the part in Unity's Cg

			#pragma vertex vert 
			#pragma fragment frag

			#include "UnityCG.cginc" //Defines Unity standard shader functions

			float4 _MainColor;
			sampler2D _MainTex;
			float4 _MainTex_ST; //Used to intract with Unity Editor

			struct AppData
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct VertexToFragment
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			// vertex shader 
			VertexToFragment vert(AppData input)
			{
				VertexToFragment output;

				output.pos = UnityObjectToClipPos(input.vertex);

				output.uv = TRANSFORM_TEX(input.uv, _MainTex);

				return output;
			}

			// fragment shader
			float4 frag(VertexToFragment input) : COLOR
			{
				float4 textureColor = tex2D(_MainTex, input.uv);
				textureColor *= _MainColor;

				return 1.0 - textureColor;
			}

				ENDCG // here ends the part in Cg 
			}
	}
}
