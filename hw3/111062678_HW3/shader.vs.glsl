#version 330
#define M_PI 3.1415926535897932384626433832795

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;
layout (location = 2) in vec3 aNormal;
layout (location = 3) in vec2 aTexCoord;

out vec2 texCoord;
out vec3 vertex_color;
out vec3 vertex_normal;
out vec3 ambient;
out vec4 eye_position;

uniform mat4 um4p;	
uniform mat4 um4v;
uniform mat4 um4m;

uniform vec3 Ka, Kd, Ks;
uniform vec3 light_move;
uniform int light_idx;
uniform int Shininess;
uniform int lighting_model;
uniform int cutoff;
uniform float intensity;


// [TODO] passing uniform variable for texture coordinate offset

void main() 
{
	// [TODO]
	texCoord = aTexCoord;
	gl_Position = um4p * um4v * um4m * vec4(aPos, 1.0);

	vertex_normal = normalize( mat3( transpose( inverse(um4v * um4m) ) ) * aNormal); 
	eye_position = um4v * um4m * vec4(aPos.x, aPos.y, aPos.z, 1.0);
	vec3 viewpoint_vec = normalize(-eye_position.xyz);
	vec3 Ia = vec3(0.15, 0.15, 0.15);
	vec3 Ip = vec3(1, 1, 1);
	ambient = Ia * Ka;





	if(lighting_model == 0){  //per-vertex lighting model

		if(light_idx == 0){    //directional light

			//vec4 position = um4v * vec4(vec3(1, 1, 1) + light_move, 1);
			vec3 position = vec3(1, 1, 1) + light_move;
			 
			vec3 direction = vec3(0, 0, 0);

		
			vec3 direction_normalize = normalize(position.xyz - direction);

			vec3 Rp = normalize(reflect( -direction_normalize , vertex_normal));  

			
			vec3 diffuse = Ip * Kd  * max(dot(vertex_normal, direction_normalize), 0);
			vec3 specular = Ip * Ks * pow(max(dot( Rp, viewpoint_vec ), 0), Shininess ) ;

			vertex_color =  ambient + intensity * diffuse + specular ;
	
		}
		else if(light_idx == 1){	//positional(point) light
	
			//vec4 position = um4v * vec4(vec3(0, 2, 1) + light_move, 1);
			vec3 position = vec3(0, 2, 1) + light_move;
			


			vec3 direction_normalize = normalize(position.xyz - eye_position.xyz );

			vec3 Rp = normalize(reflect( -direction_normalize , vertex_normal));  

			
			vec3 diffuse = Ip * Kd  * max(dot(vertex_normal, direction_normalize), 0);
			vec3 specular = Ip * Ks * pow(max(dot(Rp, viewpoint_vec), 0), Shininess );

			float dist = length(position.xyz - eye_position.xyz);
			float Fatt = min((1.0 / (0.01 + 0.8 * dist + 0.1 * (dist * dist))), 1); 

			vertex_color =  ambient + Fatt * (intensity * diffuse + specular) ;
		
		}
		else{	//spot light

			//vec4 position = um4v * vec4(vec3(0, 0, 2) + light_move, 1);
			vec3 position = vec3(0, 0, 2) + light_move;
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

			vertex_color =  ambient + Fatt * spotlight_effect * (ambient + diffuse + specular) ;


	
		}
	}
	else{  ////per-vertex lighting model
	
		vertex_color = aColor;

	}

	



}
