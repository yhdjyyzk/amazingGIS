uniform sampler2D u_texture;
uniform vec3 u_color;
uniform float u_time;

varying vec2 v_uv;

void main () {
  float uv_y = v_uv.y + fract(u_time / 1000.0);

  if (uv_y >= 1.) {
    uv_y = uv_y - 1.;
  }

  vec2 uv = vec2(v_uv.x, uv_y);
  vec4 color = texture2D(u_texture, uv);
  gl_FragColor = color * vec4(u_color, 1.);
}