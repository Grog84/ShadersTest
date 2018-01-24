Shader "Custom/Surface Glass" 
{
	Properties 
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_NormalMap("Normal map", 2D) = "bump" {}
		_ReflectionMap("Reflection Map", Cube) = "" {}
		_FresnelPower("Fresnel Power", Range(1, 30)) = 10
		_Distortion("Distortion", Range(0, 1)) = 0.1
	}

	SubShader 
	{
		Tags { "Queue"="Transparent" }
		
		GrabPass
		{
			"_BackgroundTexture"
		}

		CGPROGRAM

		#pragma surface surf CustomLighting fullforwardshadows 
		#pragma	vertex vert

		sampler2D _MainTex;
		sampler2D _NormalMap;

		samplerCUBE _ReflectionMap;

		sampler2D _BackgroundTexture;

		fixed4 _Color;

		half _FresnelPower;
		half _Distortion;

		struct Input
		{
			float2 uv_MainTex;
			float4 grabPos;
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

			output.grabPos = ComputeGrabScreenPos(UnityObjectToClipPos(v.vertex));
		}

		half4 LightingCustomLighting(CustomSurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
		{
			half diffuseComponent = dot(s.Normal, lightDir) * 0.5 + 0.5; //Wrap lighting

			fixed3 lightColor = _LightColor0.rgb * diffuseComponent;

			half fresnel = 1.0 - dot(s.Normal, viewDir);
			fresnel = pow(fresnel, _FresnelPower);

			fixed3 reflectionColor = texCUBE(_ReflectionMap, reflect(-viewDir, s.Normal)) * _LightColor0.rgb;

			reflectionColor *= fresnel;

			half4 color;
			color.rgb = (s.Albedo * lightColor + reflectionColor) * atten;

			color.a = s.Alpha;

			return color;
		}

		void surf(Input input, inout CustomSurfaceOutput output)
		{
			output.Normal = UnpackNormal(tex2D(_NormalMap, input.uv_MainTex));

			input.grabPos.xy += output.Normal.xy * _Distortion;
			output.Albedo = tex2Dproj(_BackgroundTexture, input.grabPos);

			output.Alpha = 1.0;
		}

		ENDCG
	}
}
