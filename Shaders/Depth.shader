Shader "Unlit/Depth"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" {}
        _FirstColor ("Color 1", Color) = (1, 1, 1, 1)
        _SecondColor ("Color 2", Color) = (1, 1, 1, 1)
        _FogThreshold ("Fog Threshold", Range(0, 1)) = 0.5
        _FogMultiplier ("Fog Multiplier", float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 screenSpace : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            float4 _FirstColor;
            float4 _SecondColor;
            float _FogThreshold;
            float _FogMultiplier;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.screenSpace = ComputeScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 mainTex = tex2D(_MainTex, i.uv);
                float2 screenSpaceUV = i.screenSpace.xy / i.screenSpace.w;
                float depth = saturate(Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screenSpaceUV)) * _FogMultiplier);
                float3 color = lerp(mainTex, _SecondColor, depth * _FogThreshold);
                return float4(color, 1);
            }
            ENDCG
        }
    }
}
