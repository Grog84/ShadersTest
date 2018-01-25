Shader "Custom/ToonNoHide" 
{
	Properties 
	{
		_Color ("Color", Color) = (1,1,1,1)
		_Emission("Emission", Color) = (0,0,0,0)
		_OutlineColor("Outline Color (A thickness)", Color) = (0,0,0,0.1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_LightRamp("Light ramp", 2D) = "white" {}
		_SpecularRamp("Specular ramp", 2D) = "black" {}
		_NormalMap("Normal map", 2D) = "bump" {}
	}

	SubShader 
	{
		Tags{ "Queue" = "Transparent" }

		Pass //Outline pass
		{
			Name "Outline"

			Cull Front
			ZWrite Off
			//ZTest Always

			CGPROGRAM

			#pragma vertex vert 
			#pragma fragment frag

			float4  _OutlineColor;

			struct AppData
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct VertexToFragment
			{
				float4 pos : SV_POSITION;
			};

			// vertex shader 
			VertexToFragment vert(AppData input)
			{
				VertexToFragment output;

				input.vertex.xyz += input.normal * _OutlineColor.a * 0.2;

				output.pos = UnityObjectToClipPos(input.vertex);

				return output;
			}

			// fragment shader
			float4 frag(VertexToFragment input) : COLOR
			{
				return _OutlineColor;
			}

			ENDCG // here ends the part in Cg 
		}

		Cull Back
		ZWrite On

		CGPROGRAM

		#pragma surface surf CustomLighting fullforwardshadows noambient
		#pragma	vertex vert

		sampler2D _MainTex;
		sampler2D _NormalMap;

		sampler2D _LightRamp;
		sampler2D _SpecularRamp;

		fixed4 _Color;
		fixed4 _Emission;

		struct Input 
		{
			float2 uv_MainTex;
		};

		struct CustomSurfaceOutput
		{
			//Standard surface shader fields ----- 
			fixed3 Albedo;
			fixed3 Normal;
			fixed3 Emission;
			fixed Alpha;
			//------------------------------------
		};
		
		void vert(inout appdata_full v, out Input output) 
		{
			UNITY_INITIALIZE_OUTPUT(Input, output);
		}

		half4 LightingCustomLighting(CustomSurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
		{
			half diffuseComponent = dot(s.Normal, lightDir) * 0.5 + 0.5;

			half3 reflectedLightDir = normalize(reflect(-lightDir, s.Normal));
			half specularComponent = dot(reflectedLightDir, viewDir) * 0.5 + 0.5;
			half3 specularColor = tex2D(_SpecularRamp, half2(specularComponent, 0.0)) * _LightColor0.rgb;

			fixed3 lightColor = tex2D(_LightRamp, half2(diffuseComponent, 0.0)).rgb * _LightColor0.rgb;

			half4 color;
			color.rgb = (s.Albedo * lightColor + specularColor) * atten;
			color.rgb += s.Emission;

			color.a = s.Alpha;

			return color;
		}
		
		void surf (Input input, inout CustomSurfaceOutput output)
		{
			fixed4 mainColor = tex2D(_MainTex, input.uv_MainTex) * _Color;
			
			output.Albedo = mainColor.rgb;
			output.Emission = _Emission;

			output.Normal = UnpackNormal(tex2D(_NormalMap, input.uv_MainTex));

			output.Alpha = mainColor.a;
		}

		ENDCG
	}
}
