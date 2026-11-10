shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D albedo_tex : source_color, filter_linear, repeat_disable;
uniform vec4 albedo_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform vec2 uv_offset = vec2(0.0, 0.0);

float fold_u(float u) {
	float wrapped = mod(u, 2.0);
	if (wrapped < 0.0) {
		wrapped += 2.0;
	}
	if (wrapped > 1.0) {
		wrapped = 2.0 - wrapped;
	}
	return wrapped;
}

void fragment() {
	vec2 card_uv = UV * uv_scale + uv_offset;
	card_uv.x = fold_u(card_uv.x);
	card_uv.y = clamp(card_uv.y, 0.0, 1.0);
	ALBEDO = texture(albedo_tex, card_uv).rgb * albedo_color.rgb;
}
