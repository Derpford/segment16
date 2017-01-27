-- Makes the sprite fade away at the edges.

fadeEffect = love.graphics.newShader[[

extern number factor = 1;
extern number startAlpha = 0.5;
extern bool isWhite = false;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
	vec4 src = Texel(tex, tc);
	number alphaNewX = startAlpha - (abs(0.5 - tc.x)*factor);
	number alphaNewY = startAlpha - (abs(0.5 - tc.y)*factor);
	number alphaNew = alphaNewX*alphaNewY;
	src.a = src.a * alphaNew;
	if(isWhite==true){
		src.r=1;
		src.g=1;
		src.b=1;
	}
	return src * color;

}

]]