#version 460
#extension GL_EXT_ray_tracing : enable
#extension GL_EXT_nonuniform_qualifier : enable

struct Vertex
{
    vec3 pos;
    vec3 normal;
    vec2 uv;
    vec4 color;
    vec4 joint0;
    vec4 weight0;
    vec4 tangent;
};

layout(binding = 3, set = 0) buffer Vertices{float v[];} vertices[];
layout(binding = 4, set = 0) buffer Indices{uint i[];} indices[];
layout(binding = 5, set = 0) uniform sampler2D textureSamplers[];
layout(binding = 6, set = 0) uniform InstanceDataOnDevice
{
	mat4 worldMatrix;
    int meshIndex;
    int baseColorTextureIndex;
    int normalTextureIndex;
    int occlusionTextureIndex;
} instanceData[];

Vertex unpack(uint meshIndex, uint index)
{
    uint vertexSize = 24;
    uint offset = index * vertexSize;

    Vertex v;
    v.pos    = vec3(vertices[meshIndex].v[offset + 0],       vertices[meshIndex].v[offset + 1], vertices[meshIndex].v[offset + 2]);
    v.normal = vec3(vertices[meshIndex].v[offset + 3],       vertices[meshIndex].v[offset + 4], vertices[meshIndex].v[offset + 5]);
    v.uv     = vec2(vertices[meshIndex].v[offset + 6], 1.0 - vertices[meshIndex].v[offset + 7]);
    v.color  = vec4(vertices[meshIndex].v[offset + 8],       vertices[meshIndex].v[offset + 9], vertices[meshIndex].v[offset + 10], vertices[meshIndex].v[offset + 11]);

	return v;
}

layout(location = 0) rayPayloadInEXT vec3 payLoad;
hitAttributeEXT vec3 attribs;

void main()
{
    uint meshIndex = instanceData[gl_InstanceID].meshIndex;
    uint baseColorTextureIndex = instanceData[gl_InstanceID].baseColorTextureIndex;

    vec3 lightPos = vec3(3, -10, 5);
    vec3 lightColor = vec3(1);
    vec3 ambient = vec3(0.5);

	Vertex v0 = unpack(meshIndex, indices[meshIndex].i[3 * gl_PrimitiveID + 0]);
	Vertex v1 = unpack(meshIndex, indices[meshIndex].i[3 * gl_PrimitiveID + 1]);
	Vertex v2 = unpack(meshIndex, indices[meshIndex].i[3 * gl_PrimitiveID + 2]);

    const vec3 barycentricCoords = vec3(1.0f - attribs.x - attribs.y, attribs.x, attribs.y);
	vec3 pos    = gl_WorldRayOriginEXT + gl_WorldRayDirectionEXT * gl_HitTEXT;
	vec3 normal = normalize(v0.normal * barycentricCoords.x
                            + v1.normal * barycentricCoords.y
                            + v2.normal * barycentricCoords.z);
	vec2 uv     = v0.uv     * barycentricCoords.x + v1.uv     * barycentricCoords.y + v2.uv     * barycentricCoords.z;

    vec3 baseColor = texture(textureSamplers[baseColorTextureIndex], uv).xyz;
    baseColor = pow(baseColor, vec3(2.2));

    vec3 diffuse = baseColor * max(ambient, lightColor * dot(normal, normalize(lightPos - pos)));

    payLoad = pow(diffuse, vec3(1 / 2.2));
//    payLoad = vec3(pos.x, - pos.y, pos.z) + 0.5;
//    payLoad = vec3(uv, 1);
}
