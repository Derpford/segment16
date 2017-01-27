-- adapted from http://www.youtube.com/watch?v=qNM0k522R7o
-- Thanks, BlackBulletIV, for making this thing. I hope you don't mind if I use it.

shaderBloomRed = love.graphics.newShader[[

extern vec2 size;
extern int samples; // pixels per axis; higher = bigger glow, worse performance
extern float quality; // lower = smaller glow, better quality

vec4 effect(vec4 colour, Image tex, vec2 tc, vec2 sc)
{
  vec4 source = Texel(tex, tc);
  vec4 sum = vec4(0);
  int diff = (samples - 1) / 2;
  vec2 sizeFactor = vec2(1) / size * quality;
  
  colour.r = colour.r * 1;
  colour.g = colour.g * 0.5;
  colour.b = colour.b * 0.5;
     
  for (int x = -diff; x <= diff; x++)
    {
    for (int y = -diff; y <= diff; y++)
      {
      vec2 offset = vec2(x, y) * sizeFactor;
      sum += Texel(tex, tc + offset);
      }
    }
  return ((sum / (samples * samples)) + source) * colour;
}]]

shaderBloomRed:send("size",{600,600})
shaderBloomRed:send("samples",5)
shaderBloomRed:send("quality",2.5)