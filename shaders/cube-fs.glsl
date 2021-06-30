#version 330 core

struct Material {
    sampler2D diffuse;
    sampler2D specular;
    float shininess;
    sampler2D emissionMap;
};

struct Light {
    vec3 position;
    vec3 direction;
    float cutOff;
    float outerCutOff;
    
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
    
    float distance = length(light.position - FragPos);
    float attenuation = 1.0f / (light.constant + light.linear * distance + light.quadratic * distance * distance);
      
    vec3 lightDir = normalize(light.position - FragPos);
    
    vec3 norm = normalize(Normal);
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = light.diffuse * diff * texture(material.diffuse, TexPos).rgb;
    
    vec3 reflectDir = reflect(-lightDir, norm);
    float spec = pow(max(dot(-light.direction, reflectDir), 0.0), material.shininess);
    vec3 specular = light.specular * spec * texture(material.specular, TexPos).rgb;
    
    ambient *= attenuation;
    diffuse *= attenuation;
    specular *= attenuation;
    
    float theta = dot(normalize(-light.direction), lightDir);
    float epsilon = light.cutOff - light.outerCutOff;
    float intensity = clamp((theta - light.outerCutOff) / epsilon, 0.0f, 1.0f);
    
    diffuse *= intensity;
    specular *= intensity;
    
    vec3 result = ambient + diffuse + specular;
    
    FragColor = vec4(result, 1.0);
}
