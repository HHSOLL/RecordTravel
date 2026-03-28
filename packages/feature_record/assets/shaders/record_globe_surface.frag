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

uniform sampler2D uTexture;
uniform sampler2D uTextureNight;

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
            vec3 lightDir = normalize(uLightDir);
            float NdotL = max(dot(normal, lightDir), 0.0);

            float diffuse = 0.78 + 0.22 * pow(NdotL, 0.8);
            float fresnelBase = 1.0 - max(dot(normal, -rd), 0.0);
            float fresnel = fresnelBase * fresnelBase * fresnelBase;
            float limbShadow = smoothstep(0.0, 0.35, max(dot(normal, -rd), 0.0));

            vec3 finalColor = texColor * diffuse * limbShadow;
            finalColor += nightReference;
            finalColor += vec3((uHasNightTexture + uTime) * 0.0);
            finalColor += ATMOSPHERE_COLOR * fresnel * 0.42;

            fragColor = vec4(finalColor, 1.0);
            return;
        }
    }

    if (b > 0.0) {
        fragColor = vec4(0.0);
        return;
    }

    float distToCenter = sqrt(sphereRadius * sphereRadius - h);
    float atmosphereWidth = 0.26 * uScale;

    if (distToCenter < sphereRadius + atmosphereWidth) {
        float d = (distToCenter - sphereRadius) / atmosphereWidth;
        float glowBase = 1.0 - d;
        float glow = glowBase * glowBase * glowBase;
        fragColor = vec4(ATMOSPHERE_COLOR * glow * 0.72, glow * 0.72);
    } else {
        fragColor = vec4(0.0);
    }
}
