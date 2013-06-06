// This work is licensed under a Creative Commons Attribution 3.0 Unported License.
// http://creativecommons.org/licenses/by/3.0/deed.en_GB
//
// You are free:
//
// to copy, distribute, display, and perform the work
// to make derivative works
// to make commercial use of the work


Shader "Hidden/GlitchShader" {
Properties {
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_DispTex ("Base (RGB)", 2D) = "bump" {}
	_Intensity ("Glitch Intensity", Range(0.1, 1.0)) = 1
}

SubShader {
	Pass {
		ZTest Always Cull Off ZWrite Off
		Fog { Mode off }

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma fragmentoption ARB_precision_hint_fastest 
		
		#include "UnityCG.cginc"
		
		uniform sampler2D _MainTex;
		uniform sampler2D _DispTex;
		float _Intensity;
		
		float filterRadius;
		float flip_up, flip_down;
		float displace;
		float scale;
		
		struct v2f {
			float4 pos : POSITION;
			float2 uv : TEXCOORD0;
		};
		
		v2f vert( appdata_img v )
		{
			v2f o;
			o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
			o.uv = v.texcoord.xy;
			
			return o;
		}
		
		half4 frag (v2f i) : COLOR
		{
	
			half4 normal = tex2D (_DispTex, i.uv.xy * scale);
			
			if(i.uv.y < flip_up)
				i.uv.y = 1 - (i.uv.y + flip_up);
			
			if(i.uv.y > flip_down)
				i.uv.y = 1 - (i.uv.y - flip_down);
			
			i.uv.xy += (normal.xy - 0.5) * displace * _Intensity;
			
			
			half4 color = tex2D(_MainTex,  i.uv.xy);
			half4 redcolor = tex2D(_MainTex,  i.uv.xy + 0.01 * filterRadius * _Intensity);	
			half4 greencolor = tex2D(_MainTex,  i.uv.xy + 0.01 * filterRadius * _Intensity);
			
			if(filterRadius > 0){
				color.r = redcolor.r * 1.2;
				color.b = greencolor.b * 1.2;
			}else{
				color.g = redcolor.b * 1.2;
				color.r = greencolor.g * 1.2;
			}
			
			return color;
		}
		ENDCG
	}
}

Fallback off

}