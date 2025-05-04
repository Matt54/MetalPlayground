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

// Regular Polygon
inline float sdfRegularPolygon(float2 position, float radius, int sides) {
    float angleFromCenter = atan2(position.y, position.x);
    float segmentAngle = 2.0 * M_PI_F / float(sides);
    
    angleFromCenter = fmod(angleFromCenter, segmentAngle) - segmentAngle/2.0;
    float distanceFromCenter = length(position);
    float2 rotatedPosition = distanceFromCenter * float2(cos(angleFromCenter), sin(angleFromCenter));
    
    return rotatedPosition.x - radius * cos(segmentAngle/2.0);
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

// Cross
inline float sdfCross(float2 position, float2 dimensions) {
    float2 distanceFromCenter = abs(position);
    return min(distanceFromCenter.x - dimensions.y, distanceFromCenter.y - dimensions.x);
}

// Regular Star
inline float sdfStar(float2 position, float outerRadius, float innerRadius, int points) {
    float angleFromCenter = atan2(position.y, position.x);
    float segmentAngle = M_PI_F / float(points);
    
    angleFromCenter = fmod(angleFromCenter, 2.0 * segmentAngle) - segmentAngle;
    float distanceFromCenter = length(position);
    float2 rotatedPosition = distanceFromCenter * float2(cos(angleFromCenter), sin(angleFromCenter));
    
    float2 outerPoint = float2(outerRadius * cos(segmentAngle), outerRadius * sin(segmentAngle));
    float2 innerPoint = float2(innerRadius, 0.0);
    
    float distanceToOuter = length(rotatedPosition - outerPoint);
    float distanceToInner = length(rotatedPosition - innerPoint);
    
    return min(distanceToOuter, distanceToInner);
}
