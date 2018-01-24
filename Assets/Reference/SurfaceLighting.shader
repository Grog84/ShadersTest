Shader "Custom/Surface Lighting" 
{
	Properties 
	{
		_Color ("Color", Color) = (1,1,1,1)
		_Emission("Emission", Color) = (0,0,0,0)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_NormalMap("Normal map", 2D) = "bump" {}
		_Shininess("Shininess", Range(1, 128)) = 10
	}

	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		
		CGPROGRAM

		#pragma surface surf CustomLighting fullforwardshadows 
		#pragma	vertex vert

		sampler2D _MainTex;
		sampler2D _NormalMap;

		fixed4 _Color;
		fixed4 _Emission;

		half _Shininess;

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
			v.vertex.xyz += v.normal * sin(_Time.w + v.vertex.x * 20.0) * 0.01;

			UNITY_INITIALIZE_OUTPUT(Input, output);
			
		}

		half4 LightingCustomLighting(CustomSurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
		{
			half diffuseComponent = max(0, dot(s.Normal, lightDir));

			half3 reflectedLightDir = normalize(reflect(-lightDir, s.Normal));
			half specularComponent = max(0.0, dot(reflectedLightDir, viewDir));
			half3 specularColor = _LightColor0.rgb * pow(specularComponent, _Shininess);

			fixed3 lightColor = _LightColor0.rgb * diffuseComponent;

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
