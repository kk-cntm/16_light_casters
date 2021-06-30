#version 330 core

struct Material {
    sampler2D diffuse;
    sampler2D specular;
    float shininess;
    sampler2D emissionMap;
};

struct Light {
    vec3 position;
    
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    
    float constant;
    float linear;
    float quadratic;
};

out vec4 FragColor;

in vec3 Normal;
in vec3 FragPos;
in vec2 TexPos;
  
uniform vec3 lightColor;
uniform vec3 objectColor;
uniform Material material;
uniform Light light;
uniform vec3 cameraPos;

void main()
{
    // ambient
    vec3 ambient = light.ambient * vec3(texture(material.diffuse, TexPos));
      
    // diffuse
    vec3 norm = normalize(Normal);
    vec3 lightDir = normalize(light.position - FragPos);
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = light.diffuse * diff * texture(material.diffuse, TexPos).rgb;
    
    vec3 viewDir = normalize(cameraPos - FragPos);
    vec3 reflectDir = reflect(-lightDir, norm);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
    vec3 specular = light.specular * spec * texture(material.specular, TexPos).rgb;
    
    float distance = length(light.position - FragPos);
    float attenuation = 1.0f / (light.constant + light.linear * distance + light.quadratic * distance * distance);
    
    ambient *= attenuation;
    diffuse *= attenuation;
    specular *= attenuation;
            
    vec3 result = ambient + diffuse + specular;
    FragColor = vec4(result, 1.0);
}
