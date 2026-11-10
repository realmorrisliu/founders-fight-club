shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D albedo_tex : source_color, filter_linear, repeat_disable;
uniform vec4 albedo_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform vec2 uv_offset = vec2(0.0, 0.0);

void fragment() {
	vec2 card_uv = clamp(UV * uv_scale + uv_offset, vec2(0.0), vec2(1.0));
	ALBEDO = texture(albedo_tex, card_uv).rgb * albedo_color.rgb;
}
