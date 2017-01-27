-- Makes the sprite fade away at the edges.

fadeEffect = love.graphics.newShader[[

extern float factor;
extern float startAlpha;
extern bool isWhite;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
	float alphaNewX = 0.0;
	float alphaNewY = 0.0;
	float alphaNew  = 0.0;

	vec4 src = Texel(tex, tc);
	alphaNewX = startAlpha - (abs(0.5 - tc.x)*factor);
	alphaNewY = startAlpha - (abs(0.5 - tc.y)*factor);
	alphaNew = alphaNewX*alphaNewY;
	src.a = src.a * alphaNew;
	if(isWhite==true){
		src.r=1.0;
		src.g=1.0;
		src.b=1.0;
	}
	return src * color;

}

]]

fadeEffect:send("factor", 1)
fadeEffect:send("startAlpha", 0.5)
fadeEffect:send("isWhite", false)