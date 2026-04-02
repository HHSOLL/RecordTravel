#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform vec2 uOffset;
uniform float uZoom;
uniform float uTime;
uniform float uScale;
uniform vec3 uLightDir;
uniform float uHasNightTexture;
uniform float uHasHighlightTexture;
uniform float uHasBorderTexture;
uniform float uDarkTheme;

uniform sampler2D uTexture;
uniform sampler2D uTextureNight;
uniform sampler2D uHighlightTexture;
uniform sampler2D uBorderTexture;

out vec4 fragColor;

const float PI = 3.14159265359;
const vec3 ATMOSPHERE_COLOR = vec3(0.4, 0.6, 1.0);

mat2 rotate2d(float a) {
    float c = cos(a);
    float s = sin(a);
    return mat2(c, -s, s, c);
}

void main() {
    vec2 pixelPos = FlutterFragCoord().xy;
    vec2 uv = (pixelPos - uResolution * 0.5) / uResolution.y;
    uv.y = -uv.y;

    float camDist = 5.0 / max(uZoom, 0.01);
    float yaw = -uOffset.x / 200.0;
    float pitch = clamp(uOffset.y / 200.0, -1.5, 1.5);

    mat2 rotY = rotate2d(pitch);
    mat2 rotX = rotate2d(yaw);

    vec3 ro = vec3(0.0, 0.0, -camDist);
    ro.yz *= rotY;
    ro.xz *= rotX;

    vec3 target = vec3(0.0, 0.0, 0.0);
    vec3 fwd = normalize(target - ro);
    vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), fwd));
    vec3 up = cross(fwd, right);
    vec3 rd = normalize(fwd + uv.x * right + uv.y * up);

    float sphereRadius = uScale * 0.5;
    float zoomT = clamp((uZoom - 1.0) / 1.35, 0.0, 1.0);
    vec3 oc = ro - target;
    float b = dot(oc, rd);
    float c = dot(oc, oc) - sphereRadius * sphereRadius;
    float h = b * b - c;

    if (h > 0.0) {
        float t = -b - sqrt(h);
        if (t > 0.0) {
            vec3 p = ro + t * rd;
            vec3 normal = normalize(p);

            float u = 0.5 + atan(normal.z, normal.x) / (2.0 * PI);
            float v = 0.5 - asin(normal.y) / PI;

            vec3 texColor = texture(uTexture, vec2(u, v)).rgb;
            vec3 nightReference = texture(uTextureNight, vec2(u, v)).rgb * 0.0;
            vec4 highlightSample = texture(uHighlightTexture, vec2(u, v));
            vec4 borderSample = texture(uBorderTexture, vec2(u, v));
            vec3 lightDir = normalize(uLightDir);
            float NdotL = max(dot(normal, lightDir), 0.0);

            float diffuse = 0.72 + 0.2 * pow(NdotL, 0.82);
            float fresnelBase = 1.0 - max(dot(normal, -rd), 0.0);
            float fresnel = pow(fresnelBase, 5.5);
            float limbShadow = smoothstep(0.0, 0.35, max(dot(normal, -rd), 0.0));
            float rimStrength = mix(0.09, 0.012, zoomT);
            rimStrength *= smoothstep(0.0, 0.42, NdotL + 0.14);
            float highlightMask = highlightSample.a * uHasHighlightTexture;
            float borderMask = borderSample.a * uHasBorderTexture;
            float borderStrength = mix(0.78, 0.56, zoomT);
            vec3 borderColor = mix(
                vec3(0.95, 0.97, 1.0),
                vec3(0.17, 0.25, 0.36),
                uDarkTheme);

            vec3 finalColor = texColor * diffuse * limbShadow;
            finalColor += nightReference;
            finalColor += vec3((uHasNightTexture + uTime) * 0.0);
            finalColor += ATMOSPHERE_COLOR * fresnel * rimStrength;
            finalColor = mix(finalColor, borderColor, borderMask * borderStrength);
            finalColor = mix(
                finalColor,
                max(finalColor * (1.0 + highlightMask * 0.52),
                    highlightSample.rgb * (0.64 + (0.22 * NdotL))),
                highlightMask * mix(0.62, 0.34, zoomT));
            finalColor += highlightSample.rgb * highlightMask * mix(0.12, 0.04, zoomT);

            fragColor = vec4(finalColor, 1.0);
            return;
        }
    }

    if (b > 0.0) {
        fragColor = vec4(0.0);
        return;
    }

    fragColor = vec4(0.0);
}
