#define S(a,b,t) smoothstep(a,b,t)
#ifdef GL_ES
precision mediump float;
#endif
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
mat2 rotate(float a){//function for rotation of coordinte axis
    float s=sin(a);
    float c=cos(a);
    return mat2(c, -s, s, c);
}
vec2 hash( vec2 p ){
    p = vec2( dot(p,vec2(2127.1,81.17)),dot(p,vec2(1269.5,283.37)) );
	return fract(sin(p)*43758.5453);
}
vec3 red=vec3(193.0/255.0,37.0/255.0,44.0/255.0);
vec3 blue=vec3(112.0/255.,145./255.,240./255.);
vec3 yellow=vec3(226./255.,149./255.,49./255.);
vec3 blackish=vec3(22./255.,24./255.,29./255.);
vec3 green=vec3(0.,116./255.,67./255.);
float heartShape(vec2 uv) {
    uv.x-=0.5;
    uv.x*=1.5;
    uv.y -= 0.4;
    uv.y*=1.5;
    float x = uv.x;
    float y = uv.y;
    return pow(x*x + y*y - 0.3, 3.0) - x*x*y*y*y;
}
//noise func from https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
float noise( in vec2 p ){
    vec2 i = floor( p );
    vec2 f = fract( p );
	vec2 u = f*f*(3.0-2.0*f);
    float n = mix( mix( dot( -1.0+2.0*hash(i+vec2(0.0,0.0)),f-vec2(0.0,0.0)), 
                        dot( -1.0+2.0*hash(i+vec2(1.0,0.0)),f-vec2(1.0,0.0)),u.x),
                   mix( dot( -1.0+2.0*hash(i+vec2(0.0,1.0)),f-vec2(0.0,1.0)), 
                        dot( -1.0+2.0*hash(i+vec2(1.0,1.0)),f-vec2(1.0,1.0)),u.x),u.y);
	return 0.5 + 0.5*n;
}
void main(){
  	vec2 st=gl_FragCoord.xy/u_resolution.xy;
    float ratio=u_resolution.x/u_resolution.y;
    vec2 tuv=st;
    //center the coordinate axis
    tuv-=.5;
    float degree=noise(vec2(u_time*.1,tuv.x*tuv.y));
    //this is done to ake sure rotation doesnt look weird on non square screens
    tuv.y*=1./ratio;
    tuv*=rotate(radians((degree-.5)*720.+180.));
	tuv.y*=ratio;
    //adding variations
    float frequency=4.;
    float amplitude=30.;
    float speed=u_time*1.5;
    tuv.x+=sin(tuv.y*frequency+speed)/amplitude;
    //arbitrary constants can be adjusted according to wants
   	tuv.y+=sin(tuv.x*frequency*1.2+speed)/(amplitude*.4);
    //this is mixing according to smoothstep functions
    //keep both edges as same to visualise the actual movement of colors
    vec3 layer1=mix(red,blackish,S(-.4,.4,tuv.x));
    vec3 layer2=mix(blue,green,S(-.3,.2,tuv.x));
    layer2=mix(layer2,yellow,S(.0,.3,tuv.x));
    vec3 color=mix(layer1,layer2,S(.4,-.3,tuv.y));
    gl_FragColor = mix(vec4(color,1.),vec4(1.),step(0.,heartShape(st)));
}