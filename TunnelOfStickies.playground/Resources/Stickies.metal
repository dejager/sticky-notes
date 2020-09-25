#include <metal_stdlib>
using namespace metal;

#define pi 3.141592653589793

float random(float2 st) {
  return fract(sin(dot(st.xy, float2(12.9898, 78.233))) * 43758.5453123);
}

kernel void youMustBeSoOrganized(texture2d<float, access::write> o[[texture(0)]],
                                 constant float &time [[buffer(0)]],
                                 constant float2 *touchEvent [[buffer(1)]],
                                 constant int &numberOfTouches [[buffer(2)]],
                                 ushort2 gid [[thread_position_in_grid]]) {

  // coordinates

  int width = o.get_width();
  int height = o.get_height();
  float2 res = float2(width, height);
  float2 uv = (float2(gid) * 2.0 - res.xy) / res.y;

  // config

  float z = time * 28.0;
  float i = floor(z);
  float offset = fract(z);
  float shadow = 1.0;

  // drawing

  for(float z = 1.0; z < 150.0; z += 1.0) {
    float z2 = z - offset;
    float rand = z + i;
    float dadt = (random(float2(rand, 1.0)) * 2.0 - 1.0) * 0.5;
    float a = random(float2(rand, 1.0)) * 2.0 * pi + dadt * time;
    float pullback = random(float2(rand, 3.0)) * 4.0 + 1.0;
    float r = random(float2(rand, 4.0)) * 0.5 + 1.4;
    float g = random(float2(rand, 5.0)) * 0.5 + 0.7;
    float b = random(float2(rand, 6.0)) * 0.5 + 0.7;

    float2 origin = float2(sin(rand * 0.005) + sin(rand * 0.002), cos(rand * 0.005) + cos(rand * 0.002)) * z2 * 0.002;

    float2 dir = float2(cos(a), sin(a));
    float dist = dot(dir, uv - origin) * z2;
    float xdist = dot(float2(-dir.y, dir.x), uv - origin) * z2;
    float wobble = dist - pullback;

    if(wobble > 0.0) {
      float4 color = float4(30.0 * float3(r, g, b) * shadow / (z2 + 30.0), 1.0);
      o.write(color, gid);
      return;
    } else {
      shadow *= 1.0 - exp((dist-pullback)*2.0)*0.2;
    }
  }
  float4 color = float4(0);
  o.write(color, gid);
}
