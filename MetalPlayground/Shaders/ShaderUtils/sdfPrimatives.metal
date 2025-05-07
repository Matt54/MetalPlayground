//
//  sdfPrimatives.metal
//  MetalPlayground
//
//  Created by Matt Pfeiffer on 5/4/25.
//

#include <metal_stdlib>
using namespace metal;

inline float sdfCircle(float2 localPos, float radius) {
    float distanceFromCenter = length(localPos);
    return distanceFromCenter - radius;
}

inline float sdfBox(float2 localPos, float2 halfSize) {
    float2 delta = abs(localPos) - halfSize;
    float unsignedDistance = length(max(delta, 0.0));
    float insideDistance = min(max(delta.x, delta.y), 0.0);
    return unsignedDistance + insideDistance;
}

inline float sdfEquilateralTriangle(float2 localPos, float radius) {
    const float sqrtThree = sqrt(3.0);
    
    float2 pos = localPos;
    pos.x = abs(pos.x) - radius;
    pos.y = pos.y + radius / sqrtThree;
    
    if (pos.x + sqrtThree * pos.y > 0.0) {
        pos = float2(pos.x - sqrtThree * pos.y, -sqrtThree * pos.x - pos.y) * 0.5;
    }
    
    pos.x -= clamp(pos.x, -2.0 * radius, 0.0);
    
    return -length(pos) * sign(pos.y);
}

// Rounded Box
inline float sdfRoundedBox(float2 position, float2 halfSize, float cornerRadius) {
    float2 distanceFromCenter = abs(position) - halfSize + cornerRadius;
    return length(max(distanceFromCenter, 0.0)) + min(max(distanceFromCenter.x, distanceFromCenter.y), 0.0) - cornerRadius;
}

// Regular Hexagon
inline float sdfHexagon(float2 position, float radius) {
    const float3 k = float3(-0.866025404, 0.5, 0.577350269);  // (-sqrt(3)/2, 1/2, 1/sqrt(3))
    
    float2 p = abs(position);
    p -= 2.0 * min(dot(k.xy, p), 0.0) * k.xy;
    p -= float2(clamp(p.x, -k.z * radius, k.z * radius), radius);
    
    return length(p) * sign(p.y);
}

// Line Segment
inline float sdfLine(float2 position, float2 startPoint, float2 endPoint, float thickness) {
    float2 positionToStart = position - startPoint;
    float2 lineDirection = endPoint - startPoint;
    float projectionFactor = clamp(dot(positionToStart, lineDirection) / dot(lineDirection, lineDirection), 0.0, 1.0);
    return length(positionToStart - lineDirection * projectionFactor) - thickness;
}

// Capsule
inline float sdfCapsule(float2 position, float2 startPoint, float2 endPoint, float radius) {
    float2 positionToStart = position - startPoint;
    float2 lineDirection = endPoint - startPoint;
    float projectionFactor = clamp(dot(positionToStart, lineDirection) / dot(lineDirection, lineDirection), 0.0, 1.0);
    return length(positionToStart - lineDirection * projectionFactor) - radius;
}

// Ellipse
inline float sdfEllipse(float2 position, float2 radii) {
    float2 scaledPosition = position / radii;
    float scaleFactor = length(scaledPosition);
    return (scaleFactor - 1.0) * min(radii.x, radii.y);
}

// Cross with rounded corners
inline float sdfCross(float2 position, float2 size, float cornerRadius) {
    // Take absolute value to handle symmetry
    float2 p = abs(position);
    
    // Swap if y > x to handle both orientations
    if (p.y > p.x) {
        p = p.yx;
    }
    
    // Calculate distance to the cross shape
    float2 distanceToEdge = p - size;
    float maxDistance = max(distanceToEdge.y, distanceToEdge.x);
    
    // Handle the corner regions
    float2 cornerDistance = (maxDistance > 0.0) ? distanceToEdge : float2(size.y - p.x, -maxDistance);
    
    return sign(maxDistance) * length(max(cornerDistance, 0.0)) + cornerRadius;
}

// Pentagram
inline float sdfPentagram(float2 position, float radius) {
    // Constants for pentagram geometry
    const float k1x = 0.809016994;  // cos(π/5)
    const float k2x = 0.309016994;  // sin(π/10)
    const float k1y = 0.587785252;  // sin(π/5)
    const float k2y = 0.951056516;  // cos(π/10)
    const float k1z = 0.726542528;  // tan(π/5)
    
    const float2 v1 = float2(k1x, -k1y);
    const float2 v2 = float2(-k1x, -k1y);
    const float2 v3 = float2(k2x, -k2y);
    
    float2 p = position;
    p.x = abs(p.x);
    p -= 2.0 * max(dot(v1, p), 0.0) * v1;
    p -= 2.0 * max(dot(v2, p), 0.0) * v2;
    p.x = abs(p.x);
    p.y -= radius;
    
    float2 closestPoint = v3 * clamp(dot(p, v3), 0.0, k1z * radius);
    return length(p - closestPoint) * sign(p.y * v3.x - p.x * v3.y);
}

// Uneven Capsule
inline float sdfUnevenCapsule(float2 position, float radius1, float radius2, float height) {
    position.x = abs(position.x);
    float b = (radius1 - radius2) / height;
    float a = sqrt(1.0 - b * b);
    float k = dot(position, float2(-b, a));
    
    if (k < 0.0) {
        return length(position) - radius1;
    }
    if (k > a * height) {
        return length(position - float2(0.0, height)) - radius2;
    }
    return dot(position, float2(a, b)) - radius1;
}

// Heart
inline float sdfHeart(float2 position, float size) {
    // Scale and center the position
    position = position / size;
    
    // Take absolute of x for symmetry
    float2 p = position;
    p.x = abs(p.x);
    
    // Check if we're in the top part of the heart
    if (p.y + p.x > 1.0) {
        // Top circular parts
        return (length(p - float2(0.25, 0.75)) - sqrt(2.0)/4.0) * size;
    }
    
    // Bottom part of the heart
    float2 maxPoint = 0.5 * max(p.x + p.y, 0.0);
    float d = min(
        length(p - float2(0.0, 1.0)),
        length(p - maxPoint)
    );
    
    return d * sign(p.x - p.y) * size;
}
