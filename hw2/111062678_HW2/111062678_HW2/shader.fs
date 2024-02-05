#version 330 core
#define M_PI 3.1415926535897932384626433832795

out vec4 FragColor;

in vec3 vertex_color;
in vec3 vertex_normal;
in vec3 ambient;
in vec4 eye_position;

uniform int light_idx;
uniform vec3 Ka, Kd, Ks;
uniform vec3 light_move;
uniform int lighting_model;
uniform int Shininess;
uniform float intensity;
uniform mat4 v;
uniform int cutoff;


void main() {
	// [TODO]
	//FragColor = vec4(vertex_normal, 1.0f);
	vec3 viewpoint_vec = normalize(-eye_position.xyz);
	vec3 Ip = vec3(1, 1, 1);

	if(lighting_model == 0){
		FragColor = vec4(vertex_color, 1.0f);
	}
	else{

		if(light_idx == 0){    //directional light

			//vec4 position = v * vec4(vec3(1, 1, 1) + light_move, 1);
			vec3 position = vec3(1, 1, 1) + light_move;
			 
			vec3 direction = vec3(0, 0, 0);

		
			vec3 direction_normalize = normalize(position.xyz - direction);

			vec3 Rp = normalize(reflect( -direction_normalize , vertex_normal));  

			
			vec3 diffuse = Ip * Kd  * max(dot(vertex_normal, direction_normalize), 0);
			vec3 specular = Ip * Ks * pow(max(dot( Rp, viewpoint_vec ), 0), Shininess ) ;

			
			FragColor = vec4(ambient + intensity * diffuse + specular , 1.0f);
	
		}
		else if(light_idx == 1){	//positional(point) light
	
			vec4 position = v * vec4(vec3(0, 2, 1) + light_move, 1);
			//vec3 position = vec3(0, 2, 1) + light_move;
			
			vec3 direction_normalize = normalize(position.xyz - eye_position.xyz );

			vec3 Rp = normalize(reflect( -direction_normalize , vertex_normal));  

			
			vec3 diffuse = Ip * Kd  * max(dot(vertex_normal, direction_normalize), 0);
			vec3 specular = Ip * Ks * pow(max(dot(Rp, viewpoint_vec), 0), Shininess );

			float dist = length(position.xyz - eye_position.xyz);
			float Fatt = min((1.0 / (0.01 + 0.8 * dist + 0.1 * (dist * dist))), 1); 

			FragColor = vec4(ambient + Fatt * (intensity * diffuse + specular) , 1.0f);
	
		}
		else{	//spot light

			vec4 position = v * vec4(vec3(0, 0, 2) + light_move, 1);
			//vec3 position = vec3(0, 0, 2) + light_move;
			vec3 direction = vec3(0, 0, -1);

			float spotlight_effect = 0;

			//float cutoff  = 30;

			vec3 direction_normalize = normalize(position.xyz - eye_position.xyz );
			if ( dot(-direction_normalize, direction) > cos(cutoff * M_PI / 180)) 
				spotlight_effect = pow(max( dot(-direction_normalize, direction), 0 ), 50);
            else 
				spotlight_effect = 0;

			float dist = length(position.xyz - eye_position.xyz);
			float Fatt = min((1.0 / (0.05 + 0.3 * dist + 0.6 * (dist * dist))), 1); 
			
			vec3 Rp = normalize(reflect( -direction_normalize , vertex_normal));  

			vec3 diffuse = Ip * Kd  * max(dot(vertex_normal, direction_normalize), 0);
			vec3 specular = Ip * Ks * pow(max(dot(Rp, viewpoint_vec), 0), Shininess );
 
			FragColor = vec4(ambient + Fatt * spotlight_effect * (ambient + diffuse + specular) , 1.0f);

	
		}






	
		
	}
	
	




}
