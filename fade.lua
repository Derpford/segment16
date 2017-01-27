-- Makes the sprite fade away at the edges.

fadeEffect = love.graphics.newShader[[

extern number factor;
extern number startAlpha;
extern bool isWhite;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
	number alphaNewX = 0.0
	number alphaNewY = 0.0
	number alphaNew  = 0.0

	vec4 src = Texel(tex, tc);
	alphaNewX = startAlpha - (abs(0.5 - tc.x)*factor);
	alphaNewY = startAlpha - (abs(0.5 - tc.y)*factor);
	alphaNew = alphaNewX*alphaNewY;
	src.a = src.a * alphaNew;
	if(isWhite==true){
		src.r=1;
		src.g=1;
		src.b=1;
	}
	return src * color;

}

]]

fadeEffect:send("factor", 1)
fadeEffect:send("startAlpha", 0.5)
fadeEffect:send("isWhite", false)