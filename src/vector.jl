import Base.push!
import Base.*

abstract type Material end

const Vec3{T <: Real} = Array{T, 1}

function Vec3{T}(x::T, y::T, z::T) where T
    [x, y, z]
end

function Vec3(x::T, y::T, z::T) where T
    Vec3{T}(x, y, z)
end

normsquared(vector::Vec3) = sum(map(x -> x^2, vector))

norm(vector::Vec3) = √normsquared(vector)

dot(v1::Vec3, v2::Vec3) = sum(v1 .* v2)

unitvector(v) = v / norm(v)

struct Ray{T <: AbstractFloat}
    origin::Vec3{T}
    direction::Vec3{T}

    function Ray{T}(orgn::Vec3{T}, dir::Vec3{T}) where T
        new(orgn, unitvector(dir))
    end
end

function Ray(orgn::Vec3{T}, dir::Vec3{T}) where T
    Ray{T}(orgn, dir)
end

function rayat(ray::Ray, t)
    ray.origin + t * ray.direction
end

struct Sphere{T <: AbstractFloat}
    center::Vec3{T}
    radius::T
    color::RGB
    ks::Float64

    function Sphere{T}(c::Vec3{T}, r::T, color::RGB, ks::Float64) where T
        new(c, r, color, ks)    
    end
end

function Sphere(c::Vec3{T}, r::T, color::RGB, ks::Float64) where T
    Sphere{T}(c, r, color, ks)
end

struct LightSource{T <: AbstractFloat}
    lightPos::Vec3{T}
    lightColor::RGB

    function LightSource{T}(lightPos::Vec3{T}, lightColor::RGB) where T
        new(lightPos, lightColor)    
    end
end

function LightSource(phi::T, psi::T, rho::T, lightColor::RGB) where T
    lightPos = Vec3(rho*cos(phi)*sin(psi), rho*sin(phi)*sin(psi), rho*cos(psi))
    LightSource{T}(lightPos, lightColor)
end

function hit!(sphere::Sphere, ray::Ray)
    a = normsquared(ray.direction)
    CO = ray.origin - sphere.center
    b = dot(CO, ray.direction)
    c = normsquared(CO) - sphere.radius^2

    delta = b*b - a*c

    if delta <= 0
        return -1.0
    else
        return (-b - sqrt(delta))/a
    end
end

function reflect(dir::Vec3, normal::Vec3)
    dir -  2.0 * dot(dir, normal) * normal
end