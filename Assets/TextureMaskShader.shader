Shader "Custom/TextureMaskShader"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" { }
		_SecondaryTex("Texture", 2D) = "white" { }
		_MaskTex("Texture", 2D) = "white" { }
	}

	SubShader // Unity chooses the subshader that fits the GPU best
	{
		Pass // some shaders require multiple passes
		{
			CGPROGRAM // here begins the part in Unity's Cg

			#pragma vertex vert 
			#pragma fragment frag

			#include "UnityCG.cginc" //Defines Unity standard shader functions

			sampler2D _MainTex;
			sampler2D _SecondaryTex;
			sampler2D _MaskTex;
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
				/*float4 textureColor = tex2D(_MainTex, input.uv) * (1.0 - tex2D(_MaskTex, input.uv));
				float4 maskText = tex2D(_MaskTex, input.uv) * tex2D(_SecondaryTex, input.uv);*/

				float4 mainTexture = tex2D(_MainTex, input.uv);
				float4 secondaryTexture = tex2D(_SecondaryTex, input.uv);
				float4 maskText = tex2D(_MaskTex, input.uv);
				
				return lerp(mainTexture, secondaryTexture, maskText.r);
				/*return textureColor + maskText;*/
			}

				ENDCG // here ends the part in Cg 
			}
	}
}
