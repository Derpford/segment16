--Draw random parts of the screen with an offset.

glitchEffect = love.graphics.newShader[[

extern number randx = 0;
extern number ymin = 0;
extern number ysize = 1;
number ymax = ymin + ysize;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
	if(sc.y > ymin){
		if(sc.y < ymax){
			tc.x = tc.x + randx;
		}
	}
	return Texel(tex,tc) * color;
}

]]